---
title: H5游戏引擎的选择
date: 2018-04-19 20:00:00
category : 游戏开发
tags: []
---

HTML5，新的Web标准在2014年10月份发布，旨在让浏览器上运行的页面内容和互动更加丰富。许多之前需要插件完成的事情，标准都以简洁的形式予以支持。各大浏览器都在近几年都开始支持H5，Chrome、Safari、IE、腾讯等。过去两年基于H5开发的游戏也不胜枚举，放弃了之前的基于Flash的页游方式，如今跨平台跨设备变得更加便捷，加上硬件性能的提升，基于Web的应用和游戏估计会越来越多。

![HTML](/images/html5-2014.png)

<!--more-->

### HTML5为游戏开发提供了什么？


三大核心标准：

- Canvas：画布元素可以使用Javascript脚本动态在其上绘制2D的图形和图像。一些简单的二维游戏可以直接用时Canvas渲染即可。操作Canvas的脚本接口，和Windows下的图像接口GDI非常类似。

- WebGL：WebGL是基于OpenGL ES 2.0制定的硬件图像接口标准，OpenGL ES则是OpenGL嵌入式设备的标准，开放的OpenGL和Windows下DirectX，还有最新的Vulcan都是需要硬件支持的。WebGL标准意味着可以在Web页面中不借助住插件的情况下，使用GPU来绘制2D、3D的图形和图像。这应该是基于H5进行游戏开发的最大福音。

- WebSocket：基于Web的全双工通信方式。之前基于HTTP实现全双工通信，比较麻烦并且低效。有了WebSocket，基于Web的游戏可以非常方便地和游戏服务器进行通信。

其他相关标准：

- WebStorage： 旨在代替之前的Cookie方式，一种新的方式来存储浏览器和网页服务器交互的中间数据，支持全局存储和一次性会话存储。

- GeoLocation ： Web也可以方便地获得设备的地理位置信息，使得基于位置开发LBS的应用和游戏成为可能。

- TouchEvents ： 移动设备多以触屏方式进行操作，H5对其触发的事件也进行了支持。

### H5游戏引擎

#### Egret(白鹭)

北京白鹭是全球最大的HTML5一站式移动技术和服务提供商，致力于为移动互联网全行业提供技术解决方案与服务。截止2017年1月份，白鹭引擎创建的内容占据全行业70%份额，H5游戏全渠道累计排名Top 30，白鹭引擎产品占57%，月流水超过100万的H5游戏，全部由白鹭引擎创建，超过3700款App，采用白鹭H5+原生打包解决方案。

 ![Egret](/images/html5-egret-tools.png)

- Egret Engine：白鹭引擎，遵循HTML5标准的2D引擎及全新打造的3D引擎，解决了HTML5性能问题及碎片化问题，灵活地满足开发者2D或3D游戏的需求，并有着极强的跨平台运行能力。

- Egret Wing：可视化编辑工具，支持主流开发语言与技术的编辑器，通过可视化编辑，提高游戏开发效率，同时支持Node.js开发扩展插件，更好的定制化自有内容。

- DragonBones：动画制作工具，面向设计师的动画创作平台，使用更少的美术成本制作更生动的动画效果。多语言支持，仅需一次制作即可全平台发布。

- Egret Feather：是一款粒子编辑器，各个参数的组合塑造千变万化的效果，为游戏添姿添彩。

- Res Depot：是 Egret 游戏的可视化资源管理工具，能够轻松高效地管理海量游戏素材和配置文件资源。

- Egret-iOS-Support：是将基于 Egret 引擎开发的游戏转换为 iOS APP 的工具。

-  Egret-iOS-Support：是将基于 Egret 引擎开发的游戏转换为 Android APP 的工具。

- Egret Micro Client：微端是一种 H5 游戏的原生打包方案。初始包体小、易推广、存留远超传统，具备多网络启动模式和资源缓存功能，易用的第三方 SDK 接入方案。

- Egret Runtime：HTML5游戏加速器，是一款支持3D的HTML5游戏加速器，解决低端机对HTML5标准支持不佳，体验差的弊端，可以适配不同的系统让HTML5游戏效果媲美原生游戏。


####  LayaAir

