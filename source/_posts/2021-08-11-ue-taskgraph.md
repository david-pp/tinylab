---
title: UE并发-TaskGraph的实现和用法
date: 2021-08-11 23:40:00
category : UE从里到外
tags: [UE, 多线程, 并发]
---


TaskGraph是UE中基于任务的并发机制。可以创建任务在指定类型的线程中执行，同时提供了等待机制，其强大之处在于可以调度一系列有依赖关系的任务，这些任务组成了一个有向无环的任务网络（DAG），并且任务的执行可以分布在不同的线程中。

![ThreadPool](/images/ue/taskgraph-dagtask.png)


TaskGraph支持两种类型的线程：

* 一种是由TaskGraph系统后台创建的线程，称之为AnyThread。
* 另一种是外部线程，包括系统线程（比如：主线程）或者其他基于`FRunnableThread`创建的线程，初始化的时候需要Attach到TaskGraph系统，此类线程成为NamedThread。

<!--more-->

# 1.TaskGraph简介

## 1.1.AnyThread

AnyThread是由TaskGraph系统创建的后台线程，会持续地从相应优先级队列中拿任务执行，线程的个数由当前运行的系统及CPU核心数决定的。对于AnyThread，有优先级和线程集合的概念。

**线程优先级（Thread Priority）：**

对于AnyThread，TaskGraph系统在初始化时，会根据需要创建多个优先级的线程（线程名 - 描述，线程类型标记，系统线程优先级）：

* TaskGraphThreadNP X - 正常优先级，`NormalThreadPriority`，`TPri_BelowNormal`
* TaskGraphThreadHP X - 高优先级，`HighThreadPriority`，`TPri_SlightlyBelowNormal`
* TaskGraphThreadBP X - 低优先级，`BackgroundThreadPriority`， `TPri_Lowest`


**线程集（Thread Set）：**

* 一组多个优先级的线程，称为为ThreadSet
* 至少1个，最多3个（由`CREATE_HIPRI_TASK_THREADS`和`CREATE_BACKGROUND_TASK_THREADS`决定是否创建高/低优先级线程）
    
## 1.2.NamedThread

NamedThread是外部创建的线程，该类型初始化时，可以通过Attach操作，设置TLS指向相应的Worker对象：

```c++
// 绑定主线程（GameThread）
FTaskGraphInterface::Get().AttachToThread(ENamedThreads::GameThread);
```

目前支持的NamedThread有：

 * StatsThread - 统计性能线程，`FStatsThread`
 * RHIThread - 渲染硬件接口层线程，`FRHIThread`
 * AudioThread - 音频线程，`FAudioThread`
 * GameThread  - 游戏逻辑线程，主线程
 * RenderThread  - 渲染线程，`FRenderingThread`

NameThread的支持两个任务队列（由QueueIndex指定）：

```c++
FThreadTaskQueue Queues[ENamedThreads::NumQueues];
```

- `MainQueue` - 对应`Queues[0]`（默认）
- `LocalQueue` - 对应`Queues[1]`


## 1.3.Task Priority

AnyThread和NamedThread都支持两种优先级的任务：

- 正常优先级 - `NormalTaskPriority`，对应的`FStallingTaskQueue`中的`PriorityQueues[0]`
- 高优先级 - `HighTaskPriority`，对应的`FStallingTaskQueue`中的`PriorityQueues[`]`

AnyThread和NamedThread都类似的任务队列，使用的无锁优先级队列，该队列优先Pop出高优先级任务，具体分析参见之前文章：《原子操作及其在TaskGraph中的应用》：
```c++
FStallingTaskQueue<FBaseGraphTask, PLATFORM_CACHE_LINE_SIZE, 2> StallQueue;
```

## 1.4.ThreadAndIndex 

TaskGraph中许多接口需要指定线程类型，比如：

```c++
 // 要在该类型线程中执行
ENamedThreads::Type ThreadToExecuteOn,    

