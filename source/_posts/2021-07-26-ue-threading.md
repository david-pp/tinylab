---
title: UE并发-线程和同步机制
date: 2021-07-26 22:00:00
category : UE从里到外
tags: [UE, 多线程, 并发]
---

Unreal Engine提供了多种并发机制，从简单的原子操作，到复杂的TaskGraph系统。线程及其同步机制是最基础的，其本身许多内容和C++标准线程库、Pthread等线程库并无二致。本文简单整理下，UE并发中最基础的内容：

- 线程/线程管理器的结构
- 线程的常见操作
- 三种同步机制：原子操作、临界区/读写锁、事件机制。

<!--more-->

## 1.线程

![Threading](/images/ue/ue-threading.jpeg)

### 1.1.结构

**接口层：**

* FRunnable - 可在任何一个线程中运行的对象，调用模式：Init() -> Run() -> Exit()。
* FRunnableThread - 平台对立的线程对象，创建时根据平台创建相应的子类。
* FThreadManager - 线程管理器，所有使用`FRunableThread::Create`创建的线程，都会添加都该全局管理器。
* FSingleThreadRunnable - 提供Tick接口，对于不支持多线程的系统，可以创建FFakeThread，然后通过主线程中调用FThreadManager::Tick来驱动FakeThread运行的Tick操作。

**实现层：**

- FRunnableThreadWin - Windows系统下的线程的实现
- FRunnableThreadPThread - pthread的封装，一般Unix/Linux/Mac多线程都是用pthread库实现。
- FFakeThread - 不支持多线程的系统，模拟一个“假”线程。


### 1.2.常用操作

> 创建线程：使用`FRunnableThread::Create`创建线程并运行

```c++
class FSimpleThread : public FRunnable
{
public:
    FSimpleThread(const FString& TheName) : Name(TheName)
    {
        // 创建平台无关的线程并运行
        RunnableThread = FRunnableThread::Create(this, *Name);
    }
    //....
    FString Name;
    FRunnableThread* RunnableThread = nullptr;
};

```

> 线程回调：在创建的线程中运行`Init、Run、Exit`。

```c++
virtual bool Init() override
{
    // 初始化（在该线程中调用）
    return true;
}

virtual uint32 Run() override
{
    // 线程主逻辑
    while (!bStop)
    {
        FPlatformProcess::Sleep(1);
    }
    return 0;
}

virtual void Exit() override
{
    // 线程退出时执行（在该线程中调用）
}
```

> 结束线程：跳出`Run`操作，等待线程结束（`RunnableThread->WaitForCompletion`）。

```c++
// 等待线程结束（WaitForCompletion），线程的Join操作。
virtual void Stop() override
{
    bStop = true;
    if (RunnableThread) 
        RunnableThread->WaitForCompletion();
}
```

> 获取当前线程ID和名字

```c++
uint32 CurrentThreadId = FPlatformTLS::GetCurrentThreadId();
FString CurrentThreadName = FThreadManager::Get().GetThreadName(CurrentThreadId);

```

> 遍历当前所有线程对象

```c++
inline void DumpAllThreads(const char* Log)
{
    FThreadManager::Get().ForEachThread(
        [=](uint32 ThreadID, FRunnableThread* Thread)
        {
            UE_LOG(LogTemp, Display, TEXT("%s: %s,%u"), ANSI_TO_TCHAR(Log), *Thread->GetThreadName(), ThreadID);
        });
}
```

### 1.3.完整示例

> <https://github.com/david-pp/UESnippets/blob/main/SnippetAsync/Private/SimpleThread.h>

