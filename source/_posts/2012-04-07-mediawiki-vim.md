---
layout: post
title: MediaWiki编辑工具
category : 工具
tags : [wiki]
date: 2012-04-07 02:18  +0800
---

### 1. vim+wikimedia.vim

#### 简介：

使用vim的wikimedia.vim插件，可以高亮wiki语法关键字，自动补齐等功能。对于喜欢用vim编辑器的人来说，用此方式编辑wiki再好不过了。可以自动识别的文件类型为*.wiki，或者set filetype=mediawiki。

![vim](/images/2012-04-07-1.jpg)

#### 安装：

1. 下载VIM插件：<http://www.vim.org/scripts/script.php?script_id=1787>  
2. 解压缩到$HOME/.vim/或$VIMDIR/vimfile/目录下面  
3. 确认：$HOME/.vim/syntax/mediawiki.vim  
4. 确认：$HOME/.vim/ftdetect/mediawiki.vim  

### 2. WYSIWYG(CKEditor)

#### 简介：

该MediaWiki扩展，使得用户可以以WYSIWYG方式编辑WIKI，使用了CKEditor。

#### 安装：

1. 下载WYSIWYG包：<http://www.smwplus.com/index.php/Help:WYSIWYG_extension_1.6.0>   
2. 解压缩  
3. 复制wysiwyg-1.6.0_0\extensions\WYSIWYG 到 ..\htdocs\mediawiki\extensions  
4. 配置MediaWiki的LocalSettings.php   
	
	require_once(“$IP/extensions/WYSIWYG/WYSIWYG.php”);

5. 设置可以使用者的权限   

所有人可用：`$wgGroupPermissions['*']['wysiwyg']=true; `

注册用户可以：`$wgGroupPermissions['registered_users']['wysiwyg']=true;`

![CKEditor](/images/2012-04-07-2.jpg)


### Microsoft Office Word Add-in For MediaWiki

#### 简介：

可以将MS Word 2007/2012的文档直接保存为MediaWiki语法格式的文件。

#### 安装：

下载WORD插件：<http://www.microsoft.com/download/en/details.aspx?id=12298>

运行插件安装程序