// 任务要执行的线程
static ENamedThreads::Type GetDesiredThread()
{
    return ENamedThreads::AnyThread;
}
```

为了降低参数的个数，UE把一些标记也融合进了线程类型变量，比如：

```c++
// NamedThread中的LocalQueue
GameThread_Local = GameThread | LocalQueue, 
// AnyThread，高优先级线程，任务低优先级
AnyHiPriThreadHiPriTask = AnyThread | HighThreadPriority | HighTaskPriority, 
```

同时也提供了帮助函数：

```c++
// 计算线程类型：NameThread类型或者AnyThread
FORCEINLINE Type GetThreadIndex(Type ThreadAndIndex);
// 计算NamedTread的任务队列索引
FORCEINLINE int32 GetQueueIndex(Type ThreadAndIndex);
// 计算任务的优先级： 0, 1
FORCEINLINE int32 GetTaskPriority(Type ThreadAndIndex);
// 计算线程的优先级：0, 1, 2
FORCEINLINE int32 GetThreadPriorityIndex(Type ThreadAndIndex);
```

## 1.5.Simple Examples


**一个简单示例感受下：**

```c++
inline void Test_GraphTask_Simple1()
{
    // 创建一个任务并在后台AnyThread中执行
    FGraphEventRef Event = FFunctionGraphTask::CreateAndDispatchWhenReady([]()
        {
            UE_LOG(LogTemp, Display, TEXT("Main task"));
            FPlatformProcess::Sleep(5.f); // pause for a bit to let waiting start
        }
    );
    check(!Event->IsComplete());
    
    // 在主线程中等待该任务完成
    Event->Wait(ENamedThreads::GameThread);
    UE_LOG(LogTemp, Display, TEXT("Over1 ..."));
 

    // 同时创建多个任务
    FGraphEventArray Tasks;
    for (int i = 0; i < 10; ++i)
    {
        Tasks.Add(FFunctionGraphTask::CreateAndDispatchWhenReady([i]()
        {
            UE_LOG(LogTemp, Display, TEXT("Task %d"), i);
        }));
    }
    
    // 在主线程中等待所有任务完成
    FTaskGraphInterface::Get().WaitUntilTasksComplete(MoveTemp(Tasks), ENamedThreads::GameThread);
    UE_LOG(LogTemp, Display, TEXT("Over2 ..."));
}
```

# 2.TaskGraph的实现

## 2.1.TaskGraph的类结构

![ThreadPool](/images/ue/taskgraph-class.png)

**接口层核心类：**

* `FTaskGraphInterface` - TaskGraph的接口类，可以通过`FTaskGraphInterface::Get()`来访问。
* `FBaseGraphTask` - 任务基类，在线程中执行时会调用`ExecuteTask`。
* `FGraphEvent` - 后续任务的集合（SubseuentList），依赖的任务完成后，这些后续任务才会被放入TaskGraph的任务队列进行执行，Graph Event的生命周期由引用计数控制。一般用`FGraphEventRef`代表一个任务事件，`FGraphEventArray`代表一组任务事件。
* `TGraphTask` - 基于模板的实现，内置一个用户自定义任务，该任务类必须满足下面的约束：

```c++
class FGenericTask
{
    TSomeType	SomeArgument;
public:
    FGenericTask(TSomeType InSomeArgument) : SomeArgument(InSomeArgument)
    {
        // 构造函数一般只做成员变量的初始化
    }

    // 用于统计
    FORCEINLINE TStatId GetStatId() const
    {
        RETURN_QUICK_DECLARE_CYCLE_STAT(FGenericTask, STATGROUP_TaskGraphTasks);
    }

    // 任务要被分配的线程类型
    ENamedThreads::Type GetDesiredThread()
    {
        return ENamedThreads::[named thread or AnyThread];
    }

