---
layout: post
title: initramfs 简介，一个新的 initial RAM disks 模型
category : Linux
tags : [Linux, 内核学习]
date: 2009-02-06 14:00:00 +0800
---

译自: <http://linuxdevices.com/articles/AT4017834659.html> (by Rob Landley, TimeSys (Mar. 15, 2005))

### 问题

当 Linux 内核启动系统时，它必须找到并执行第一个用户程序，通常是 init。用户程序存在于文件系统，故 Linux 内核必须找到并挂载上第一个(根)文件系统，方能成功开机。

通常，可用的文件系统都列在 /etc/fstab，所以 mount 可以找到它们。但 /etc/fstab 它本身就是一个文件，存在于文件系统中。找到第一个文件系统成为鸡生蛋蛋生鸡的问题，而且为了解决它，内核开发者建立内核命令列选项 root=，用来指定 root 文件系统存在于哪个设备上。

十五年前，root= 很容易解释。它可以是软盘或硬盘上的分区。如今 root 文件系统可以存在于各种不同类型的硬件(SCSI, SATA, flash MTD) ，或是由不同类型硬件所建立的 RAID 上。它的位置随着不同启动而不同，像可热插拔的 USB 设备被插到有多个 USB 孔的系统上 - 当有多个 USB 设备时，哪一个是正确的？root 文件系统也可能被压缩(如何？)，被加密(用什么 keys？)，或 loopback 挂载(哪里？)。它甚至可以存在外部的网络服务器，需要内核去取得 DHCP 地址，完成 DNS lookup，并登入到远程服务器(需账号及密码)，全部都在内核可以找到并执行第一个 userspace 程序之前。

如今，root= 已没有足够的信息。即使将所有特殊案例的行为都放进内核也无法帮助设备列举，加密，或网络登入这些随着系统不同而不同的系统。更糟的是，替核心加入这些复杂的工作，就像是用汇编语言写 web 软件 ：可以做到，但使用适当的工具会更容易完成。核心是被设计成服从命令，而不是给命令。

为了这个不断增加复杂度的工作， 核心开发者决定去寻求更好的方法来解决这整个问题。


### 解决方法

Linux 2.6 核心将一个小的 ram-based initial root filesystem(initramfs) 包进内核，且若这个文件系统包含一个程序 init，核心会将它当作第一个程序执行。此时，找寻其它文件系统并执行其它程序已不再是内核的问题，而是新程序的工作。

initramfs 的内容不需是一般功能。若给定系统的 root 文件系统存在于一个加密过的网络块设备，且网络地址、登入、加密都存在 USB 设备 "larry" (需密码方能存取)里，系统的 initramfs 可以有特殊功能的程序，它知道这些事，并使这可以运作。

对系统而言，不需要很大的 root 文件系统，也不需要寻址或切换到任何其它 root 文件系统。

### 这跟 initrd 有何不同?

Linux kernel 已经有方法提供 ram-based root filesystem，initrd 机制。对 2.4 及更早的 kernel 来说，initrd 仍然是唯一的方法去做这一连串的事。但 kernel 开发者选择在 2.6 实现一个新的机制是有原因的。

### ramdisk vs ramfs

ramdisk (如 initrd) 是 基于ram的块设备，这表明它是一块固定大小的内存，它可以被格式化及挂载，就像磁盘一样。这表明 ramdisk 的内容需先格式化并用特殊的工具(像是 mke2fs 及 losetup)做前置作业，而且如同所有的块设备，它需要文件系统驱动程序在执行时期解释数据。这也有人工的大小限制不论是浪费空间(若 ramdisk 没有满，已被占用的额外的内存也不能用来做其它事)或容量限制(若 ramdisk 满了，但其它仍有闲置的内存，也不能不经由重新格式化将它扩展)。

但 ramdisk 由于缓冲机制（caching）实际上浪费了更多内存。Linux 被设计为将所有的文件及目录做缓存，不论是对块设备的读出或写入，所以 Linux 复制数据到 ramdisk及从 ramdisk 复制数据出来，page cache 给 file data 用，而 dentry cache 给目录用。ramdisk 的下面则伪装为块设备。

几年前，Linus Torvalds 有一个巧妙的想法：Linux 的缓存是否可以被挂载一个文件系统？只要保持文件在缓存中且不要将它们清除，直到它们被删除或系统重新启动？Linus 写了一小段程序将缓存包起来，称它为 ramfs，而其它的 kernel 开发者建立一个加强版本称为 tmpfs(它可以写数据到 swap，及限制挂载点的大小，所以在它消耗完所有可用的内存前它会填满)。initramfs 就是 tmpfs 的一个实例。
这些基于ram的文件系统自己改变大小以符合数据所需的大小。增加文件到 ramfs(或增大原有的文件)会自动配置更多的内存，并删除或截去文件以释放内存。在块设备及缓存间没有复制动作，因为没有实际的块设备。在缓存中的只是数据的复制。更好的是这并不是新的程序代码，而是已存在的 Linux 缓存程序代码新的应用，这表示它几乎没有增加大小，非常简单，且基于已经历测试的基础上。

