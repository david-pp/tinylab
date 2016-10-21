---
layout: post
title: 编码之道：结构体 vs. 对象
category : 编码之道 
tags : [编码规范,重构]
date: 2015/03/15 06:37  +0800
--- 

在编程中，现实中的事物及其组织，需要用数据抽象来表示。在C++语言中，既可以使用使用过程式的struct来做数据抽象，同时也可以使用面向对象的class来做抽象。在语言层面上，struct和class除了默认访问权限不一样，其它都是一样，但本文中区别对待之，一般使用struct时代表的是数据，Plain Of Data，即就是所谓的POD类型，可以直接存档和在网络上传输。而class代表的是对象的类，支持面向对象中的各种用法。

<!--more-->


### 1. 数据的抽象

**结构体(struct实例)**：面向过程式的做法，C语言对数据的抽象都是采用这种方式，定义好结构体，同时有一堆操作相应结构体的函数。随便翻开用C写的代码，比比皆是。但要注意，C语言中的struct没有访问限制，把结构体的构造（成员函数）全部暴露给了使用者，这是有好处的，但在面向对象中违反了信息隐藏。

特点：

- 暴露数据实现
- 行为可以使用外置函数提供

如：

``` c
struct Point {
   int x;
   int y;
};
```

**对象(class实例)**：面向对象式的做法，面向对象讲究信息隐藏，面向接口编程，隐藏实现细节。比如下面的Point类，使用者只需要知道它是一个“点”，支持两种坐标系形式：直角坐标和极坐标，且有相应的成员函数可以使用，根本不用关心成员变量是什么，或怎么样来组织。

特点：

- 隐藏数据实现
- 暴露行为接口

如：

``` c
class Point {

public:
     int getX();
     int getY();
     void setByCartesion(int x, int y);

     int getR();
     int getTheta();     
     void setByPolor(int r, int theta);

// God knows the following.. who cares?    
private:
     int x_; 
     int y_;
};
```


### 2. 反对称性

上面的两种数据抽象方式，其实有个有意思的特性，可以称之为反对称性：

> 过程式的struct容易添加新的函数，缺难于修改成员变量；而对象式的class容易修改成员变量，却难于添加新函数。


#### 2.1 过程式

针对下面的代码思考下面的问题：

- Shape增加一个计算周长的函数?
- Shape增加一种新类型?

``` c
struct Shape
{
   int type;
   union {
      Point  rect;
      double radius;
   };
};

double caclArea(Shape* shape)
{
  switch (shape->type)
  {
      case RECT:   
        return shape->rect.width*shape->rect.height;
      case CIRCLE: 
        return shape->radius*shape->radius*3.14;
  }
}
```

你会发现，Shape把所有细节了类型全部暴露给你，你需要添加一个计算周长的函数，只需要添加一个函数即可。如下：

``` c
double caclLength(Shape* shape)
{
  switch (shape->type)
  {
      case RECT:   
        return 2*(shape->rect.width+shape->rect.height);
      case CIRCLE: 
        return 2*shape->radius*3.14;
  }
}
```

再思考第二个问题，假设要添加一种新类型椭圆（ELLIPSE），或者修改Shape中某个变量的名字，这个时候你会发现问题来了，加一种新类型，几乎所有相关函数都要修改，如果使用了此结构体相关的函数非常多的时候，那问题就更大了。

#### 2.2 对象式

针对下面的代码，同样思考上面的问题：

- Shape增加一个计算周长的函数?
- Shape增加一种新类型?


``` c
class Shape {
public:
   virtual double caclArea();
};

class Squre : public Shape {
public:
   double caclArea(){ return width_ * height_;}
private:
   double width_;
   double height_:
};

class Circle : public Shape {
public:
   double caclArea(){ return 3.14*radius_* radius_;}
private:
   double radius_;
};
```

先考虑第一个问题，增加一个计算周长的函数，或者修改calcArea的名字，当有很多Shape的子类的时候，你会发现也是很麻烦的一件事情，几乎相关的类都需要改动。

但是对于第二个问题，修改Shape的实现或者增加一种新类型椭圆（ELLIPSE），仅需要添加一个子类，或者修改部分代码就OKAY了。


### 3. 做出选择

通过上面的分析，根据实际情况，合理使用过程式抽象或者对象式抽象。

过程式适合：

- 结构相对固定
- 行为变化较大
- 如:Point, Time, ...等结构相对固定的数据，或者存档，网络传输中使用。

对象式适合：

- 行为相对固定
- 经常会添加新类型

最后记住：避免混合使用，弄出来个四不像，使用者苦不堪言！！