    // 任务的执行逻辑，其中参数：
    //  CurrentThread - 任务执行的线程类型信息
    //  MyCompletionGraphEvent - 该任务的后续任务，可以通过DontCompleteUntil让其挂起直到后续后续任务完成再继续
    void DoTask(ENamedThreads::Type CurrentThread, const FGraphEventRef& MyCompletionGraphEvent)
    {
        // The arguments are useful for setting up other tasks. 
        // Do work here, probably using SomeArgument.
        MyCompletionGraphEvent->DontCompleteUntil(TGraphTask<FSomeChildTask>::CreateTask(NULL,CurrentThread).ConstructAndDispatchWhenReady());
    }
};
```

**实现层：**

* `FTaskGraphImplementation` - TaskGraph系统的实现类，下面会详细介绍。
* `FWorkerThread` - TaskGraph包含多个`FWorkerThread`对象，该结构有下面几个变量：
    * `RunnableThread` - 线程对象。
        * AnyThread时创建一个线程
        * NamedThread时为Null
    * `TaskGraphWorker` - Woker对象，负责调度和执行任务。
        * AnyThread时指向`FTaskThreadAnyThread`对象
        * NamedThread时指向`FNamedTaskThread`对象

## 2.2.TaskGraph的实现细节

![ThreadPool](/images/ue/taskgraph-arch.png)

其中：

* WokerQueue：Woker线程队列。分两部分：
    * NamedThread，其数量为`NumNamedThread`
    * AnyThread，其数量为：ThreadSet的大小 x ThreadSet的数量

* AnyThread：
    * 放入任务：根据线程优先级和任务优先级，把任务放进相应的队列
    * 执行任务：每个AnyThread对应的线程，会一直从`IncommingAnyThreadTasks[Priority]`中拿任务执行，空闲则挂起（无锁、可挂起、优先级队列）。

* NamedThread：
    * 放入任务：根据QueueIndex和任务优先级，把任务放进相应的队列。
    * 执行任务：通过在相应线程中手动执行`WaitUntilTaskCompletes`来执行队列里面的任务。

**FTaskGraphImplement的成员变量及其说明：**

```c++
// 后台线程及数据（Windows平台下，最多有83个线程）
FWorkerThread       WorkerThreads[MAX_THREADS];
// 在用的线程数量
int32               NumThreads;
// NamedThread线程数量
int32               NumNamedThreads;
// 线程优先级数量（一个ThreadSet对应的线程数量，范围：1-3）
int32               NumTaskThreadSets;
// 线程集合（ThreadSet）的数量（不同平台下，根据CPU核心数量计算得出）
int32               NumTaskThreadsPerSet;

// 控制ThreadSet集合大小，是否创建高/低优先级线程
bool                bCreatedHiPriorityThreads;
bool                bCreatedBackgroundPriorityThreads;
```

其中：

```c++
enum
{
    // 最大线程数量
    //  - ThreadSet最多26组
    MAX_THREADS = 26 * (CREATE_HIPRI_TASK_THREADS + CREATE_BACKGROUND_TASK_THREADS + 1) + ENamedThreads::ActualRenderingThread + 1,
    // 线程优先级最多3个
    MAX_THREAD_PRIORITIES = 3
};
```

**TaskGraph系统的初始化入口：**

```c++
// FEngineLoop::PreInitPreStartupScreen
// initialize task graph sub-system with potential multiple threads
SCOPED_BOOT_TIMING("FTaskGraphInterface::Startup");

// 初始化整个TaskGraph系统
FTaskGraphInterface::Startup(FPlatformMisc::NumberOfCores());

// 当前线程Attach为GameThread
FTaskGraphInterface::Get().AttachToThread(ENamedThreads::GameThread);
```

## 2.3.TaskGraph的实现示例

**一个DAG的例子：**

![ThreadPool](/images/ue/taskgraph-dagtask.png)


**代码片段：**

```c++
FGraphEventRef TaskA, TaskB, TaskC, TaskD, TaskE;

// TaskA
TaskA = TGraphTask<FTask>::CreateTask().ConstructAndDispatchWhenReady(TEXT("TaksA"), 1, 1);

// TaskB 依赖 TaskA
{
    FGraphEventArray Prerequisites;
    Prerequisites.Add(TaskA);
    TaskB = TGraphTask<FTask>::CreateTask(&Prerequisites).ConstructAndDispatchWhenReady(TEXT("TaksB"), 1, 1);
}

// TaskC 依赖 TaskB
{
    FGraphEventArray Prerequisites;
    Prerequisites.Add(TaskB);
    TaskC = TGraphTask<FTask>::CreateTask(&Prerequisites).ConstructAndDispatchWhenReady(TEXT("TaksC"), 1, 1);
}

// TaskD 依赖 TaskA
{
    FGraphEventArray Prerequisites;
    Prerequisites.Add(TaskA);
    TaskD = TGraphTask<FTask>::CreateTask(&Prerequisites).ConstructAndDispatchWhenReady(TEXT("TaksD"), 1, 3);
}