系统使用 initramfs 作为它的 root 文件系统甚至不需要将文件系统驱动程序内建到 kernel，因为没有块设备要用来做文件服务器。只是存在内存中的文件罢了。

### initrd vs initramfs

底层架构的改变是 kernel 开发者建立一个新的实现的理由，但当他们在那里时他们清除了很多不好的行为及假设。
initrd 被设计为旧的 root= 的 root 设备检测程序代码的前端，而不是取代它。它执行 /linuxrc，这被用来完成设定功能(像是登入网络，决定哪个设备含有 root 分区，或用文件做为 loopback 设备)，告诉 kernel 哪个块设备含有真的 root 设备(通过写入de_t 数据到 /proc/sys/kernel/real-root-dev)，且回传给 kernel，所以 kernel 可以挂载真的 root 设备及执行真的 init 程序。

这里假设“真的根设备”是块设备而不是网络共享的，同时也假设 initrd 自己不是做为真的 root 文件系统。kernel 也不会执行 /linuxrc 而做为特殊的进程（ID=1），因为这个 process ID(它有特殊的属性，像是做为唯一无法被以 kill -9 的 process) 被保留给 init，kernel 在它挂载真的 root 文件系统后会等它执行。

用 initramfs，kernel 开发者移除所有的假设。当 kernel 启动了在 initramfs 外的 /init，kernel 即做好决定并回去等待接受命令。用 initramfs，kernel 不需要关心真的 root 档案系统在哪里，而在 initramfs 的 /init 被执行为真的 init，以 PID 1。(若 initramfs 的 init 需要不干涉特别的 PID 给其它程序，它可以用 exec() 系统呼叫，就像其它人一样)

### 总结

传统的 root= kernel 命令列选项仍然被支持且可用。但在开发支持initial RAM disk支持内核时，提供了许多优化和灵活性。

### 译者注

**查看initramfs的内容**

	# mkdir initrd
	# cd intrd
	# cp /boot/initrd.img initrd.img
	# gunzip initrd.img
	# cpio -i --make-directories < initrd.img
	#

**创建initramfs**

a. mkinitramf

	# mkinitramfs -o /boot/initrd.img 2.6.2

Note: 2.6.25是需要创建initramfs的kernel版本号，如果是给当前kernel制作initramfs，可以用uname -r查看当前的版本号。提供kernel版本号的主要目的是为了在initramfs中添加指定kernel的驱动模块。mkinitramfs会把/lib/modules/${kernel_version}/ 目录下的一些启动会用到的模块添加到initramfs中。

b. update-initramfs

更新当前kernel的initramfs

	# update-initramfs -u

在添加模块时，initramfs tools只会添加一些必要模块，用户可以通过在/etc/initramfs-tools/modules文件中加入模块名称来指定必须添加的模块。

命令：mkinitramfs, update-initramfs

**mkinitcpio**

在Arch Linux中，有一个新一代的initramfs制作工具。相对于老的mkinitrd和mkinitramfs，它有以下很多优点。查看详细《使用mkinitcpio》。

**参考链接**：

* 精通initramfs构建 <http://linuxman.blog.ccidnet.com/blog-htm-do-list-uid-60710-type-blog-dirid-14402.html> 
* 制作initramfs镜像 <http://www.diybl.com/course/6_system/linux/Linuxjs/200888/135080.html>  

-----------------------------------------------------

原文如下：

-----------------------------------------------------

### The problem. (Why "root=" doesn't scale.)

When the Linux kernel boots the system, it must find and run the first user program, generally called "init". User programs live in filesystems, so the Linux kernel must find and mount the first (or "root") filesystem in order to boot successfully.

Ordinarily, available filesystems are listed in the file /etc/fstab so the mount program can find them. But /etc/fstab is itself a file, stored in a filesystem. Finding the very first filesystem is a chicken and egg problem, and to solve it the kernel developers created the kernel command line option "root=", to specify which device the root filesystem lives on.

Fifteen years ago, "root=" was easy to interpret. It was either a floppy drive or a partition on a hard drive. These days the root filesystem could be on dozens of different types of hardware (SCSI, SATA, flash MTD), or even spread across several of them in a RAID. Its location could move around from boot to boot, such as hot pluggable USB devices on a system with multiple USB ports -- when there are several USB devices, which one is correct? The root filesystem might be compressed (how?), encrypted (with what keys?), or loopback mounted (where?). It could even live out on a network server, requiring the kernel to acquire a DHCP address, perform a DNS lookup, and log in to a remote server (with username and password), all before the kernel can find and run the first userspace program.

