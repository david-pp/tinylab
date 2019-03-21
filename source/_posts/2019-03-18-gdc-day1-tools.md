---
title: 工具系统：让每天的工作变得轻松些（GDC）
date: 2019-03-18 20:00:00
category :
tags: []
---

以下内容来自GDC分享后整理，加上自己的一些半吊子翻译和自己的看法，若有不当指出欢迎指出。

原标题：The System of Tools: Reducing Frustration in a Daily Workflow
原作者：Laura Teeples (Workflow UX Designer, 343 Industries)

<!--more-->

![gdc](/images/gdc-tools-talker.jpeg)

日常工具效率的提升，能节约很多时间，所以优化工具就该挑使用频率最高的：

![gdc](/images/gdc-tools-1.jpeg)

节约了时间，私有工具的话就能让团队成员好过些，商业工具的话就能让客户轻松些。使用者的心情是很重要的。

![gdc](/images/gdc-tools-2.jpeg)

### 过去的方式

需求都是如此，更不用说对工具了，一般都是如下操作：

- 复制（Copy）
- 粘贴（Paste）
- 快速重用（Reuse）

为了所谓的快速重用，复制粘贴代码，工具慢慢就变成一个个打满创可贴的工具，实现功能为主，完全不考虑用户体验，这样的工具慢慢就会被使用者吐槽，最终遭到抛弃，那么工具团队花这么大力气做的事情又有啥意义呢？

![gdc](/images/gdc-tools-3.jpeg)


## 一种新方式

是时候做出一些改变了：

![gdc](/images/gdc-tools-4.jpeg)

之前最大的问题就是：**看到一个问题，就整一个工具，对于整个工作流和工具系统不管不顾**。日常工作流中涉及到的工具是有一套体系的，所以看问题要看到全貌，不要响应式地解决问题。

提出新的工具开发方式：

- **用户学习（User Studies）**：观察工具使用者怎么工作的，怎么使用工具的？找到核心需求。

![gdc](/images/gdc-tools-6.jpeg)

- **使用便利贴进行头脑风暴（Sticky Note Session/Meetings）**：程序员写工具千万不能自嗨，工具也是一个产品，得把最迫切的需求给讨论出来，遵循敏捷用户故事那一套，绝对没问题。产品都是不断讨论，不断验证做出来的。

![gdc](/images/gdc-tools-7.jpeg)

- **表格练习（Spreadsheet Exercises）**：做工具需求管理，个人觉得一般的Issue Tracking比她的Excel好用，当然她的方案还提到用Excel做模拟，知道自己做的优化对于工作效率到底能提升多少，未开动之前就先进行模拟。

![gdc](/images/gdc-tools-8.jpeg)

当然，工具开发也需要考虑其它目标：

![gdc](/images/gdc-tools-5.jpeg)

新的工具开发方式，对老的方式提出如下挑战：

![gdc](/images/gdc-tools-10.jpeg)


### 有效性评估

重新定义成功的工具：

> 有效性 = 功能 + 操作时间 + 操作频率 + 和其他工具配合需要的时间和频率

![gdc](/images/gdc-tools-11.jpeg)

针对上面几个关键点，开发过程中，常问问自己下面的问题：

![gdc](/images/gdc-tools-12.jpeg)

希望每天都过的轻松点：

![gdc](/images/gdc-tools-9.jpeg)

### 小结

国外的开发者都非常擅长总结，经常会提出一些方法论，从该演讲者学习到开发工具的一些方法：

- 多去观察工具使用者的工作情况
- 把问题放在第一位，不要自嗨去以程序的角度去做开发
- 切记把问题放在当前整个工作流中去看，要看到所有问题，要看到全景，针对全景来开发工具。
