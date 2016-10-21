---
layout: post
title: 每周一荐：用gnuplot绘制函数曲线
category : 每周一荐
tags : [gnuplot]
date: 2012-05-17 21:30  +0800
---

喜欢数学的人，都说数学公式是世界上最简洁而深刻的诗，数学曲线是世界上最美的图画。本周给大家推荐一个开源的函数曲线绘制工具：gnuplot。别小看这个工具，年龄和我一般大，gnuplot 是在 1986 年由 Colin Kelley 和 Thomas Williams 最初开发的。许多参与者都在为不同的“终端”创建变种方面做出了贡献。在 1989 和 1990 年，这些变种被合并到 gnuplot 2.0 中。2004 年 4 月，发布了 4.0 版本。前缀gnu千万不要误解和Linux世界的GNU有关系，只是一个巧合，gnuplot被开发出来的时候，GNU不久才诞生。

Gnuplot 是一种免费分发的绘图工具，可以移植到各种主流平台。它可以下列两种模式之一进行操作：当需要调整和修饰图表使其正常显示时，通过在 gnuplot 提示符中发出命令，可以在交互模式下操作该工具。或者，gnuplot 可以从文件中读取命令，以批处理模式生成图表。例如，如果您正在运行一系列的实验，需要每次运行后都查看结果图表；或者当您在图表最初生成很久以后需要返回图表修改某些内容时，批处理模式能力会特别有用。当在 WYSIWIG 编辑器中很难捕获用于修饰图表的鼠标单击事件时，您可以很容易地将 gnuplot 命令保存在文件中，六个月后将其加载到交互式会话中重新执行。

##### 启动界面：

![gunplot](/images/2012-05-17-1.jpg)


##### 绘制二维函数曲线：

![gunplot](/images/2012-05-17-2.jpg)


	damp(t) = exp(-s*wn*t)/sqrt(1.0-s*s)
	per(t) = sin(wn*sqrt(1.0-s**2)*t - atan(-sqrt(1.0-s**2)/s))
	c(t) = 1-damp(t)*per(t)
	 
	wn = 1.0
	set xrange [0:13]
	set samples 50
	set dummy t
	set key box
	 
	plot s=.1,c(t),s=.3,c(t),s=.5,c(t),s=.7,c(t),s=.9,c(t),s=1.0,c(t),s=1.5,c(t),s=2.0,c(t)


##### 绘制三维曲面：

![gunplot](/images/2012-05-17-3.jpg)

	set samples 20
	set isosamples 20
	set view 60,30
	set xrange [-3:3]
	set yrange [-3:3]
	set zrange [-1:1]
	set ztics -1,0.5,1
	set grid z
	set border 4095
	splot sin(x) * cos(y)


##### 绘制直方图：

![gunplot](/images/2012-05-17-4.jpg)

	set title "A demonstration of boxes in mono with style fill pattern"
	set samples 11
	set boxwidth 0.5 
	set style fill pattern border
	plot [-2.5:4.5] 100/(1.0+x*x) title 'pattern 0' with boxes lt -1, \
	                 80/(1.0+x*x) title 'pattern 1' with boxes lt -1, \
	                 40/(1.0+x*x) title 'pattern 2' with boxes lt -1, \
	                 20/(1.0+x*x) title 'pattern 3' with boxes lt -1


上面随便举了几个例子，gnuplot提供了很多函数曲线显示控制的命令。能绘制的曲线有两种：1> 数学函数；2> 数据文件。gnuplot用于数据可视化是个不错的选择。小巧但功能强大，推荐给喜欢数学的同学。

##### 更多资料：

1. 主页：<http://www.gnuplot.info/>