// TaskE 依赖 TaskC、TaskD
{
    FGraphEventArray Prerequisites {TaskC, TaskD};
    TaskE = TGraphTask<FTask>::CreateTask(&Prerequisites).ConstructAndDispatchWhenReady(TEXT("TaksE"), 1, 1);
}

UE_LOG(LogTemp, Display, TEXT("Construct is Done ......"));

// 在当前线程等待，直到TaskE完成
TaskE->Wait();
UE_LOG(LogTemp, Display, TEXT("Over ......"));
```

**对象结构：**

一个任务主要由两部分构成：
- Task对象，表示任务本身
- GraphEvent对象，表示任务之间的依赖关系（后续任务集合）

整个任务DAG由上面两部组成，如下所示：

![ThreadPool](/images/ue/taskgraph-dagtask3.png)

**Wait操作的实现：**

无论哪种Wait操作：
* `Event->Wait()`
* `FTaskGraphInterface::Get().WaitUntilTaskCompletes()`

最终调用的都是`FTaskGraphImplementation::WaitUntilTasksComplete`


**a.** 对于AnyThread来说，Wait操作相当于给DAG最后再加一个Trigger任务节点，挂起到该Trigger任务执行完成：

* 会创建一个`FTriggerEventGraphTask`对象
* 然后使用`FEvent`挂起到该Trigger任务完成（调用`FEvent::Trigger`）

![ThreadPool](/images/ue/taskgraph-wait.png)

**b.** 对于NamedThread来说，Wait操作也是给DAG最后加了一个任务节点（`FReturnGraphTask`），执行NamedThread里面的任务，直到这个ReturnTask完成。


# 3.TaskGraph的简单用法

## 3.1.自定义任务

定义一个两个示例任务：

* FGraphTaskSimple - 一次性任务（`ESubsequentsMode::FireAndForget`）
* FTask - 有依赖关系的任务（`ESubsequentsMode::TrackSubsequents`）

**代码示例：**

```c++
// 定义一个一次性任务
class FGraphTaskSimple
{
public:
    FGraphTaskSimple(const TCHAR* TheName, int InSomeArgument, float InWorkingTime = 1.0f)
        : TaskName(TheName), SomeArgument(InSomeArgument), WorkingTime(InWorkingTime)
    {
        Log(__FUNCTION__);
    }

    ~FGraphTaskSimple()
    {
        Log(__FUNCTION__);
    }

    FORCEINLINE TStatId GetStatId() const
    {
        RETURN_QUICK_DECLARE_CYCLE_STAT(FGraphTaskSimple, STATGROUP_TaskGraphTasks);
    }

    // AnyThread中运行
    static ENamedThreads::Type GetDesiredThread()
    {
        return ENamedThreads::AnyThread;
    }

    // FireAndForget：一次性任务，没有依赖关系
    static ESubsequentsMode::Type GetSubsequentsMode()
    {
        return ESubsequentsMode::FireAndForget;
    }

    // 执行任务
    void DoTask(ENamedThreads::Type CurrentThread, const FGraphEventRef& MyCompletionGraphEvent)
    {
        // The arguments are useful for setting up other tasks. 
        // Do work here, probably using SomeArgument.
        FPlatformProcess::Sleep(WorkingTime);
        Log(__FUNCTION__);
    }

public:
    // 自定义参数
    FString TaskName;
    int SomeArgument;
    float WorkingTime;

    // 日志接口
    void Log(const char* Action)
    {
        uint32 CurrentThreadId = FPlatformTLS::GetCurrentThreadId();
        FString CurrentThreadName = FThreadManager::Get().GetThreadName(CurrentThreadId);
        UE_LOG(LogTemp, Display, TEXT("%s@%s[%d] - %s, SomeArgument=%d"), *TaskName, *CurrentThreadName,
               CurrentThreadId,
               ANSI_TO_TCHAR(Action), SomeArgument);
    }
};

// 定义一个支持依赖关系的任务
class FTask : public FGraphTaskSimple
{
public:
	using FGraphTaskSimple::FGraphTaskSimple;

	FORCEINLINE TStatId GetStatId() const
	{
		RETURN_QUICK_DECLARE_CYCLE_STAT(FGraphTask, STATGROUP_TaskGraphTasks);
	}

	static ENamedThreads::Type GetDesiredThread()
	{
		return ENamedThreads::AnyThread;
	}

