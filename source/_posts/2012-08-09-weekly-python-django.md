---
layout: post
title: 每周一荐：Python Web开发框架Django
category : 每周一荐
tags : [Python, Django, Web开发]
date: 2012-08-09 22:40  +0800
---

花了两周时间，利用工作间隙时间，开发了一个基于Django的项目任务管理Web应用。项目计划的实时动态，可以方便地被项目成员查看（^_^又重复发明轮子了）。从前台到后台，好好折腾了一把，用到：HTML、CSS、JavaScript、Apache、Python、mod_wsgi、Django。好久不用CSS和JavaScript了，感到有点生疏了，查了无数次手册。后台Django开发环境的搭建也花了不少时间和精力。记录下来，免得以后走弯路。同时给大家推荐一下Django框架，如果你想非常快速地编写自己的web应用，可以考虑使用Django，同时Django还会给你提供一个功能强大的后台管理界面。

Django是一个开源的Web应用框架，由Python写成。采用MVC的软件设计模式，主要目标是使得开发复杂的、数据库驱动的网站变得简单。Django注重组件的重用性和“可插拔性”，敏捷开发和DRY法则（Don’t Repeat Yoursef）。在Django中Python被普遍使用，甚至包括配置文件和数据模型。它可以运行在启用了mod_python或mod_wsgi的Apache2，或者任何兼容WSGI（Web Server Gataway Interface）的Web服务器。

### 1. Django的快速开发

* 第一步（Model）：设计自己的数据模型。
* 第二步（View）：创建网页模板。Django自己的Html模板语言，非常容易将数据和模板结合起来，创建动态页面。
* 第三步（Control）：定义URL，提供服务和控制。

* 入门教程：<https://docs.djangoproject.com/en/1.4/intro/tutorial01/>

### 2. Django开发环境的搭建

Django可以运行在任何遵守WSGI的Web服务器上。本文主要介绍Apache2+mod_wsgi+Django的环境搭建。所需要的软件如下：

* Apache2：Web服务器  
* Python2.x：Python语言支持  
* mod_wsgi：Apache的WSGI模块，有了该模块的支持，就可以用Python做为CGI脚本来编写网络应用（之前还有一个mod_python，在Apache官网上发现mod_python已经过时，渐渐要被mod_wsgi替代，据说mod_wsig性能要好一些）  
* Django：一个强大的Python Web开发框架，本文的主角。  


#### 2.1 Apache的安装

	下　　载：http://httpd.apache.org/download.cgi （选择版本2.2.22，mod_wsig暂不支持2.4.2）
	解压缩　：$tar xvfz httpd-NN.tar.gz
	$cd httpd-NN
	编译配置：$./configure –with-included-apr –prefix=PREFIX #with-included-apr选项指定使用apache软件包里面的apr库
	编　　译：$make
	安　　装：$make install
	配　　置：$vim PREFIX/conf/httpd.conf
	测　　试：$PREFIX/bin/apachectl -k start
	参　　考：
	官方主页：<http://httpd.apache.org/>
	安装文档：<http://httpd.apache.org/docs/2.2/install.html>

#### 2.2 Python的安装

	下　　载：http://www.python.org/getit/releases/2.7.3/（选择2.X版都可以，3.0暂不支持）
	解压缩　：$tar xvf python-X.tar
	$cd python-Y
	编译配置：$./configure –enable-shared –prefix=PREFIX #–enable-shared选项指定生成python的动态库
	编　　译：$make
	安　　装：$make install
	测　　试：$python
	参　　考：
	官方主页：http://www.python.org/

#### 2.3 mod_wsgi模块的安装

	下　　载：http://code.google.com/p/modwsgi/ （选择3.3版本）
	解压缩　：$tar xvfz mod_wsgi.X.Y.tar.gz
	$cd mod_wsgi.X.Y
	编译配置：$././configure –with-apxs=/usr/local/apache2/bin/apxs –with-python=/usr/local/bin/python # 指定Apache2的模块编译程序和Python解析器
	编　　译：$make
	安　　装：$make install
	测　　试：$python

##### 2.3.1  配置Apache（修改/usr/local/apche2/confi/httpd.conf）

1>. 加载wsgi模块

	LoadModule wsgi_module modules/mod_wsgi.so
	....

2>. HTTP请求处理脚本

	WSGIScriptAlias /test  /home/xxx/www/test.wsgi
	<Directory "/home/xxx/www">
	Order allow, deny
	Allow from all
	</Directory>

##### 2.3.2 编写test.wsgi（WSGI标准：<http://www.python.org/dev/peps/pep-3333/>）

	def application(environ, start_response):
	    status = '200 OK'
	    output = 'Hello World!'

	    response_headers = [('Content-type', 'text/plain'),
	                        ('Content-Length', str(len(output)))]
	    start_response(status, response_headers)

	    return [output]

##### 2.3.3  重启apche2

