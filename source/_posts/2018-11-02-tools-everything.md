---
title: Everything：快速找到你想要的文件
date: 2018-11-02 21:00:00
category : 工具
tags: []
---

常言道：**工欲善其事，必先利其器；能用键盘坚决不用鼠标；能敲一下搞定坚决不敲多次**。作为一个变态的程序猿，都是这么要求自己的。之前也收集了许多效率工具，很有必要拿出来分享一下。今天介绍一个本地文件搜索工具：Everything，对于那些桌面和磁盘文件经常乱七八糟的，找个东西花半天的同学特别适用。Everything这个工具，当你第一次启动它的时候，它会快速地把你磁盘里面所有文件根据文件名生成索引，当然也可以根据需要，可以指定要查找的目录或者排除掉一些目录，然后可以根据文件名精确、模糊去匹配，快速定位到想要的文件。

<!--more-->

几个简单演示感受下（搜索结果秒出，千万别拿WINDOWS本身Explore的搜索来对比，没有对比就没有伤害）：

- 查找当前电脑里面的patchupdate.exe文件：

![Everything](/images/everything-1.png)


- 查找当前电脑里面所有的jpg图片：

![Everything](/images/everything-3.png)

- 作为键盘流，呼出和隐藏Everything必须加个快捷键，`Tools->Options->Keyboard`可以进行设置（个人偏爱：WIN+`）

![Everything](/images/everything-2.png)


简直就是一个超级流畅的本地搜索引擎，有没有。它的功能不止于此，你也可以把网络共享的一些文件夹加进来，也是通过`Tools->Options->Indexes->Folders`进行设置，格式如：`\\192.168.1.16\xx`。


- 自己电脑里面的所有文件，想要别人去访问，把自己的电脑当作一个HTTP文件服务器如何？进行下面设置：
  
![Everything](/images/everything-5.png))

恭喜，局域网内的同学就可以随意下载你电脑上的文件啦。用浏览器打开：

![Everything](/images/everything-4.png))


- 那能不能检索局域网内别人电脑里面的内容，下载或者进行操作呢？答案是大大的YES，在需要被检索的电脑上，启动Everything，在：`Tools->Options->ETP/FTP Server`里面进行设置；然后其他Everything打开`Tools->Connect To ETP Server`，然后填写IP、用户名、密码即可，把指定的电脑当作自己外接的一块硬盘来用，感觉爽YY。

![Everything](/images/everything-6.png))


Everything对文件的快速检索，不止于此，支持正则表达式，文件列表等等功能，甚至支持命令行玩法、还提供了做二次开发的SDK，有兴趣的同学自行Google，本帖七言八语主要是让大家知道有这么个神器。工具虽小，对于经常在一堆文件中摸爬滚打的同学们来说就是一把利器，还不赶快用起来？

PS. 公众号写点东西这件事，是要坚持下去了。没啥可写也要写、强迫自己总结分享一些好玩的、有趣的。

