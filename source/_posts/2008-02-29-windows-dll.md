---
layout: post
title: Windows动态链接库
category : Windows
tags : [大学时代, Windows, dll]
---

动态链接库为模块化应用程序提供了一种方式，使得更新和重用程序更加方便。当几个应用程序在同一时间使用相同的函数时，它也帮助减少内存消耗，这是因为虽然每个应用程序有独立的数据拷贝，但是它们的代码却是共享的。
 
### 动态连接库的概念

动态链接库是应用程序的一个模块，这个模块用于到处一些函数和数据供程序中的其他模块使用。应该从以下三个方面来理解：

1. 动态连接库是应用程序的一部分，它的任何操作大都是代表应用程序进行的。所以动态链接库文件和可执行文件在本质上来说是一样的，都是作为模块被进程加载到自己的空间地址的。
2. 动态链接库在程序在编译时不会被插入到可执行文件中，在程序运行时整个库的代码才会调入内存，这就是所谓的“动态链接”。
3. 如果多个程序用到同一个动态链接库，Windows在物理内存中只保留一份库的代码，仅通过分页机制将这份代码映射到不同的进程中。这样不管有多少个程序同时使用一个库，库代码实际占用的物理内存永远只有一份。

动态链接库（Dynamic Link Library）的缩写为DLL，大部分动态链接库镜像文件的扩展名为dll，但扩展名为其他的文件也有可能是动态链接库，如系统中的某些exe文件，各种控件（ocx）等都是动态链接库
 
### 动态链接库的入口点函数
 
```
BOOL APIENTRY DllMain( HANDLE hModule,
                       DWORD ul_reason_for_call,
                       LPVOID lpReserved
                                    )
{
    switch (ul_reason_for_call)
       {
              case DLL_PROCESS_ATTACH:
              case DLL_THREAD_ATTACH:
              case DLL_THREAD_DETACH:
              case DLL_PROCESS_DETACH:
                     break;
    }
    return TRUE;
}
```

**hModule** 
	参数是本DLL模块的句柄，即本动态链接库模块的实例句柄，数值上是这个文件的映像加载到进程的地址空间时使用的基地址。需要注意的是，在动态链接库中通过“GetModuleHandle(NULL)”语句得到的是主模块（可执行文件的映像）的基地址，而不是DLL文件的基地址。

**ul_reason_for_call**
	参数表示本次调用的原因，可能是下4中情况的一种：

	1. DLL_PROCESS_ATTACH      表示动态链接库刚被某个进程加载，程序可以在这里做一些初始化工作，并返回TRUE表示初始化成功，返回FALSE表示初始化出错，这样库的装载就会失败。这给动态链接库一个机会来阻止自己被装入。
	2. DLL_PROCESS_DETACH      此时相反，表示动态链接库将被卸载，程序可以在这里进行一些资源的释放工作。
	3. DLL_THREAD_ATTACH表示应用程序创建了一个线程。
	4. DLL_THREAD_DETACH       表示某个线程正常终止了。
 
                                                                              
### 动态链接库中的函数
 
DLL能够定义两种函数，导出函数和内部函数。导出函数可以被其他模块调用，也可以被定这个模块调用，而内部函数只能被定义这个函数的模块调用。

动态链接库的主要功能是向外导出函数，供进程中其他模块使用。动态链接库中代码的编写也没什么特别之处，还要包含文件还可以使用资源，C++类等。

动态链接库工程编译后，在工程的Debug或者Release目录下会生成两个个有用的文件，.dll文件就是动态链接库，.lib文件是供程序开发用的导入库，.h文件包含了导出函数的声明。
 
### 导出函数的使用
 
调用DLL中的导出函数有两种方法：

**第一种. 装载期间动态链接。**

模块可以像调用本地函数一样调用从其他模块导出的函数（API函数就是这样用的）。装载期间链接必须使用DLL的导入库（.lib文件），它为系统提供了加载这个DLL和定位这个DLL中的导出函数所需的所有信息。

所谓装载期间链接，就是应用程序启动时由加载器（加载应用程序的组件）载入dll。载入器如何知道要载入哪些DLL呢？这些信息记录在可执行文件（PE文件）的idata节中。使用这种方法不用自己写代码显式的加载DLL。在程序只需：

```
#include “ xxx.h”
#pragma comment(lib,”xxx”)
```

或者直接将xxx.lib文件添加到工程中，效果是一样的。

**注意：**