These days, "root=" just isn't enough information. Even hard-wiring tons of special case behavior into the kernel doesn't help with device enumeration, encryption keys, or network logins that vary from system to system. Worse, programming the kernel to perform these kind of complicated multipart tasks is like writing web software in assembly language: it can be done, but it's considerably easier to simply use the proper tools for the job. The kernel is designed to follow orders, not give them.

With no end to this ever-increasing complexity in sight, the kernel developers decided to back up and find a better way to deal with the whole problem.

### The solution

Linux 2.6 kernels bundle a small ram-based initial root filesystem into the kernel, and if this filesystem contains a program called "/init" the kernel runs that as its first program. At that point, finding some other filesystem containing some other program to run is no longer the kernel's problem, but is now the job of the new program.

The contents of initramfs don't have to be general purpose. If a given system's root filesystem lives on an encrypted network block device, and the network address, login, and decryption key are all to be found on a USB device named "larry" (which requires a password to access), that system's initramfs can have a special-purpose program that knows all about that, and makes it happen.

For systems that don't need a large root filesystem, there's no need to locate or switch to any other root filesystem.

### How is this different from initrd?

The linux kernel already had a way to provide a ram-based root filesystem, the initrd mechanism. For 2.4 and earlier kernels, initrd is still the only way to do this sort of thing. But the kernel developers chose to implement a new mechanism in 2.6 for several reasons.

### ramdisk vs ramfs

A ramdisk (like initrd) is a ram based block device, which means it's a fixed size chunk of memory that can be formatted and mounted like a disk. This means the contents of the ramdisk have to be formatted and prepared with special tools (such as mke2fs and losetup), and like all block devices it requires a filesystem driver to interpret the data at runtime. This also imposes an artificial size limit that either wastes space (if the ramdisk isn't full, the extra memory it takes up still can't be used for anything else) or limits capacity (if the ramdisk fills up but other memory is still free, you can't expand it without reformatting it).

But ramdisks actually waste even more memory due to caching. Linux is designed to cache all files and directory entries read from or written to block devices, so Linux copies data to and from the ramdisk into the "page cache" (for file data), and the "dentry cache" (for directory entries). The downside of the ramdisk pretending to be a block device is it gets treated like a block device.

A few years ago, Linus Torvalds had a neat idea: what if Linux's cache could be mounted like a filesystem? Just keep the files in cache and never get rid of them until they're deleted or the system reboots? Linus wrote a tiny wrapper around the cache called "ramfs", and other kernel developers created an improved version called "tmpfs" (which can write the data to swap space, and limit the size of a given mount point so it fills up before consuming all available memory). Initramfs is an instance of tmpfs.

These ram based filesystems automatically grow or shrink to fit the size of the data they contain. Adding files to a ramfs (or extending existing files) automatically allocates more memory, and deleting or truncating files frees that memory. There's no duplication between block device and cache, because there's no block device. The copy in the cache is the only copy of the data. Best of all, this isn't new code but a new application for the existing Linux caching code, which means it adds almost no size, is very simple, and is based on extremely well tested infrastructure.

A system using initramfs as its root filesystem doesn't even need a single filesystem driver built into the kernel, because there are no block devices to interpret as filesystems. Just files living in memory.

### Initrd vs initramfs

The change in underlying infrastructure was a reason for the kernel developers to create a new implementation, but while they were at it they cleaned up a lot of bad behavior and assumptions.

Initrd was designed as front-end to the old "root=" root device detection code, not a replacement for it. It ran a program called "/linuxrc" which was intended to perform setup functions (like logging on to the network, determining which of several devices contained the root partition, or associating a loopback device with a file), tell the kernel which block device contained the real root device (by writing the de_t number to /proc/sys/kernel/real-root-dev), and then return to the kernel so the kernel could mount the real root device and execute the real init program.

This assumed that the "real root device" was a block device rather than a network share, and also assumed that initrd wasn't itself going to be the real root filesystem. The kernel didn't even execute "/linuxrc" as the special process ID 1, because that process ID (and its special properties like being the only process that can not be killed with "kill -9") was reserved for init, which the kernel was waiting to run after it mounted the real root filesystem.

With initramfs, the kernel developers removed all these assumptions. Once the kernel launches "/init" out of initramfs, the kernel is done making decisions and can go back to following orders. With initramfs, the kernel doesn't care where the real root filesystem is (it's initramfs until further notice), and the "/init" program from initramfs is run as a real init, with PID 1. (If initramfs's init needs to hand that special Process ID off to another program, it can use the exec() syscall just like everybody else.)

### Summary

The traditional root= kernel command-line option is still supported and usable, but new developments in the types of initial RAM disks supported by the kernel provide many optimizations and much-needed flexibility for the future of the Linux kernel. The next article in this series, available in next month's issue of TimeSource, explains how you can start making the transition to the new initramfs initial RAM disk mechanism.

