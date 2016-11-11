---
title: Linux下的文件打包和压缩
date: 2016-11-11 15:05:48
category : 工具
tags: [Linux, 工具]
---

为什么要整理一下Linux下的打包和压缩工具呢？原因很简单，因为遇到问题了：**游戏服务器可执行文件、配置和各种资源文件有4G多，每次在做版本的时候，编译完打包压缩要用掉10分钟多**。我在上篇[C++构建系统选择](/2016/10/28/build-system/)里面有提到过，200万行的代码编译用时不到10分钟，而现在一个简单的打包压缩竟然占用了10分钟，虽说这个步骤日常开发过程中很少操作，但每次凌晨做版本的时候，由于需求的变更，需要不断地构建、打包、压缩。做版本的同学苦不堪言，所有开发人员也得等着，这样浪费大家宝贵的时间是极度可耻的，家人和孩子们还等着回家了啊！

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

#### zip

官方首页：http://www.info-zip.org/mans/zip.html

`zip`用于压缩，`unzip`用于解压缩，生成的文件格式是`.zip`。非常古老的压缩方式，压缩比比较低，好处就是由于古老，所以基本上是个操作系统都会默认对此进行支持。

虽然zip和gzip使用的算法都是基于DEFLATE，但具体文件格式是不一样的，所以`.zip`和`.gz`文件是不兼容的。zip很少在Linux下使用，Linux下直接用`gzip`即可，多数情况都是其他平台下生成的`.zip`在Linux系统下面解压一下。

压缩：

``` bash
zip squash.zip file1 file2 file3  # 压缩文件
zip -r squash.zip dir1              # 目录打包并压缩
```

解压缩：

``` bash
unzip squash.zip
```

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

#### xz

#### 7z


### 使用tar进行打包和压缩

tar cf myfile.tar.bz2 -I pbzip2 file1 fileN dir_to_compress/

### 并行压缩和解压缩


普通 vs. 并行         |  普通版用时  | 并行版用时
-------------------|-------------|--------------
gzip vs. pigz          | |
bzip2 vs. pbzip2    | |
xz  vs. pixz            | |

#### pigz

PIGZ – pigz, which stands for Parallel Implementation of GZip, is a fully functional replacement for gzip that takes advantage of multiple processors and multiple cores when compressing data.

http://zlib.net/pigz/

#### pbzip2

PBZIP2 – pbzip2 is a parallel implementation of the bzip2 block-sorting file compressor that uses pthreads and achieves near-linear speedup on SMP machines. The output of this version is fully compatible with bzip2 v1.0.2 (ie: anything compressed with pbzip2 can be decompressed with bzip2).

http://compression.ca/pbzip2/


#### pixz

https://github.com/vasi/pixz


### 压缩算法对比

### 小结

### 参考资料

- https://www.digitalocean.com/community/tutorials/an-introduction-to-file-compression-tools-on-linux-servers
- http://ilinuxkernel.com/?p=1748
- http://compression.ca/pbzip2/


