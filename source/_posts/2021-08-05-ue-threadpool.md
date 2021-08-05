---
title: UE并发-线程池和AsyncTask
date: 2021-08-05 23:40:00
category : UE从里到外
tags: [UE, 多线程, 并发]
---

为了更高效地利用线程，而不是每个任务都创建一个线程，UE中提供了线程池的方案，可以将多个任务分配在N个线程中执行。任务过多时，排队执行，也可以撤销排队。本文简单介绍下：

- 线程池`FQueuedThreadPool`的实现。
- 使用`IQueuedWork`自定义一个简单任务类，并放入线程池中执行。
- 引擎全局的几个线程池：`GThreadPool`、`GIOThreadPool`、`GBackgroundPriortyThreadPool`、`GLargeThreadPool`。
- AyncTask的用法。

# 1.线程池的实现

**结构：**

![ThreadPool](/images/ue/threadpool1.png)

**接口层：**

- `IQueuedWork` - 任务接口，继承使用。
- `FQueuedThreadPool` - 线程池的接口类，常用操作：
    - `AddQueuedWork` - 把任务放入线程池中执行，若有空闲线程，直接分配给空闲线程，若没有空闲线程，放入线程池维护的队列，后台线程会从队列中自己拿任务执行。
    - `RetractQueuedWork` - 撤回指定任务，只能撤回正在排队的，已经在执行的没法撤回。    

**实现层：**

- `FQueuedThreadPoolBase` - 线程池的实现类
    - `QueueWork` - 排队的任务
    - `QueuedThreads` - 空闲的线程
    - `AllThreads` - 所有线程（`FQueueThread`）

- `FQueuedThread` - 线程池的后台线程实现
    - 线程运行时，若没有任务则挂起，有任务时执行任务，执行完一个任务后，从线程池队列中再拿一个执行（`FQueuedThreadPoolBase::ReturnToPoolOrGetNextJob`），直到没有任务，再次挂起自己
    - 若目前线程为空闲，放入一个任务后，执行该线程的`DoWork`，结束挂起开始执行任务

**运行示意图：**

![ThreadPool](/images/ue/threadpool2.png)

<!--more-->

# 2.线程池的用法

- 定义可以放入线程池执行的Worker类，需要重载：
    - `DoThreadedWork` - 在线程池中的某个线程中执行
    - `Abandon` - 线程池释放自己时（`Destroy`），放弃排队的任务时会调用该函数。

```c++
class FSimpleQueuedWorker : public IQueuedWork
{
public:
    FSimpleQueuedWorker(const FString& Name) : WorkerName(Name) {
        Log(__FUNCTION__);
    }

    virtual ~FSimpleQueuedWorker() override {
        Log(__FUNCTION__);
    }

    // 在线程池中的某个线程中执行
    virtual void DoThreadedWork() override {
        FPlatformProcess::Sleep(0.2);
        Log(__FUNCTION__);
        // 任务结束，释放创建的Worker对象，也可以交给调用者析构
        delete this;
    }

    // 放弃该任务的执行
    virtual void Abandon() override {
        Log(__FUNCTION__);
        // 任务被放弃，释放创建的Worker对象，也可以交给调用者析构
        delete this;
    }

    void Log(const char* Action) {
        uint32 CurrentThreadId = FPlatformTLS::GetCurrentThreadId();
        FString CurrentThreadName = FThreadManager::Get().GetThreadName(CurrentThreadId);
        UE_LOG(LogTemp, Display, TEXT("%s@%s[%d] - %s"),
               *WorkerName, *CurrentThreadName, CurrentThreadId, ANSI_TO_TCHAR(Action));
    }

public:
    FString WorkerName;
};
```

- 创建一个线程池，并执行一批任务：
    - `FQueuedThreadPool::Allocate` - 在堆中分配一个线程池对象
    - `FQueuedThreadPool::Create` - 创建线程池，可以指定线程的数量、堆栈大小、线程的优先级。

