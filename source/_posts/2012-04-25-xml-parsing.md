---
layout: post
title: 解析XML文件
category : 重构
tags : [重构, XML]
date: 2012-04-25 21:15 +0800
---

### 动机

网游服务器端开发过程中，很多控制游戏的参数都不应该直接硬编码的。需要各种各样的配置和脚本文件，好处：

可以由策划或数值去随意修改，而不用动程序代码

配置可以动态加载，可以动态改变服务器运行中的参数，对已经发布的功能进行调整
一般，可采用：

1. ini配置，一般用于window下的软件，游戏客户端有时会用到。比较简单，功能有限。  
2. Excel表格，数值策划特别喜欢用这个，可以做很多运算，生成数值，可以用VBA做更多的事情。  
3. xml配置，对于层次比较深、结构比较复杂的数据，应该算最佳选择了。  

XML(eXtensible Markup Language)是一种标记语言，用于说明数据是什么，以及携带数据信息。主要用于：

1. 丰富文件(Rich Documents)：自定文件描述并使其更丰富  
2. 元数据(Metadata)：描述其它文件  
3. 配置文件(Configuration Files)：设定应用程序的参数  

下面主要介绍一下对于xml文件作为服务器配置时候的解析方案。

### 问题

解析下面的XML文件：

```
<config>
     <node1 prop1="100" prop2="i am string", prop3="2012-01-02 23:00:00"/>
 
     <node2 id="1" prop1="100" prop2="string1"/>
     <node2 id="2" prop1="100" prop2="string1"/>
     <node2 id="3" prop1="100" prop2="string1"/>
     <node2 id="4" prop1="100" prop2="string1"/>
 
     <node3 prop1="100"  prop2="string1"/>
     <node3 prop1="100"  prop2="string1"/>
     <node3 prop1="100"  prop2="string1"/>
     <node3 prop1="100"  prop2="string1"/>
</config>
```

* node1 – 整个xml文件里面只有一个该节点  
* node2 – 有多个并且id属性可以作为它的键值，称之为节点map  
* node3 – 有多个名为node3的节点，但没有键值，称之为节点vector  

### 一般的解决方案

使用XMLPaser（用libxml2封装的一个解析器）来解析（TinyXML也类似，DOM方式的都大同小异）：

```

XMLPaser xml;
if (xml.initFile("xxx.xml"))
{
     xmlNodePtr root = xml.getRootNode("config");
     if (root)
     {
          // 解析node1的prop1和prop2属性
           struct NodeConfig{
                    int prop1;
                    string prop2;
               } config;
 
          xmlNodePtr node1 = root->getChildNode(root, "node1");
          if (node1)
          {
 
               node1->getNodePropNum(node1, "prop1", &config.prop1, sizeof(config.prop1));
               node2->getNodePropStr(node1, "prop2", config.prop2);
          }
 
          // 解析node2节点map
           struct NodeConfig{
                    int prop1;
                    string prop2;
           };
          std::map<int, NodeConfig> nodemap;
 
          xmlNodePtr node2 = root->getChildNode(root, "node2");
          while (node2)
          {
               int id;
               NodeConfig config;
 
               node2->getNodePropNum(node2, "id", &id, sizeof(id));
               node2->getNodePropNum(node2, "prop1", &config.prop1, sizeof(config.prop1));
               node2->getNodePropStr(node2, "prop2", config.prop2);
 
               nodemap[id] = config;               
 
               node2 = node2->getNextNode(node2, "node2");
          }
 
          // 解析node3节点vector
          .....
     }
}

```

**坏味道分析**

上面的代码，有几点不足之处，列举如下：

1> 代码重复

整个解析过程大同小异，一步一步遍历加载在内存中的节点树
节点或节点属性的名称、节点的层次结构不同的时候，就得写不同的代码，一般会采用复制代码的方式
使用不便

往往要写一个单件管理器，在服务器启动的时候加载该配置，然后在管理器里面把需要的数据结构都定义好
使用的时候，引用管理器里面的成员变量，代码既丑陋又容易出错