    // TrackSubsequents - 支持依赖检查
	static ESubsequentsMode::Type GetSubsequentsMode()
	{
		return ESubsequentsMode::TrackSubsequents;
	}
};
```

## 3.2.一次性任务

**代码示例：**

```c++
inline void Test_GraphTask_Simple()
{
    // 创建一个一次性任务并执行，任务结束自动删除
    TGraphTask<FGraphTaskSimple>::CreateTask().
        ConstructAndDispatchWhenReady(TEXT("SimpleTask1"), 10000, 3);

    // 创建一个任务但不放入TaskGraph执行
    TGraphTask<FGraphTaskSimple>* Task = TGraphTask<FGraphTaskSimple>::CreateTask().ConstructAndHold(
        TEXT("SimpleTask2"), 20000);
    if (Task)
    {
        // Unlock操作，放入TaskGraph执行
        UE_LOG(LogTemp, Display, TEXT("Task is Unlock to Run..."));
        Task->Unlock();
        Task = nullptr;
    }
}
```


## 3.3.顺序依赖任务

有三个任务，需要按照顺序执行，任务本身在不同的AnyThread中执行：

![ThreadPool](/images/ue/taskgraph-task.png)

**代码示例：**

```c++
// TaskA -> TaskB -> TaskC
inline void Test_GraphTask_Simple2()
{
    UE_LOG(LogTemp, Display, TEXT("Start ......"));

    FGraphEventRef TaskA, TaskB, TaskC;

    // TaskA
    {
        TaskA = TGraphTask<FTask>::CreateTask().ConstructAndDispatchWhenReady(TEXT("TaksA"), 1, 3);
    }

    // TaskA -> TaskB
    {
        FGraphEventArray Prerequisites;
        Prerequisites.Add(TaskA);
        TaskB = TGraphTask<FTask>::CreateTask(&Prerequisites).ConstructAndDispatchWhenReady(TEXT("TaksB"), 2, 2);
    }

    // TaskB -> TaskC
    {
        FGraphEventArray Prerequisites{TaskB};
        TaskC = TGraphTask<FTask>::CreateTask(&Prerequisites).ConstructAndDispatchWhenReady(TEXT("TaksC"), 3, 1);
    }


    UE_LOG(LogTemp, Display, TEXT("Construct is Done ......"));

    // Waiting until TaskC is Done
    // FTaskGraphInterface::Get().WaitUntilTaskCompletes(TaskC);
    // Or.
    TaskC->Wait();

    UE_LOG(LogTemp, Display, TEXT("TaskA is Done : %d"), TaskA->IsComplete());
    UE_LOG(LogTemp, Display, TEXT("TaskB is Done : %d"), TaskA->IsComplete());
    UE_LOG(LogTemp, Display, TEXT("TaskC is Done : %d"), TaskC->IsComplete());
    UE_LOG(LogTemp, Display, TEXT("Over ......"));
}
```

## 3.4.Gather/Fence任务

`FNullGraphTask`，一个执行体为空的任务，用于等待多个任务结束后的点，类似Fork-Join模型中的Join操作。


![ThreadPool](/images/ue/taskgraph-nulltask.png)

**代码示例：**

```c++
//
//  TaskA ->
//          | -> NullTask(Gather/Fence)
//  TaskB ->
//
inline void Test_GraphTask_NullTask()
{
    // 创建并运行TaskA，TaskB
    auto TaskA = TGraphTask<FTask>::CreateTask().ConstructAndDispatchWhenReady(TEXT("TaskA"), 1, 2);
    auto TaskB = TGraphTask<FTask>::CreateTask().ConstructAndDispatchWhenReady(TEXT("TaskB"), 2, 1);

    // 创建一个空任务，依赖于TaskA和TaskB
    FGraphEventRef CompleteEvent;
    {
        DECLARE_CYCLE_STAT(TEXT("FNullGraphTask.Gather"),
                           STAT_FNullGraphTask_Gather,
                           STATGROUP_TaskGraphTasks);
        FGraphEventArray Prerequisites;
        Prerequisites.Add(TaskA);
        Prerequisites.Add(TaskB);
        CompleteEvent = TGraphTask<FNullGraphTask>::CreateTask(&Prerequisites).ConstructAndDispatchWhenReady(
            GET_STATID(STAT_FNullGraphTask_Gather), ENamedThreads::GameThread);
    }


    UE_LOG(LogTemp, Display, TEXT("Construct is Done ......"));

    // 等待TaskA和TaskB任务完成
    CompleteEvent->Wait();

    UE_LOG(LogTemp, Display, TEXT("Over ......"));
}
```

## 3.5.Delegate任务

支持两种代理任务：

* `FSimpleDelegateGraphTask` - Delegate对象没有参数

* `FDelegateGraphTask` - Delegate对象有两个参数，形如：`TaskDelegate(NamedThreads::Type CurrentThread, const FGraphEventRef& MyCompletionGraphEvent)`，和上面定义的任务的DoTask参数相同。

**代码示例：**

```c++
inline void Test_GraphTask_Delegate()
{
    // Simple Delegate
    FSimpleDelegateGraphTask::CreateAndDispatchWhenReady(
        FSimpleDelegateGraphTask::FDelegate::CreateLambda([]()
        {
            uint32 CurrentThreadId = FPlatformTLS::GetCurrentThreadId();
            FString CurrentThreadName = FThreadManager::Get().GetThreadName(CurrentThreadId);
            UE_LOG(LogTemp, Display, TEXT("%s[%d] - Simple Delegate"), *CurrentThreadName, CurrentThreadId);
        }),
        TStatId()
    );


    // Delegate
    FTaskGraphInterface::Get().WaitUntilTaskCompletes(
        FDelegateGraphTask::CreateAndDispatchWhenReady(
            FDelegateGraphTask::FDelegate::CreateLambda(
                [](ENamedThreads::Type InCurrentThread, const FGraphEventRef& MyCompletionGraphEvent)
                {
                    FPlatformProcess::Sleep(3);
                    uint32 CurrentThreadId = FPlatformTLS::GetCurrentThreadId();
                    FString CurrentThreadName = FThreadManager::Get().GetThreadName(CurrentThreadId);
                    UE_LOG(LogTemp, Display, TEXT("%s[%d] - Delegate, %d"), *CurrentThreadName, CurrentThreadId,
                           InCurrentThread);
                }),
            TStatId()
        ),
        ENamedThreads::GameThread
    );

    UE_LOG(LogTemp, Display, TEXT("Over ......"));
}
```

## 3.6.Function任务

封装了TUniqueFunction，可以直接用于执行某一个函数对象，或者Lambda函数。

**代码示例：**

```c++
inline void Test_GraphTask_Function()
{
    // 无参数的形式
    FFunctionGraphTask::CreateAndDispatchWhenReady([]()
    {
        uint32 CurrentThreadId = FPlatformTLS::GetCurrentThreadId();
        FString CurrentThreadName = FThreadManager::Get().GetThreadName(CurrentThreadId);
        UE_LOG(LogTemp, Display, TEXT("%s[%d] - Fuction with Void"), *CurrentThreadName, CurrentThreadId);
    }, TStatId());


    // 有参数形式
    FFunctionGraphTask::CreateAndDispatchWhenReady(
        [](ENamedThreads::Type InCurrentThread, const FGraphEventRef& MyCompletionGraphEvent)
        {
            FPlatformProcess::Sleep(3);
            uint32 CurrentThreadId = FPlatformTLS::GetCurrentThreadId();
            FString CurrentThreadName = FThreadManager::Get().GetThreadName(CurrentThreadId);
            UE_LOG(LogTemp, Display, TEXT("%s[%d] - Function with parameters, %d"), *CurrentThreadName, CurrentThreadId,
                   InCurrentThread);
        }, TStatId())->Wait(ENamedThreads::GameThread);

    UE_LOG(LogTemp, Display, TEXT("Over ......"));
}
```

# 4.并行计算Fibonacci数列的示例

使用TaskGraph实现一个同步和异步模式的，并行计算斐波拉切数列的例子。通过下面示例，感受下其强大之处，使用TaskGraph可以以简洁的代码轻松实现Map/Reduce或Fork/Join模式。

## 形式1：同步模式

通过递归实现，每次调用创建两个任务，并等待其结束。直到所有子任务完成，返回结果。

```c++
int64 Fibonacci(int64 N)
{
    check(N > 0);
    if (N <= 2)
    {
        // 递归结束条件
        return 1;
    }
    else
    {
        std::atomic<int64> F1{ -1 };
        std::atomic<int64> F2{ -1 };
        FGraphEventArray GraphEvents;
        // Fork：创建两个任务，子任务递归调用Fibonacci
        GraphEvents.Add(FFunctionGraphTask::CreateAndDispatchWhenReady([&F1, N] { F1 = Fibonacci(N - 1); }));
        GraphEvents.Add(FFunctionGraphTask::CreateAndDispatchWhenReady([&F2, N] { F2 = Fibonacci(N - 2); }));

        // Join：等待上面两个任务结束
        FTaskGraphInterface::Get().WaitUntilTasksComplete(MoveTemp(GraphEvents));
        check(F1 > 0 && F2 > 0);

        return F1 + F2;
    }
}
```

## 形式2：异步模式

也是通过递归调用构建一个树状的任务网络，然后返回它的GraphEvent对象（根结点）。然后任务的执行分配在不同的AnyThread中执行，遇到结束条件时，执行`ResEvent->DispatchSubsequents`，然后父任务才算完成，完成事件依次往上抛，到最终的根结点。

```c++
FGraphEventRef Fib(int64 N, int64* Res)
{
    if (N <= 2)
    {
        // 递归结束条件，返回一个空事件，并执行分发
        *Res = 1;
        FGraphEventRef ResEvent = FGraphEvent::CreateGraphEvent();
        ResEvent->DispatchSubsequents();
        return ResEvent;
    }
    else
    {
        TUniquePtr<int64> F1 = MakeUnique<int64>();
        TUniquePtr<int64> F2 = MakeUnique<int64>();

        FGraphEventArray SubTasks;

        auto FibTask = [](int64 N, int64* Res)
        {
            return FFunctionGraphTask::CreateAndDispatchWhenReady
            (
                [N, Res]
                (ENamedThreads::Type, const FGraphEventRef& CompletionEvent)
                {
                    // 递归调用
                    FGraphEventRef ResEvent = Fib(N, Res);
                    // 若返回的事件没完成，当前任务不算结束
                    CompletionEvent->DontCompleteUntil(ResEvent);
                }
            );
        };
    
        // 创建两个子任务
        SubTasks.Add(FibTask(N - 1, F1.Get()));
        SubTasks.Add(FibTask(N - 2, F2.Get()));

        // 创建计算任务，依赖上面两个任务
        FGraphEventRef ResEvent = FFunctionGraphTask::CreateAndDispatchWhenReady
        (
            [F1 = MoveTemp(F1), F2 = MoveTemp(F2), Res]
            {
                *Res = *F1 + *F2;
            }, 
            TStatId{}, &SubTasks
        );

        return ResEvent;
    }
}

