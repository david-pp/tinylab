---
title: Linux下的文件打包和压缩
date: 2016-11-11 15:05:48
category : 工具
tags: [Linux, 工具]
---

为什么要整理一下Linux下的打包和压缩工具呢？原因很简单，因为遇到问题了：**游戏服务器可执行文件、配置和各种资源文件有4G多，每次在做版本的时候，编译完打包压缩要用掉10分钟多**。我在上篇[C++构建系统选择](/2016/10/28/build-system/)里面有提到过，200万行的代码编译用时不到10分钟，而现在一个简单的打包压缩竟然占用了10分钟，虽说这个步骤日常开发过程中很少操作，但每次凌晨做版本的时候，由于需求的变更，需要不断地构建、打包、压缩。做版本的同学苦不堪言，所有开发人员也得等着，这样浪费大家宝贵的时间是极度可耻的！

遇到问题就要解决问题，问题解决了如果不记下来，下次遇到了又得去折腾了。下面进入正题。

虽说打包和压缩的原因各种各样，最重要的目的就是：**减少文件的体积，从而节约磁盘空间和网络带宽**。压缩文件的时候，最注重两个因素：**速度**和**压缩比**。慢如蜗牛还是快如闪电？当然选择越快越好、压缩比越高越好。但是鱼与熊掌不可兼得，往往压缩比高的算法，需要的计算量就比较大，花费的时间就比较多。有没有加速的办法呢？

下面我会介绍一下我所熟知的Linux下的打包压缩工具，并做下对比，给出建议。上面遇到的问题，最后也会给出解决方法。

<!--more-->

### 打包和压缩工具概览

#### 打包命令

Linux下的打包命令是`tar`，意思是：Tape Archiver。在计算机远古时代，打包后的文件会写到磁带（Tape）里面，所以才有了`tar`。而打包往往伴随着压缩，于是`tar`命令本身也支持多种压缩方式。

Linux下还有一个与此非常相似的命令`ar`，意思是：Archive。同为打包有啥区别了？
一般`ar`是用来打包目标文件生成静态库`.a`文件的，基本上不会用于普通文件的打包。

#### 压缩命令

下面会对Linux下常见的压缩命令：`zip, gzip, bzip2, xz, 7za`进行对比。结果如下表：

命令   | 发布时间 |  压缩算法             | 压缩用时 | 解压用时 | 压缩后的大小
------|----------|-------------------| -------    |------      | ------
zip     | 1990      | DEFLATE              |  2m43s   | 2m15s   | 796MB
gzip   | 1993      | DEFLATE              |  2m34s   | 32s        | 796MB
bzip2 | 1996      | Burrows-Wheeler |  9m20s   | 2m1s     | 660MB
xz      | 2009      | LZMA,LZMA2      |  28m31s | 1m3s     | 474MB
7za    | 1999      | LZMA,LZMA2      |  1m51s   | 52S       | 487MB


数据测试文件`game.tar`，大小为4G左右。下面为测试脚本：

``` bash
tarfile=game.tar

echo "-------zip"
time zip $tarfile.zip $tarfile;
rm $tarfile
ls -lh $tarfile.zip
time unzip $tarfile.zip

echo "--------gzip"
time gzip $tarfile
ls -lh $tarfile.gz
time gzip -d $tarfile.gz

echo "--------bzip2"
time bzip2 $tarfile
ls -lh $tarfile.bz2
time bzip2 -d $tarfile.bz2

echo "--------xz"
time xz $tarfile
ls -lh $tarfile.xz
time xz -d $tarfile.xz

echo "--------7za"
time 7za a $tarfile.7z $tarfile
rm $tarfile
ls -lh $tarfile.7z
time 7za e $tarfile.7z
```

"压缩用时"、"解压用时"和"压缩后的大小"是用`game.tar`进行测试的。测试的机器CPU是32核，型号为：`Intel(R) Xeon(R) CPU E5-2670 @ 2.60GHz`。


### 文件压缩


#### gzip

官方首页：http://www.gzip.org/

gzip, GNU的zip，是Linux的经典压缩工具，压缩后的文件后缀是`.gz`。采用的算法也是DEFLATE，该算法广泛应用于PNG图像、HTTP协议、SSH等。最大的优势就是速度快，压缩比还不错，几乎所有Linux系统都有安装gzip。

gzip压缩后的文件大小和`.zip`也差不多，压缩时间和`zip`相差不大，但解压缩的速度要明显高于`zip`。在Linux一般通过`tar`调用，很少直接使用。

压缩：

``` bash
gzip game.tar   # 压缩文件
gzip -r  dir   # 目录下的所有文件进行递归压缩（目录下的所有文件都会生成.gz文件）
```

解压缩：

``` bash
gzip -d game.tar.gz
```

#### bzip2

官方首页： http://www.bzip.org/

