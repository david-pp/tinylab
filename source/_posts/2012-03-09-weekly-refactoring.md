---
layout: post
title: 每周一荐：重构
category : 每周一荐
tags : []
date: 2012-03-09 09:07 +0800
---

### 书籍：《重构：改善既有代码的设计》


#### 简介

Martin Fowler和《重构:改善既有代码的设计》(中文版)另几位作者清楚揭示了重构过程，他们为面向对象软件开发所做的贡献，难以衡量。《重构:改善既有代码的设计》(中文版)解释重构的原理（principles）和最佳实践方式（best practices），并指出何时何地你应该开始挖掘你的代码以求改善。《重构:改善既有代码的设计》(中文版)的核心是一份完整的重构名录（catalog of refactoring），其中每一项都介绍一种经过实证的代码变换手法（code transformation）的动机和技术。某些项目如Extract Method和Move Field看起来可能很浅显，但不要掉以轻心，因为理解这类技术正是有条不紊地进行重构的关键。

![重构](/images/2012-03-09-1.jpg)

#### 笔记

##### Composing Methods

Extract Method: 你有一段代码可以被组织在一起并独立起来，将其放入一个独立的函数，并让函数名称解释该函数的用途

Inline Method: 一个函数，其本体和名称同样清楚易懂，在函数调用点插入函数本体，然后移除该函数

Inline Temp: 你有一个临时变量，只被一个简单表达式赋值一次，将所有对该变量的引用，替换为对它赋值的那个表达式自身

Replace Temp With Query: 你的程序以一个临时变量保存某一个表达式的运算结果，将这个表达式提炼到一个独立的函数中，将这个临时变量的所有被引用点替换为对新函数的调用。新函数也可以被其它函数使用。

Introduce Explaining Variable: 你有个复杂的表达式，将该复杂的表达式或其中的一部分的结果放进一个临时变量，以此变量名称来解释表达式的用途

Split Temporary Variable: 你的程序有某个临时变量被赋值超过一次，它既不是循环变量，也不是一个集用临时变量。针对每次赋值，创造一个独立的、对应的临时变量。

Remove Assignments to Parameters: 你的代码对一个参数进行赋值动作，以一个临时变量取代该参数的位置

Replace Method With Method Object: 你有一个大型函数，其中对局部变量的使用，使你无法使用Extract Method。将这个函数放入一个单独的对象，如此一来局部变量就变成了对象内的值域，然后你尅在同一个对象中将这个大型函数分解为数个小型函数。

Substitute Algorithm: 你想要把某个算法替换为另一个更清楚的算法，将函数本体替换为另外一个算法。

##### Moving  Feature Between Object

Move Method: 你的程序中，有个函数与其所驻class之外的另外一个class进行更多交流（调用或者，或被后者调用）。在该函数最长引用的class中建立一个有着类似行为的新函数。将旧函数变成一个单纯的委托函数，或是将旧函数完全删除。

Move Field: 你的程序中，某个值域被其所驻class之外的另一个classs更多的用到。在target class建立一个new field，修改source field的所有用户，令它们改用 new field。

Extract Class: 某个class做了应该由两个classes做的事。建立一个新class，将相关的值域和函数从旧class搬移到新class。

Inline Class: 你的某个class没有做太多事情（没有承担足够责任）。将class的所有特性搬移到另外一个class中，然后移除原class。

Hide Delgate: 客户直接调用server object（服务对象）的delegate class。在server端（某个class）建立客户所需的所有函数，用以隐藏委托关系。

Remove Middle Man: 某个class做了过多的简单委托动作。让客户端直接调用delegate（受托类）。

Introduce Foreign Method: 你所使用的server class 需要一个额外的函数，但你无法修改这个class。在client class中建立一个函数，并以一个server class实体作为第一个参数。

Introduce Local Extension: 你所使用的server class需要一些额外的函数，但你无法修改这个class。建立一个新class，使它包含这些额外函数。让这个扩展品成为source class的subclass（子类）或 wrapper（外覆类）。

##### Organizing Data

Self Encapsluate: 你直接访问一个值域，但与值域直接的耦合关系逐渐变得笨拙。为这个值域建getting/setting methods，并且以这些函数来访问值域。

Replace Data Value with Object: 你有一比数据项，需要额外的数据和行为。你将这笔数据变成一个对象。

Change Value to Reference: 你有一个class，衍生出许多相等实体，你希望将它们替换为单一对象。将这个value object变成一个reference object。

Change Reference to Value: 你有个reference object，很小且不可变，而且不易管理。将它鞭策一个value object。

Replace Array with Object: 你有一个数组，其中的元素各自代表不同的东西。以对象替换数组，对于数组中的每个元素，以一个值域表示。