在任意网络浏览器中输入：http://www.mysite.com/test。看到“Hello World!”，恭喜你成功安装了WSGI模块。

	参　　考：
	官方主页：http://code.google.com/p/modwsgi/
	安装文档：http://code.google.com/p/modwsgi/wiki/QuickInstallationGuide
	配置文档：http://code.google.com/p/modwsgi/wiki/QuickConfigurationGuide
	WSGI文档：http://www.python.org/dev/peps/pep-3333/

#### 2.4 Django的安装

	下　　载：https://www.djangoproject.com/download/ （选择1.4版本）
	解压缩　：$tar xvfz Django-1.4.tar.gz
	$cd Django-1.4
	安　　装：$python setup.py install
	测　　试：
	$python
	>>> import django
	>>> print(django.get_version())
	参　　考：
	官方主页：https://www.djangoproject.com/
	安装文档：https://docs.djangoproject.com/en/1.4/intro/install/
	快速入门：https://docs.djangoproject.com/en/1.4/intro/tutorial01/

### 3. Django中文支持

Django使用的是UTF-8编码，所以对于国际化支持不成问题。因为初次玩Django，中文显示乱，折腾死人了（一直在用的的mysql默认字符串是latin1编码，vim默认保存的文件编码为ascii）。最终得出结论，如果中文显示乱码，或者Django报错(… unicode …blabla…)，请检查：

Django的设置。打开自己项目的settings.py，LANGUAGE_CODE=”zh_CN” ？FILE_CHARSET=’UTF-8′ ？DEFAULT_CHARSET=’utf-8′？

查看自己项目所有的文件编码是否以UTF-8编码保存的？确保.py文件第一行要加上：#-*-  coding:utf-8 -*- ？

HTML模板文件head部分，添加<meta http-equiv=“Content-Type” content=“text/html;charset=utf-8″/>

检查自己项目的数据库字符串编码是否为UTF-8，命令如下：

查看：

	show create database dbname;
	show create table tablename;
	show full columns from tablename;

创建：

	create database dbname CHARACTER SET utf8;
	create table tblname CHARACTER SET utf8;

修改：

	alter database dbname CHARACTER SET = utf8;
	alter table tablename CONVERT TO CHARACTER SET utf8;

### 4. Django应用的部署

Django应用的运行有两个方式，一种是在开发阶段，使用创建项目下面的manager.py runserver ip:port来启动一个用Python实现的轻型web服务器；另外一种就是通过mod_wsgi将你自己的应用部署到生产环境，对外提供服务。下面简单介绍一下Django的部署（虚拟主机上的配置，自行参考文档）。

假设你创建的Django项目文件列表如下：

	my-site
	|- my-site
	|- myapp
	    |-static
	    |- ...
	|- static
	    |- css
	    |- js
	    | ...
	|- apache
	|- ...

#### 4.1. 创建Django项目的wsgi脚本（my-site/apache/django.wsgi），内容如下：

	import os, sys

	sys.path.append('/.../www/')
	sys.path.append('/.../www/my-site')
	os.environ['DJANGO_SETTINGS_MODULE'] = 'my-site.settings'
	os.environ['PYTHON_EGG_CACHE'] = '/.../www/.python-eggs'

	import django.core.handlers.wsgi

	_application = django.core.handlers.wsgi.WSGIHandler()

	def application(environ, start_response):
	    if environ['wsgi.url_scheme'] == 'https':
	        environ['HTTPS'] = 'on'
	    return _application(environ, start_response)

#### 4.2. 配置Apache（httpd.conf），内容如下：

1>. 请求访问www.xxx.com/的时候，转到django.wsgi

	WSGIScriptAlias / /.../www/my-site/apache/django.wsgi

	<Directory /.../www/my-site/apache>
	Order deny,allow
	Allow from all
	</Directory>

2>. 静态文件的访问路径配置

	Alias /static/ /.../www/my-site/static/

	<Directory /.../www/my-site/static>
	Order deny,allow
	Allow from all
	</Directory>

#### 4.3. 配置setting.py

	EBUG=False

自定义404.html，500.html模板（网页未找到、服务器内部错误）

#### 4.4. 静态文件

	STATIC_ROOT = ‘/…/www/my-site/static/’
	STATIC_URL = ‘/static/’
	$./manager.py collectstatic

注意：开发阶段，一般都会把相应app的静态文件，放在app目录下的static目录下。在正式生产环境部署的时候，使用./manager.py collectstatic来把所有静态文件收集到STATIC_ROOT指定的位置，包括管理后台的。

#### 4.5. 重启apahce

浏览器输入相应的URL地址，看到你自己的web应用界面的话，恭喜大功告成！

### 5. 总结

本文主要介绍了一下Django开发环境的搭建、Django应用的部署和中文乱码的解决方法。具体如何使用Django快速地创建自己的web应用，并没有提及。Django相对来说，文档比较齐全，加上官方推出的一本书：《The Django Book》，相信只要开发环境搭建好，创建自己的Web应用也会非常容易。

进一步学习Django，请看：

* Django1.4文档：<https://docs.djangoproject.com/en/1.4/>  
* Django Book 英文版：<http://www.djangobook.com/en/2.0/>  
* Django Book 中文版：<http://djangobook.py3k.cn/2.0/>  