```c++
inline void Test_SimpleQueuedWorker()
{
    // 创建线程池，有5个线程
    FQueuedThreadPool* CreatePool = FQueuedThreadPool::Allocate();
    Pool->Create(5, 0, TPri_Normal, TEXT("SimpleThreadPool"));

    int WokerNum = 100;
    for (int i = 0; i < WokerNum; ++i)
    {
        FString Name = TEXT("Worker") + FString::FromInt(i);
        
        // 创建Worker对象并交给线程池执行
        Pool->AddQueuedWork(new FSimpleQueuedWorker(Name));
    }

    // 等待部分任务完成
    int TickCount = 20;
    for (int i = 0; i < TickCount; ++i)
    {
        // Consume
        UE_LOG(LogTemp, Display, TEXT("Tick[%d] ........ "), i);
        FPlatformProcess::Sleep(0.1);
    }

    // 线程池释放，没有完成的任务会被放弃（Abandon）
    Pool->Destroy();
    delete Pool;
}
```

# 3.引擎中的全局线程池

获取线程数量的几个操作：

* `FPlatformMisc::NumberOfWorkerThreadsToSpawn()` -> CPU核心数-2
* `FPlatformMisc::NumberOfIOWorkerThreadsToSpawn()` -> 4

全局定义了四个线程池，分别如下（调试时，线程名为：PoolThread X）：

- GThreadPool : 最常用的全局线程池，FAsyncTask默认使用。
    - Client: NumberOfWorkerThreadsToSpawn
    - Server: 1
   
- GBackgroundPriorityThreadPool : 低优先级线程池
    - Client: 2
    - Server: 1
  
- GLargeThreadPool：Editor模式下用的线程池
    * Client：Max(NumberOfCoresIncludingHyperthreads() - 2, 2)

- GIOThreadPool：IO操作的线程池
    - Client：NumberOfIOWorkerThreadsToSpawn
    - Server：2


`GThreadPool`初始化代码如下，其他类似：

```c++
// FEngineLoop::PreInitPreStartupScreen
GThreadPool = FQueuedThreadPool::Allocate();
int32 NumThreadsInThreadPool = FPlatformMisc::NumberOfWorkerThreadsToSpawn();
// we are only going to give dedicated servers one pool thread
if (FPlatformProperties::IsServerOnly()){
     NumThreadsInThreadPool = 1;
}
verify(GThreadPool->Create(NumThreadsInThreadPool, StackSize * 1024, TPri_SlightlyBelowNormal, TEXT("ThreadPool")));
```

# 4.AsyncTask的使用

上面继承自`IQueuedWork`的任务类，对应的任务对象只能在线程池后台线程中运行。现在需要一种能力，同一个类型的任务，可以指定它在线程中异步执行，也可以指定它在当前调用线程中执行，这样对于调试和任务调度提供了一定的灵活性，代码也更简洁下，这就是`FAsyncTask`/`FAutoDeleteAsyncTask`模板类的用途，它们继承自`IQueduedTask`。

## 4.1.定义一个可以异步/同步执行的任务

该任务类，必须实现下面两个接口：
- `DoWork` - 执行任务
- `GetStatId` - 性能统计

示例代码：

``` c++
class SimpleExampleTask : public FNonAbandonableTask
{
    friend class FAsyncTask<SimpleExampleTask>;

    int32 ExampleData;
    float WorkingTime;

public:
    SimpleExampleTask(int32 InExampleData, float TheWorkingTime = 1)
        : ExampleData(InExampleData), WorkingTime(TheWorkingTime) { }

    ~SimpleExampleTask() {
        Log(__FUNCTION__);
    }
    
    // 执行任务（必须实现）
    void DoWork() {
        // do the work...
        FPlatformProcess::Sleep(WorkingTime);
        Log(__FUNCTION__);
    }
    
    // 用时统计对应的ID（必须实现）
    FORCEINLINE TStatId GetStatId() const
    {
        RETURN_QUICK_DECLARE_CYCLE_STAT(ExampleAsyncTask, STATGROUP_ThreadPoolAsyncTasks);
    }

    void Log(const char* Action)
    {
        uint32 CurrentThreadId = FPlatformTLS::GetCurrentThreadId();
        FString CurrentThreadName = FThreadManager::Get().GetThreadName(CurrentThreadId);
        UE_LOG(LogTemp, Display, TEXT("%s[%d] - %s, ExampleData=%d"), *CurrentThreadName, CurrentThreadId,
               ANSI_TO_TCHAR(Action), ExampleData);
    }
};
```