2> 不安全

节点名称、属性名称都是字符串，拼错了，运行时会发生逻辑错误

### 更好的解决方案

C++的结构与XML的对应树状结构对应起来，也就是数据绑定方案（Xml Data Binding）。自己曾经实现过一个Xml Data Binding库，名为xml_parser。具体用法如下：

**step1: 编写一份描述XML结构的配置文件（也是一份XML文件,xml_parser.xml）**

```

<config>
     <node1 prop1="int" prop2="string" prop3="t_Date"/>
     <node2 id="int" prop1="int" prop2="string" container_="map" key_="id"/>
     <node3 prop1="int"  prop2="string" container_="vector" />
</config>

```

**step2: 生成binding类**

     xmlpg -f xml_paser.xml -o xml_parser.h

***step3: 应用程序中使用**

```

xml_config<xml_paser> xml;
if (xml.load("xxx.xml"))
{
     // node1的prop1和prop2属性
     int prop1 = xml.node1.prop1();
     string prop2 = xml.node1.prop2();
     t_Date date  = xml.node1.prop3();

     // node2节点map
     for (xml_paser::Node2MapIter it = xml.node2.begin(); it != xml.node2.end(); ++ it)
     {
          int id = it->first;
          int prop1 = it->second.prop1();
          string prop2 = it->second.prop2();
     }

     // node3节点vector
     for (size_t i = 0; i < xml.node3.size(); i ++)
     {
          int prop1 = xml.node3[i].prop1();
          string prop2 = xml.node3[i].prop2();
     }
}

```


### 更多解决方案

<table class="table" border="1">
<thead>
     <tr>
          <th>方式</th>
          <th>特征</th>
          <th>开源库</th>
     </tr>
</thead>
<tbody>
     <tr>
          <td>DOM(Document Object Model)</td>
          <td>
               1. 文档对象模型，整个文档就是一个根节点及其子节点构成;
               2. 树状，有子节点、父节点、兄弟节点;
               3. 访问效率较低
          </td>
          <td>
               libxml2;
               Xerces-C++;
               TinyXML;
               SlimXML;
               RapidXML
          </td>
     </tr>
     <tr>
          <td>SAX(Simple API for XML)</td>
          <td>基于事件解析XML</td>
          <td>
               libxml2;
               Xerces-C++
          </td>
     </tr>
     <tr>
          <td>Data Binding</td>
          <td>
1. C++的结构与XML的对应树状结构对应起来，使用起来比较容易;
2. 安全，C++的结构为静态的，不会因为写错节点或节点属性名称拼写错误而导致逻辑错误;
3. 代码简洁、清晰;
4. 访问效率高，对所为节点或节点属性的访问只是函数调用，而不像DOM方式去循环遍历整个子树的节点，做一系列字符串比较操作;
5. 不足之处，结构必须已知，DOM方式则不论程序里面对应的结构，先把整个节点树加载到内存中，程序根据自己的需要去读取自己想要的节点或节点属性
          </td>
          <td>CodeSynthesis XSD</td>
     </tr>
</tbody>
</table>


### XML与Excel表格做配置的比较

<table class="table" border="1">
<thead>
     <tr>
          <th>比较</th>
          <th>XML</th>
          <th>Excel表格</th>
     </tr>
</thead>
<tbody>
     <tr>
          <td>结构</td>
          <td>树状的层次结构</td>
          <td>MxN的二维数组</td>
     </tr>
     <tr>
          <td>适用性</td>
          <td>信息具有层次性; 结构复杂</td>
          <td>有一个键值可以索引的关联数组结构; 结构简单</td>
     </tr>
     <tr>
          <td>不足之处</td>
          <td>配置起来不是那么方便，每个节点名、属性名都必须指定</td>
          <td>添加新列的时候，不一定所有行都用到该列属性，容易导致空间的浪费</td>
     </tr>
</tbody>
</table>