```c++
class FSimpleThread : public FRunnable
{
public:
	FSimpleThread(const FString& TheName) : Name(TheName)
	{
		RunnableThread = FRunnableThread::Create(this, *Name);
		Log(__FUNCTION__);
	}

	virtual ~FSimpleThread() override
	{
		if (RunnableThread)
		{
			RunnableThread->WaitForCompletion();
			delete RunnableThread;
			RunnableThread = nullptr;
			Log(__FUNCTION__);
		}
	}

	virtual bool Init() override
	{
		Log(__FUNCTION__);
		return true;
	}

	virtual uint32 Run() override
	{
		while (!bStop)
		{
			FPlatformProcess::Sleep(1);
			Log(__FUNCTION__);
		}
		return 0;
	}

	virtual void Exit() override
	{
		Log(__FUNCTION__);
	}


	virtual void Stop() override
	{
		bStop = true;
		if (RunnableThread)
			RunnableThread->WaitForCompletion();
	}

	void Log(const char* Action)
	{
		uint32 CurrentThreadId = FPlatformTLS::GetCurrentThreadId();
		FString CurrentThreadName = FThreadManager::Get().GetThreadName(CurrentThreadId);

		if (RunnableThread)
		{
			UE_LOG(LogTemp, Display, TEXT("%s@%s[%d] - %s,%d, %s"), *Name, *CurrentThreadName, CurrentThreadId,
			       *RunnableThread->GetThreadName(),
			       RunnableThread->GetThreadID(), ANSI_TO_TCHAR(Action));
		}
		else
		{
			UE_LOG(LogTemp, Display, TEXT("%s@%s[%d] - %s,%d, %s"), *Name, *CurrentThreadName, CurrentThreadId,
			       TEXT("NULL"), 0, ANSI_TO_TCHAR(Action));
		}
	}

public:
	FString Name;
	FRunnableThread* RunnableThread = nullptr;
	FThreadSafeBool bStop;
};

#define SAFE_DELETE(Ptr)  if (Ptr) { delete Ptr; Ptr = nullptr; }

inline void DumpAllThreads(const char* Log)
{
	FThreadManager::Get().ForEachThread(
		[=](uint32 ThreadID, FRunnableThread* Thread)
		{
			UE_LOG(LogTemp, Display, TEXT("%s: %s,%u"), ANSI_TO_TCHAR(Log), *Thread->GetThreadName(), ThreadID);
		});
}

inline void Test_SimpleThread()
{
	// Create Threads
	FSimpleThread* SimpleThread1 = new FSimpleThread(TEXT("SimpleThread1"));
	FSimpleThread* SimpleThread2 = new FSimpleThread(TEXT("SimpleThread2"));

	DumpAllThreads(__FUNCTION__);

	// Ticks
	int TickCount = 100;
	for (int i = 0; i < TickCount; ++i)
	{
		// Consume
		UE_LOG(LogTemp, Display, TEXT("Tick[%d] ........ "), i);
		FPlatformProcess::Sleep(0.1);
	}

	// Stop Thread
	SimpleThread1->Stop();
	SimpleThread2->Stop();

	// Destroy Threads
	SAFE_DELETE(SimpleThread1);
	SAFE_DELETE(SimpleThread2);
}
```


## 2.同步机制

支持三种类型的同步操作，用于线程之间的同步操作：
- 原子操作
- 临界区/读写锁
- 事件

### 2.1.Atomic

> FPlatformAtomics

平台独立的原子操作，编译器和系统级的原子操作封装。

> 原子操作：TAtomic -> std::atomic

TAtomic，是Unreal使用模板实现的原子操作封装，功能类似`std::atomic`，随着C++标准对于并发支持的完善，官方建议使用`std::atomic`。

```c++
TAtomic<int> Counter;
Counter ++; // Atomic increment -> FPlatformAtomics::InterlockedIncrement
if (Counter.Load()) // Atomic read -> FPlatformAtomics::AtomicRead
{
}
```

> 支持原子操作的计数器：FThreadSafeCounter/FThreadSafeCounter64/FThreadSafeBool

```c++
FThreadSafeCounter Counter2;
Counter2.Increment(); // FPlatformAtomics::InterlockedIncrement
Counter2.Decrement(); // FPlatformAtomics::InterlockedDecrement
if (Counter2.GetValue() == 0) // FPlatformAtomics::AtomicRead
{
}
```
    
### 2.2.Locking

> 互斥锁/临界区：FCriticalSection/FScopeLock

FCriticalSection，Windows下使用临界区实现，Pthread用mutex实现。

