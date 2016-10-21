---
layout: post
title: 临时变量管理器
category : 重构
tags : [重构, C++]
date: 2012-05-08 21:00  +0800
---

### 问题

有些变量，它们在特定的情况下才有意义。有些功能需要多步才能完成，结果就需要一些中间变量保存过程的状态，过程结束后变量就失去存在的价值。缺点：

1. 浪费存储空间，虽然内存很廉价，但还是能省则省  
2. 中间变量变多的时候，所在类越来越大，越来越难以理解  

### 解决方案

封装一个中间变量管理器：支持创建、删除、取值、设值这几个操作就行。

**临时变量定义**：

```
class Player
{
public:
     enum TempVariableType
     {
          kTempInvalid,
          kTempTest,
          kTempJumpVerification,
     };
 
     TempVariableManager<Player> tmpvars;
}; 
 
struct JumpVerification
{
     JumpVerification(DWORD x_=0, DWORD y_=0, DWORD mapid_=0) :
          x(x_), y(y_), mapid(mapid_) {}
     DWORD x;
     DWORD y;
     DWORD mapid;
};
 
// 中间变量的定义
define_tempvariable(Player, kTempTest, DWORD);
define_tempvariable(Player, kTempJumpVerification, JumpVerification);

```

**临时变量的使用**：

```
// 新创建
pUser->tmpvars.create<SceneUser::kTempTest>(20);
pUser->tmpvars.create<SceneUser::kTempJumpVerification>(JumpVerification(10,10,101));
 
// 删除
pUser->tmpvars.release(SceneUser::kTempTest);
pUser->tmpvars.release(SceneUser::kTempJumpVerification);
 
// 取值
pUser->tmpvars.get<SceneUser::kTempTest>();
pUser->tmpvars.get<SceneUser::kTempJumpVerification>().x
pUser->tmpvars.get<SceneUser::kTempJumpVerification>().y
 
JumpVerification& jv = pUser->tmpvars.get<SceneUser::kTempJumpVerification>();
jv.x;
jv.y;
 
// 设值
pUser->tmpvars.get<SceneUser::kTempTest>() = 100;
pUser->tmpvars.get<SceneUser::kTempJumpVerification>().x = 100;
JumpVerification& jv = pUser->tmpvars.get<SceneUser::kTempJumpVerification>();
jv.x = 100;
jv.y = 100;

```

