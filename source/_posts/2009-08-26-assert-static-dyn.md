---
layout: post
title: 编译时断言和运行时断言
category : Linux开发
tags : [boost]
date: 2009-08-26 18:15:00 +0800
---

通常为了检测一些条件，我们往往在程序里面加断言。一般只在DEBUG版有效，RELEASE版断言不生成任何代码。C++可以使用两种断言: 静态断言和动态断言，即就是运行期断言和编译期断言！顾名思义，运行期断言是在程序运行过程中判断指定的条件，若条件满足，万事OK，若断言失败，则程序给出提示然后被abort掉；编译期断言是在编译时候检查条件是否满足，不满足情况下，编译器给出错误提示(需要人为实现)，只要条件不成立，程序是编译不过的。静态断言，BOOST库有实现(boost/static_assert.hpp)，主要原理就是根据"sizeof(不完整类型)"会报错。动态断言在cassert库文件有实现。实现如下:
 
### 动态断言:（cassert）
 
```

#ifdef NDEBUG
 
// 不做任何处理
#  define assert(expr)   
 
#else
 
// __assert_failed 打印错误消息(包含表达式串，文件，所在行，所在函数名)，然后abort()。
#  define assert(expr)  ((expr) ? 0 : __assert_failed(__STRING(expr),  __FILE__,  __LINE__, __PRETTY_FUNCTION__, 0))  
 
#endif

```
 
### 静态断言:(boost/static_assert.hpp)
 
``` 

template <bool x> struct STATIC_ASSERTION_FAILURE;
 
template <> struct STATIC_ASSERTION_FAILURE<true> { enum { value = 1 }; };
 
template<int x> struct static_assert_test{};
 
#define BOOST_STATIC_ASSERT( B ) /
    typedef ::boost::static_assert_test</
    sizeof(::boost::STATIC_ASSERTION_FAILURE< (bool) (B) >)
    >  boost_static_assert_typedef_
 
// 当B为false时，sizeof(STATIC_ASSERTION_FAILURE<false>)，STATIC_ASSERTION_FAILURE<false>)没有实现(不能实例化)，为不完整类，编译器报错！

```
 
注意：和动态断言不同的是，静态断言可以在名称空间，类，函数，模板(函数模板和类模板)中使用，因为他用的是typedef。
 
静态断言的详细用法，查看：<http://www.boost.org/doc/libs/1_39_0/doc/html/boost_staticassert.html>

