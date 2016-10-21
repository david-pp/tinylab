---
layout: post
title: cocos2d-iphone源码分析(2)：Director
category : 游戏开发
tags : [iOS, cocos2d]
date: 2013/01/24  14:44  +0800
--- 

### 简介

CCDirector负责创建和处理主窗口，和管理场景的的执行。同时负责：

* 初始化OpenGL ES的context
* 设置OpenGL像素格式（默认是RGB565）
* 设置OpenGL缓冲深度（默认是0-bit）
* 设置投影模式（默认是3D）

CCDirector一般作为单件使用，标准用法是：[[CCDirector sharedDirector] methodName]。IOS下[CCDirector sharedDirector]返回的对象是CCDirectorDisplayLink。

CCDirector继承自UIViewController。CDirector是真个引擎的核心，它控制整个运行过程。一般初始化代码如下：

```

// Main Window
     window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

     // Director
     director_ = (CCDirectorIOS*)[CCDirector sharedDirector];
     [director_ setDisplayStats:NO];
     [director_ setAnimationInterval:1.0/60];

     // GL View
     CCGLView *__glView = [CCGLView viewWithFrame:[window_ bounds]
                                             pixelFormat:kEAGLColorFormatRGB565
                                             depthFormat:0 /* GL_DEPTH_COMPONENT24_OES */
                                     preserveBackbuffer:NO
                                               sharegroup:nil
                                           multiSampling:NO
                                        numberOfSamples:0
                                ];

     [director_ setView:__glView];
     [director_ setDelegate:self];
     director_.wantsFullScreenLayout = YES;

     // Retina Display ?
     [director_ enableRetinaDisplay:useRetinaDisplay_];

     // Navigation Controller
     navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
     navController_.navigationBarHidden = YES;

     // AddSubView doesn't work on iOS6
     [window_ addSubview:navController_.view];
//     [window_ setRootViewController:navController_];

     [window_ makeKeyAndVisible];

     // create the main scene
     CCScene *scene = [CCScene node];
     ....
     // and run it!
     [director_ pushScene: scene];

```

初始化流程：

1. director_ = (CCDirectorIOS*)[CCDirector sharedDirector];

[CCDirector sharedDirector]返回的对象是CCDirectorDisplayLink，创建CCScheduler（调度器）、CActionManager（动作管理器）、CCTouchDispatcher（触摸事件处理器），并把创建的动作管理器加入调度器，然后调度器就在时间片离调用CActionManager相关方法。（相关文件：CCDirector.m, CCDirectorIOS.m）

2. [director_ setAnimationInterval:1.0/60];  设置FPS。

3. 初始化GLView，为渲染准备一个视图。

3.   [director_ setView:__glView];

[director_ setDelegate:self];

Director是继承于UIViewController，设置视图和代理者。

4.   CCScene *scene = [CCScene node];

创建主场景。

5   [director_ pushScene: scene];

把主场景推入场景堆栈，并执行。

### 任务

* Memory Helper：使用purgeCacheData方法，可以自动清除所有cocos2d缓存的数据
* Scene OpenGL Helper：可以设置OpenGL的Alpha混合和深度检测（setAlphaBlending、setDethTest）
* Director Integration with a UIKit view：
* Director Scene Landscape：场景布局
* Director Scene Management：管理场景（runWithscene, pushScene, popScene, replaceScene, end, pause, resume, stopAnimation,startAnimation,drawScene）

### 属性

* runningThread：cocos2d线程
* runningScene：当前正在运行的场景，cocos2d一次只能运行一个场景
* animationInterval：FPS
* displayStats：控制是否显示一些统计信息
* isPaused：控制Director是否暂停
* isAnimating：控制Director是否运行
* projection：设置OpenGL的投影
* totalFrames：从Director开始运行，执行的帧数
* secondsPerFrame：每一帧用时
* deltegate：实现CDirectorDelegate协议的代理对象
* scheduler：调度器
* actionManager：动作管理器
* touchDispatcher：用户触摸操作的处理器

### 查看更多相关代码：

<test/DirectorTest.m>