Duplicate Observed Object: 你有一些domain data置于GUI控件中，而domain Method 需要访问之。将该数据copy 到一个domain object中，建立一个Observer模式，用以对domain object和GUI object内的重复数据进行同步控制。

Change Unidirectional Association to Bidirectional : 两个classes都需要对方的特性，但期间只有一条单向连接。添加一个反向指针，并使修改函数能够同时更新两条连接。

Change Bidirectional Association to Unidirectional: 两个classes直接有双向关联，但其中一个class如今不再需要另一个class的特性。去除不必要的关联。

Replace Magic Number with Symbolic Constant: 你有一个字面数值，带有特别的含义。创造一个常量，根据其意义为它命名，并将上述的字符数值替换为这个常量。

Encapsulate Filed: 你在class中一个public值域，将它声明为private，并提供相应得分访问函数。

Encapsulate Collection: 有个函数返回一个群集，让这个函数返回该群集的一个只读映像，并在这个class中提供添加/删除群集元素的函数。

Replace Record with Data class: 你需要面对传统编程环境中的record struct。为该record创建一个哑数据对象。

Replace Type Code with Class : class之中有一个数值型别码，但它并不影响class的行为。以一个新class替换该数值型别码。

Replace Type Code with Subclass: 你有一个不可变的type code，它会影响class的行为。以一个subclass取代这个type code。

Replace Type Code with State/Stratgery: 你有 一个type code，它会影响class的行为，但你无法使用subclassing。以state object取代type code。

Replace Subclass with Fields: 你的各个subclass的唯一差别只在返回常量数据的函数身上。修改这些函数，使它们返回superclass中的某个值域，然后销毁subclass。

##### Simplifing Conditional Expression

Decompose Condtional: 你有一个复杂的条件语句，从if、then、else三个段落中分别提取出独立函数。

Consolidate Condtional Expression: 你有一系列条件测试，都得到相同的结果。将这些测试合并为一个条件式，并将这个条件式提炼成为一个独立函数。

Consolidate Duplicate Condtional Fragment: 在条件式的每个分支上有着相同的一段代码。将这段代码搬移到条件式之外。

Remove Control Flag: 在一系列布尔表达式中，某个变量带有控制标记的作用。以break语句或return语句取代控制标记。

Replace Nested Condtional wiht Guard Clauses: 函数中的条件逻辑使人难以看清楚正常的执行路径。使用卫语句表现所以特殊情况。

Replace Conditional with Polymorphism: 你手上有个条件式，它根据对象型别的不同而选择不同的行为。将这个条件表达式的每个分支放进一个subclass内的覆写函数中，然后将原函数声明为抽象函数。

Introduce Null Object: 你需要再三检查某物是否为null value，将null value替换为null object。

Introduce Assertion: 某一段代码需要对程序状态作出某种假设，以断言明确表现这种假设。

##### Making Method Calls Simpler

Rename Method: 函数的名称未能揭示函数的用途，修改函数的名称。

Add Parameter : 某个函数需要从调用端得到更多信息，为此函数添加一个对象参数，让该对象带进函数所需信息。

Remove Parameter: 函数本体不再需要某个参数，将该参数删除。

Seperate Query from Modifier: 某个函数既返回对象状态值，又修改对象状态，建立两个不同的函数，其中一个负责查下，另一个负责修改。

Parameterize Method: 若干函数做了类似的工作，但在函数本体中却包含了不同的值，建立一个单一函数，以参数表达那些不同的值。

Replace Parameter with Explict Methods: 你有一个函数，其内完全取决于参数采取不同的反应。针对该参数的每一个可能值，建立一个对立函数。

Preserver Whole Object :你从某个对象中取出若干值，将他们昨晚某一次函数调用时的参数。改使用传递整个对象。

Replace Parameter with Methods: 对象调用某个函数，并将所得结果作为参数，传递给另一个函数。而接收该参数的函数也可以调用前一个函数。让参数接受者去除该项参数，并直接调用前一个函数。

Introduce Parameter Object :  某些参数总是很自然的同时出现，以一个对象取代这些参数。

Remove Setting Method: 你的clas中的某个值域，应该在对象初始时被设值，然后就不再改变。去掉该值域的设值函数。

Hide Method: 有一个函数，从来没有被其它任何class用到。将这个函数修改为private。

Replace Constructor with Factory Method: 你希望在创建对象时不仅仅是对它做简单的建构动作。将构造函数替换为工厂函数。

Encapsulate Downcast: 某个函数返回的对象，需要由函数调用者执行向下转型动作。将down-cast动作移动到函数中。

