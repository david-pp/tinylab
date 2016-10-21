---
layout: post
title: PSP游戏开放环境的建立
tagline: 获得toolchain和PSPSDK开发工具包，然后将其用CYGWIN运行
category : 游戏开发
tags : [大学时代, PSP]
date: 2008-04-20 17:30:00 +0800
---

 
	说明：原文见于http://www.psp-programming.com/tutorials/c/lesson01.htm  
	初次翻译，错误难免，还请见谅。
 
我们有一系列关于如何自制PSP（Playstation Potable）软件的教程，这份将是第一期。如果你正在读这个，恭喜你，作为程序员你遇到了一个大障碍。和刚开始编程时遇到的麻烦一样。好了，开始阅读教程了。

要创建你自己的程序，第一步就是要建立开发环境。该开发环境能可以将源代码编译成可以在PSP上执行的文件。我们将要在操作系统上安装两个重要的工具软件。
 
第一个工具叫做CYGWIN，这是一个用于Windows平台上的Linux模拟器，它可以在你的电脑上创建一个模拟的Linux环境，只有这样才可以运行一些必须在Linux下运行的程序。听起来有点可怕，不过不用担心，其实很容易用的。
 
需要的第二个东西就时toolchain。这是PSP编程的关键，提供了你所需要的一切，包括头文件、库、编译器和一些例程。安装了这个之后，你就可以开始编写自己的第一个程序了。
 
现在开始介绍颇不急待想要了解的部分：开发环境的安装。
      
第一步就是安装CYGWIN。先在CYGWIN网站上下载CYGWIN的安装程序。

下载好之后，打开该可执行文件，会闪现一个安装界面；点击“next”按钮，此时你将可以看到有三个选项，选择默认选项“Install from Internet”，点击“next”；确定在那个目录下安装CYGWIN，如过不想将其安装在“C：/cygwin”处则更改之即可（C：是本地磁盘），其他选项设为默认，点击next；现在又提示让你确定“在哪里存放下载的安装文件”，这个选项无关紧要，不过最好将其放在一个自己可以找到的目录下，以便安装完之后删除。选定了合适的地方之后，点击next；下一屏会问你你的网络设置，如果你没有使用代理（或者不知道代理是甚么），直接点next。如果不行的话，返回上一步让他用IE浏览器的设置；然后，会提供一个下载安装文件的服务器列表，任何一个都可以，选择一个点击next；现在开始下载安装文件包列表，得几分钟时间，依赖于你的网速；下载完之后，拖动滑块，在“devel”哪里点击“default”使得它变成“install”。继续拖动滑块，将“Web”下面的“wget”设置为“install”。完成之后，点击next。CYGWIN将会被下载然后安装选择了的包。这个可能会用掉很长时间，所以等待的时候你可以看看电视或者浏览其他网页。完成CYGWIN安装之后，准备安装toolchain。
 
现在我们就可以在CYGWIN环境下安装toolchain了。为了建立开放环境，首先必须运行CYGWIN。从开始菜单或者“C：/cygwin”目录下，运行一个CYGWIN bash shell（cygwinbat）。会打开一个命令行，当可以看到“yourusername@yourcomputername~”，说明你的CYGWIN环境已经成功建立了，此时就可以关闭该窗口。

下载最新的toolchain（点击此处），在最上面就可以看见了，下载该文件。下载完成之后，使用winrar将其解压缩至“C：/cygwin/home/user”文件目录下，这里的“user”是你的用户名。现在就可以安装toolchain了。再次打开CYGWIN bash shell，现在是时候介绍一些Linux命令行了，在一行的开头有“$”这个符号，它意味着正在运行的shell是在用户模式下，和根（管理员）模式相对。这一点在CYGWIN中是很重要的，如果你不曾使用过Linux命令行的话，这一点也是要注意的。
 
现在需要改变目录至刚解压缩的toolchain目录下，在bash shell 中打“ls”，它代表list，会给出当前目录下所有文件的名称和其他信息（和Windows下的dir命令相似。现在就应该可以看见一个“psptoolchain”的文件夹，这就是我们所想要改变的目录。因此打“cd psptoolchain”然后按回车。CD代表改变文件目录（Change Directory），该命令会改变当前操作的目录。此刻打“ls”命令，就可以看见所有包含在“psptoolchain”目录下的文件。这里有一个我们将要用于创建所有东西的文件“toolchain.sh”。

由于toolchain的最近问题，我们必须更新所有的东西。因此更新和修改toolchain脚本，必须使用“svn update”然后回车。

结束之后输入“./toolchain.sh”执行更新后的脚步然后回车。在Linux下，“.”表示当前目录，而“..”表示父层目录。所以该命令表示执行在当前目录下的“toolchain.sh”脚本。Toolchain.sh脚步将会为你完成剩下的所有工作。这个会花掉近几个小时，依赖于你得机器配置。
 
漫长得等待终于结束了，现在可以进行最后一步了。必须告知CYGWIN在哪里可以找到PSPSDK（toolchain安装的）和toochian。为了实现上述目标，必须改变“C:/cygwin/cygwin.bat ”文件使它包含一些路径。关闭CYGWIN，然后使用资源管理器在“C:/cygwin”目录下右键点击“cygwin.bat”。选择“编辑”后弹出一个记事本窗口，显示的内容如下：

```
@echo off
C:
chdir C:/cygwinb/bin
bash - -login –i
```

将其改为：

```
@echo off
C:
chdir C:/cygwinb/bin
set path = %path%; C:/cygwin/usr/local/pspdev/bin
set PSPSDK = C:/cygwin/usr/local/posdev
bash - -login –i
```

现在PSP游戏开放环境就建立好了。如果你现在有源代码的话就可以编译了，使用cd命令进入到源代码目录下，用make命令进行编译，就会生成一个eboot.pbp文件，该文件就可以直接放入你的PSP中运行。如果没有的话，可以通过下一节的学习来创建你自己的简单应用程序。

