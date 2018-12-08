---
title: Linux下的差异和补丁工具
date: 2018-12-08 22:00:00
category :
tags: []
---

补丁（Patch）是软件生命周期管理的一部分，当软件有BUG需要进行修复，或者新增特性时都可以通过打补丁的形式更新到用户手里。补丁按照作用可以分为N种：修复BUG的叫BUGFIX、解决安全问题的叫安全补丁、等等。软件更新中的补丁文件类型主要是二进制的，补丁也大量用于代码开发过程中，想当年Linux内核的代码主要就是靠社区开发者把修改制作成补丁发给Linus大佬，据说Apache服务器的名字就来自“A Patch”，如今的版本控制软件SVN、Git虽说可以自动完成修改的合并，但其原理也是基于差异和补丁的思想。

![补丁流程](/images/patch-1.png)

补丁是软件、代码、各种更新中非常重要的手段，废话不多说，今天主要介绍一下Linux生成补丁的差异工具（Diff）和打补丁的工具（Patch）：

 - 历史悠久的`diff` 和 `patch`，主要用于制作文本类型的补丁。
 - 二进制差异和补丁工具`bsdiff` 和 `bspath`
 - Google的小胡瓜`Courgette`。

<!--more-->

### `diff` 和 `patch`

`diff`和`patch`在代码开发过程中大量使用，用于文本文件。就以代码为例做下简单演示：

假设有文件test.cpp内容如下（暂且叫它为test_v1.0.cpp）：

```c++
#include <iostream>
#include <fstream>

int main()
{
        std::cout << "hello" << std::endl;
}

```

经过一次修改后，内容如下（修改后的文件内容如test_v1.1.cpp）：

```c++
#include <iostream>
#include <string>

int main()
{
        std::cout << "hello world" << std::endl;
}

```

**制作补丁：**

```bash
diff -u test_v1.0.cpp test_v1.1.cpp > test.patch
```

生成的补丁内容如下，看着是不是很眼熟，`svn diff`和`git diff`差不多也长这样：

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

**打补丁，下面任何一条命令都可以，执行完就把test_v1.0.cpp的内容更新到和test_v1.1.cpp完全一样了：**

```bash
patch -p0 <test.patch
patch test_v1.0.cpp test.patch
```

PS. 文件夹之间也可以直接做差异，示例如下：

```bash
diff -Naur sources-orig/ sources-fixed/ > source.patch
patch -p1 < source.patch
```

不要问我这些命令参数到底是什么意思，自行`--help`或者google！

### `bsdiff` 和 `bspatch`

虽说`diff`和`patch`也可以用来对二进制文件进行差异，但生成的差异文件太大，效果一般。对于二进制文件要进行差异，有一对更好用的工具`bsdiff`和`bspatch`，这两个工具在Googe Chromium自动更新中使用，代码简单而强悍，很容易嵌入到自己的工程。

两个命令的用法如下：

```bash
bsdiff oldfile newfile patchfile  
bspatch oldfile newfile patchfile
```

- **bsdiff** - 对oldfile和newfile进行差异，生成补丁文件patchfile。bsdiff是比较费内存的，需要大概max(17*n,9*n+m)+O(1)字节（其中：n是oldfile的大小，m是newfile的大小），时间复杂度为O((n+m) log n)，对于大文件还是挺花时间的，不过一般情况下制作补丁是在软件开发者手里进行的，只要保证打补丁的过程速度够快，问题也不大。

- **bspatch** - 对oldfile打补丁patchfile，生成newfile。bspatch对内存的需求是n+m+O(1)字节，时间复杂度为O(n+m)，速度不错。

下面就以一个游戏服务器可执行文件为例，大小大概为386M：

**差异下制作二进制补丁：**

```bash
time bsdiff 20181101R1/BillServer  20181109/BillServer  BillServer.patch

real	5m7.083s
user	5m4.776s
sys	0m2.022s
```

在比较强力的服务器上面竟然用了5分钟。看下生成的结果：

```bash
 ll -h 20181101R1/BillServer  20181109/BillServer  BillServer.patch BillServer.patch
-rwxrwxr-x 1 ztgame ztgame 386M 11月  1 17:02 20181101R1/BillServer
-rwxrwxr-x 1 ztgame ztgame 386M 11月  8 19:15 20181109/BillServer
-rw-rw-r-- 1 ztgame ztgame 5.7M 12月  8 15:18 BillServer.patch
```

好在补丁内容是非常小只有5.7MB，毕竟时间不久，两个版本之间的差异还没有多大。

**打补丁：**

```bash
time bsdiff-4.3/bspatch 20181101R1/BillServer BillServer BillServer.patch

real	0m3.225s
user	0m2.694s
sys	0m0.528s
```

速度很快，完全可以接受。验证下结果，没啥问题：

```bash
md5sum 20181109R1/BillServer BillServer
5f028efba51254d557e0e97e41d89763  20181109R1_ZT2/release/BillServer
5f028efba51254d557e0e97e41d89763  BillServer
```

可以看到对游戏服务器版本的更新，采用二进制差异进行会更快：更小的网络中转、更快的补丁时间。

### `Courgette`

上面提到Google这帮大神，在做Chrom自动更新时，选择了`bsdiff`和`bspatch`方案，但他们还不满足于此，还是觉得`bsdiff`生成的补丁有些大，要做到极致，最后自行开发了一套差异和补丁机制`Courgette`，特别时对代码生成文件效果极佳。

一般，使用`bsdiff`大概过程是这样的：

```
    server:
        diff = bsdiff(original, update)
        transmit diff

    client:
        receive diff
        update = bspatch(original, diff)
```

`Courgette`另辟蹊径，有些时候我们修改一两行代码，生成的可执行文件的差异会很大，但是源码其实时没有多大差异的，于是先进行反编译，然后对反编译的汇编代码进行调整（这步是最关键的），最终使用汇编代码进行差异。大概过程如下：

```
server:
    asm_old = disassemble(original)
    asm_new = disassemble(update)
    asm_new_adjusted = adjust(asm_new, asm_old)
    asm_diff = bsdiff(asm_old, asm_new_adjusted)
    transmit asm_diff

client:
    receive asm_diff
    asm_old = disassemble(original)
    asm_new_adjusted = bspatch(asm_old, asm_diff)
    update = assemble(asm_new_adjusted)
```

下面是Google的对比数据：

```
完整更新	 10,385,920
bsdiff更新    704,512
Courgette更新	      78,848
```

效果还是很明显的，其实不光对于可执行文件，普通二进制`Courgette`也是可以搞定的。不细说了，有兴趣的直接看参考资料里面的链接。`Courgette`并没有进行实测，它的代码位于Chromium项目，需要自行进行编译，时间原因了解下即可，若那天要用一定要尝试下。

### 参考资料

- https://opensource.com/article/18/8/diffs-patches
- http://www.daemonology.net/bsdiff/
- http://dev.chromium.org/developers/design-documents/software-updates-courgette
