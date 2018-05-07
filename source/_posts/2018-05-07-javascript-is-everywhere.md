---
title: 无处不在的JavaScript
date: 2018-05-05 21:00:00
category : 游戏开发
tags: []
---

整天埋头于C++之中，熟不知JavaScript这一脚本语言竟然发展如此迅速。话说，当年Brendan Eich大神在1995年，用了10天时间设计了JavaScript语言初版，作为胶水语言运行在Netscape的浏览器上，这货天生就是用来做网页开发的。自从Google的v8解析引擎之后，Chrome浏览器瞬间碾压群雄，各大浏览器厂商不得不对自己的JavaScript引擎进行升级，如今跑起来都是溜的飞起。Node.js更是不得了，使得JavaScript可以摆脱浏览器独立运行，使得这一门脚本语言变得无所不能，甚至都可以用来开发显卡驱动层。

<!--more-->

### 1.语言标准

- 浏览器端支持的JavaScript主要包含了三部分：ECMAScript、DOM、BOM。ECMAScript是语言的标准，对语言进行规范化；DOM是文档对象模型，规范化页面内容的访问和操作；BOM最浏览器对象模型，操作和访问浏览器窗口对象，比如历史记录、前进、回退等。ECMAScript近几年特别活跃，使得JavaScript语言的特性有比较大的改变，让这门基于原型的脚本语言变得更加通用和便捷。ES6引入了类、模块等语义，使得面向对象变得更加便捷。

  ![JavaScript标准化](/images/js-timeline2.png)

  各大浏览器厂商也在不断跟进语言标准。当前比较安全的是ES5，ES6大部分特性可用。

  ![JavaScript](/images/js-browsers.png)

- CommonJS是非浏览器环境的规范，Node.js采用了该规范设计自己的模块系统。

  ![CommonJS](/images/js-common-js.png)

### 2.用途

得益于语言标准化、高性能的解析引擎和Node.js。JavaScript变的无所不能，前后端通吃。看下面流行的JS框架，是不是有种欲罢不能心情，JS的坑也不再仅仅是玩玩Web页面了，深似海的感觉。

  ![JavaScript](/images/js-frameworks.jpg)

如今的JS，可以用来开发运行在各种各样设备上的应用。最大的好处就是一次开发，任意平台上面运行。

- Web应用：运行于浏览器的应用，当然手机浏览器也是自适应支持的。最近热门的前端框架有Google的Angular，FaceBook的React，出自中国尤雨溪同学只手的Vue.js等，基于这些现代化的框架，开发出的页面或应用都超级方便和高效。

- 手机应用：手机原生应用（Native），打包成iOS、Andriod的包直接运行。Apache的Cordova，FaceBook的React Native，都可以作为一个非常好的起点。

- 桌面应用：当前正在使用的文本编辑器Atom、和大名鼎鼎的VS Code都是用JavaScript写的，不知道的同学可能要吓掉大牙了，它们都是基于Electron开发的。使用Electron开发的桌面应用，自带跨平台、热更新、安装包等功能。

- 服务器端开发：Node.js如今的npm包不计其数，用来进行后台开发也是轻车熟路。甚至用来写一个简单的MMORPG游戏后台也是可以的，如网易的Pomelo游戏服务器框架。

### 3.未来

如今JavaScript已无处不在，将来应用场景会越来越多，基于Web开发的应用会遍地开花。因为：

- HTML5标准的普及。
- ES标准不断的迭代，语言本身不断在完善。当前要想使用新特性，还有一门TypeScript可选。
- Node.js社区不断的发展壮大。
- 解析引擎越来越高效，WebAssembly现已变成现实。
- 硬件性能的提升，使得开发效率变的尤为重要，为此放弃一些性能损失也是值得的。

若要开发系统级的，大规模的、高性能的应用请绕行，如今这货不适合。

### 4.小结

> 人最可怕的是，被自己当前岗位职责和工作内容蒙蔽了双眼而不自知。

作为一名技术人，不要局限于自己当前的岗位职责。谁说做后台开发就不能研究下前端技术？谁说写逻辑的游戏程序员就不能研究下引擎？往往下结论的哪个人是你自己。

在不同的语言、技术中学习和贯通，也是另外一翻乐趣。不设限、不逾矩。


![JavaScript](/images/js-tobe.png)