Layabox是搜游网络科技（北京）有限公司打造的中国游戏引擎提供商品牌，旗下第二代引擎LayaAir是基于HTML5协议的开源引擎，性能与3D是引擎的核心竞争力。同时支持ActionScript3、JavaScript、TypeScript三种开发语言，并且一次开发同时发布APP（安卓与iOS）、HTML5、微信小游戏、QQ玩一玩等多个平台的游戏引擎。除支持2D\3D\VR\AR的游戏开发外，引擎还可以用于应用软件、广告、营销、教育等领域。

旗下还拥有LayaAirIDE等开发工具链，支持开发者可视化编辑UI、动画、代码编写、打包、多平台发布等，为开发者提供丰富的开发与支撑工具

 ![LayaAir](/images/html5-laya.png)

####  Cocos2d-JS

Cocos2d-X支持基于H5的游戏，使用Javascript编写，貌似大家对Cocos2d开发H5评价一般，懒得介绍了，知道有这货即可。

####  Phaser

一款国外的基于H5（Canvas和WebGL）的游戏引擎，完全开源，可以使用JavaScript或者TypeScript进行开发。快速做一些小游戏也是可以尝试使用的。

 ![Phaser](/images/html5-phaser.png)

### H5渲染引擎

上面列了几个游戏引擎，若技术实力强，为了获取更高的性能或自由度，可以尝试下面的Web渲染引擎。

#### Pixi.js

[PixiJS](http://www.pixijs.com/)是一个快速的轻量级的2D动画渲染引擎，主要使用了WebGL技术，能帮助展示、驱动和管理富有交互性的图形、制作游戏。使用JavaScript以及其他HTML5技术，结合PixiJS引擎，可以创建出丰富的交互式图形，跨平台的应用程序和游戏。

#### Three.js

[Three.js](https://threejs.org/)是一个3D渲染引擎，基于WebGL，对WebGL进行了封装，使得开发基于WebGL的3DWeb应用变得更加简单，效果是相当的炫酷，官网提供了大量的演示代码。

#### Babylon.js

[Babylon.js](https://www.babylonjs.com/)也是一个为构建3D网页游戏而存在的JavaScript渲染引擎，可以体验到H5、WebGL、WebVR和Web Audio技术带来的改变。

### 如何选择？

在了解了众多的H5游戏引擎和渲染引擎，在开发中如何选择了？（**以下仅是本人通过最近几天收集的信息，做出一个初步判断，尚未经过项目验证，慎重采取建议。**）

####  H5游戏引擎 vs H5渲染引擎？

游戏引擎包含的功能会更多，成熟的游戏引擎更会包括一系列的工具，渲染只是游戏引擎的一部分。部分游戏引擎由于封装，渲染性能一般会低于专业的渲染引擎。

- 要快速开发，选择游戏引擎准没错。
- 要更多的自由度和性能，选成熟的渲染引擎。（前提：需要一定的技术实力、同时周期也会比较长）

#### 渲染引擎的选择？

- 2D游戏，选Pixi.js。
- 3D游戏，Three.js和Babylon.js都可以。
- 若觉得渲染引擎封装的不行或者满足不了，那你可以基于WebGL自行编写。（前提：你真的是闲的蛋疼）

#### 游戏引擎的选择？

- Cocos2d-JS，不看了直接放弃。
- Egret，快速开发一个2D的游戏，拥有丰富的工具级，性能稍微比LayaAir差点，官方提供了Runtime可以接入，或许会有用，基于Egret做的2D游戏上线产品还是比较多的。3D功能暂时不成熟，慎用。
- LayaAir，主打3D和性能，大概试用了一下Laya的工具，比Egret还是差了不少。

另外附上别人做的一个WebGL 2D渲染引擎性能评测：
https://k8w.github.io/webgl_2d_benchmark/

| 引擎 | PC fps/drawcall | iPhone6 fps/drawcall | 运行时动态合并图集 | 单批次多纹理 |
| --- | --- | --- | --- | --- |
| Pixi.js | 60fps/125dc | 33fps/250dc | 无 | 有 |
| Layaair | 33fps/70dc | 25fps/70dc | 有 | 无
| Egret | 30fps/2000dc | 15fps/2000dc | 无 | 无

经过上面的对比，简单点说：

- **想要快速地开发一款2D H5游戏，选择Egret。**
- **想要快速开发一款3D H5游戏，选择LayaAir。**

至于其他选项，自行斟酌。

### 参考资料

- https://html5gameengine.com/
- https://en.wikipedia.org/wiki/HTML5
- http://phaser.io/
- http://www.pixijs.com/
- https://threejs.org/
- https://www.egret.com/
- https://www.layabox.com/
