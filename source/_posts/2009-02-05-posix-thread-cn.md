---
layout: post
title: POSIX多线程程序设计
category : Linux开发
tags : [多线程, pthread]
date: 2009-02-05 21:27:00 +0800
---

### 目录 

1. [摘要](#abstract)  
2. [译者序](#david)
3. [Pthreads 概述](#pthread-intro)  
	3.1 [什么是线程?](#3.1)  
	3.2 [什么是Pthreads?](#3.2)  
	3.3 [为什么使用Pthreads?](#3.3)   
	3.4 [使用线程设计程序](#3.4)   
4. [Pthreads API编译多线程程序](#4)  
5. [线程管理](#5)  
	5.1 [创建和终止线程](#5.1)  
	5.2 [向线程传递参数](#5.2)  
	5.3 [连接（Joining）和分离（Detaching）线程](#5.3)  
	5.4 [栈管理](#5.4)   
	5.5 [其它函数](#5.5)   
6. [互斥量（Mutex Variables）](#6)   
	6.1 [互斥量概述](#6.1)   
	6.2 [创建和销毁互斥量](#6.2)  
	6.3 [锁定（Locking）和解锁（Unlocking）互斥量](#6.3)  
7. [条件变量（Condition Variable）](#7)  
	7.1 [条件变量概述](#7.1)  
	7.2 [创建和销毁条件变量](#7.2)  
	7.3 [等待（Waiting）和发送信号（Signaling）](#7.3)  
8. [没有覆盖的主题](#8)
9. [Pthread 库API参考](#9)  
10. [参考资料](#10)

---------------------------------------------------

### <a id="abstract"></a> 1. 摘要

在多处理器共享内存的架构中（如：对称多处理系统SMP），线程可以用于实现程序的并行性。历史上硬件销售商实现了各种私有版本的多线程库，使得软件开发者不得不关心它的移植性。对于UNIX系统，IEEE POSIX 1003.1标准定义了一个C语言多线程编程接口。依附于该标准的实现被称为POSIX theads 或 Pthreads。 

该教程介绍了Pthreads的概念、动机和设计思想。内容包含了Pthreads API主要的三大类函数：线程管理（Thread Managment）、互斥量（Mutex Variables）和条件变量（Condition Variables）。向刚开始学习Pthreads的程序员提供了演示例程。 

适于：刚开始学习使用线程实现并行程序设计；对于C并行程序设计有基本了解。不熟悉并行程序设计的可以参考EC3500: Introduction To Parallel Computing。

---------------------------------------------------

### <a id="david"></a> 2. 译者序

三天时间，终于在工作期间，抽空把上一篇POSIX threads programing翻译完了。由于水平有限，翻译质量差强人意，若有不合理或错误之处，请您之处，在此深表感谢！有疑问点此查看原文。在参考部分提及的几本关于Pthreads库的大作及该文章原文和译文可在下面的连接下载：

* 本篇及其英文原文:  <http://download.csdn.net/source/992256>
* 多线程编程指南:  <http://download.csdn.net/source/992248>
* Programing with POSIX thread(强烈推荐): <http://download.csdn.net/source/992239>
* Pthread Primer(强烈推荐): <http://download.csdn.net/source/992213>

---------------------------------------------------

### <a id="pthread-intro"></a> 3. Pthreads概述 

#### <a id="3.1"></a> 3.1 什么是线程? 
 
技术上，线程可以定义为：可以被操作系统调度的独立的指令流。但是这是什么意思呢？ 

对于软件开发者，在主程序中运行的“函数过程”可以很好的描述线程的概念。 

进一步，想象下主程序（a.out）包含了许多函数，操作系统可以调度这些函数，使之同时或者（和）独立的执行。这就描述了“多线程”程序。 
怎样完成的呢？ 
 
在理解线程之前，应先对UNIX进程（process）有所了解。进程被操作系统创建，需要相当多的“额外开销”。进程包含了程序的资源和执行状态信息。如下： 

* 进程ID，进程group ID，用户ID和group ID 
* 环境 
* 工作目录  
* 程序指令 
* 寄存器 
* 栈 
* 堆 
* 文件描述符 
* 信号操作（Signal actions） 
* 共享库 
* 进程间通信工具（如：消息队列，管道，信号量或共享内存） 

![进程](/images/2009-02-05-process.gif)

线程使用并存在于进程资源中，还可以被操作系统调用并独立地运行，这主要是因为线程仅仅复制必要的资源以使自己得以存在并执行。 

独立的控制流得以实现是因为线程维持着自己的： 

* 堆栈指针 
* 寄存器 
* 调度属性（如：策略或优先级） 
* 待定的和阻塞的信号集合（Set of pending and blocked signals） 
* 线程专用数据（TSD：Thread Specific Data.） 

因此，在UNIX环境下线程： 

* 存在于进程，使用进程资源 
* 拥有自己独立的控制流，只要父进程存在并且操作系统支持 
* 只复制必可以使得独立调度的必要资源 
* 可以和其他线程独立（或非独立的）地共享进程资源 
* 当父进程结束时结束，或者相关类似的 
* 是“轻型的”，因为大部分额外开销已经在进程创建时完成了 

因为在同一个进程中的线程共享资源： 

* 一个线程对系统资源（如关闭一个文件）的改变对所有其它线程是可以见的 
* 两个同样值的指针指向相同的数据 
* 读写同一个内存位置是可能的，因此需要成员显式地使用同步 

---------------------------------------------------

#### <a id="3.2"></a> 3.2 什么是 Pthreads? 

历史上，硬件销售商实现了私有版本的多线程库。这些实现在本质上各自不同，使得程序员难于开发可移植的应用程序。 

为了使用线程所提供的强大优点，需要一个标准的程序接口。对于UNIX系统，IEEE POSIX 1003.1c（1995）标准制订了这一标准接口。依赖于该标准的实现就称为POSIX threads 或者Pthreads。现在多数硬件销售商也提供Pthreads，附加于私有的API。 

Pthreads 被定义为一些C语言类型和函数调用，用pthread.h头（包含）文件和线程库实现。这个库可以是其它库的一部分，如libc。 


---------------------------------------------------

#### <a id="3.3"></a> 3.3 为什么使用 Pthreads? 

使用Pthreads的主要动机是提高潜在程序的性能。 

当与创建和管理进程的花费相比，线程可以使用操作系统较少的开销，管理线程需要较少的系统资源。 

例如，下表比较了fork()函数和pthread_create()函数所用的时间。计时反应了50,000个进程/线程的创建，使用时间工具实现，单位是秒，没有优化标志。 

备注：不要期待系统和用户时间加起来就是真实时间，因为这些SMP系统有多个CPU同时工作。这些都是近似值。 

<table class="table table-striped">
	<thead>
		<tr>
			<th rowspan="2">平台</th>
			<th colspan="3">fork()</th>
			<th colspan="3">pthread_create()</th>
		</tr>
		<tr>
			<th>real</th>
			<th>user</th>
			<th>sys</th>
			<th>real</th>
			<th>user</th>
			<th>sys</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>AMD 2.4 GHz Opteron (8cpus/node) </td>
			<td>41.07</td> 
			<td>60.08</td> 
			<td>9.01</td>
			<td>0.66</td>
			<td>0.19</td>
			<td>0.43</td>
		</tr>
		<tr>
			<td>IBM 1.9 GHz POWER5 p5-575 (8cpus/node) </td>
			<td>64.24</td> 
			<td>30.78</td> 
			<td>27.68</td>
			<td>1.75</td>
			<td>0.69</td>
			<td>1.10</td>
		</tr>
		<tr>
			<td>IBM 1.5 GHz POWER4 (8cpus/node) </td>
			<td>104.05</td> 
			<td>48.64</td> 
			<td>47.21</td>
			<td>2.01</td>
			<td>1.00</td>
			<td>1.52</td>
		</tr>
		<tr>
			<td>INTEL 2.4 GHz Xeon (2 cpus/node) </td>
			<td>54.95</td> 
			<td>1.54</td> 
			<td>20.78</td>
			<td>1.64</td>
			<td>0.67</td>
			<td>0.90</td>
		</tr>
		<tr>
			<td>INTEL 1.4 GHz Itanium2 (4 cpus/node)  </td>
			<td>54.54</td> 
			<td>1.07</td> 
			<td>22.22</td>
			<td>2.03</td>
			<td>1.26</td>
			<td>0.67</td>
		</tr>
	</tbody>
</table>

在同一个进程中的所有线程共享同样的地址空间。较于进程间的通信，在许多情况下线程间的通信效率比较高，且易于使用。 

较于没有使用线程的程序，使用线程的应用程序有潜在的性能增益和实际的优点： 

* CPU使用I/O交叠工作：例如，一个程序可能有一个需要较长时间的I/O操作，当一个线程等待I/O系统调用完成时，CPU可以被其它线程使用。 
* 优先/实时调度：比较重要的任务可以被调度，替换或者中断较低优先级的任务。 
* 异步事件处理：频率和持续时间不确定的任务可以交错。例如，web服务器可以同时为前一个请求传输数据和管理新请求。 

考虑在SMP架构上使用Pthreads的主要动机是获的最优的性能。特别的，如果一个程序使用MPI在节点通信，使用Pthreads可以使得节点数据传输得到显著提高。 

例如： 

* MPI库经常用共享内存实现节点任务通信，这至少需要一次内存复制操作（进程到进程）。 
* Pthreads没有中间的内存复制，因为线程和一个进程共享同样的地址空间。没有数据传输。变成cache-to-CPU或memory-to-CPU的带宽（最坏情况），速度是相当的快。 
* 比较如下： 

<table class="table table-striped">
	<thead>
		<tr>
			<th>Platform</th>
			<th>MPI Shared Memory Bandwidth(GB/sec) </th>
			<th>Pthreads Worst Case Memory-to-CPU Bandwidth (GB/sec) </th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>AMD 2.4 GHz Opteron </td>
			<td>1.2</td>
			<td>5.3</td>
		</tr>
		<tr>
			<td>IBM 1.9 GHz POWER5 p5-575</td>
			<td>4.1</td>
			<td>16</td>
		</tr>
		<tr>
			<td>IBM 1.5 GHz POWER4 </td>
			<td>2.1</td>
			<td>4</td>
		</tr>
		<tr>
			<td>Intel 1.4 GHz Xeon </td>
			<td>0.3</td>
			<td>4.3</td>
		</tr>
		<tr>
			<td>Intel 1.4 GHz Itanium 2</td>
			<td>1.8</td>
			<td>6.4</td>
		</tr>
	</tbody>
</table>

---------------------------------------------------

#### <a id="3.4"></a> 3.4 使用线程设计程序 

##### 并行编程:  

在现代多CPU机器上，pthread非常适于并行编程。可以用于并行程序设计的，也可以用于pthread程序设计。 

并行程序要考虑许多，如下： 

* 用什么并行程序设计模型？ 
* 问题划分 
* 加载平衡（Load balancing） 
* 通信 
* 数据依赖 
* 同步和竞争条件 
* 内存问题 
* I/O问题 
* 程序复杂度 
* 程序员的努力/花费/时间 
* ...  

包含这些主题超出本教程的范围，有兴趣的读者可以快速浏览下“Introduction to Parallel Computing”教程。 

大体上，为了使用Pthreads的优点，必须将任务组织程离散的，独立的，可以并发执行的。例如，如果routine1和routine2可以互换，相互交叉和（或者）重叠，他们就可以线程化。 
 
拥有下述特性的程序可以使用pthreads： 

* 工作可以被多个任务同时执行，或者数据可以同时被多个任务操作。 
* 阻塞与潜在的长时间I/O等待。 
* 在某些地方使用很多CPU循环而其他地方没有。 
* 对异步事件必须响应。 
* 一些工作比其他的重要（优先级中断）。 

Pthreads 也可以用于串行程序，模拟并行执行。很好例子就是经典的web浏览器，对于多数人，运行于单CPU的桌面/膝上机器，许多东西可以同时“显示”出来。 

使用线程编程的几种常见模型： 

* **管理者/工作者（Manager/worker）**：一个单线程，作为管理器将工作分配给其它线程（工作者），典型的，管理器处理所有输入和分配工作给其它任务。至少两种形式的manager/worker模型比较常用：静态worker池和动态worker池。 

* **管道（Pipeline）**：任务可以被划分为一系列子操作，每一个被串行处理，但是不同的线程并发处理。汽车装配线可以很好的描述这个模型。 

* **Peer**: 和manager/worker模型相似，但是主线程在创建了其它线程后，自己也参与工作。 


##### 共享内存模型（Shared Memory Model）:  

所有线程可以访问全局，共享内存 

线程也有自己私有的数据 

程序员负责对全局共享数据的同步存取（保护） 
 
##### 线程安全（Thread-safeness）:  

线程安全：简短的说，指程序可以同时执行多个线程却不会“破坏“共享数据或者产生“竞争”条件的能力。 

例如：假设你的程序创建了几个线程，每一个调用相同的库函数： 

* 这个库函数存取/修改了一个全局结构或内存中的位置。 
* 当每个线程调用这个函数时，可能同时去修改这个全局结构活内存位置。 
* 如果函数没有使用同步机制去阻止数据破坏，这时，就不是线程安全的了。 
 
如果你不是100%确定外部库函数是线程安全的，自己负责所可能引发的问题。 

建议：小心使用库或者对象，当不能明确确定是否是线程安全的。若有疑虑，假设其不是线程安全的直到得以证明。可以通过不断地使用不确定的函数找出问题所在。 


---------------------------------------------------

### <a id="4"></a> 4. 编译多线程程序 

下表列出了一些编译使用了pthreads库程序的命令： 

<table class="table table-striped">
	<thead>
		<tr>
			<th>Compiler/Platform</th>
			<th>Compiler Command</th>
			<th>Description</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td rowspan="3">IBM AIX</td>
			<td>xlc_r / cc_r </td>
			<td>C (ANSI  /  non-ANSI) </td>
		</tr>
		<tr>
			<td>xlC_r </td>
			<td>C++</td>
		</tr>
		<tr>
			<td>xlf_r -qnosave, xlf90_r -qnosave </td>
			<td>Fortran - using IBM's Pthreads API (non-portable) </td>
		</tr>
		<tr>
			<td rowspan="2">INTEL Linux </td>
			<td>icc -pthread</td>
			<td>C</td>
		</tr>
		<tr>
			<td>icpc -pthread </td>
			<td>C++</td>
		</tr>
		<tr>
			<td rowspan="2">PathScale Linux  </td>
			<td>pathcc -pthread</td>
			<td>C</td>
		</tr>
		<tr>
			<td>pathCC -pthread </td>
			<td>C++</td>
		</tr>
		<tr>
			<td rowspan="2">PGI Linux </td>
			<td>pgcc -lpthread</td>
			<td>C</td>
		</tr>
		<tr>
			<td>pgCC -lpthread </td>
			<td>C++</td>
		</tr>
		<tr>
			<td rowspan="2">GNU Linux, AIX </td>
			<td>gcc -pthread</td>
			<td>C</td>
		</tr>
		<tr>
			<td>g++ -pthread </td>
			<td>C++</td>
		</tr>
	</tbody>
</table>

---------------------------------------------------

### <a id="5"></a> 5. 线程管理（Thread Management） 


#### <a id="5.1"></a> 5.1 创建和结束线程 

**函数**：

	pthread_create (thread,attr,start_routine,arg)  
	pthread_exit (status)  
	pthread_attr_init (attr)  
	pthread_attr_destroy (attr)  

**创建线程**:  

最初，main函数包含了一个缺省的线程。其它线程则需要程序员显式地创建。 

pthread_create 创建一个新线程并使之运行起来。该函数可以在程序的任何地方调用。 

pthread_create参数： 

	thread：返回一个不透明的，唯一的新线程标识符。 
	attr：不透明的线程属性对象。可以指定一个线程属性对象，或者NULL为缺省值。 
	start_routine：线程将会执行一次的C函数。 
	arg: 传递给start_routine单个参数，传递时必须转换成指向void的指针类型。没有参数传递时，可设置为NULL。 

一个进程可以创建的线程最大数量取决于系统实现。 

一旦创建，线程就称为peers，可以创建其它线程。线程之间没有指定的结构和依赖关系。 
 
Q：一个线程被创建后，怎么知道操作系统何时调度该线程使之运行？ 

A：除非使用了Pthreads的调度机制，否则线程何时何地被执行取决于操作系统的实现。强壮的程序应该不依赖于线程执行的顺序。

 
**线程属性**:

线程被创建时会带有默认的属性。其中的一些属性可以被程序员用线程属性对象来修改。 

pthread_attr_init 和 pthread_attr_destroy用于初始化/销毁先成属性对象。 

其它的一些函数用于查询和设置线程属性对象的指定属性。 

一些属性下面将会讨论。 

**结束终止**:  

结束线程的方法有一下几种： 

* 线程从主线程（main函数的初始线程）返回。 
* 线程调用了pthread_exit函数。 
* 其它线程使用 pthread_cancel函数结束线程。 
* 调用exec或者exit函数，整个进程结束。 

pthread_exit用于显式退出线程。典型地，pthread_exit()函数在线程完成工作时，不在需要时候被调用，退出线程。 

如果main()在其他线程创建前用pthread_exit()退出了，其他线程将会继续执行。否则，他们会随着main的结束而终止。 

程序员可以可选择的指定终止状态，当任何线程连接（join）该线程时，该状态就返回给连接（join）该线程的线程。 

清理：pthread_exit()函数并不会关闭文件，任何在线程中打开的文件将会一直处于打开状态，知道线程结束。 

讨论：对于正常退出，可以免于调用pthread_exit()。当然，除非你想返回一个返回值。然而，在main中，有一个问题，就是当main结束时，其它线程还没有被创建。如果此时没有显式的调用pthread_exit()，当main结束时，进程（和所有线程）都会终止。可以在main中调用pthread_exit()，此时尽管在main中已经没有可执行的代码了，进程和所有线程将保持存活状态，。 

**例子: Pthread 创建和终止**

该例用pthread_create()创建了5个线程。每一个线程都会打印一条“Hello World”的消息，然后调用pthread_exit()终止线程。 

```

#include <pthread.h> 
#include <stdio.h> 
#define NUM_THREADS     5 
 
void *PrintHello(void *threadid) 
{ 
   int tid; 
   tid = (int)threadid; 
   printf("Hello World! It's me, thread #%d!/n", tid); 
   pthread_exit(NULL); 
} 
 
int main (int argc, char *argv[]) 
{ 
   pthread_t threads[NUM_THREADS]; 
   int rc, t; 
   for(t=0; t<NUM_THREADS; t++){ 
      printf("In main: creating thread %d/n", t); 
      rc = pthread_create(&threads[t], NULL, PrintHello, (void *)t); 
      if (rc){ 
         printf("ERROR; return code from pthread_create() is %d/n", rc); 
         exit(-1); 
      } 
   } 
   pthread_exit(NULL); 
} 

```

--------------------------------------------

#### <a id="5.2"></a> 5.2 向线程传递参数 

pthread_create()函数允许程序员想线程的start routine传递一个参数。当多个参数需要被传递时，可以通过定义一个结构体包含所有要传的参数，然后用pthread_create()传递一个指向改结构体的指针，来打破传递参数的个数的限制。 
所有参数都应该传引用传递并转化成（void*）。 
  
	Q：怎样安全地向一个新创建的线程传递数据？ 
	A：确保所传递的数据是线程安全的（不能被其他线程修改）。下面三个例子演示了那个应该和那个不应该。 
 
Example 1 - Thread Argument Passing  

下面的代码片段演示了如何向一个线程传递一个简单的整数。主线程为每一个线程使用一个唯一的数据结构，确保每个线程传递的参数是完整的。 

```

int *taskids[NUM_THREADS]; 
 
for(t=0; t<NUM_THREADS; t++) 
{ 
   taskids[t] = (int *) malloc(sizeof(int)); 
   *taskids[t] = t; 
   printf("Creating thread %d/n", t); 
   rc = pthread_create(&threads[t], NULL, PrintHello,  
        (void *) taskids[t]); 
   ... 
} 

```
 
Example 2 - Thread Argument Passing  

例子展示了用结构体向线程设置/传递参数。每个线程获得一个唯一的结构体实例。 

```

struct thread_data{ 
   int  thread_id; 
   int  sum; 
   char *message; 
}; 
 
struct thread_data thread_data_array[NUM_THREADS]; 
 
void *PrintHello(void *threadarg) 
{ 
   struct thread_data *my_data; 
   ... 
   my_data = (struct thread_data *) threadarg; 
   taskid = my_data->thread_id; 
   sum = my_data->sum; 
   hello_msg = my_data->message; 
   ... 
} 
 
int main (int argc, char *argv[]) 
{ 
   ... 
   thread_data_array[t].thread_id = t; 
   thread_data_array[t].sum = sum; 
   thread_data_array[t].message = messages[t]; 
   rc = pthread_create(&threads[t], NULL, PrintHello,  
        (void *) &thread_data_array[t]); 
   ... 
} 
 
```
 
Example 3 - Thread Argument Passing (Incorrect)  

例子演示了错误地传递参数。循环会在线程访问传递的参数前改变传递给线程的地址的内容。 

```
int rc, t; 
 
for(t=0; t<NUM_THREADS; t++)  
{ 
   printf("Creating thread %d/n", t); 
   rc = pthread_create(&threads[t], NULL, PrintHello,  
        (void *) &t); 
   ... 
} 
 
```

----------------------------------------------------

#### <a id="5.3"></a> 5.3 连接（Joining）和分离（Detaching）线程 

**函数**:  

	pthread_detach (threadid,status)  
	pthread_attr_setdetachstate (attr,detachstate)  
	pthread_attr_getdetachstate (attr,detachstate)  
	pthread_join (threadid,status)  

**连接**: 

“连接”是一种在线程间完成同步的方法。例如： 
 
pthread_join()函数阻赛调用线程知道threadid所指定的线程终止。 

如果在目标线程中调用pthread_exit()，程序员可以在主线程中获得目标线程的终止状态。 

连接线程只能用pthread_join()连接一次。若多次调用就会发生逻辑错误。 

两种同步方法，互斥量（mutexes）和条件变量（condition variables），稍后讨论。 

可连接（Joinable or Not）?  

当一个线程被创建，它有一个属性定义了它是可连接的（joinable）还是分离的（detached）。只有是可连接的线程才能被连接（joined），若果创建的线程是分离的，则不能连接。 

POSIX标准的最终草案指定了线程必须创建成可连接的。然而，并非所有实现都遵循此约定。 

使用pthread_create()的attr参数可以显式的创建可连接或分离的线程，典型四步如下： 

* 声明一个pthread_attr_t数据类型的线程属性变量 
* 用pthread_attr_init()初始化改属性变量 
* 用pthread_attr_setdetachstate()设置可分离状态属性 
* 完了后，用pthread_attr_destroy()释放属性所占用的库资源 

**分离（Detaching）**：

pthread_detach()可以显式用于分离线程，尽管创建时是可连接的。 
没
有与pthread_detach()功能相反的函数 

**建议**：

* 若线程需要连接，考虑创建时显式设置为可连接的。因为并非所有创建线程的实现都是将线程创建为可连接的。 
* 若事先知道线程从不需要连接，考虑创建线程时将其设置为可分离状态。一些系统资源可能需要释放。 

**例子: Pthread Joining**

Example Code - Pthread Joining  

这个例子演示了用Pthread join函数去等待线程终止。因为有些实现并不是默认创建线程是可连接状态，例子中显式地将其创建为可连接的。

```

#include <pthread.h> 
#include <stdio.h> 
#define NUM_THREADS    3 
 
void *BusyWork(void *null) 
{ 
   int i; 
   double result=0.0; 
   for (i=0; i<1000000; i++) 
   { 
     result = result + (double)random(); 
   } 
   printf("result = %e/n",result); 
   pthread_exit((void *) 0); 
} 
 
int main (int argc, char *argv[]) 
{ 
   pthread_t thread[NUM_THREADS]; 
   pthread_attr_t attr; 
   int rc, t; 
   void *status; 
 
   /* Initialize and set thread detached attribute */ 
   pthread_attr_init(&attr); 
   pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE); 
 
   for(t=0; t<NUM_THREADS; t++) 
   { 
      printf("Creating thread %d/n", t); 
      rc = pthread_create(&thread[t], &attr, BusyWork, NULL);  
      if (rc) 
      { 
         printf("ERROR; return code from pthread_create()  
                is %d/n", rc); 
         exit(-1); 
      } 
   } 
 
   /* Free attribute and wait for the other threads */ 
   pthread_attr_destroy(&attr); 
   for(t=0; t<NUM_THREADS; t++) 
   { 
      rc = pthread_join(thread[t], &status); 
      if (rc) 
      { 
         printf("ERROR; return code from pthread_join()  
                is %d/n", rc); 
         exit(-1); 
      } 
      printf("Completed join with thread %d status= %ld/n",t, (long)status); 
   } 
 
   pthread_exit(NULL); 
} 
 
```

--------------------------------------------------

#### <a id="5.4"></a> 5.4 栈管理 

**函数**:  
	
	pthread_attr_getstacksize (attr, stacksize)  
	pthread_attr_setstacksize (attr, stacksize)  
	pthread_attr_getstackaddr (attr, stackaddr)  
	pthread_attr_setstackaddr (attr, stackaddr)  

**防止栈问题**:

POSIX标准并没有指定线程栈的大小，依赖于实现并随实现变化。 

很容易超出默认的栈大小，常见结果：程序终止或者数据损坏。 

安全和可移植的程序应该不依赖于默认的栈限制，但是取而代之的是用pthread_attr_setstacksize分配足够的栈大小。 

pthread_attr_getstackaddr和pthread_attr_setstackaddr函数可以被程序用于将栈设置在指定的内存区域。 

在LC上的一些实际例子:  

默认栈大小经常变化很大，最大值也变化很大，可能会依赖于每个节点的线程数目。 

<table class="table table-striped">
	<thead>
		<tr>
			<th> Node Architecture</th>
			<th> #CPUS </th>
			<th> Memory(GB) </th>
			<th> Default Size (bytes) </th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td> AMD Opteron </td>
			<td> 8 </td>
			<td> 16 </td>
			<td> 2,097,152 </td>
		</tr>
		<tr>
			<td> Intel IA64 </td>
			<td> 4 </td>
			<td> 8 </td>
			<td> 33,554,432 </td>
		</tr>
		<tr>
			<td> Intel IA32 </td>
			<td> 2 </td>
			<td> 4 </td>
			<td> 2,097,152 </td>
		</tr>
		<tr>
			<td> IBM Power5 </td>
			<td> 8 </td>
			<td> 32 </td>
			<td> 196,608</td>
		</tr>
		<tr>
			<td> IBM Power4 </td>
			<td> 8 </td>
			<td> 16 </td>
			<td> 196,608</td>
		</tr>
		<tr>
			<td> IBM Power3 </td>
			<td> 16 </td>
			<td> 32 </td>
			<td> 98,304 </td>
		</tr>
	</tbody>
</table>


**例子: 栈管理**

Example Code - Stack Management  

这个例子演示了如何去查询和设定线程栈大小。  

```

#include <pthread.h> 
#include <stdio.h> 
#define NTHREADS 4 
#define N 1000 
#define MEGEXTRA 1000000 
  
pthread_attr_t attr; 
  
void *dowork(void *threadid) 
{ 
   double A[N][N]; 
   int i,j,tid; 
   size_t mystacksize; 
 
   tid = (int)threadid; 
   pthread_attr_getstacksize (&attr, &mystacksize); 
   printf("Thread %d: stack size = %li bytes /n", tid, mystacksize); 
   for (i=0; i<N; i++) 
     for (j=0; j<N; j++) 
      A[i][j] = ((i*j)/3.452) + (N-i); 
   pthread_exit(NULL); 
} 
  
int main(int argc, char *argv[]) 
{ 
   pthread_t threads[NTHREADS]; 
   size_t stacksize; 
   int rc, t; 
  
   pthread_attr_init(&attr); 
   pthread_attr_getstacksize (&attr, &stacksize); 
   printf("Default stack size = %li/n", stacksize); 
   stacksize = sizeof(double)*N*N+MEGEXTRA; 
   printf("Amount of stack needed per thread = %li/n",stacksize); 
   pthread_attr_setstacksize (&attr, stacksize); 
   printf("Creating threads with stack size = %li bytes/n",stacksize); 
   for(t=0; t<NTHREADS; t++){ 
      rc = pthread_create(&threads[t], &attr, dowork, (void *)t); 
      if (rc){ 
         printf("ERROR; return code from pthread_create() is %d/n", rc); 
         exit(-1); 
      } 
   } 
   printf("Created %d threads./n", t); 
   pthread_exit(NULL); 
} 

```

--------------------------------------------------

#### <a id="5.5"></a> 5.5 其他各种函数

	pthread_self ()  
	pthread_equal (thread1,thread2)  

pthread_self返回调用该函数的线程的唯一，系统分配的线程ID。 

pthread_equal比较两个线程ID,若不同返回0，否则返回非0值。 

注意这两个函数中的线程ID对象是不透明的，不是轻易能检查的。因为线程ID是不透明的对象，所以C语言的==操作符不能用于比较两个线程ID。 

	pthread_once (once_control, init_routine)  

pthread_once 在一个进程中仅执行一次init_routine。任何线程第一次调用该函数会执行给定的init_routine，不带参数，任何后续调用都没有效果。 

init_routine函数一般是初始化的程序 

once_control参数是一个同步结构体，需要在调用pthread_once前初始化。例如： 

	pthread_once_t once_control = PTHREAD_ONCE_INIT;  
 

---------------------------------------------------- 

### <a id="6"></a> 6. 互斥量（Mutex Variables）


#### <a id="6.1"></a> 6.1 概述 

互斥量（Mutex）是“mutual exclusion”的缩写。互斥量是实现线程同步，和保护同时写共享数据的主要方法 

互斥量对共享数据的保护就像一把锁。在Pthreads中，任何时候仅有一个线程可以锁定互斥量，因此，当多个线程尝试去锁定该互斥量时仅有一个会成功。直到锁定互斥量的线程解锁互斥量后，其他线程才可以去锁定互斥量。线程必须轮着访问受保护数据。 

互斥量可以防止“竞争”条件。下面的例子是一个银行事务处理时发生了竞争条件：

<table class="table talbe.stripped">
	<thead>
		<tr>
			<th> Thread 1 </th>
			<th> Thread 2 </th>
			<th> Balance </th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>Read balance: $1000 </td>
			<td></td>
			<td>$1000</td>
		</tr>
		<tr>
			<td></td>
			<td>Read balance: $1000 </td>
			<td>$1000</td>
		</tr>
		<tr>
			<td></td>
			<td>Deposit $200 </td>
			<td>$1000</td>
		</tr>
		<tr>
			<td>Deposit $200</td>
			<td></td>
			<td>$1000</td>
		</tr>
		<tr>
			<td>Update balance $1000+$200 </td>
			<td></td>
			<td>$1200</td>
		</tr>
		<tr>
			<td></td>
			<td>Update balance $1000+$200 </td>
			<td>$1200</td>
		</tr>
	</tbody>
</table>

上面的例子，当一个线程使用共享数据资源时，应该用一个互斥量去锁定“Balance”。 

一个拥有互斥量的线程经常用于更新全局变量。确保了多个线程更新同样的变量以安全的方式运行，最终的结果和一个线程处理的结果是相同的。这个更新的变量属于一个“临界区（critical section）”。 

使用互斥量的典型顺序如下： 

* 创建和初始一个互斥量 
* 多个线程尝试去锁定该互斥量 
* 仅有一个线程可以成功锁定改互斥量 
* 锁定成功的线程做一些处理 
* 线程解锁该互斥量 
* 另外一个线程获得互斥量，重复上述过程 
* 最后销毁互斥量 

当多个线程竞争同一个互斥量时，失败的线程会阻塞在lock调用处。可以用“trylock”替换“lock”，则失败时不会阻塞。 

当保护共享数据时，程序员有责任去确认是否需要使用互斥量。如，若四个线程会更新同样的数据，但仅有一个线程用了互斥量，则数据可能会损坏。 

-------------------------------------------------

#### <a id="6.2"></a> 6.2 创建和销毁互斥量 

**函数**：

	pthread_mutex_init (mutex,attr)  
	pthread_mutex_destroy (mutex)  
	pthread_mutexattr_init (attr)  
	pthread_mutexattr_destroy (attr)  

**用法**：

互斥量必须用类型pthread_mutex_t类型声明，在使用前必须初始化，这里有两种方法可以初始化互斥量： 

声明时静态地，如：
	pthread_mutex_t mymutex = PTHREAD_MUTEX_INITIALIZER;  

动态地用pthread_mutex_init()函数，这种方法允许设定互斥量的属性对象attr。 

互斥量初始化后是解锁的。 

attr对象用于设置互斥量对象的属性，使用时必须声明为pthread_mutextattr_t类型，默认值可以是NULL。Pthreads标准定义了三种可选的互斥量属性： 
 
* 协议（Protocol）： 指定了协议用于阻止互斥量的优先级改变 
* 优先级上限（Prioceiling）：指定互斥量的优先级上限 
* 进程共享（Process-shared）：指定进程共享互斥量 

注意所有实现都提供了这三个可先的互斥量属性。 

pthread_mutexattr_init()和pthread_mutexattr_destroy()函数分别用于创建和销毁互斥量属性对象。 

pthread_mutex_destroy()应该用于释放不需要再使用的互斥量对象。 

-------------------------------------

#### <a id="6.3"></a> 6.3 锁定和解锁互斥量 

**函数**：  

	pthread_mutex_lock (mutex)  
	pthread_mutex_trylock (mutex)  
	pthread_mutex_unlock (mutex)  

**用法**：

线程用pthread_mutex_lock()函数去锁定指定的mutex变量，若该mutex已经被另外一个线程锁定了，该调用将会阻塞线程直到mutex被解锁。 

pthread_mutex_trylock() will attempt to lock a mutex. However, if the mutex is already locked, the routine will return immediately with a "busy" error code. This routine may be useful in  

pthread_mutex_trylock()

尝试着去锁定一个互斥量，然而，若互斥量已被锁定，程序会立刻返回并返回一个忙错误值。该函数在优先级改变情况下阻止死锁是非常有用的。 

线程可以用pthread_mutex_unlock()解锁自己占用的互斥量。在一个线程完成对保护数据的使用，而其它线程要获得互斥量在保护数据上工作时，可以调用该函数。若有一下情形则会发生错误： 

* 互斥量已经被解锁 
* 互斥量被另一个线程占用 

互斥量并没有多么“神奇”的，实际上，它们就是参与的线程的“君子约定”。写代码时要确信正确地锁定，解锁互斥量。下面演示了一种逻辑错误： 

	·                    Thread 1     Thread 2     Thread 3 
	·                    Lock         Lock          
	·                    A = 2        A = A+1      A = A*B 
	·                    Unlock       Unlock     
 
Q：有多个线程等待同一个锁定的互斥量，当互斥量被解锁后，那个线程会第一个锁定互斥量？ 

A：除非线程使用了优先级调度机制，否则，线程会被系统调度器去分配，那个线程会第一个锁定互斥量是随机的。 

**例子：使用互斥量**

Example Code - Using Mutexes  

例程演示了线程使用互斥量处理一个点积（dot product）计算。主数据通过一个可全局访问的数据结构被所有线程使用，每个线程处理数据的不同部分，主线程等待其他线程完成计算并输出结果。 

```

#include <pthread.h> 
#include <stdio.h> 
#include <malloc.h> 
 
/*    
The following structure contains the necessary information   
to allow the function "dotprod" to access its input data and  
place its output into the structure.   
*/ 
 
typedef struct  
 { 
   double      *a; 
   double      *b; 
   double     sum;  
   int     veclen;  
 } DOTDATA; 
 
/* Define globally accessible variables and a mutex */ 
 
#define NUMTHRDS 4 
#define VECLEN 100 
   DOTDATA dotstr;  
   pthread_t callThd[NUMTHRDS]; 
   pthread_mutex_t mutexsum; 
 
/* 
The function dotprod is activated when the thread is created. 
All input to this routine is obtained from a structure  
of type DOTDATA and all output from this function is written into 
this structure. The benefit of this approach is apparent for the  
multi-threaded program: when a thread is created we pass a single 
argument to the activated function - typically this argument 
is a thread number. All  the other information required by the  
function is accessed from the globally accessible structure.  
*/ 
 
void *dotprod(void *arg) 
{ 
 
   /* Define and use local variables for convenience */ 
 
   int i, start, end, offset, len ; 
   double mysum, *x, *y; 
   offset = (int)arg; 
      
   len = dotstr.veclen; 
   start = offset*len; 
   end   = start + len; 
   x = dotstr.a; 
   y = dotstr.b; 
 
   /* 
   Perform the dot product and assign result 
   to the appropriate variable in the structure.  
   */ 
 
   mysum = 0; 
   for (i=start; i<end ; i++)  
    { 
      mysum += (x[i] * y[i]); 
    } 
 
   /* 
   Lock a mutex prior to updating the value in the shared 
   structure, and unlock it upon updating. 
   */ 
   pthread_mutex_lock (&mutexsum); 
   dotstr.sum += mysum; 
   pthread_mutex_unlock (&mutexsum); 
 
   pthread_exit((void*) 0); 
} 
 
/*  
The main program creates threads which do all the work and then  
print out result upon completion. Before creating the threads, 
the input data is created. Since all threads update a shared structure,  
we need a mutex for mutual exclusion. The main thread needs to wait for 
all threads to complete, it waits for each one of the threads. We specify 
a thread attribute value that allow the main thread to join with the 
threads it creates. Note also that we free up handles when they are 
no longer needed. 
*/ 
 
int main (int argc, char *argv[]) 
{ 
   int i; 
   double *a, *b; 
   void *status; 
   pthread_attr_t attr; 
 
   /* Assign storage and initialize values */ 
   a = (double*) malloc (NUMTHRDS*VECLEN*sizeof(double)); 
   b = (double*) malloc (NUMTHRDS*VECLEN*sizeof(double)); 
   
   for (i=0; i<VECLEN*NUMTHRDS; i++) 
    { 
     a[i]=1.0; 
     b[i]=a[i]; 
    } 
 
   dotstr.veclen = VECLEN;  
   dotstr.a = a;  
   dotstr.b = b;  
   dotstr.sum=0; 
 
   pthread_mutex_init(&mutexsum, NULL); 
          
   /* Create threads to perform the dotproduct  */ 
   pthread_attr_init(&attr); 
   pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE); 
 
        for(i=0; i<NUMTHRDS; i++) 
        { 
        /*  
        Each thread works on a different set of data. 
        The offset is specified by 'i'. The size of 
        the data for each thread is indicated by VECLEN. 
        */ 
        pthread_create( &callThd[i], &attr, dotprod, (void *)i); 
        } 
 
        pthread_attr_destroy(&attr); 
 
        /* Wait on the other threads */ 
        for(i=0; i<NUMTHRDS; i++) 
        { 
          pthread_join( callThd[i], &status); 
        } 
 
   /* After joining, print out the results and cleanup */ 
   printf ("Sum =  %f /n", dotstr.sum); 
   free (a); 
   free (b); 
   pthread_mutex_destroy(&mutexsum); 
   pthread_exit(NULL); 
}    

```

----------------------------------------------

### <a id="7"></a> 7. 条件变量（Condition Variables）

#### <a id="7.1"></a> 7.1 概述 

条件变量提供了另一种同步的方式。互斥量通过控制对数据的访问实现了同步，而条件变量允许根据实际的数据值来实现同步。 

没有条件变量，程序员就必须使用线程去轮询（可能在临界区），查看条件是否满足。这样比较消耗资源，因为线程连续繁忙工作。条件变量是一种可以实现这种轮询的方式。 

条件变量往往和互斥一起使用 

使用条件变量的代表性顺序如下： 

	主线程（Main Thread）  
	o                                声明和初始化需要同步的全局数据/变量（如“count”） 
	o                                生命和初始化一个条件变量对象 
	o                                声明和初始化一个相关的互斥量 
	o                                创建工作线程A和B 

	Thread A  
	o                                工作，一直到一定的条件满足（如“count”等于一个指定的值） 
	o                                锁定相关互斥量并检查全局变量的值 
	o                                调用pthread_cond_wait()阻塞等待Thread-B的信号。注意pthread_cond_wait()能够自动地并且原子地解锁相关的互斥量，以至于它可以被Thread-B使用。 
	o                                当收到信号，唤醒线程，互斥量被自动，原子地锁定。 
	o                                显式解锁互斥量 
	o                                继续 
	Thread B  
	o                                工作 
	o                                锁定相关互斥量 
	o                                改变Thread-A所等待的全局变量 
	o                                检查全局变量的值，若达到需要的条件，像Thread-A发信号。 
	o                                解锁互斥量 
	o                                继续 

	Main Thread  
	Join / Continue  

----------------------------------------------

#### <a id="7.2"></a> 7.2 创建和销毁条件变量 

**Routines**:  

	pthread_cond_init (condition,attr)  
	pthread_cond_destroy (condition)  
	pthread_condattr_init (attr)  
	pthread_condattr_destroy (attr)  

**Usage**:  

条件变量必须声明为pthread_cond_t类型，必须在使用前初始化。有两种方式可以初始条件变量： 

声明时静态地。如：
	
	pthread_cond_t myconvar = PTHREAD_COND_INITIALIZER;  

用pthread_cond_init()函数动态地。创建的条件变量ID通过condition参数返回给调用线程。该方式允许设置条件变量对象的属性，attr。 
 
可选的attr对象用于设定条件变量的属性。仅有一个属性被定义：线程共享（process-shared），可以使条件变量被其它进程中的线程看到。若要使用属性对象，必须定义为pthread_condattr_t类型（可以指定为NULL设为默认）。 

注意所有实现都提供了线程共享属性。 

pthread_condattr_init()和pthread_condattr_destroy()用于创建和销毁条件变量属性对象。 

条件变量不需要再使用时，应用pthread_cond_destroy()释放条件变量。 

---------------------------------------------

#### <a id="7.3"></a> 7.3 在条件变量上等待（Waiting）和发送信号（Signaling） 

**函数**：

	pthread_cond_wait (condition,mutex)  
	pthread_cond_signal (condition)  
	pthread_cond_broadcast (condition)  

**用法**：

pthread_cond_wait()阻塞调用线程直到指定的条件受信（signaled）。该函数应该在互斥量锁定时调用，当在等待时会自动解锁互斥量。在信号被发送，线程被激活后，互斥量会自动被锁定，当线程结束时，由程序员负责解锁互斥量。 

pthread_cond_signal()函数用于向其他等待在条件变量上的线程发送信号（激活其它线程）。应该在互斥量被锁定后调用。 

若不止一个线程阻塞在条件变量上，则应用pthread_cond_broadcast()向其它所以线程发生信号。 

在调用pthread_cond_wait()前调用pthread_cond_signal()会发生逻辑错误。 
 
使用这些函数时适当的锁定和解锁相关的互斥量是非常重要的。如： 

* 调用pthread_cond_wait()前锁定互斥量失败可能导致线程不会阻塞。 
* 调用pthread_cond_signal()后解锁互斥量失败可能会不允许相应的pthread_cond_wait()函数结束（保存阻塞）。 

**例子：使用条件变量 **

Example Code - Using Condition Variables  

例子演示了使用Pthreads条件变量的几个函数。主程序创建了三个线程，两个线程工作，根系“count”变量。第三个线程等待count变量值达到指定的值。 

```

#include <pthread.h> 
#include <stdio.h> 
 
#define NUM_THREADS  3 
#define TCOUNT 10 
#define COUNT_LIMIT 12 
 
int     count = 0; 
int     thread_ids[3] = {0,1,2}; 
pthread_mutex_t count_mutex; 
pthread_cond_t count_threshold_cv; 
 
void *inc_count(void *idp)  
{ 
  int j,i; 
  double result=0.0; 
  int *my_id = idp; 
 
  for (i=0; i<TCOUNT; i++) { 
    pthread_mutex_lock(&count_mutex); 
    count++; 
 
    /*  
    Check the value of count and signal waiting thread when condition is 
    reached.  Note that this occurs while mutex is locked.  
    */ 
    if (count == COUNT_LIMIT) { 
      pthread_cond_signal(&count_threshold_cv); 
      printf("inc_count(): thread %d, count = %d  Threshold reached./n",  
             *my_id, count); 
      } 
    printf("inc_count(): thread %d, count = %d, unlocking mutex/n",  
           *my_id, count); 
    pthread_mutex_unlock(&count_mutex); 
 
    /* Do some work so threads can alternate on mutex lock */ 
    for (j=0; j<1000; j++) 
      result = result + (double)random(); 
    } 
  pthread_exit(NULL); 
} 
 
void *watch_count(void *idp)  
{ 
  int *my_id = idp; 
 
  printf("Starting watch_count(): thread %d/n", *my_id); 
 
  /* 
  Lock mutex and wait for signal.  Note that the pthread_cond_wait  
  routine will automatically and atomically unlock mutex while it waits.  
  Also, note that if COUNT_LIMIT is reached before this routine is run by 
  the waiting thread, the loop will be skipped to prevent pthread_cond_wait 
  from never returning.  
  */ 
  pthread_mutex_lock(&count_mutex); 
  if (count<COUNT_LIMIT) { 
    pthread_cond_wait(&count_threshold_cv, &count_mutex); 
    printf("watch_count(): thread %d Condition signal  
           received./n", *my_id); 
    } 
  pthread_mutex_unlock(&count_mutex); 
  pthread_exit(NULL); 
} 
 
int main (int argc, char *argv[]) 
{ 
  int i, rc; 
  pthread_t threads[3]; 
  pthread_attr_t attr; 
 
  /* Initialize mutex and condition variable objects */ 
  pthread_mutex_init(&count_mutex, NULL); 
  pthread_cond_init (&count_threshold_cv, NULL); 
 
  /* For portability, explicitly create threads in a joinable state */ 
  pthread_attr_init(&attr); 
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE); 
  pthread_create(&threads[0], &attr, inc_count, (void *)&thread_ids[0]); 
  pthread_create(&threads[1], &attr, inc_count, (void *)&thread_ids[1]); 
  pthread_create(&threads[2], &attr, watch_count, (void *)&thread_ids[2]); 
 
  /* Wait for all threads to complete */ 
  for (i=0; i<NUM_THREADS; i++) { 
    pthread_join(threads[i], NULL); 
  } 
  printf ("Main(): Waited on %d  threads. Done./n", NUM_THREADS); 
 
  /* Clean up and exit */ 
  pthread_attr_destroy(&attr); 
  pthread_mutex_destroy(&count_mutex); 
  pthread_cond_destroy(&count_threshold_cv); 
  pthread_exit(NULL); 
 
} 

```

----------------------------------------

### <a id="8"></a> 8. 没有覆盖的主题 
 
Pthread API的几个特性在该教程中并没有包含。把它们列在下面： 

* 线程调度 
** 线程如何调度的实现往往是不同的，在大多数情况下，默认的机制是可以胜任的。 
** Pthreads　API提供了显式设定线程调度策略和优先级的函数，它们可以重载默认机制。 
* API不需要实现去支持这些特性 
* Keys：线程数据（TSD） 
* 互斥量的Protocol属性和优先级管理 
* 跨进程的条件变量共享 
* 取消线程（Thread Cancellation ） 
* 多线程和信号（Threads and Signals）  


------------------------------------------

### <a id="9"></a> 9. Pthread 库API参考 
 
**Pthread Functions**:

* Thread Management  

	pthread_create   
	pthread_exit   
	pthread_join   
	pthread_once   
	pthread_kill   
	pthread_self   
	pthread_equal   
	pthread_yield   
	pthread_detach   

* Thread-Specific Data 

	pthread_key_create  
	pthread_key_delete 
	pthread_getspecific  
	pthread_setspecific 

* Thread Cancellation 
** pthread_cancel 
** pthread_cleanup_pop 
** pthread_cleanup_push 
** pthread_setcancelstate 
** pthread_getcancelstate  
** pthread_testcancel 

* Thread Scheduling 
** pthread_getschedparam 
** pthread_setschedparam 

* Signals 
** pthread_sigmask 

**Pthread Attribute Functions**:

* Basic Management 
** pthread_attr_init 
** pthread_attr_destroy 

* Detachable or Joinable 
** pthread_attr_setdetachstate 
** pthread_attr_getdetachstate 

* Specifying Stack Information 
** pthread_attr_getstackaddr 
** pthread_attr_getstacksize 
** pthread_attr_setstackaddr 
** pthread_attr_setstacksize 

* Thread Scheduling Attributes 
** pthread_attr_getschedparam 
** pthread_attr_setschedparam 
** pthread_attr_getschedpolicy 
** pthread_attr_setschedpolicy 
** pthread_attr_setinheritsched 
** pthread_attr_getinheritsched 
** pthread_attr_setscope 
** pthread_attr_getscope 

**Mutex Functions**:

* Mutex Management 
** pthread_mutex_init 
** pthread_mutex_destroy 
** pthread_mutex_lock 
** pthread_mutex_unlock 
** pthread_mutex_trylock 

* Priority Management 
** pthread_mutex_setprioceiling 
** pthread_mutex_getprioceiling 

**Mutex Attribute Functions**:

* Basic Management 
** pthread_mutexattr_init 
** pthread_mutexattr_destroy 

* Sharing 
** pthread_mutexattr_getpshared 
** pthread_mutexattr_setpshared 

* Protocol Attributes 
** pthread_mutexattr_getprotocol 
** pthread_mutexattr_setprotocol 

* Priority Management 
** pthread_mutexattr_setprioceiling 
** pthread_mutexattr_getprioceiling 

**Condition Variable Functions**:

* Basic Management 
** pthread_cond_init 
** pthread_cond_destroy 
** pthread_cond_signal 
** pthread_cond_broadcast 
** pthread_cond_wait 
** pthread_cond_timedwait 

**Condition Variable Attribute Functions**:

* Basic Management 

	pthread_condattr_init 
	pthread_condattr_destroy 

* Sharing 

	pthread_condattr_getpshared 
	pthread_condattr_setpshared 
 
--------------------------------------------

### <a id="10"></a> 参考资料 
 
* Author: Blaise Barney, Livermore Computing.  
* "Pthreads Programming". B. Nichols et al. O'Reilly and Associates.  
* "Threads Primer". B. Lewis and D. Berg. Prentice Hall  
* "Programming With POSIX Threads". D. Butenhof. Addison Wesley 
* www.awl.com/cseng/titles/0-201-63392-2  
* "Programming With Threads". S. Kleiman et al. Prentice Hall  

(完)


 





