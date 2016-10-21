---
layout: post
title: 每周一荐：Google的序列化框架Protobuf
category : 每周一荐
tags : [protobuf, Google]
date: 2012-05-31 21:00  +0800
---

### 1. 简介

Protocol Buffers是Google的一个序列化框架，可以非常方便地把程序中用到的结构化数据转换成二进制字节块，并且它对于结构化数据的编码也是比较特殊的，一个字节最高位（MSB）代表下一个字节是否和当前这个字节构成一个数据。因此，Protobuf的存储效率比较高，数值小的占的字节数少，数值大的占的相应的字节数就比较多。

Protobuf对于程序中对应的结构会有一份结构描述文件。可以通过它提供的protoc生成指定类型的代码（C++、Java等），对于网络协议的编写有极大的方便，一处定义，然后可以转换成多种语言的代码。同时，还支持RPC。

以前在项目中也写过序列化相关的代码，最质朴的BYTE、WORD、DWORD、QWORD或者对应的数组，并且可以非常方便地对于STL容器进行序列化，容器的嵌套也不在话下（如:std::map<DWORD, std::vector<…> >）。但对于数据结构的变动，就必须自己进行版本化控制。而Protobuf对于结构每一个字段都有一个标识，只要保证按着它的添加规则来（具体参考下面的链接），版本控制基本上就都可以靠Protobuf搞定了。

### 2. 一个简单的例子

**step1：写一个example.proto文件**

	message Person {
	  required int32 id = 1;
	  required string name = 2;
	  optional string email = 3;
	}

**step2：使用protoc编译，生成指定程序类型的代码（example.pb.h, example.pb.cc）**

	protoc -I=$SRC_DIR --cpp_out=$DST_DIR $SRC_DIR/example.proto

**step3：使用生成的代码**

序列化代码片段：

```
Person person;
person.set_id(123);
person.set_name("Bob");
person.set_email("bob@example.com");
 
fstream out("person.pb", ios::out | ios::binary | ios::trunc);
person.SerializeToOstream(&out);
out.close();
```

反序列化代码片段：

```
Person person;
fstream in("person.pb", ios::in | ios::binary);
if (!person.ParseFromIstream(&in)) {
  cerr << "Failed to parse person.pb." << endl;
  exit(1);
}
 
cout << "ID: " << person.id() << endl;
cout << "name: " << person.name() << endl;
if (person.has_email()) {
  cout << "e-mail: " << person.email() << endl;
}
```

### 3. 更多参考资料

1. Protobuf下载：<https://code.google.com/p/protobuf/>  
2. Protobuf文档：<https://developers.google.com/protocol-buffers/?hl=zh-CN>  
3. Protobuf编码规则：<https://developers.google.com/protocol-buffers/docs/encoding?hl=zh-CN>  
4. Protocol Buffer Basics: C++ <https://developers.google.com/protocol-buffers/docs/cpptutorial?hl=zh-CN>  