template<int64 N>
void Fib()
{
    TUniquePtr<int64> Res = MakeUnique<int64>();
    // 异步计算Fib
    FGraphEventRef ResEvent = Fib(N, Res.Get());
    // 干点其它事情...
    
    // 等待异步计算结束，输出结果
    ResEvent->Wait();
    UE_LOG(LogTemp, Display, TEXT("Fibonacci(%d) = %d"), N, *Res);
}
```

# 5.小结

通过以上示例和实现分析，可以看到UE的TaskGraph提供了一套非常方便的，基于任务的并发机制。加上低层无锁任务队列的实现，让其任务调度的性能有了保证。

另外有一点要一直强调：任务执行体中的代码，一定要明确知道它在什么类型的线程中执行，是否存在数据竞争。比如：Gameplay相关的对象操作，如Actor的创建和删除的任务，只能在GameThread类型的线程中执行，若放入其它线程执行就会有问题。

PS.之前在一游戏项目中实现过类似的异步任务机制，后台多个线程执行任务，最终Wait操作只能在游戏逻辑主线程中，比起UE的TaskGraph简直就是小巫见大巫了。代码片段如下：
> <https://github.com/david-pp/tinyworld/blob/master/common/async.h>

# 6.参考资料

示例完整代码：

> <https://github.com/david-pp/UESnippets/blob/main/SnippetAsync/Private/SimpleGraphTask.h>

UE源码：

> `Engine/Source/Runtime/Core/Public/Async/TaskGraphInterfaces.h`
> `Engine/Source/Runtime/Core/Private/Tests/Async/TaskGraphTest.cpp`

