---
layout: post
title: 内核模块相关命令：lsmod,depmod,modprob...
category : Linux
tags : [Linux命令]
date: 2009-02-04 18:06:00 +0800
---

### lsmod

**功能**：列出内核已载入模块的状态

**用法**：lsmod

**描述**：

lsmod 以美观的方式列出/proc/modules的内容。输出为：

     Module(模块名)    Size(模块大小)   Used by(被...使用)
 
	 eg. ne2k_pci           8928               0
     8390                 9472              1 ne2k_pci
 
在/proc/modules中相应的是：
   
    (模块名，模块大小，被...使用，模块地址(猜的，以后确认)) 
    ne2k_pci 8928 0 - Live 0x3086400
    8390 9472 1 ne2k_pci , Live 0xe086000
 
### depmod

**功能**：分析可加载模块的依赖性，生成modules.dep文件和映射文件。

**用法**：
	depmod [-b basedir] [-e] [-F System.map] [-n] [-v] [version] [-A]
    depmod [-e] [-F System.map] [-n] [-v] [version] [filename...]

**描述**：

Linux内核模块可以为其它模块提供提供服务(在代码中使用EXPORT_SYMBOL)，这种服务被称作"symbols"。若第二个模块使用了这个symbol，则该模块很明显依赖于第一个模块。这些依赖关系是非常繁杂的。
    
depmod读取在/lib/modules/version 目录下的所有模块，并检查每个模块导出的symbol和需要的symbol，然后创建一个依赖关系列表。默认地，该列表写入到/lib/moudules/version目录下的modules.dep文件中。若命令中的filename有指定的话，则仅检查这些指定的模块(不是很有用)。
 
若命令中提供了version参数，则会使用version所指定的目录生成依赖，而不是当前内核的版本(uname -r 返回的)。
                                
**选项**：

    -b basedir  --basedir basedir  若你的模块并没有正确的在/lib/mdules/version下，可以指定目录生成依赖。
    -e  --errsyms  和-F选项一起使用，当一个模块需要的symbol在其它模块里面没有提供时，做出报告。正常情况下，模块没有提供的symbol都在内核中有提供。
    -F  --filesyms System.map 提供一个System.map文件(在内核编译时生成的)许-e选项报告出unresolved symbol。
    -n  --dry_run  将结果modules.dep和各种映射文件输出到标准输出(stdout)，而不是写到模块目录下。
    -A --quick  检查是否有模块比modues.dep中的模块新，若没有，则退出不重新生成文件。

 
### modprobe

**功能**：Linux内核添加删除模块

**用法**：

    modprobe [ -v ] [ -V ] [-C config-file] [ -n ] [ -i ] [ -q ] [ -o modulename] [ modulename ] [ module parameters ... ]
    modprobe [ -r ] [ -v ] [ -n ] [ -i ] [ modulename ... ]
    modprobe [ -l ] [ -t dirname ] [ wildcard ]
    modprobe [ -c ]

**描述**：

    modprobe可智能地添加和删除Linux内核模块(为简便起见，模块名中'_'和'-'是一样的)。modprobe会查看模块目录/lib/modules/'uname -r'里面的所有模块和文件，除了可选的/etc/modprobe.conf配置文件和/etc/modprobe.d目录外。
 
    modprobe需要一个最新的modules.dep文件，可以用depmod来生成。该文件列出了每一个模块需要的其他模块，modprobe使用这个去自动添加或删除模块的依赖。
 
**选项**：

    -v --verbose  显示程序在干什么，通常在出问题的情况下，modprobe才显示信息。
    -C --config  重载(^_^,意思取C++的重载)默认配置文件(/etc/modprobe.conf或/etc/modprobe.d)。
    -c --showconfig  输出配置文件并退出
    -n --dry-run  可以和-v选项一起使用，调试非常有用
    -i --ignore-install --ignore-remove 该选项会使得modprobe忽略配置文件中的，在命令行上输入的install和remove命令。
    -q --quiet 一般modprobe删除或插入一个模块时，若没有找到会提示错误。使用该选项，会忽略指定的模块，并不提示任何错误信息。
    -r --remove  该选项会导致modprobe去删除，而不是插入一个模块。通常没有没有理由去删除内核模块，除非是一些有bug的模块。你的内核也不一定支持模块的卸载。
    -V --verssion 版本信息
    -f --force  和同时使用--force-vermagic ，--force-modversion一样。使用该选项是比较危险的。
    -l --list 列出所有模块
    -a --all 插入所有命令行中的模块
    -t --type 强制 -l 显示dirname中的模块
    -s --syslog 错误信息写入syslog
      
### modinfo

**功能**：显示内核模块的信息

**用法**：

    modinfo [ -0 ] [ -F field] [modulename | filename ... ]
    modinfo -V
    modinfo -h

**描述**：

modinfo列出Linux内核中命令行指定的模块的信息。若模块名不是一个文件名，则会在/lib/modules/version 目录中搜索，就像modprobe一样。
    
modinfo默认情况下，为了便于阅读，以下面的格式列出模块的每个属性：fieldname : value。
 
**选项**：

    -V --version 版本
    -F --field 仅在一行上显示field值，这对于脚本较为有用。常用的field有：author, description, licence, param, depends, alias, filename。
    -0 --NULL 使用'/0'字符分隔field值，而不是一个新行。对脚本比较有用。
    -a -d -l -p -n 这些分别是author, description, license, param ,filename的简短形式。
 
 
### insmod

**功能**：向Linux内核中插入一个模块

**用法**：insmod [filename] [modue options ...]

**描述**：

insmod是一个向内核插入模块的小程序：若文件名是一个连字符'-'，模块从标准输入输入。大多数用户使用modprobe，因为它比较智能化。
 
### rmmod

**功能**：删除内核中的一模块

**用法**：rmmod [ -f ] [ -w ] [ -s ] [ -v ] [ modulename ]

**描述**：

rmmod是一个可以从内核中删除模块的小程序，大多数用户使用modprobe -r去删除模块。
 
**选项**：

    -v --verbose  显示程序正在做些什么，一般只显示执行时的错误信息。
    -f --force  该选项是非常危险：除非编译内核时，CONFIG_MODULE_FORCE_UNLOAD被设置该命令才有效果，否则没效果。用该选项可以删除正在被使用的模块，设计为不能删除的模块，或者标记为unsafe的模块。
    -w --wait 通常，rmmod拒绝删除正在被使用的模块。使用该选项后，指定的模块会被孤立起来，直到不被使用。
    -s  --syslog  将错误信息写入syslog，而不是标准错误(stderr)。
    -V  --version 版本信息
    


以上内容是参考man翻译的，若有疑问请用man ...查看原始文档，翻译有误之处还望见谅。