1. 发布软件时必须将该软件使用的DLL与程序一起发布。载入器在加载DLL文件时，默认情况是在应用程序的当前目录下查找，如果找不到就会到系统盘“/windows/system32”文件夹下查找，如果还是找不到就安错误处理。这种方法加载DLL库的缺点很明显，如果用户丢失了DLL文件，那么程序永远也不能启动了。所以很多时候要采取运行期间动态链接的方法。
2. 运行期间动态链接。模块也可以使用LoadLibray或者LoadLibrayEx函数在运行期间加载这个DLL。DLL被加载之后，加载模块调用GetProcAddress函数获得DLL导出函数的地址，然后通过函数地址调用DLL中的函数。

**第二种. 运行期间动态链接是在程序运行过程中显示地去加载DLL库，从中导出所需的函数。**
	
为了能够运行期动态的导出函数，一般需要在工程中建立一个DEF文件来指定要导出的函数。在新添的.def文件中写入如下内容：

	EXPORTS              
	 xxxFunction

这两行说明此DLL库要向外导出xxxFunction函数。

调用DLL导出函数时分两步进行。

1>. 加载目标DLL，如下代码：

	HMODULE hModule=LoadLibrary(“xxx.dll”);

LoadLibrary函数的作用是加载指定目录下的DLL库到进程的虚拟地址空间，函数执行成功返回此DLL模块的句柄，否则返回NULL。事实上，载入器也是调用这个函数加载DLL的。在不使用DLL模块时，应该调用FreeLibrary函数释放它所占的资源。

2>. 取得目标DLL中导出函数的地址，这项工作由GetProcAddress函数来完成。

	FARPROC GetProcAddress(
	     HMODULE hModule, // 函数所在模块的模块句柄
	     LPCSTR lpProcName // 函数的名称
	)

函数执行成功返会函数的地址，失败返回NULL。

在使用方法一时，三个文件都会被用到，使用第二种方法时，只有.dll文件会被用到。

### 例子

- **生成DLL**

```
// DllTest.cpp : Defines the entry point for the DLL application.
// 生成DLL文件，.def文件用于运行期间动态链接，若为静态则不需该文件

#include "stdafx.h"
#include "DllTest.h"
#include <stdio.h>

HMODULE g_hModule;

BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
                     )
{
    switch(ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:   // 刚被某个进程加载
        g_hModule = (HMODULE) hModule;
        break;
    }
    return TRUE;

}

// 自定义导出函数

void DllTest1(LPCSTR pszContent)
{
    char sz[MAX_PATH];
    ::GetModuleFileName(g_hModule,sz,MAX_PATH);
    MessageBox(NULL,pszContent,strrchr(sz,'/')+1,MB_OK);
}
 
void DllTest2()
{
    DllTest1("Hello world!  Hello Dll files!");
}

```


```
// DllTest.h
// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the DLLTEST_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// DLLTEST_API functions as being imported from a DLL, wheras this DLL sees symbols
// defined with this macro as being exported.
#ifdef DLLTEST_EXPORTS
#define DLLTEST_API __declspec(dllexport)
#else
#define DLLTEST_API __declspec(dllimport)
#endif

// 声明要导出的函数
DLLTEST_API void DllTest1(LPCSTR pszContent);
DLLTEST_API void DllTest2();
```

```                                                            
// DllTest.def
EXPORTS
 DllTest1
 DllTest2

```

- **使用Dll动态链接库** 

```
// DllUse1.cpp : Defines the entry point for the console application.
// 装载期间动态链接

#include "stdafx.h"
#include "DllTest.h"
#pragma comment(lib,"DllTest")

int main(int argc, char* argv[])
{
    DllTest2();
    return 0;
}
```

```              
// DllUse2.cpp : Defines the entry point for the console application.
// 运行期间动态链接

#include "stdafx.h"
#include <windows.h>

typedef void(*PFNDLLTEST2)(void);

int main(int argc, char* argv[])
{
    // 加载DLL
    HMODULE hModule = LoadLibrary("DllTest.dll");
    if(hModule != NULL)
    {
        // 取得DllTest的导出函数的地址
        PFNDLLTEST2 mDllTest2 = (PFNDLLTEST2)GetProcAddress(hModule, "DllTest2");
        if(mDllTest2 != NULL)
        {    
            mDllTest2();
        }
        // 卸载DLL
        FreeLibrary(hModule);
    }
    return 0;
}
```

