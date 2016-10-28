---
layout: post
title:  C++构建系统的选择
category : 开发环境 
tags : [C++, make, cmake]
date: 2016-10-28
---

C++少说也用了十年了，从简单的Hello World到200百万行的游戏项目，编译和构建的工具也经历了各种升级。最终的开发环境，选择了Clang+GDB+CMake。当然不断改进和升级开发工具的脚步尚未停止，只要能提高开发效率，怎样折腾都是值得的。

期间经历了：
1. 直接调用编译和链接命令
2. 使用Makefile
3. 使用CMake
4. 不断尝试其他构建系统，如：b2、WAF、SCons

![ C++构建系统的选择](/images/2016-10-28-build-system.jpg)

<!--more-->

### 对构建系统的要求

由于C/C++本身的特性，如：跨平台、高性能等、编写复杂等，对构建系统也是提出了一定的要求：

- **支持并行编译**：构建系统能否支持并行编译？对于编译速度的要求，我给自己定的目标是<10min，超过10min要么换机器，要么想办法优化代码依赖。上百万行的代码，并行编译时必须的，否则一不小心改一行代码等个把小时，这样开发时间白白浪费在编译上太不值得了。

- **自动生成依赖**：构建系统是否仅仅编译刚修改过的及其依赖的文件？代码的依赖关系，要我们自己去手动写脚本（一般gcc/clang的话，使用`gcc -M xx.cpp`）？

- **跨平台**：构建系统能否仅写一份构建脚本，支持多种平台？有些项目需要进行交叉编译，测试环境和运行环境是在不同的平台环境下。

- **支持自定义构建目标**： 构建系统必须支持扩展，支持自定义Target等。如：protobuf文件可以根据依赖规则自动生成.h、.cpp；自定义一些用于打包或测试的命令（`make pack`、`make test`）。

下面大概介绍一下上面提到的构建系统，具体用法不赘述，官方网站是最好的开始地方。

### 基于make的

#### GNU Make

对于玩Linux的人来说，这是太熟悉不过的东西了。小规模的项目或仅自己玩的项目，手写Makefile完全就足够了。

GNU Make 是一个控制源码生成可执行文件或其他文件的工具。需要一个叫Makefile的文件来说明构建的目标和规则。

最简单的规则大概是这样的：

``` bash
target:   dependencies ...
          commands
          ...
```
意思是：生成`target`，依赖于`dependencies`，如果`dependencies`有修改或者`target`不存在，就逐个执行下面的`commands`去生成`target`。

下面贴一个复杂的Makefile感受下：

``` make
CXX      = g++
CXXFLAGS = -g -I../proto.client -I../common
LDFLAGS  = -L../common  -L../proto.client/ -lproto.client -L/usr/local/lib -lzmq -lprotobuf -ltinyworld

OBJS = main.o

SRCS = $(OBJS:%.o=%.cpp)
DEPS = $(OBJS:%.o=.%.d) 

TARGET=gateserver

.PHONY: all clean

all : $(TARGET)

include $(DEPS)
$(DEPS): $(SRCS)
	@$(CXX) -M $(CXXFLAGS) $< > $@.$$$$; \
		sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ >$@; \
		rm -f $@.$$$$

$(OBJS): %.o: %.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(TARGET): $(OBJS) ../common/libtinyworld.a
	$(CXX) $(OBJS) -o $@ $(CXXFLAGS) $(LDFLAGS)

clean:
	@rm -rf $(TARGET)
```

#### Microsoft NMake

在Windows下面做开发，Visual Studio基本上完全胜任。微软自己的IDE功能强大，对于项目构建的管理IDE帮着你搞定了。VS的构建的管理其实用的是微软自己的Make，叫NMAKE。脚本还是IDE，各有千秋：IDE好处就是它什么都帮你干了，简单方便；坏处就是对构建的方式和过程了解的比较浅，自由度没那么大，遇到大型项目的特殊需求时要各种查资料。

MSDN上面的NMAKE脚本示例：
``` make
# Sample makefile

!include <win32.mak>

all: simple.exe challeng.exe

.c.obj:
  $(cc) $(cdebug) $(cflags) $(cvars) $*.c

simple.exe: simple.obj
  $(link) $(ldebug) $(conflags) -out:simple.exe simple.obj $(conlibs) lsapi32.lib

challeng.exe: challeng.obj md4c.obj
  $(link) $(ldebug) $(conflags) -out:challeng.exe $** $(conlibs) 
```

### 自动生成make脚本的

手动写make脚本自由度大，为了自由度，它的设计比较简单，有许多上述对构建系统的要求它没法支持。如：GUN Make没法自己知道代码的依赖，需要借助编译器来自己写脚本；跨平台就更不可能了。

还有一个重要的影响就是对于环境的自动检测。如果你的代码发布出去，任何一个人下载下来需要进行编译，他的编译器、操作系统环境、依赖的第三方库的位置和版本都会有差异，如何进行编译？难到要下载你代码的人去手动修改你的Makefile吗？当然不是，这个时候在编译之前还需要一步：检测当前编译环境、操作系统环境、第三方库的位置等，不满足要求就直接报错，检测到所有依赖后再根据这些信息生成适合你当前系统的Makefile，然后才能进行编译。

在Linux下安装一个源码包时，一般都是这么几步：

``` bash
./configure --prefix=xxx
make
make install
```

其中的`configure`就是检测环境，生成Makefile的脚本。

#### GNU Build System

- Autoconf
- Automake
- Libtool

#### CMake

### 非基于make的

#### SCons
#### WAF
#### b2

### 参考资料

- https://www.softprayog.in/tutorials/understanding-gnu-build-system
- https://www.gnu.org/software/make/
- http://www.cmake.org/
