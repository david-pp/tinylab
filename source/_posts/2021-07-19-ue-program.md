---
title: 使用UnrealEngine创建独立应用
date: 2021-07-19 22:00:00
category : UE实践笔记
tags: [UE, UBT]
---

# 0.动机

UE源码简直就一个宝库，里面封装了许多有用、好玩的代码。想一探究竟，还是得动手，尤其是低层代码，写点测试代码验证下和自己的理解是否有偏差也很重要。能脱离UEEditor，快速写点独立的测试代码？能把UE源码当作一个可复用的快平台的代码库来用？能用UE写独立的GUI工具？

答案当然都是：YES！下面尝试解决这几个问题：

- 快速编写测试代码
- 创建独立应用程序（比如：命令行工具、基于Slate界面的工具）
- 把UE当作一个代码库来用，开发自己的各种应用

测试代码仓库（不定期更新）：<https://github.com/david-pp/UESnippets>

<!--more-->

# 1.UBT命令行用法

UBT（Unreal Build Tool），是UE的构建工具，基于C#开发的，让UE的构建方式统一起来，跨越硬件平台、操作系统、编译器、甚至是构建系统的限制。各种平台下的IDE（VS、Xcode、Rider、VSCode等）构建本质上都用的UBT。假设我们没有IDE，如何使用命令行来构建整个项目（以下以Mac系统下为例，Windows/Linux类似）。

> 定义快捷命令：

```bash
# UE安装路径
export UE_PATH=/Users/david/UnrealEngine4.26
 
# UE4Editor可执行文件
alias ue4="$UE_PATH/Engine/Binaries/Mac/UE4Editor.app/Contents/MacOS/UE4Editor"
# UBT工具命令（Mac下在Mono环境下运行）
alias ubt="mono $UE_PATH/Engine/Binaries/DotNET/UnrealBuildTool.exe"
```

> 生成工程文件（IDE工程，纯命令行玩时，非必要）：

```bash
# 生成XCode工程
ubt -projectfiles -XCodeProjectFiles -game -project=$PWD/HelloUE.uproject

# 生成CMake工程
ubt -projectfiles -CMakefile -game -project=$PWD/HelloUE.uproject
```

> 构建游戏项目：

```bash
#
# 直接用UBT：
#
# Target - HelloUEEditor
# Platform - Mac
# Mode - Development
# -Project - 游戏项目的.uproject文件
# -Verbose - UBT构建时显示Verbose信息，便于了解UBT做了什么
# -Timestamps - UBT的日志输出加上时间戳
# -Progress - 显示构建进度
# 更多参数参见UBT源码（GlobalOptions ：Engine/Source/Programs/UnrealBuildTool/UnrealBuildTool.cs）

ubt HelloUEEditor Mac Development -Project=$PWD/HelloUE.uproject  

#
# 或者，相应平台下的构建脚本：
#
$UE_PATH/Engine/Build/BatchFiles/Mac/Build.sh HelloUEEditor Mac Development -Project=$PWD/HelloUE.uproject 
```
 
> 启动游戏项目

```bash
ue4 $PWD/HelloUE.uproject
```

# 2.独立应用的配置和构建

UE支持独立的应用程序Program，可以由C#/C++开发。有两种方式来开发自己独立的应用：

- Engine目录：位于`Engine/Soure/Programs`，有许多值得参考的例子，比如：BlankProgram、SlateViewer等。
- Game目录：位于自己游戏项目的`Game/Source/Programs`，或自定义目录。

## 2.1 Program的构建命令

Engine目录下的Program构建：

```bash
ubt BlankProgram Mac Development
```

Game目录下的Program构建：

```bash
# 构建MyBlankProgram
ubt MyBlankProgram Mac Development -Project=$PWD/HelloUE.uproject

# 运行MyBlankProgram
./Binaries/Mac/MyBlankProgram
> LogMyBlankProgram: Display: Hello World! by David !!
```

