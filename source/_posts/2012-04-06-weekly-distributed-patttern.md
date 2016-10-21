---
layout: post
title: 每周一荐：分布式计算的模式语言
category : 每周一荐
tags : []
date: 2012-04-06 01:08  +0800
---

### 书籍：《面向模式的软件架构IV：分布式计算的模式语言》


#### 简介

迄今为止，人们提出的软件开发模式有不少是关于分布式计算的，但人们始终无法以完整的视角了解分布式计算中各种模式是如何协同工作、取长补短的。构建复杂的分布式系统似乎成为了永远也无法精通的一门手艺。本书的出版改变了这一切。

本书是经典的POSA系列的第4卷，介绍了一种模式设计语言，将分布式系统开发中的114个模式联系起来。书中首先介绍了一些分布式系统和模式语言的概念，然后通过一个仓库管理流程控制系统的例子，介绍如何使用模式语言设计分布式系统，最后介绍模式语言本身。

![分布式计算的模式语言](/images/2012-04-06-1.jpg)

使用这一模式语言，人们可以有效地解决许多与分布式系统开发相关的技术问题，如

★ 对象交互

★ 接口与组件划分

★ 应用控制

★ 资源管理

★ 并发与同步

本书从实用角度展示了如何从现有的主要模式中整合出一门全面的模式语言，用于开发分布式计算中间件及应用程序。作为该领域在市场上唯一统揽全局的书，它将给读者带来醍醐灌顶的感觉！

#### 笔记

以前总是困惑自己正在开发的游戏网络通信框架是前人怎么想出来的，看着底层那些乱七八糟的代码，即膜拜又感到不解。看到本书讲的一个模式：Half-Sync/Half-Async 顿时感觉清楚了许多。这本书对于很多模式都讲的不是很细致，只是粗略总结一下，详细的用法和介绍还是要去参考一些《面向模式的软件架构I》、《面向模式的软件架构II》、《设计模式：可复用面向对象基础》。对于网络框架的架构这本书和《面向模式的软件架构II》必备。

下面把书中提及到的分布式相关的模式列举出来：

**从混沌到结构（From Mud To Structure ）**

1. 领域模型（Domain Model）  
2. 分层（Layers）  
3. MVC模式（Model-View-Controller）  
4. PAC模式（Presentation-Abastraction-Control）  
5. 微内核（Microkernel）  
6. 反射（Reflection）  
7. 管道和过滤器（Pipes and Filters）  
8. 共享仓库（Shared Repository）  
9. 黑板（Blackboard）  
10. 领域对象（Domain Object）  

**分布式架构**

1. 消息机制（Messaging）  
2. 消息通道（Message Channel）  
3. 消息端点（Message Endpoint）  
4. 消息转换器（Message Translator）  
5. 消息路由（Message Router）  
6. 发布-订阅者（Publisher-Subscriber）  
7. 代理者（Broker）   
8. 客户端代理（Client Proxy）  
9. 请求者（Requestor）  
10. 调用者（Invoker）  
11. 客户端请求处理（Client Request Handler）  
12. 服务端请求处理（Server Request Handler）  


**事件分派（Event Demultiplexing and Dispatching）**

1. Reator  
2. Proator  
3. Acceptor-Connector  
4. Asynchronous Completion Token  

**接口划分（Interface Partitioning ）**

1. Explicit Interface  
2. Extension Interface  
3. Introspective Interface  
4. 动态调用接口（Dynamic Invocation Interface）  
5. 代理（Proxy）  
6. 业务委托（Business Delegate）  
7. 外观模式（Facade）  
8. 复合方法（Combined Method）  
9. 迭代器（Iterator）  
10. 枚举方法（Enumeration Method）  
11. 批处理方法（Batch Method）  

**组件划分（Component Partitioning）**

1. 封装实现（Encapsulated Implementation）  
2. 整体-部分（Whole-Part）  
3. 组合模式（Composite）  
4. 主从模式（Master-Slave）  
5. Half-Object plus Protocol  
6. Replicated Component Group  

**应用控制（Application Control）**

1. 页控制器（Page Controller）  
2. 前端控制器（Front Controller）  
3. 应用控制器（Application Controller）  
4. 命令处理器（Command Processor）  
5. 模板视图（Template View）  
6. 转换视图（Transform View）  
7. 防火墙代理（Firewall Proxy）  
8. 授权（Authorition）  

**并发（Concurrency）**

1. Half-Sync/Half-Async  
2. Leader/Followers  
3. Active Object  
4. Monitor Object  

**同步（Synchronization）**

1. 守护挂起（Guarded Suspension）  
2. Future  
3. 线程安全接口（Thread-Safe Interface）  
4. 双检查锁（Double-Checked Locking）  
5. 策略锁定（Strategized Locking）  
6. 范围锁定（Scoped Locking）  
7. 线程指定存储（Thread-Specific Storage）  
8. 复制值（Copied Value）  
9. 常量值（Immutable Value）  

**对象交互（Object Interaction）**

1. 观察者（Observer）  
2. 双分配（Double Dispatch）  
3. 中间者（Mediator）  
4. 命令模式（Command）  
5. 备忘录模式（Memento）  
6. 环境对象（Context Object）  
7. 数据传输对象（Data Transfer Object）  
8. 消息（Message）  
 
**适配和扩展（Adaptation and Extension）**

1. 桥接模式（Bridge）  
2. 对象适配器（Object Adapter）  
3. 责任链（Chain of Responsibility）  
4. 解释器（Interpreter）  
5. 插入器（Interceptor）  
6. 访问者（Visitor）  
7. 修饰模式（Decorator）  
8. Execute-Around Object  
9. 模板方法（Template Method）  
10. 策略模式（Strategy）  
11. 空对象（NULL Object）  
12. 封装外观（Wrapper Facade）  
13. Declarative Component Configuration  

**模态行为（Modal Behavior）**

1. 状态对象（Objects for States）  
2. 状态方法（Methods for States）  
3. 状态集合（Collections for States）  

**资源管理（Resource Management）**

1. 容器（Container）  
2. 组件配置（Component Configurator）  
3. 对象管理器（Object Manager）  
4. 查找（Lookup）  
5. 虚拟代理（Virtual Proxy）  
6. 生命周期回调（Lifecyce Callback）  
7. 任务协调器（Task Coordinator）  
8. 资源池（Resource Pool）  
9. 资源缓冲（Resource Cache）  
10. Layzy Acquisition  
11. Eager Acquisition  
12. Partial Acquisition  
13. Activator  
14. Evictor  
15. Leasing  
16. 自动垃圾回收（Automated Garbage Collection）  
17. 计数句柄（Counting Handle）  
18. 抽象工厂（Abstract Factory）  
19. 构建者（Builder）  
20. 工厂方法（Factory Method）  
21. Disposal Method  

**数据库访问（Database Access）**

1. 数据库访问层（Database Access Layer）  
2. 数据映射（Data Mapper）  
3. 行数据网关（Row Data Gateway）  
4. 表格数据网关闭（Table Data Gateway）  
5. Active Record  

以上模式详细内容还需要更加深入的应用才能很好的掌握。继续学习…