## 4.2.FAutoDeleteAsyncTask的用法

自动删除的任务，调用者不用管，任务结束或被放弃时，都会自动析构。示例：

```c++
inline void Test_SimpleTask_1()
{
    // 在指定线程池中执行，默认在：GThreadPool
    (new FAutoDeleteAsyncTask<SimpleExampleTask>(1000))->StartBackgroundTask();

    // 在当前线程中执行
    (new FAutoDeleteAsyncTask<SimpleExampleTask>(2000))->StartSynchronousTask();
}

```

## 4.3.FAsyncTask的用法

任务的生命周期由调用者负责，可以在调用线程中：
- `IsDone` - 判定任务是否完成。
- `WaitCompletionWithTimeout` - 在指定的范围内等待任务完成，
- `EnsureCompletion` - 确保任务完成，若还在排队，直接撤销，在当前线程中执行。一般该操作用于任务收尾。
- `Cancel` - 取消任务，只能取消正在排队的。

**示例1:**

```c++
inline void Test_SimpleTask_2(bool bForceOnThisThread)
{
    // 创建一个任务
    FAsyncTask<SimpleExampleTask>* MyTask = new FAsyncTask<SimpleExampleTask>(1000);

    // 同步/异步执行该任务
    if (bForceOnThisThread)
        MyTask->StartSynchronousTask();
    else
        MyTask->StartBackgroundTask();

    // 检查是否结束？（可以用于一些帧内判定，不适合自旋式检查）
    bool IsDone = MyTask->IsDone();
    UE_LOG(LogTemp, Display, TEXT("Is Done : %d"), IsDone);

    // 保证任务被执行
    //  - 若该任务在线程池中排队，则拿出来在该线程中执行
    //  - 若该任务在线程池执行，则等待直到它完成
    MyTask->EnsureCompletion();
    delete MyTask;
}
```

**示例2：**

```c++
inline void Test_SimpleTask_3()
{
    using FSimpleExampleAsyncTask = FAsyncTask<SimpleExampleTask>;

    int TaskCount = 20;
    TArray<FSimpleExampleAsyncTask*> Tasks;

    // 创建一批任务，并异步在GPoolThread中执行
    for (int i = 0; i < TaskCount; ++i)
    {
        FSimpleExampleAsyncTask* MyTask = new FSimpleExampleAsyncTask(i + 1, 3);
        if (MyTask)
        {
            MyTask->StartBackgroundTask();
            Tasks.Add(MyTask);
        }
    }

    // 等待线程池中的任务执行
    FPlatformProcess::Sleep(5);

    // 运行一段时间，检查任务的状态
    TArray<FSimpleExampleAsyncTask*> RemainTasks;
    for (auto Task : Tasks)
    {
        if (Task->IsDone())  // 完成，则删除任务
        {
            UE_LOG(LogTemp, Display, TEXT("Done ......"));
            delete Task;
        }
        else
        {
            if (Task->Cancel())  // 没完成，尝试取消任务，并删除
            {
                UE_LOG(LogTemp, Display, TEXT("Cancel ........"));
                delete Task;
            }
            else // 正在运行的任务是没法取消的
            {
                UE_LOG(LogTemp, Display, TEXT("Still Working ....."));
                RemainTasks.Add(Task);
            }
        }
    }
    Tasks.Reset();

    // 等待任务完成
    for (auto Task : RemainTasks)
    {
        UE_LOG(LogTemp, Display, TEXT("EnsureCompletion ..."));
        Task->EnsureCompletion();
        delete Task;
    }

    UE_LOG(LogTemp, Display, TEXT("Over .............."));
}

```

# 5.参考资料

代码示例：

- 线程池：
> <https://github.com/david-pp/UESnippets/blob/main/SnippetAsync/Private/SimpleQueuedWorker.h>
- AysncTask：
> <https://github.com/david-pp/UESnippets/blob/main/SnippetAsync/Private/SimpleQueuedWorker.h>

UE源码：

- `Engine/Source/Runtime/Core/Public/Misc/QueuedThreadPool.h`
- `Engine/Source/Runtime/Core/Public/Misc/IQueuedWork.h`
- `Engine/Source/Runtime/Core/Public/Async/AsyncWork.h`
