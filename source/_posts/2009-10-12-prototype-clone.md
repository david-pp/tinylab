---
layout: post
title: Prototype模式去掉Clone方法
category : 设计模式
tags : [设计模式]
date: 2009-10-12 22:02:00 +0800
---

### 意图:

用原型实例指定创建对象的种类，并且通过拷贝这些原型创建新的对象。
 
### 结构图:

![结构图](/images/2009-10-12-1.jpg)
                             
Prototype的主要缺陷是每一个Prototype的子类都必须实现Clone操作，这很烦。
一般都这样实现:

```
 
Prototype* ConcretePrototype::Clone()
{
     return new ConcretePrototype(*this);
}

```
 
### 现在想去掉这个重复的操作

**结构图如下**:

![结构图](/images/2009-10-12-2.jpg)

**实现如下**:
 
```

class PrototypeWrapper
{
     public:
          ~PrototypeWrapper() {}
          virtual Prototype* clone() = 0;
};
 
template <typename T>
class PrototypeWrapperImpl : public PrototypeWrapper
{
     public:
          PrototypeWrapperImpl()
          {
               _prototype = new T();
          }
          virtual Prototype* clone()
          {
               return new T(*_prototype);
          }
     private: 
          T* _prototype;
};

```
 
**使用**:
 
```

PrototypeWrapper* prototype = new PrototypeWrapperImpl<ConcretePrototype>();
Prototype* p = prototype->clone();

```
