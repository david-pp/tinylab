---
layout: post
title: 成绩管理系统的C++实现
tagline: 帮同学做的课程设计
category : 课程设计
tags : [大学时代]
---

帮同学做的课程设计：成绩管理系统，同时学习一下C++，编程实践一下。

<!--more-->

```

//list.h
#pragma once
////////////////////////////////////////////
typedef struct 
{
 long SID;           //学号
 char Name[20];      //姓名
 double DailyScore;  //平时成绩
 double FinalScore;  //期末成绩
 double TotalScore;  //总评成绩
} SCOREINFO;
////////////////////////////////////////////
struct NODE
{
 SCOREINFO  ScoreInfo;
 struct NODE * next;
};
typedef struct NODE Node;
typedef Node *  Link;
///////////////////////////////////////////

class List
{
 Link Head;
public:
 List(void);
 ~List(void);
 Link CreateList(void);                   //创建链表
 int  PrintList(void);                    //打印链表的内容
 void FreeList(void);                     //释放链表的所有内容
 Link InsertList(SCOREINFO & ScInfo);     //插入一个节点并以学号的顺序排列
 int DeleteList(long sid);               //以学号删除一个节点
 
 int InquireList(long sid,SCOREINFO & ScInfo);         //以学号查询
 Link ModifyList(SCOREINFO & ScInfo);     //修改链表
 Link GetHead(void);
 Link SaveList(char * FileName);
 Link LoadList(char * FileName);
 void SetHead(Link h);
};
//////////////////////////////////////////////
#define SUBNUM 6
class Score
{
private:
 int  ClassID;                          //班级号
    char * SUBNAME[SUBNUM];                //科目名称  
 char  FILENAME[SUBNUM][30];            // 班级号+科目名称=磁盘文件
 Link HEAD[SUBNUM];                     //链表的头指针
 List LIST[SUBNUM];                     //链表对象
    
 char Command[50];                      //选择后所输入的命令
 char SubCommand[3][20];                //分解后的命令子项
 int Choice;                            //选择
 
 List list1;
public:
 Score(int CID);                     //默认为一班的成绩,可以声明时修改
 
 int GetChoice(void);
 
 void InputScore(void);
 void InquireScore(void);
 void ModifyScore(void);
 void DeleteScore(void);
 void SaveChanges(void);
 int ScanCommand(void);
 void QuitSystem(void);
 int GetIndex(char * SubName);
};
 
//list.cpp
#include "./list.h"
#include<iostream>
#include<cstdlib>
#include<fstream>
#include<cstring>
#include<cctype>

using namespace std;
List::List(void)
{
 Head=NULL;
}
void List::SetHead(Link h)
{
 Head=h;
}
List::~List(void)
{
}
//建立链表
Link List::CreateList(void)
{
    Link New,Pointer;
 Head=new  Node;
    if(Head==NULL)  
    std::cout<<"Memory Allocte Failed!/n";
   else
   {
    //建立表头
    std::cout<<"输入一位学生的成绩:/n";
    std::cout<<"学号:";
    std::cin>>Head->ScoreInfo.SID;
    std::cout<<"姓名:";
    std::cin>>Head->ScoreInfo.Name;
    std::cout<<"平时成绩:";
    std::cin>>Head->ScoreInfo.DailyScore;
    std::cout<<"期末成绩:";
    std::cin>>Head->ScoreInfo.FinalScore;
    Head->ScoreInfo.TotalScore=Head->ScoreInfo.DailyScore*0.3+Head->ScoreInfo.FinalScore*0.7;
    Head->next=NULL;
       Pointer=Head;
    while(1)
    {   //建立新结点
     New= new Node;
     
     std::cout<<"输入一位学生的成绩:/n";
           std::cout<<"学号(-1 to end):";
     std::cin>>New->ScoreInfo.SID;
     if(New->ScoreInfo.SID==-1)
      break;
        std::cout<<"姓名:";
     std::cin>>New->ScoreInfo.Name;
        std::cout<<"平时成绩:";
     std::cin>>New->ScoreInfo.DailyScore;
        std::cout<<"期末成绩:";
     std::cin>>New->ScoreInfo.FinalScore;
     New->ScoreInfo.TotalScore=New->ScoreInfo.DailyScore*0.3+New->ScoreInfo.FinalScore*0.7;
     New->next=NULL;
           //将新结点连接在头结点上
     Pointer->next=New;
     Pointer=New;
    }             
   }
      
   return Head;
}
//打印链表
int List::PrintList(void)
{   
 int counter=0; //计数器
    Link Pointer;
 //Pointer指向头结点
 Pointer=Head;
    //显示数据信息
 cout<<"/n学号/t姓名/t平时成绩/t期末成绩/t总评成绩";
    cout<<"/n------------------------------------------------------------------";
 while(Pointer!=NULL)
 {
  std::cout<<"/n"<<Pointer->ScoreInfo.SID;
  std::cout<<"/t"<<Pointer->ScoreInfo.Name;
  std::cout<<"/t"<<Pointer->ScoreInfo.DailyScore;
  std::cout<<"/t/t"<<Pointer->ScoreInfo.FinalScore;
  std::cout<<"/t/t"<<Pointer->ScoreInfo.TotalScore;
  cout<<"/n------------------------------------------------------------------";
        counter++;
    //每一屏可以显示10条信息
    if(counter%10==0)
    {  
     std::cout<<"/nPress Enter to Continue........../n";
     getchar();
     getchar();
     cout<<"/n学号/t姓名/t平时成绩/t期末成绩/t总评成绩";
           cout<<"/n------------------------------------------------------------------";
    }
    //指向下一个结点
    Pointer=Pointer->next;
 }
       return 1;
}
//////////////////////////////////////////////
void List::FreeList(void)
{
 Link Pointer;
 while(Head!=NULL)
 {
  Pointer=Head;
  Head=Head->next;
  delete Pointer;
 }
}
//向链表中插数据信息(按学号由大到小顺序插入)
Link List::InsertList(SCOREINFO & ScInfo)
{
 Link Pointer,New,Back;
 //同时指向头结点,不论链表是否为空
 Pointer=Head;
 Back=Head;
    //要插入的结点
 New=new Node;
 New->ScoreInfo=ScInfo;
 New->next=NULL;
  
 //如果链表为空,或者要插入的学号小于已存在链表头结点的学号,则插入头结点
 if(Pointer==NULL||(Pointer->ScoreInfo.SID>New->ScoreInfo.SID))
   {
      New->next=Head;
      Head=New;
   }
  else 
  {  
   //插入到链表中或尾部
   while(Pointer->ScoreInfo.SID<New->ScoreInfo.SID)
    {  
     Back=Pointer;
     Pointer=Pointer->next;
              if(Pointer==NULL)
     {  
      //插到链表尾部
      Back->next=New;
      goto end;
     }
    }
    //插到链表中间
    New->next=Pointer;
    Back->next=New;
   } 
    
    end:
 return Head;
}
// 依学号删除链表中的结点
// 返回为 0 时,表明没有找到(包括链表为空,没找到)
// 返回为 1 时,表明找到并删除了找到的结点
int List::DeleteList(long sid)       
{
    Link Pointer;
    Link Back;
 //指向同一结点
 Pointer=Head;
 Back=Head;
 //如果链表为空
    if(Pointer==NULL)
   return 0;
    //删除链表头结点
 if(Head->ScoreInfo.SID==sid)
 {
        Head=Pointer->next;
  delete Pointer;
  return 1;
 }
   //删除链表尾和中间的结点
    //跳过头结点
 Back=Pointer;
 Pointer=Pointer->next;
 while(Pointer->ScoreInfo.SID!=sid)
 {
  Back=Pointer;
  Pointer=Pointer->next;
  //没有找到
  if(Pointer==NULL)
      return 0;
 }
 //删除表中的结点或表尾的结点
 Back->next=Pointer->next;
 delete Pointer;
 return 1;
}
//查询链表,如果找到的话就返回找的结点
//返回值为0时: 表示链表为空,或者没有找到该结点
//返回值为1时: 表示找到要找的结点
int List::InquireList(long sid,SCOREINFO & ScInfo)
{
    Link Pointer;
    Link Back;
 //指向同一结点
 Pointer=Head;
 Back=Head;
 //如果链表为空
    if(Pointer==NULL)
   return 0;
    //是头结点
 if(Head->ScoreInfo.SID==sid)
 {
  ScInfo=Head->ScoreInfo;
  return 1;
 }
    //跳过头结点
 Back=Pointer;
 Pointer=Pointer->next;
 while(Pointer->ScoreInfo.SID!=sid)
 {
  Back=Pointer;
  Pointer=Pointer->next;
  //没有找到
  if(Pointer==NULL)
      return 0;
 }
 //找到,位于链表中间或链表尾
 ScInfo=Pointer->ScoreInfo;
 return 1;
}
////////////////////////////////////
Link List::ModifyList(SCOREINFO & ScInfo)
{
  Link Pointer;
     Link Back;
  Pointer=Head;
    while(1)
 {
  if(Pointer->next==NULL)
  {
   std::cout<<"Not Found!/n";
   break;
  };
  if(Head->ScoreInfo.SID==ScInfo.SID)
  {
     
   Head=Pointer->next;
   Pointer->ScoreInfo=ScInfo;
   break;
  };
  Back=Pointer;
  Pointer=Pointer->next;
  if(Pointer->ScoreInfo.SID==ScInfo.SID)
  {
   Back->next=Pointer->next;
   Pointer->ScoreInfo=ScInfo;
   break;
  };
 }
 return Head;
}
Link List::GetHead(void)
{
 return Head;
}
//保存链表中的数据到以 FileName指定的磁盘文件
Link List::SaveList(char * FileName)
{    
 Link Pointer;
 Pointer=Head;
    //定义 输出流文件
 std::ofstream fout;
 fout.open(FileName,ios_base::out|ios_base::trunc|ios_base::binary);
 //文件打开失败
 if(!fout.is_open())
 {
  std::cout<<"File Can't Open!/n";
  exit(0);
 }
    //写入文件
 while(Pointer!=NULL)
 {
  fout.write((char *)& Pointer->ScoreInfo,sizeof SCOREINFO);
  Pointer=Pointer->next;
 }
    
 fout.close();
 return Head;
}
//将由FileName指定的文件中的数据读到链表中
Link List::LoadList(char * FileName)
{
    Link New,Pointer;
    //定义输入流文件
 ifstream  fin;
 fin.open(FileName,ios_base::in|ios_base::binary);
 //文件打开失败
 if(!fin.is_open())
 {
  std::cout<<"File Open Erros!/n";
  exit(0);
 }
 //如果链表为空的话
 if(Head==NULL)
 {   
  fin.close();
  return Head;
 }
  //不为空则:
    //建立新结点
 Head=new  Node;
    if(Head==NULL)  
    std::cout<<"Memory Allocte Failed!/n";
   else
   {   
    //建立头结点
    fin.read((char *) &Head->ScoreInfo,sizeof SCOREINFO);
       Head->next=NULL;
       Pointer=Head;
    //读入到链表
    while(1)
    {
     
     New= new Node;
     New->next=NULL;
           if(!fin.read((char *) &New->ScoreInfo,sizeof SCOREINFO))
      break;
     Pointer->next=New;
     Pointer=New;
    }             
   }
      
   return Head;
}

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
Score::Score(int CID)
{    
 
       ////////////////////////可以重新定义要用到的科目名称/////////////////////////
    SUBNAME[0]="Math";      SUBNAME[1]= "Physics"  ;          SUBNAME[2]="English";
       SUBNAME[3]="Chemistry"; SUBNAME[4]= "Biology";            SUBNAME[5]="Chinese";
      //组合文件名
       ClassID=CID;
    for(int i=0;i<SUBNUM;i++)
    {   
     char CIDstr[50];
        itoa(ClassID,CIDstr,10);
     strcpy(FILENAME[i],CIDstr);
     strcat(FILENAME[i],SUBNAME[i]);
     strcat(FILENAME[i],".dat");
     
    }
    
 ///////////////////////////////////////////////////////////////////////////////
     //加载文件里的数据;
    /*
      char cho[10];
      while(1)
      {
         cout<<"是不时第一次操作"<<ClassID<<"班的成绩管理:(Y/N)?/n";
      cin>>cho;
           //如果是第一次操作该班的成绩
     if(stricmp(cho,"Y")==0)
     {
         for(int i=0;i<SUBNUM;i++)
         {   
       //保存空文件,加载的也时空文件
          LIST[i].SaveList(FILENAME[i]);
                   LIST[i].LoadList(FILENAME[i]);
          }
       break;
    
      }
     //如果不是
      if(stricmp(cho,"N")==0)
   {       
    for(int i=0;i<SUBNUM;i++)
          {  
       List   TempList;
       TempList.LoadList(FILENAME[i]);
       TempList.PrintList();
          LIST[i].LoadList(FILENAME[i]);
       //LIST[i].PrintList();
           }
      break;
   }
      }
     */
    list1.LoadList("1math.dat");
    list1.PrintList();
    //////////////////////////////////////////////////////////////////////////////
    //主菜单选项
    while(1)
    {
     GetChoice();
           if(Choice==6)
      { 
        QuitSystem();
        break;
      }
     switch(Choice)
     {
     case 1: InputScore();
          break;
     case 2: InquireScore();
          break;
     case 3: ModifyScore();
          break;
     case 4: DeleteScore();
          break;
     case 5: SaveChanges();
          break;
     default: cout<<"/nWrong Choice! Please Input Again/n";
     }
    }
     /////////////////////////////////////////////////////////////////////////////
}

//打印主菜单,并作出选择
int Score::GetChoice(void)
{  
 cout<<"/n                                   成绩管理系统                                ";
 cout<<"/n-------------------------------------------------------------------------------";
 cout<<"/n               选项                        |                   帮助           ";
 cout<<"/n       1.   录入成绩(全新录入或新增一条)   | Command> *时 全新输入,+ 时新增 ";
 cout<<"/n       2.   查询成绩(可以查看全部和一条)   | Command>*时 显示所有成绩";
 cout<<"/n                                           | Command>(学号)时显示该学生的成绩项";
 cout<<"/n                                           | Command>(学号 课程名):以某科的成绩";
 cout<<"/n       3.   修改成绩(修改某个学生的成绩)   | Command>(学号):修改该学生所有成绩";
 cout<<"/n                                           | Command>(学号 课程名):以某科的成绩";
 cout<<"/n       4.   删除成绩(删除某个学生的成绩)   | Command>(学号):删除该学生所有成绩";
 cout<<"/n                                           | Command>(学号 课程名):以某科的成绩";
 cout<<"/n       5.   保存所作的修改                 | Choice:5   写入磁盘文件";
 cout<<"/n       6.   退出系统                       | Choice:6   退出该系统";
 cout<<"/n----Choice:";
 cin>>Choice;
 return Choice;
}

/////////////////////////////////////////////////////////////////////////
void Score::InputScore(void)
{
 cout<<"    Command>";
 cin>>Command;
 //Command> *时,输入所有科目的成绩(全新输入)
 if(strcmp(Command,"*")==0)
 {  
  
  for(int i=0;i<SUBNUM;i++)
  {  
   cout<<"/n---------------------------------/n";
      cout<<"-----输入"<<SUBNAME[i]<<"的成绩/n";
            //建立相应的链表
   LIST[i].CreateList();
  }
 }
 //输入某个学生的成绩,(包括他的任何一科),新增一条;
 else if(strcmp(Command,"+")==0)
 {  
  
  long   StuID;
  char   StuName[20];
  SCOREINFO ScoInfo;
  cout<<"-----输入学号:";
  cin>>StuID;
  cout<<"-----输入姓名:";
  cin>>StuName;
  ScoInfo.SID=StuID;
  strcpy(ScoInfo.Name,StuName);
  for(int i=0;i<SUBNUM;i++)
  {   
   cout<<"/n----输入"<<SUBNAME[i]<<"的成绩项/n";
   cout<<"平时成绩:";
   cin>>ScoInfo.DailyScore;
   cout<<"期末成绩:";
   cin>>ScoInfo.FinalScore;
   ScoInfo.TotalScore=ScoInfo.DailyScore*0.3+ScoInfo.FinalScore*0.7;
            //插入相应的链表
   LIST[i].InsertList(ScoInfo);
  }
  
 }
}
//查询选项
void Score::InquireScore(void)
{   
 int num;
 long StuID;
 char SubName[20];
 cout<<"    Command>";
 getchar();
 gets(Command);
 num=ScanCommand();
 if(num==2)
 {
      //输入学号和科目名称,查询该生该科的成绩
      int index;
   SCOREINFO ScoInfo;
      StuID=atol(SubCommand[0]);
   index=GetIndex(SubCommand[1]);
   //如果输入的字符不与科目字符相符则返回
   if(index==-1)
   {
    cout<<" 科目输入有误!/n";
    return ;
   }
   int exist;
   //判断是否存在
   exist=LIST[index].InquireList(StuID,ScoInfo);
   if(exist==0)
   {
    cout<<"/n不存在该学生的成绩/n";
    return ;
   }
   //打印所查到的数据
   cout<<"/n-----"<<StuID<<"号的"<<SUBNAME[index]<<"成绩为:----/n";
   cout<<"/n学号/t姓名/t平时成绩/t期末成绩/t总评成绩";
      cout<<"/n------------------------------------------------------------------";
   std::cout<<"/n"<<ScoInfo.SID;
   std::cout<<"/t"<<ScoInfo.Name;
   std::cout<<"/t"<<ScoInfo.DailyScore;
   std::cout<<"/t/t"<<ScoInfo.FinalScore;
   std::cout<<"/t/t"<<ScoInfo.TotalScore;
   cout<<"/n------------------------------------------------------------------";
  
 }
 if(num==1)
 {  
  if(strcmp(SubCommand[0],"*")==0)
  {
   //打印所有数据
   for(int i=0;i<SUBNUM;i++)
    LIST[i].PrintList();
   
  }
  else
  {  
   //输入学号后显示所有关于该生的成绩
   StuID=atol(SubCommand[0]);
 
   cout<<"/n-----"<<StuID<<"号的成绩为:-----/n";
      cout<<"/n学号/t科目/t姓名/t平时成绩/t期末成绩/t总评成绩";
            cout<<"/n------------------------------------------------------------------";
            for(int i=0;i<SUBNUM;i++)
   {
                 SCOREINFO ScoInfo;
     //判断是否存在
     int exist;
     exist=LIST[i].InquireList(StuID,ScoInfo);
     if(exist==0)
      return ;
                 //显示成绩项
              std::cout<<"/n"<<ScoInfo.SID;
     std::cout<<"/t"<<SUBNAME[i];
              std::cout<<"/t"<<ScoInfo.Name;
              std::cout<<"/t"<<ScoInfo.DailyScore;
              std::cout<<"/t/t"<<ScoInfo.FinalScore;
              std::cout<<"/t/t"<<ScoInfo.TotalScore;
              cout<<"/n------------------------------------------------------------------";
   }
  
  }
  
 }  
}
//修改选项
void Score::ModifyScore(void)
{ 
 
 int num;
 long StuID;
 char SubName[20];
 cout<<"    Command>";
 getchar();
 gets(Command);
 num=ScanCommand();
    
 ////输入学号来改变该学生的所有科目的成绩
 if(num==1)
 {       
           StuID=atol(SubCommand[0]);
     for(int i=0;i<SUBNUM;i++)
   {
                 SCOREINFO ScoInfo,NewScoInfo;
     LIST[i].InquireList(StuID,ScoInfo);
     //显示原来存在的成绩 并输入新的成绩
     NewScoInfo.SID=StuID;
     strcpy(NewScoInfo.Name,ScoInfo.Name);
     cout<<"/n---"<<StuID<<"的原"<<SUBNAME[i]<<"成绩为:/n";
     cout<<"平时成绩:"<<ScoInfo.DailyScore;
     cout<<"修改为:";  cin>>NewScoInfo.DailyScore;
     cout<<"期末成绩:"<<ScoInfo.FinalScore;
     cout<<"修改为:";  cin>>NewScoInfo.FinalScore;
     cout<<"总评成绩:"<<ScoInfo.TotalScore;
     cout<<"修改为:";  
     NewScoInfo.TotalScore=NewScoInfo.DailyScore*0.3+NewScoInfo.FinalScore*0.7;
     cout<<NewScoInfo.TotalScore<<endl;
     //确认是否保存修改
              while(1)
              {  
      char cho[10];
                  cout<<"确认(不放弃所作的修改)(Y/N)?/n";
               cin>>cho;
               if(stricmp(cho,"Y")==0)
               {   
       LIST[i].DeleteList(StuID);
       LIST[i].InsertList(NewScoInfo);
                break;
               }
               if(stricmp(cho,"N")==0)
                        break;
              }
     
   }
 }
 //输入学号和科目名称来修改
 if(num==2)
 {  
  int index;
  SCOREINFO ScoInfo,NewScoInfo;
  StuID=atol(SubCommand[0]);
     index=GetIndex(SubCommand[1]);
     //如果输入的字符不与科目字符相符则返回
     if(index==-1)
     {
    cout<<" 科目输入有误!/n";
    return ;
     }
   LIST[index].InquireList(StuID,ScoInfo);
   //显示原来存在的成绩 并输入新的成绩
   NewScoInfo.SID=StuID;
   strcpy(NewScoInfo.Name,ScoInfo.Name);
   cout<<"/n---"<<StuID<<"的原"<<SUBNAME[index]<<"成绩为:/n";
   cout<<"平时成绩:"<<ScoInfo.DailyScore;
   cout<<"修改为:";  cin>>NewScoInfo.DailyScore;
   cout<<"期末成绩:"<<ScoInfo.FinalScore;
   cout<<"修改为:";  cin>>NewScoInfo.FinalScore;
   cout<<"总评成绩:"<<ScoInfo.TotalScore;
   cout<<"修改为:";  
   NewScoInfo.TotalScore=NewScoInfo.DailyScore*0.3+NewScoInfo.FinalScore*0.7;
   cout<<NewScoInfo.TotalScore<<endl;
   //确认是否保存修改
       while(1)
       {  
     char cho[10];
           cout<<"确认(不放弃所作的修改)(Y/N)?/n";
        cin>>cho;
        if(stricmp(cho,"Y")==0)
        {   
       LIST[index].DeleteList(StuID);
       LIST[index].InsertList(NewScoInfo);
          break;
         }
         if(stricmp(cho,"N")==0)
                break;
        }
 }
}
//删除选项
void Score::DeleteScore(void)
{
 int num;
 long StuID;
 char SubName[20];
 cout<<"    Command>";
 getchar();
 gets(Command);
 num=ScanCommand();
    
 ////输入学号来删除该学生的所有科目的成绩
 if(num==1)
 {   
  StuID=atol(SubCommand[0]);
  cout<<"/n-----"<<StuID<<"号的成绩为:-----/n";
     cout<<"/n学号/t科目/t姓名/t平时成绩/t期末成绩/t总评成绩";
        cout<<"/n------------------------------------------------------------------";
        for(int i=0;i<SUBNUM;i++)
     {
                 SCOREINFO ScoInfo;
     //判断是否存在
     int exist;
     exist=LIST[i].InquireList(StuID,ScoInfo);
     if(exist==0)
      return ;
                 //显示成绩项
              std::cout<<"/n"<<ScoInfo.SID;
     std::cout<<"/t"<<SUBNAME[i];
              std::cout<<"/t"<<ScoInfo.Name;
              std::cout<<"/t"<<ScoInfo.DailyScore;
              std::cout<<"/t/t"<<ScoInfo.FinalScore;
              std::cout<<"/t/t"<<ScoInfo.TotalScore;
              cout<<"/n------------------------------------------------------------------";
          
     //确认是否删除
              while(1)
              {  
      char cho[10];
                  cout<<"确认删除(Y/N)?/n";
               cin>>cho;
               if(stricmp(cho,"Y")==0)
               {   
       LIST[i].DeleteList(StuID);
                break;
               }
               if(stricmp(cho,"N")==0)
                        break;
              }
  }
 }
 //输入学号和科目名称来删除
 if(num==2)
 {  
  int index;
  SCOREINFO ScoInfo;
  StuID=atol(SubCommand[0]);
     index=GetIndex(SubCommand[1]);
     //如果输入的字符不与科目字符相符则返回
     if(index==-1)
     {
    cout<<" 科目输入有误!/n";
    return ;
     }
        LIST[index].InquireList(StuID,ScoInfo);
     //打印所查到的数据
     cout<<"/n-----"<<StuID<<"号的"<<SUBNAME[index]<<"成绩为:----/n";
     cout<<"/n学号/t姓名/t平时成绩/t期末成绩/t总评成绩";
        cout<<"/n------------------------------------------------------------------";
     std::cout<<"/n"<<ScoInfo.SID;
     std::cout<<"/t"<<ScoInfo.Name;
     std::cout<<"/t"<<ScoInfo.DailyScore;
     std::cout<<"/t/t"<<ScoInfo.FinalScore;
     std::cout<<"/t/t"<<ScoInfo.TotalScore;
     cout<<"/n------------------------------------------------------------------";
        
  //确认是否保存修改
       while(1)
       {  
     char cho[10];
           cout<<"确认删除(Y/N)?/n";
        cin>>cho;
        if(stricmp(cho,"Y")==0)
        {   
       LIST[index].DeleteList(StuID);
          break;
         }
         if(stricmp(cho,"N")==0)
                break;
        }
 }
}
//////////////////////////////////////////////
void Score::SaveChanges(void)
{
 for(int i=0;i<SUBNUM;i++)
 {
  LIST[i].SaveList(FILENAME[i]);
 }
}
///////////////////////////////////////////
int Score::ScanCommand(void)               //扫描字符串,将其以空格分解为子字符串
{  
 int word,num,i,j;
 word=num=i=0;                         //计数器
 while(Command[i]!='/0')
 {
  if(isspace(Command[i]))           //如果字符为空
   word=0;                       //则word=0
  else
  {
   if(word==0&&isgraph(Command[i]))      //当word的状态发生变化时才执行
   {
    word=1;
    num++;
    j=0;
   }
   SubCommand[num-1][j]=Command[i];     //为子字符串赋值
   SubCommand[num-1][j+1]='/0';         //j的后一个字符为/0--结束字符
   j++;
  }
  i++;
 }
   
 return num;
}
/////////////////////////////////////////////////
void Score::QuitSystem(void)
{
  char cho[10];
  while(1)
  {
      cout<<"是否保存所做的修改(Y/N)?/n";
   cin>>cho;
  if(stricmp(cho,"Y")==0)
  {
      SaveChanges();
   break;
  }
   if(stricmp(cho,"N")==0)
         break;
  }
}
////////////////////////////////
//根据字符来求其下标,若返回为-1则说明没有该字符
int Score::GetIndex(char * SubName)
{  
 for(int i=0;i<SUBNUM;i++)
 {
  if(stricmp(SubName,SUBNAME[i])==0)
     return i;
 }
 
    return -1;
}
 
//main.cpp
#include<iostream>
#include<cstring>
#include "List.h"
using namespace std;

main()
{  
 
    List list1;
 Link head;
 //list1.CreateList();
 SCOREINFO ScoInfo,ScoInfo1,ScoInfo2;
 ScoInfo.SID=20;
 strcpy(ScoInfo.Name,"王大伟");
 ScoInfo.DailyScore=98;
 ScoInfo.FinalScore=90;
 ScoInfo.TotalScore=ScoInfo.DailyScore*0.3+ScoInfo.FinalScore*0.7;
 ScoInfo1.SID=10;
 strcpy(ScoInfo1.Name,"David");
 ScoInfo1.DailyScore=98;
 ScoInfo1.FinalScore=89;
 ScoInfo1.TotalScore=ScoInfo1.DailyScore*0.3+ScoInfo1.FinalScore*0.7;
 ScoInfo2.SID=21;
 strcpy(ScoInfo2.Name,"Jams");
 ScoInfo2.DailyScore=80;
 ScoInfo2.FinalScore=89;
 ScoInfo2.TotalScore=ScoInfo2.DailyScore*0.3+ScoInfo2.FinalScore*0.7;
 list1.InsertList(ScoInfo);
 list1.InsertList(ScoInfo1);
 list1.InsertList(ScoInfo2);
 //list1.DeleteList(10);
 //list1.DeleteList(20);
 
 //list1.CreateList();
   // int re;
 //re=list1.DeleteList(21);
 //cout<<re;
 /*
 list1.PrintList();
 SCOREINFO sc;
 re=list1.InquireList(21,sc);
 if(re==1)
 {
 cout<<re;
 cout<<"/nsid:"<<sc.SID;
 cout<<"/nname:"<<sc.Name;
 cout<<"/npinshi:"<<sc.DailyScore;
 cout<<"/nfinal:"<<sc.FinalScore;
 cout<<"/nTotal:"<<sc.TotalScore;
 }
 else
  cout<<"/nLink is NULL";
 //list1.PrintList();
 //list1.SaveList("ha.dat");
 list1.LoadList("ha.dat");
 list1.InsertList(ScoInfo);
 list1.PrintList();
   */
    //Score score(1);
 list1.LoadList("1math.dat");
 list1.PrintList();
 list1.InsertList(ScoInfo);
   
 List l[2]={List(),List()};
 
 //list1.SaveList("1math.dat");
 //l[0].LoadList("1math.dat");
 l[0]=list1;
 l[0].PrintList();
 
 
 getchar();
 getchar();
}
```