## 2.2 Program的构建配置

**参考：**

- BlankProgram - `Engine/Source/Programs/BlankProgram/`
- SlateViewer - `Engine/Source/Programs/SlateViewer/`

**代码示例：**

复制一份引擎下面的BlankProgram：<https://github.com/david-pp/UESnippets/tree/main/MyBlankProgram>

``` bash
cd $YourGame/Source
git clone https://github.com/david-pp/UESnippets.git UESnippets
```

**独立应用的构建配置：**

- `MyBlankProgram.Target.cs`

```c#
// 指定为需要构建的目标类型 TargetType.Program
Type = TargetType.Program;
// 将目标编译成一个单个的可执行文件
LinkType = TargetLinkType.Monolithic;
// 应用程序项目名
LaunchModuleName = "BlankProgram";
// 指定应用源码所在目录（默认Source/Programs下）
SolutionDirectory = "UESnippets";
// true  - 控制台程序
// false - 窗口程序
bIsBuildingConsoleApplication = true;
```

- `MyBlankProgram.Build.cs`

```c#
// 与Engine/Source/BlankProgram的区别，包含路径
PrivateIncludePaths.Add(System.IO.Path.Combine(EngineDirectory, "Source/Runtime/Launch/Public"));
PrivateIncludePaths.Add(System.IO.Path.Combine(EngineDirectory, "Source/Runtime/Launch/Private"));
```

# 3.独立的控制台应用

代码示例：<https://github.com/david-pp/UESnippets/tree/main/HelloUECpp>

```c++
#include <iostream>
#include "HelloUECpp.h"
#include "RequiredProgramMainCPPInclude.h"

IMPLEMENT_APPLICATION(HelloUECpp, "HelloUECpp");

int main(int argc, const char* argv[])
{
	FVector V1(1, 0, 0);
	FVector V2(0, 1, 0);
	float Value = V1 | V2; // Dot Product
	std::cout << "Hello UE C++! V1 * V2 = " << Value << std::endl;
}
```

构建：

```bash
cd $YourGame
ubt HelloUECpp Mac Development -Project=$PWD/$YourGame.uproject
```

# 4.独立的Slate界面应用

代码示例：<https://github.com/david-pp/UESnippets/tree/main/HelloSlate>


```c++
int RunSimpleGUI(const TCHAR* CommandLine)
{
	// start up the main loop
	GEngineLoop.PreInit(CommandLine);
                    FSlateApplication::InitializeAsStandaloneApplication(GetStandardStandaloneRenderer());
      
	// create a test window
	FGlobalTabmanager::Get()->SetApplicationTitle(LOCTEXT("AppTitle", "Hello Slate"));
	TSharedPtr<SWindow> SlateWin = SNew(SWindow)
		.Title(LOCTEXT("HelloSlate", "Hello Slate App!"))
		.ClientSize(FVector2D(900, 600))
		.AutoCenter(EAutoCenter::None);

	FSlateApplication::Get().AddWindow(SlateWin.ToSharedRef());

	while (!IsEngineExitRequested())
	{
		FSlateApplication::Get().Tick();
		FSlateApplication::Get().PumpMessages();
		FPlatformProcess::Sleep(0.01);
	}
	FCoreDelegates::OnExit.Broadcast();
	FSlateApplication::Shutdown();
	FModuleManager::Get().UnloadModulesAtShutdown();

	return 0;
}
```

构建：

```bash
cd $YourGame
ubt HelloSlate Mac Development -Project=$PWD/$YourGame.uproject
```

Simple Window效果如下：

![SimpleSlate](/images/ue/ue-simple-slate.jpeg)


Slate Viewer效果如下：

![SimpleSlate](/images/ue/ue-slate-viewer.jpeg)


# 5.参考资料

- <https://docs.unrealengine.com//en-US/ProductionPipelines/BuildTools/UnrealBuildTool/>
- UE4.26 Source Code