```c++
class ThreadSafeArray
{
public:
	int32 GetValue(int32 Index)
	{
		FScopeLock Lock(&CS);
		return Values[Index];
	}

	void AppendValue(int32 Value)
	{
		CS.Lock();
		Values.Add(Value);
		CS.Unlock();
	}

private:
	FCriticalSection CS;
	TArray<int32> Values;
};
```

> 读写锁：FRWLock/FRWScopeLock

若读操作远高于写操作，建议使用读写锁。

```c++
class ThreadSafeArray2
{
public:
	int32 GetValue(int32 Index)
	{
		FRWScopeLock ScopeLock(ValuesLock, SLT_ReadOnly);
		return Values[Index];
	}

	void AppendValue(int32 Value)
	{
		ValuesLock.WriteLock();
		Values.Add(Value);
		ValuesLock.WriteUnlock();
	}

private:
	FRWLock ValuesLock;
	TArray<int32> Values;
};

```
    
### 2.3.Event

![Threading](/images/ue/ue-event.jpeg)

FEvent，是可等待事件的接口，用来线程之间事件的等待和触发。

- 功能类似`std::condition_variable`
- Windows系统下使用`CreateEvent`创建，pthread使用`pthread_cond_create`来创建。
- 作为系统级的资源，为了降低创建和释放的消耗，创建时优先从EventPool中拿出来一个Event对象。

相关类及其用法：

> FEvent - 可等待事件接口，支持ManualReset/AutoReset两种模式。

```c++
inline void Test_Event()
{
    FEvent* SyncEvent = nullptr;

    Async(EAsyncExecution::Thread, [&SyncEvent]()
    {
        FPlatformProcess::Sleep(3);
        if (SyncEvent)
        {
            // 另外一个线程中触发事件
            SyncEvent->Trigger();
            UE_LOG(LogTemp, Display, TEXT("Trigger ....."));
        }
    });
    
    // 创建事件对象
    SyncEvent = FPlatformProcess::GetSynchEventFromPool(true);
    // 等待事件触发（infinite wait）
    SyncEvent->Wait((uint32)-1);
    // 释放事件对象
    FPlatformProcess::ReturnSynchEventToPool(SyncEvent);

    UE_LOG(LogTemp, Display, TEXT("Over ....."));
}
```

> FEventRef - 构造时创建一个Event，析构时释放该事件。

```c++
inline void Test_Event2()
{
    // 创建事件
    FEventRef SyncEvent(EEventMode::AutoReset);

    FEvent* Event = SyncEvent.operator->();
    Async(EAsyncExecution::Thread, [Event]()
    {
        FPlatformProcess::Sleep(3);
        // 触发事件
        Event->Trigger();
        UE_LOG(LogTemp, Display, TEXT("Trigger ....."));
    });
    
    // 等待事件
    SyncEvent->Wait((uint32)-1);
    UE_LOG(LogTemp, Display, TEXT("Over ....."));
}
```

> FScopeEvent - 构造时创建一个Event，析构时等待该事件，收到该事件，结束并释放事件资源。

```c++
inline void Test_Event()
{
    // waiting..
    {
        // 创建事件并等待
        FScopedEvent SyncEvent;

        Async(EAsyncExecution::Thread, [&SyncEvent]()
        {
            FPlatformProcess::Sleep(3);
            // 触发事件
            SyncEvent.Trigger();
            UE_LOG(LogTemp, Display, TEXT("Trigger ....."));
        });
        
        // SyncEvent析构时等待，并释放资源
    }

    UE_LOG(LogTemp, Display, TEXT("Over ....."));
}
```

### 3.参考源码

HAL（Hardware Abstract Layer），平台抽象层相关实现，跨平台线程、文件系统等操作。比如，线程相关操作位于FPlatformProcess::XXXX、本地线程缓存位于FPlatoformTLS::XXXX等待。

- `Engine/Source/Runtime/Core/Public/HAL/Runnable.h`
- `Engine/Source/Runtime/Core/Public/HAL/RunnableThread.h`
- `Engine/Source/Runtime/Core/Public/HAL/ThreadManager.h`
- `Engine/Source/Runtime/Core/Public/HAL/Event.h`


