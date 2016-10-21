---
layout: post
title: Redis：简介
category : 架构
tags : [redis, 开源架构]
date: 2013/07/18  21:13  +0800
--- 

Redis是一个开源的，先进的key-value持久化产品。它通常被称为数据结构服务器，它的值可以是字符串（String）、哈希（Map）、列表（List）、集合（Sets）和有序集合（Sorted sets）等类型。

可以在这些类型上面做一些原子操作，如：字符串追加、增加Hash里面的值、添加元素到列表、计算集合的交集，并集和差集；或者区有序集合中排名最高的成员。为了取得好的性能，Redis是一个内存型数据库。不限于此，看你怎么用了，也可以吧数据dump到磁盘中，或者把数据操作指令追加了一个日志文件，把它用于持久化。也可以用Redis容易的搭建master-slave架构用于数据复制。

<!--more-->

其它让它像缓存的特性包括，简单的check-and-set机制，pub/sub和配置设置。

Redis可以用大部分程序语言来操作：C、C++、C#、Java、Node.js、php、ruby等等。

Redis是用ANSI C写的，可以运行在多数POSIX系统，如：Linux，*BSD，OS X和Soloris等。官方版本不支持Windows下构建，可以选择一些修改过的版本，照样可以使用Redis。


### 数据类型

#### 字符串

Strings是Redis最基本的值类型，Redis的字符串是二进制安全的，意味着一个Redis字符串可以包含任何种类的数据，如：一个JPEG图片，一个序列化的Ruby对象。

一个字符串值最多可以有512MB的长度。

Redis的字符串有很多有趣的用法，你可以：

* String作为一个原子操作的计数器，使用INCR、DECR、INCRBY命令即可
* 用APPEND命令去追加字符串
* 使用String去随机访问vectors，使用GETRANGE和SETRANGE命令
* 大量数据编码成占据少量空间，或者创建一个用Redis作为后端的Bloom Filter，使用GETBIT和SETBIT命令

查更多字符串相关的命令：<http://redis.io/commands#string>

#### 列表

Redis Lists是简单的字符串列表，依照插入顺序。可以把元素添加到Redis列表的头部和尾部，LPUSH命令在List的头部插入一个元素，RPUSH在尾部插入一个元素，使用上面两个元素插入到一个空的List就会创建一个List。示例：

	LPUSH mylist a   # now the list is "a"
	LPUSH mylist b   # now the list is "b","a"
	RPUSH mylist c   # now the list is "b","a","c" (RPUSH was used this time)


List的最大长度是2^32-1。

Redis List主要特点就是在列表的首部和尾部O(1)时间复杂度的插入和删除。访问靠近首尾的元素速度比较快，访问中间的元素效率有所下降，访问的时间复杂度为O(N).

List可以用于：

* 为社交网络的timeline提供数据模型，使用LPUSH在用户的timeline上添加一条记录，使用LRANGE取到最近发布的一些记录。
* 可以用LPUSH和LTRIM创建一个固定大小的队列，只记着最近N个元素。
* List可以用作消息传递原语，参见Ruby的广为人知的Resque，它是一个创建后台任务的Ruby库。

查看更多命令：<http://redis.io/commands#list> 


#### 集合

Redis Sets是一个无序的字符串集合，可以在O(1)时间复杂度添加、删除、检查元素的存在性。Sets不能有重复的元素，当添加多个同样的元素时候，只保持一份COPY，意味着添加元素的时候，不用做元素存在的检查后添加这个操作。

Sets有趣的事情是，它支持服务器端完成快速完成一些诸如交集、并集、差集等操作。

Sets可用于：

* 用Sets记录不同值得元素集合。想要知道访问当前博客的IP数量？在每次访问页面时，简单地用SADD命令把IP添加到Sets即可。
* Sets比较擅长表达关系。可以用Sets创建一个标签系统，用于标签展示。
* 使用SPOP和SRANDMEMBER随机弹出元素。

查看更多命令：<http://redis.io/commands#set>

#### 哈希（字典）

Redis Hash是属性字段到值得映射，能够比较完美地表示对象（如：User有name，surname，age等字段）

	redis> HMSET user:1000 username antirez password P1pp0 age 34
	OK
	redis> HGETALL user:1000
	1) "username"
	2) "antirez"
	3) "password"
	4) "P1pp0"
	5) "age"
	6) "34"
	redis> HSET user:1000 password 12345
	(integer) 0
	redis> HGETALL user:1000
	1) "username"
	2) "antirez"
	3) "password"
	4) "12345"
	5) "age"
	6) "34"
	redis> 

字段比较少的Hash（最多100个左右）能够以占据数量空间的方式存储，所以可以用一个小Redis实例存储百万级对象。	

Hash主要用于表示对象，可以存储多个元素，也可以用于其它任务。

查看更多操作Hash的命令：<http://redis.io/commands#hash>

#### 有序集合

Redis Sorted Sets类似于Sets，是一个存储非重复的元素的集合。两者的区别是，Sorted Set的每个元素会有一个score属性，Sorted Set根据score从小到达进行排序。

可以以快速的方式添加，删除和更新元素（大约Log(N)时间复杂度）。因为元素师插入时候进行排序的，可以快速地根据score或者排名来取一个区间的元素，取有序集合的中间元素速度也是很快的。因此可以把Sorted Set当做一个智能的非重复元素的集合：元素顺序存储，快速存在性检查，快速访问中间元素。

使用Sorted Set可以高效地做很多其他类型数据库很难完成的任务。

Sorted Set可以用于：

* 一个大型在线游戏的领袖排行榜，每有新的score提交的时候使用ZADD，可以轻而易举地用ZRANGE取得前几名，也可以根据指定用户名，用ZRANK得到用户的排名。使用ZRANK和ZRANGE一起可以把分值接近的用户显示出来。所有这些操作都能快速地完成。
* Sorted Sets经常用于存储在Redis中的数据的索引。例如：有很多表示用户的hashes，你可以把年龄作为score创建一个sorted set，value是用户的ID，这时，你可以使用ZRANGEBYSCORE快速获取某个年龄范围的所有用户。

* Sorted Sets可能是最先进的数据类型，抽空了解更多相关命令吧！<http://redis.io/commands#sorted_set>


### 自言自语

很早就听说过key-value NoSQL，一直没有机会去使用，直到最近项目有台全局服务器（单点）用MySQL存储了大量的数据，每次维护和游戏玩家上线时数据库超时非常严重，对MySQL进行分表情况还是不得好转，只好分库，好一番折腾后还是不妙，单点问题让人头疼。最后狠心花一个多月时间把其改造成逻辑和数据分离的架构，数据用Redis做缓存和持久化。下周做一些压力测试，不出问题的话可以投放生产环境跑一下。

PS. 上面的简介是翻译自Redis官网，有所不当或错误之处还望指出，不胜感激！

