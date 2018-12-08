---
title: Linux下的差异和补丁工具
date: 2018-12-08 15:00:00
category : 
tags: []
---

补丁（Patch）是软件生命周期管理的一部分，当软件有BUG需要进行修复，或者新增特性时都可以通过打补丁的形式更新到用户手里。补丁按照作用可以分为N种：修复BUG的叫BUGFIX、解决安全问题的叫安全补丁、等等。软件更新中的补丁文件类型主要是二进制的，补丁也大量用于代码开发过程中，想当年Linux内核的代码主要就是靠社区开发者把修改制作成补丁发给Linus大佬，据说Apache服务器的名字就来自“A Patch”，如今的版本控制软件SVN、Git虽说可以自动完成修改的合并，但其原理也是基于差异和补丁的思想。

![补丁流程](../images/patch-1.png)

补丁是软件、代码、各种更新中非常重要的手段，废话不多说，今天主要介绍一下Linux生成补丁的差异工具（Diff）和打补丁的工具（Patch）：

 - 历史悠久的`diff` 和 `patch`，主要用于制作文本类型的补丁。 
 - 二进制差异和补丁工具`bsdiff` 和 `bspath` 
 - Google的小胡瓜`Courgette`。

<!--more-->

### `diff` 和 `patch`

`diff`和`patch`在代码开发过程中大量使用，用于文本文件。

```c++
#include <iostream>
#include <fstream>

int main()
{
        std::cout << "hello" << std::endl;
}

```

```c++
#include <iostream>
#include <string>

int main()
{
        std::cout << "hello world" << std::endl;
}

```

```bash
diff -u test_v1.0.cpp test_v1.1.cpp > test.patch
```

```c++
--- test_v1.0.cpp       2018-12-08 14:51:39.551061200 +0800
+++ test_v1.1.cpp       2018-12-08 14:47:59.530074200 +0800
@@ -1,7 +1,7 @@
 #include <iostream>
-#include <fstream>
+#include <string>

 int main()
 {
-       std::cout << "hello" << std::endl;
+       std::cout << "hello world" << std::endl;
 }

```

```bash
patch -p0 <test.patch
patch test_v1.0.cpp test.patch
```

```bash
diff -Naur sources-orig/ sources-fixed/ > source.patch

patch -p1 < source.patch
```


### `bsdiff` 和 `bspatch`

```bash
bsdiff oldfile newfile patchfile
bspatch oldfile newfile patchfile

```

```bash
bsdiff 20181101R1_ZT2/release/BillServer  20181109R1_ZT2/release/BillServer  BillServer.patch

real	5m7.083s
user	5m4.776s
sys	0m2.022s


```

```bash
time bsdiff-4.3/bspatch 20181101R1_ZT2/release/BillServer bill BillServer.patch 

real	0m3.225s
user	0m2.694s
sys	0m0.528s
```

```bash
md5sum 20181109R1_ZT2/release/BillServer bill
5f028efba51254d557e0e97e41d89763  20181109R1_ZT2/release/BillServer
5f028efba51254d557e0e97e41d89763  bill
```

```bash
 ll -h 20181109R1_ZT2/release/BillServer 20181101R1_ZT2/release/BillServer BillServer.patch 
-rwxrwxr-x 1 ztgame ztgame 386M 11月  1 17:02 20181101R1_ZT2/release/BillServer
-rwxrwxr-x 1 ztgame ztgame 386M 11月  8 19:15 20181109R1_ZT2/release/BillServer
-rw-rw-r-- 1 ztgame ztgame 5.7M 12月  8 15:18 BillServer.patch
```

### `Courgette`


