---
layout: post
title: Kernel. EXPORT_SYMBOL解析
category : Linux
tags : [内核学习]
date: 2009-04-01 23:04:00 +0800
---

### Code Segment：
 
```

include/module.h:
 
struct kernel_symbol 
{
    unsigned long value;   
    const char *name;
};
 
/* For every exported symbol, place a struct in the __ksymtab section */
#define __EXPORT_SYMBOL(sym, sec)               /
    __CRC_SYMBOL(sym, sec)                  /
    static const char __kstrtab_##sym[]         /
    __attribute__((section("__ksymtab_strings")))       /
    = MODULE_SYMBOL_PREFIX #sym;                        /
    static const struct kernel_symbol __ksymtab_##sym   /
    __attribute_used__                  /
    __attribute__((section("__ksymtab" sec), unused))   /
    = { (unsigned long)&sym, __kstrtab_##sym }
#define EXPORT_SYMBOL(sym)                  /
    __EXPORT_SYMBOL(sym, "")
#define EXPORT_SYMBOL_GPL(sym)                  /
    __EXPORT_SYMBOL(sym, "_gpl")
#endif

```
 
### Analysis:
 
1. kernel_symbol: 内核函数符号结构体

	value： 记录使用EXPORT_SYMBOL(fun)，函数fun的地址
	name： 记录函数名称（"fun"），在静态内存中
 
2. EXPORT_SYMBOL(sym) ：导出函数符号，保存函数地址和名称
 
宏等价于：（去掉gcc的一些附加属性,MODULE_SYMBOL_PREFIX该宏一般是"")
 
	static const char __kstrtab_sym[] = "sym";
	static const struct kernel_symbol __ksymtab_sym =
	    {(unsigned long)&sym, __kstrtab_sym }
	 
 
3. gcc 附加属性

__atrribute__ 指定变量或者函数属性。在此查看详细<http://gcc.gnu.org/onlinedocs/gcc-4.0.0/gcc/Variable-Attributes.html#Variable-Attributes>。
 
__attribute((section("section-name")) var : 编译器将变量var放在section-name所指定的data或者bss段里面。
 
很容易看出：EXPORT_SYMBOL(sym)将sym函数的名称__kstrtab_sym记录在，段名为"__kstrtab_strings"数据段中。 将sym所对应的kernel_symbol记录在名为__ksymtab段中。

EXPORT_SYMBOL_GPL(sym) 和EXPORT_SYMBOL不同之处在于sym对应的kenel_symbol记录在__ksymtab_gpl段中。