Replace Error Code with Exception: 某一个函数返回一个特定的代码，用以表示某种错误情况。改用异常。

Replace Exception with Test: 面对一个调用者可预先加以检查的条件，你抛出了一个异常。修改调用者，使它在调用函数之前先做检查。

##### Dealing with Generalization

Pull Up Field: 两个subclass拥有相同的值域，将此一值域移至superclass

Pull Up Method: 有些函数，在各个subclass中产生完全相同的结果，将该函数移至superclass

Pull Up Constructor Body: 你在各个subclass中拥有一些构造函数，他们的本体代码几乎完全一致。在superclass中新建一个构造函数，并在subclass构造函数中调用它

Push Down Method: superclass中的某个函数只与部分而非全部subclass有关。将这个函数移到相关的那些subclass去

Push Down Field: superclass中的某个值域只被部分而非全部subclass用到。将这个值域移到需要它的那些subclass去

Extract Subclass: class中的某些特性只被某些而非全部实体用到。新建一个subclass，将上面所说的那一部分特性移到subclass中

Extract Superclass: 两个class有些相似特性。为这两个classes建立一个superclass，将相同特性移到superclass

Extract Interface: 若干客户使用class接口中的同一子集；或者，两个classes的接口有部分相同。将相同的子集提炼到一个独立的接口中。

Collapse Hierarchy: superclass和subclass直接无太大区别，将它们合为一体。
Form Template Method: 你有一些subclasses，其中相应的某些函数以相同的顺序执行类似的措施，但各措施实际上有所不同。将各个措施分别放进独立函数中，并保持它们都有相同的签名式，于是原函数也就变得相同了。然后将原函数移到superclass。

Replace Inheritence with Delegation: 某个subclass只使用superclass接口中的一部分，或是根本不需要继承而来的数据。在subclass中新建一个值域用以保存superclass；调整subclass函数，令他改而委托superclass；然后去掉两者直接的继承关系。

Replace Delegation with Inheritence: 你在两个classes之间使用委托关系，并经常为整个接口编写许多及其简单的请托函数（delegating method），让请托class继承受托class。


##### Big Refactoring

Tease Apart Inheritance: 某个继承体系同时承担两项责任。建立两个继承体系，并通过委托关系让其中一个可以调用另一个。

Convert Procedural Design to Objects: 你手上有一些代码，以传统的过程化风格写就。将数据记录变成对象，将行为分开，并将行为移入对象之中。

Seperate Domain from Presentation: 某些GUI class之中包含了domain logic。将domain logic分离出来，为它们建立独立的domain classes。

Extract Hierarchy: 你有某些class做了太多工作，其中一部分工作是以大量条件式完成的。建立继承体系，以一个subclass表示一种特殊情况。


### 书籍：《重构手册》

#### 简介

利用这本通过示例“说话”的实例手册，可以充分发挥重构的强大功能，改善现有的软件。

身为程序员，你必须具备的一个基本功就是能够找出并改善有问题的代码，使程序能够在软件的整个生命周期中正常运转。重构可谓是安全地改善既有代码设计的一门艺术，由此可以提供高效而可靠的系统，使纷杂凌乱归于平稳有序，并能最大限度地抑制异常的出现！重构可能很难掌握，但是在专业顾问William C.Wake所撰写的这本书中，经由作者娓娓道来，有关内容得以通过一种易于学习的方式展现出来，不仅使学习之旅颇具实效，而且充满乐趣。

![重构](/images/2012-03-09-2.jpg)

对于许多人来说，学习重构的最大障碍是如何找出代码的“坏味道（smell）”，即可能存在问题之处。本书并非让你流水帐式地通读这些坏味道，而是确保你对这些坏味道有切实的理解。在此奉上了一系列精心组织的问题，通过这些问题的解决，你将会茅塞顿开，不仅会在更深层次上了解重构，而且还将获得你自己的一些心得体会。Wake采用了实例手册的方式来组织全书，以帮助你了解最为重要的重构技术并将其应用于代码之中。这是一种强调学习的方法，要求你必须充分应用本书所提供的诸多技术。除此之外，这种方法还有一个附带的好处，即尽管当前你所作的工作也许并非重构，利用本书也将有助于你更多地考虑如何创建优质的代码。

### 书籍：《重构与模式》

####简介

本书开创性地深入揭示了重构与模式这两种软件开发关键技术之间的联系，说明了通过重构实现模式改善既有的设计，往往优于在新的设计早期使用模式。本书不仅展示了一种应用模式和重构的创新方法，而且有助于读者结合实战深入理解重构和模式。书中讲述了27种重构方式。

![重构](/images/2012-03-09-3.jpg)

2012/03/09 09:07 于上海