---
layout: post
title: cocos2d-iphone源码分析(1)：场景
category : 游戏开发
tags : [iOS, cocos2d]
date: 2013-01-21 15:41  +0800
---

cocos2d-iphone是一个基于Objective-C的2D游戏引擎。还有一个跨平台版的叫cocos2d-x，这个现在貌似挺火的。用cocos2d开发应用之前，必须要先了解下面几个概念：

* Scenes：场景  
* Director：导向器  
* Layers：层  
* Sprites：精灵  

### 1.场景的概念

场景（CCScene对象）在app的工作流中，是一个比较独立的元素。你也可以把他称作“屏幕”或“关卡”。你的应用可能有很多场景，但当前状态下只能有一个被激活的场景。例如，一个小游戏，它可能有下面的场景：介绍、菜单、第一关、过度场景1、关卡2、胜利过度场景、失败过度场景、最高分场景等。

![cocos2d](/images/2013-01-21-1.jpg)

### 2.场景的实现

cocos2d的CCScene包含多个可以堆叠起来的层（CCLayer对象）。Layer为场景添加了外观和行为，一般只需要创建场景上的层对象。CCScene类族里面还有一种表示两个场景之间过度的场景，是使用CCTransitionScene对象来实现。

CCScene继承自CCNode，行为和属性和CCNode是一样的。对场景可以进行手动变换或者使用动作组（Actions）。

CCNode主要的子类有CCScene, CCLayer, CCSprite, CCMenu。下面大体介绍一下CCNode类的属性和方法：

#### 2.1 CCNode的特性

复合：可以包含其它CCNode子节点

* addChild
* getChildByTag
* removeChild

支持周期性回调

* schedule
* unschedule

可以执行各种动作及其组合

* runAction
* stopAction

#### 2.2 CCNode的任务

* 初始化和清理
* 复合模式
* 绘制
* 变换
* 场景管理
* 动作
* 调度器支持
* 转换

#### 2.3 CCNode的属性

* position：位置
* scale (x, y)：缩放
* rotation (in degrees, clockwise)：旋转
* skew：倾斜
* CCCamera (an interface to gluLookAt )：相机
* CCGridBase (to do mesh transformations)：格子
* anchor point：锚点
* size：大小
* visible：可见性
* z-order：Z序
* openGL z position

### 3. 代码示例，参见：

* test/SceneTest.m
* test/NodeTest.m
