---
layout: post
title: 编码之道：小函数的大威力
category : 编码之道 
tags : [编码规范,重构]
date: 2015/02/12  21:05  +0800
--- 

> 一屏之地，一览无余！对的！要的就是短小精悍！

翻开项目的代码，处处可见成百上千行的函数，函数体里面switch-case、if、for等交错在一起，一眼望不到头的感觉。有些变态的函数，长度可能得按公里计算了。神啊，请赐予我看下去的勇气吧！先不论逻辑如何，首先这长度直接就把人给吓到了。这些超大号函数是怎么来得呢？

<!--more-->

* 直接从别处COPY一段代码，随便改改即可，造成大量重复代码。
* 缺少封装，甚至说就没有封装，完全就是随意乱加一气，造成各个抽象层次的代码混合在一起，混乱不堪。
* 成篇的异常处理和特殊处理，核心逻辑或许就是函数体开头、中间或结束那么几行而已。

这些超长的函数，给我们造成了很大的麻烦：阅读代码找BUG几乎是不可能的事情，没有调试器估计撞墙的心都有了；重复代码造成修改困难，漏掉任何一处迟早是要出问题的；各个层次的代码混在一起，阅读代码相当吃力，人的临时记忆是有限的，不断在各个层次之间切换，一会儿就给绕晕了。

解决这些问题最重要的就是要保持函数的短小，短小的函数阅读起来要好得多，同时短小的函数意味着较好的封装。下面谈谈关于函数，应该遵循的一些原则：


### 1. 原则:取个描述性的名字

* 取个一眼就看出函数意图的名字很重要
* 长而具有描述性的名称，要比短而让人费解的好（长度适中，也不能过分长）
* 使用动词或动词+名词短语

在[编码之道：取个好名字](/posts/zoc-cleancode-2/)中已经介绍过，好名字的重要性，不再赘述。


### 2. 原则:保持参数列表的简洁

* 无参数最好，其次一元，再次二元，三元尽量避免
* 尽量避免标识参数
* 使用参数对象
* 参数列表
* 避免输出和输入混用，无法避免则输出在左，输入在右

``` c
bool isBossNpc();
void summonNpc(int id);
void summonNpc(int id, int type);
void summonNpc(int id, int state, int type); // 还能记得参数顺序吗？

void showCurrentEffect(int state, bool show); // Bad!!!
void showCurrentEffect(int state); // Good!!
void hideCurrentEffect(int state); // 新加个函数也没多难吧？

bool needWeapon(DWORD skillid, BYTE& failtype); // Bad!!!
```

### 3. 原则:保持函数短小

* 第一规则：要短小
* 第二规则：还要更短小
* 要做到“一屏之地，一览无余”更好

### 4. 原则:只做一件事

* 函数应该只做一件事，做好这件事
* 且只做这一件事

### 5. 原则:每个函数位于同一抽象层级

* 要确保函数只做一件事，函数中的语句都要在同一个抽象层级上
* 自顶下下读代码

### 6. 原则:无副作用

* 谎言，往往名不副实

### 7. 原则:操作和检查要分离

* 要么是做点什么，要么回答点什么，但二者不可兼得")
* 混合使用---副作用的肇事者

### 8. 原则:使用异常来代替返回错误码

* 操作函数返回错误码轻微违法了操作与检查的隔离原则
* 用异常在某些情况下会更好点
* 抽离try-cacth
* 错误处理也是一件事情，也应该封装为函数

``` c
bool RedisClient::connect(const std::string& host, uint16_t port)
{
	this->host = host;
	this->port = port;
	this->close();
	
	try 
	{
		redis_cli = new redis::client(host, port);
		return true;
	}
	catch (redis::redis_error& e) 
	{
		redis_cli = NULL;
		std::cerr << "error:" << e.what() << std::endl;
		return false;
	}

	return false;
}
```

### 9. 原则:减少重复代码"

> 重复是一些邪恶的根源！！！

### 10. 原则:避免丑陋不堪的switch-case

* 天生要做N件事情的货色
* 多次出现就要考虑用多态进行重构

**BAD:**

``` c
bool saveBinary(type, data) {
   switch (type) {
     case TYPE_OBJECT:
           ....
          break;
     case TYPE_SKILL:
           ...
          break;
     ....
   }
}
bool needSaveBinary(type) {
   switch (type) {
     case TYPE_OBJECT:
          return true;
     case TYPE_SKILL:
           ...
          break;
     ....
   }
}
```

``` c

class BinaryMember
{
  BinaryMember* createByType(type){
   switch (type) {
     case TYPE_OBJECT:
          return new ObjectBinaryMember;
     case TYPE_SKILL:
          return new SkillBinaryMember;
     ....
  }

  virtual bool save(data);
  virtual bool needSave(data);
};

class ObjectBinaryMember : public BinaryMember
{
   bool save(data){
       ....
   }
   bool needSave(data){
       ....
   }
};")))

```

### 最后

上面提到的原则，若要理解的更加深刻，建议去阅读《代码整洁之道》，里面有许多详尽的例子，对于写过几年代码的人来说，总会发现一些自己所在项目经常犯的毛病。

知道了这些原则，我们应该这样做:

**当在添加新函数的时候：**

- 刚下手时违反规范和原则没关系
- 开发过程中逐步打磨
- 保证提交后的代码是整洁的即可

**重构现有的函数，有下面情况的，见一个消灭一个：**

- 冗长而复杂
- 有太多缩进和嵌套循环
- 参数列表过长
- 名字随意取
- 重复了三次以上



