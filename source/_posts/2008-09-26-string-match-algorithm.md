---
layout: post
title: 字符串匹配之朴素算法和通配符扩展
category : 算法
tags : [算法, 字符串算法]
date: 2008-09-26 21:19:00 +0800
---

### 字符串匹配

**问题**：给定一个T[1..n],P[1..m] ,T和P中的任意元素属于∑（有限的字符集合），求位移s使得 T[s+1..s+m] = P[1..m].  T 代表 Text(文本串), P代表 Pattern(匹配串)。
 
有多种算法可以实现,这里只介绍最简单,最容易理解,”最笨的” 朴素匹配算法:

	T：t1 t2 ….tn
	P：p1 p2..pm
	其中（m<=n）

最容易想到的就是让P在T上一个字符一个字符的向右滑动，然后比较T的某一段时候和P想匹配，若不匹配，继续向右滑动；否则匹配成功。这样效率比较低，最坏情况下复杂度为theta((n-m+1)*m)。伪代码如下：

	n <- length[T]
	m <- lengthp[P]
	for s=0 to n-m
	     if T[s+1…s+m] = P[1…m]
	           匹配成功，输出s，若只匹配第一个，则可在此退出循环。
	     else
	           继续匹配

对于有限的字符集下（假设个数为d），若果T和P中的字符都随机出现，则平均比较次数为（n-m+1）*(1-d^-m)/(1-d^-1) <= 2(n-m+1)。呵呵,这样看来这个“笨”的算法还算可以，不算很“笨”。

下面给出一种用回溯方法写的代码：（和strstr函数功能相同）

```

int index(const char * str1, const char * str2, size_t pos)
{
       size_t i = pos;
       size_t j = 0;
       while(i < strlen(str1) && j < strlen(str2))
       {
               if(str1[i] ==  str2[j]) // matched then continue
               {
                          ++i;
                          ++j;
               }
               else     // unmatched then backtrace
               {
                   i = i - j + 1;
                   j = 0;
               }
       }
 
       if(j >= strlen(str2))  // matched and return the index
            return i-strlen(str2);
       else
            return -1;  // not found
}

```

举个例子就一清二楚了。

	T =aababcd
	P =abc
 
第1次：
	a a b a b c d
	a

匹配成功,继续下个字符的匹配，第2次：

	a a b a b c d
	a b

匹配失败，回溯，进行第3次：

	a a b a b c d
	- a

匹配成功，继续….
 
归纳下看：

第m次：

先假设数组开始的下标为0。

	T=O O …O O O O O O O
	P=      O O O O …

与P的第一个字符的下标为0，正在匹配的下标为j，此时与P[j]匹配的T的下标是i。

1）  若P[j]与T[i]匹配，则继续下一个字符的匹配，i++，j++。

2）  若P[j]与T[i]失配,  则T的下标回溯到i-j+1,P重新开始（j=0）。

若数组下标不是以0开始的，而是以一开始的，只需回溯到i=i-j+2，j=1即可。


### 扩展

加入匹配字符串中有通配符*，？。

可以匹配多个字符，多个连接在一起的*可以认为是一个，而?只能通配一个字符。则算法可以改进为：
当P[j]是’*’时，求T与P[j+1]

匹配的第一个字符所在的下标，T的下标置为此值。然后继续循环。哈哈，语言描述能力不行啊，还是直接看代码吧：

```

/*
 *decrip:match the string('*' and '?' not included) with pattern including *(se
 *        veral),?(only one)
 *input:
 *    T  --  text 
 *    P  --  Pattern
 *return:
 *     true for exit ,false for not
 *     start,end -- the index of the pattern found in the text 
 */
bool match(const char* T, const char* P, int& start, int& end)
{
    size_t i = 0;
    size_t j =0;
    size_t n = strlen(T);
    size_t m = strlen(P);
    bool bStart = true;
    while(i < n && j < m)
    {
            if(P[j] == '*')   // wildcard ,then find the first position matched with next character 
            {
                    ++j;
                    while('*' == P[j]) // "***..*" <=> "*"
                               ++j;
                    while(T[i] != P[j])
                               ++i;
                    if(i >= n) // finished, no matter matched or not
                         break;
            }
            
            if(T[i] == P[j] || '?' == P[j])
            {
                    if(bStart) // new loop start
                    {
                              start = i;
                              bStart = false;
                    }
                    ++i;
                    ++j;
                    
                    if(j == m) // match finish
                         end = i-1;
            }
            else  // unmatched ,then backtrace(start a new loop)
            {
                static size_t ipp = 0;
                ++ipp;
                i = ipp;
                j = 0;
                bStart = true;
            }
    }
    
    if(j >= m)  // succeeded to find the pattern
    {
         if( '*' == P[0])   // postfix
             start = 0;
         if( '*' == P[m-1]) // prefix
             end = n-1;
         return true;
    }
    else  
        return false;
}
 
```

### 备注

1. 以上内容，朴素算法伪代码参考《算法导论》。
2. 回溯程序是看了一位网上哥们的伪代码写的。
3. 通配符扩展是参考1），2），自己分析写的。