bzip2也是Linux系统常见的压缩方式，压缩后的文件后缀为`.bz2`。bzip2，基于[Burrows–Wheeler algorithm](https://en.wikipedia.org/wiki/Burrows%E2%80%93Wheeler_transform)，可以将文件压缩至10%-15%，解压用时比压缩用时快2-6倍。

gzip和bzip2实现算法不同，决定了它们各有优缺点：**bzip2有比较高的压缩比，相应的压缩用时也要久一些，占用的系统内存也更大；gzip最大的优势就是压缩解压速度快，压缩比稍逊于bzip2。**

压缩：

``` bash
bzip2 file
```

解压缩：
``` bash
bzip2 -d file.bz2
```

#### xz

官方首页：http://tukaani.org/xz/

xz是一个相对新的压缩命令，第一版是2009年发出来的。使用了LZMA2算法，该算法有这比高的压缩比，特别适用于对存储或带宽有严格要求的场景下，为了高的压缩比，压缩时间也是大大增加。

xz对压缩比和用时也提供了权衡的选项：

> -0 ... -9               压缩预设，默认为6。
>-e, --extreme      使用更多的CPU时间提高压缩比

压缩：

``` bash
xz file
```

解压缩：

``` bash
xz -d file.xz
```

PS. 使用xz时，要注意有些旧版本的Linux操作系统本身不支持，需要安装后才能使用。

#### zip

官方首页：http://www.info-zip.org/mans/zip.html

`zip`用于压缩，`unzip`用于解压缩，生成的文件格式是`.zip`。非常古老的压缩方式，压缩比比较低，好处就是由于古老，所以基本上是个操作系统都会默认对此进行支持。

虽然zip和gzip使用的算法都是基于DEFLATE，但具体文件格式是不一样的，所以`.zip`和`.gz`文件是不兼容的。zip很少在Linux下使用，Linux下直接用`gzip`即可，多数情况都是其他平台下生成的`.zip`在Linux系统下面解压一下。

zip、7z和gzip、bzip2、xz还有一点不同的是，zip和7z本身支持打包，其他压缩命令仅是单纯的对单个文件或文件夹递归进行压缩。

压缩：

``` bash
zip squash.zip file1 file2 file3  # 压缩文件
zip -r squash.zip dir1              # 目录打包并压缩
```

解压缩：

``` bash
unzip squash.zip
```

#### 7z

官方首页：http://www.7-zip.org/

7-Zip是一个有着高压缩比的打包压缩工具，提供了多平台（如：Windows、Mac、Linux等）支持，高压缩比也是得益于LZMA和LZMA2算法。上面的测试可以看出，7z和xz都是基于LZMA算法，但时间却天地之差，为何？答案是：7z是多线程的，压缩和解压并行计算。测试用的机器是32核的，在使用7z压缩解压时，CPU利用率达到3000%左右。

p7zip是Linux/Unix下7-ZIP的命令行版，命令是`7za`。7-ZIP并不是单纯的压缩工具，它支持多种压缩格式，在Windows/Mac有界面的系统下还有相应的GUI文件管理器工具支持。

7-ZIP的主要特点：

- High compression ratio in 7z format with LZMA and LZMA2 compression
Supported formats:
- Packing 
    - unpacking: 7z, XZ, BZIP2, GZIP, TAR, ZIP and WIM
    -Unpacking only: AR, ARJ, CAB, CHM, CPIO, CramFS, DMG, EXT, FAT, GPT, HFS, IHEX, ISO, LZH, LZMA, MBR, MSI, NSIS, NTFS, QCOW2, RAR, RPM, SquashFS, UDF, UEFI, VDI, VHD, VMDK, WIM, XAR and Z.
- For ZIP and GZIP formats, 7-Zip provides a compression ratio that is 2-10 % better than 
- the ratio provided by PKZip and WinZip
- Strong AES-256 encryption in 7z and ZIP formats
- Self-extracting capability for 7z format
- Integration with Windows Shell
- Powerful File Manager
- Powerful command line version
- Plugin for FAR Manager
- Localizations for 87 languages

压缩：

``` bash
7za a  game.7z  gamedir
```

解压：

``` bash
7za e game.7z
```

PS. 大多Linux下都没有安装7z，需要手动安装。

### 并行压缩和解压缩

压缩比和执行速度，鱼与熊掌两者兼得，如何做呢？上面也看到了7z利用多线程，执行LZMA算法也是很快就完成的。

开篇提到的问题是否也可以利用并行解决呢？由于各种原因，打包格式只能以`.bz2`的形式发布到运维系统，而`bzip2`的压缩速度实在是不敢恭维。bzip2的压缩过程是否可以并行执行？它的算法和文件格式支持的并行的话还好，不然也就没辙了，Google了一把，大神们已经准备了`pbzip2`，测试了一下，几乎被惊呆了：10min一下子只需要50s（32核E5处理器，4G文件大小）。


下面整理一下gzip、bzip2和xz及其并行版本的对比：

普通 vs. 并行         |  压缩用时                  |  解压用时
-------------------|----------------------|--------------
gzip vs. pigz          | 2m34s  vs. 0m11s    | 0m32s   vs. 0m13s
bzip2 vs. pbzip2    | 9m20s  vs. 0m40s    | 2m01s   vs. 0m12s 
xz  vs. pixz            | 28m31s vs. 1m30s   | 1m03s   vs. 0m6s 

#### pigz

官方首页：http://zlib.net/pigz/

PIGZ – pigz，并行版本的gzip的实现 （Parallel Implementation of GZip），利用多线程来执行压缩，生成的文件和gzip完全兼容。解压缩的算法不可以并行化，为了加速，pigz在解压缩的时候创建了3个线程，主线程负责执行解压缩，其他的负责读写和检查计算，所以 解压缩速度比gzip也要快一些。

输入文件被划分成128KB大小的块并行执行压缩算法，然后按照顺序写到输出文件里，默认的块大小是128KB，也可以通过`-b`选项指定大小。执行压缩的线程数量，默认是机器中所有的CPU核心数量，也可以通过`-p`指定压缩线程的数量。

压缩：

``` bash
pigz game.tar
```0

解压缩：

``` bash
pigz -d game.tar.gz
```

#### pbzip2

官方首页：http://compression.ca/pbzip2/

PBZIP2 – pbzip2，并行版本的bzip2的实现（Parallel implementation of the BZIP2），多线程压缩和解压缩，生成的文件和bzip2兼容，也即是说使用pbzip2生成的`bz2`文件，可以使用`bzip2`进行解压缩，反之亦可。pbzip2的解压过程也是多线程执行的，所以它的解压速度要快于pgiz。

块大小可以通过`-1 ..  -9`或`-b#`来指定，数字分别代表100k .. 900k（默认900k）；线程数量可以通过`-p#`来指定，默认为机器中所有CPU核心。

压缩：

``` bash
pbzip2 game.tar
```

解压缩：

``` bash
pbzip2 game.tar.bz2
```

#### pixz

官方首页：https://github.com/vasi/pixz

pixz，xz的并行和带索引版（Parallel Indexing xz）。xz生成的`.xz`文件生成一大块压缩后的数据，pixz则生成一系列压缩后的可以随机访问的小块集合。pixz这种索引功能对于特别大的tarball文件特别有用，这样从压缩后的文件里面解压部分文件成为可能。比如在备份数据时候，可能10个G的压缩包，但当你使用此包时，仅需要其中的一个文件，xz则需要把10个G解压后取自己想要的文件，而pixz则直接可以指定解压需要的文件，没必要浪费磁盘和CPU。不过要使用索引功能的话，生成的文件后缀为`.tpxz`和`.xz`不兼容的。

pixz和xz完全兼容，pixz的功能是xz的超集。听起来很不错吧！一般系统都不会安装此工具，源码安装时候依赖的包也有好几个：

- pthreads
- liblzma
- libarchive
- AsciilDoc

压缩：

``` bash
pixz game.tar game.tar.xz   # 生成与xz兼容的格式
pixz game.tar           # 生成后缀为tpxz的格式，与xz不兼容
```

解压缩：

``` bash
pixz -d game.tar.xz
pixz -d game.tar.tpxz
```


### 使用tar进行打包和压缩

上面所提到的压缩命令，`gzip、bzip2、xz`或并行版本的`pigz、pbzip2、pigxz`一般很少单独使用，多数时候都是在`tar`命令打包后执行压缩，合着`tar`一起使用。

tar本身支持的选项（xz老版本的tar可能不支持，需要更新哦！）：

``` bash
# 仅打包
tar cf  game.tar game-dir
tar xf  game.tar

# 打包后使用gzip进行压缩
tar cfz game.tar.gz game-dir
tar xfz game.tar.gz

# 打包后使用bzip2进行压缩
tar cfj game.tar.bz2 game-dir
tar xfj game.tar.bz2

# 打包后使用xz进行压缩
tar cfJ game.tar.xz game-dir
tar xfJ game.tar.xz
```

tar指定压缩工具（命令必须支持`-d`选项为解压）：

``` bash
# 打包后使用并行版本的gzip
tar -Ipigz -cf game.tar.gz game-dir
tar -Ipigz -xf game.tar.gz

# 打包后使用并行版本的bzip2
tar -Ipbzip2 -cf game.tar.bz2 game-dir
tar -Ipbzip2 -xf game.tar.bz2

# 打包后使用并行版的xz
tar -Ipixz -cf game.tar.xz game-dir
tar -Ipixz -xf game.tar.xz
```

### 压缩算法

关于压缩的工具，可谓五花八门。万变不离其宗，上面提到的工具用到的算法如下：

- [DEFLATE](https://en.wikipedia.org/wiki/DEFLATE) 
- [Burrows–Wheeler algorithm](https://en.wikipedia.org/wiki/Burrows%E2%80%93Wheeler_transform)
- [LZMA-Lempel–Ziv–Markov chain algorithm](https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Markov_chain_algorithm)

压缩算法涉及到一些数据知识和编码学，这里就不详细介绍了，有兴趣的同学自行Google。

### 小结



### 参考资料

- https://www.digitalocean.com/community/tutorials/an-introduction-to-file-compression-tools-on-linux-servers
- http://ilinuxkernel.com/?p=1748
- http://compression.ca/pbzip2/


