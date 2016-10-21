---
layout: post
title: 汉诺塔游戏的C++实现
tagline: 自娱自乐学C++
category : 课程设计
tags : [大学时代]
---

昨天没事在用别人的文曲星查字!突然看到那个汉诺塔游戏.....

反正这两天刚好手有点痒,于是就有了:

``` c
#ifndef  HANIO_H_
#define HANIO_H
class  Stack
{
private:
 enum{ MAX=50 };
 int m_node[MAX];
 int m_top;     
 int m_size;
 int m_index;  
public:
 Stack();
 ~Stack() { };
 bool  Isfull()  { return m_top==MAX-1 ;};   //堆栈满则返回TRUE
 bool  Isempty()  { return m_top==-1;};      //堆栈空则返回TRUE
 int Top()  { return m_top; };
 int TopValue() { return m_node[m_top];};
 int GetDataFromIndex(int i) { return m_node[i]; };
 int GetIndex() { return m_index; } ;
 void SetIndex(int index) { m_index = index; };
 int Size()  { return m_top+1; };
 
 bool Push(int data);
 bool Pop(int * pData);
 int  MoveToNext();
 void OutPrint();

};

class Hanio
{
 Stack  m_stack[3];
 int m_num;             //盘数
 int m_steps;           //移动次数
 int m_times;           //完成所用时间
 void print(char ch,int n);
public:
 Hanio(int num=3);
 ~Hanio() {};
 void GameStart();
 bool MoveFromTo(int x,int y);  //从x号盘移动到y号盘
 void DrawPaletes(char ch='*');            //打印3个堆的盘子
 bool IsFinished() ;               //结束返回TURE;
     
 int Solve(char from,char to,char auxiliary,int n);          //求解其解法路径
};

#endif
//hanio.cpp
#include "hanio.h"
#include <iostream>
#include<cstdlib>
#include<cstring>
#include<cctype>
#include<windows.h>
Stack::Stack()
{
 m_top=-1;
 m_index=m_top;
 for(int i=0;i<MAX;i++)
  m_node[i]=0;
}
bool Stack::Push(int data)
{
 if(Isfull())
  return false;
 m_top++;
 m_node[m_top]=data;
 m_index=m_top;
 return true;
}
bool Stack::Pop(int *pData)
{
 if(Isempty())
  return false;
 *pData=m_node[m_top];
 m_node[m_top]=0;
 m_top--;
 m_index=m_top;
 return true;
}
int Stack::MoveToNext()
{
 int temp=m_index;
 m_index--;
 return m_node[temp];
}
void Stack::OutPrint()
{  
 if(m_top!=-1)
 {
     for(int i=0;i<=m_top;i++)
   std::cout<<"["<<m_node[i]<<"]";
 }
}
 
 
///////////////////////////////////////
Hanio::Hanio(int num)
{
 m_num=num;
 m_steps=0;
 m_times=0;
 for(int i=num;i>=1;i--)
  m_stack[0].Push(i);
 //m_stack[0].OutPrint();
}
void Hanio::print(char ch,int n)
{
 for(int i=1;i<=n;i++)
  std::cout<<ch;
}
void Hanio::DrawPaletes(char ch)
{   
 int max;
 max=m_stack[0].Size()>m_stack[1].Size() ? m_stack[0].Size() : m_stack[1].Size();
 max=m_stack[2].Size()>max               ? m_stack[2].Size() : max;
    
 //std::cout<<"Max:"<<max<<std::endl;
 m_stack[0].SetIndex(max-1);
 m_stack[1].SetIndex(max-1);
 m_stack[2].SetIndex(max-1);

 for(int i=1;i<=max;i++)
 {
  int data1=m_stack[0].MoveToNext();
  int data2=m_stack[1].MoveToNext();
  int data3=m_stack[2].MoveToNext();
  if(data1==0)
   print(' ',20);
  else
  {
   print(' ',10-data1);
   print(ch,2*data1);
   print(' ',10-data1);
  }
  
  if(data2==0)
   print(' ',20);
  else
  {
   print(' ',10-data2);
   print(ch,2*data2);
   print(' ',10-data2);
  }
  
  if(data3==0)
   print(' ',20);
  else
  {
   print(' ',10-data3);
   print(ch,2*data3);
   print(' ',10-data1);
  }
  std::cout<<std::endl;
 }
 
}

bool Hanio::MoveFromTo(int x,int y)
{   
 m_steps++;     //计算所走的步数
 if(m_stack[x].Isempty())
 {
  std::cout<<x<<" pallete  is empty ! continue !"<<std::endl;
  std::cin.get();
  return false;
 }
   
 if(m_stack[y].Isempty())
 {   
  int data;
  m_stack[x].Pop(&data);
  m_stack[y].Push(data);
  return true;
 }
 else
 {
  if(m_stack[x].TopValue()>m_stack[y].TopValue())
  {
   std::cout<<"The board can't move from "<<x<<" plate to " <<y<<" plate!"<<std::endl;
   std::cin.get();
   return false;
  }
  else
  {
     int data;
     m_stack[x].Pop(&data);
     m_stack[y].Push(data);
     return true;
  }
 }
}
bool Hanio::IsFinished()
{
 return m_stack[2].Top()==m_num-1;
}
 
void Hanio::GameStart()
{   
 using namespace std;
 UINT StartTime=::GetTickCount();
 UINT EndTime;
 while(1)
 {   
  
   system("cls");
   print('-',80);
   cout<<"steps: "<<m_steps; print(' ',20);
   cout<<"Used time: "<<m_times<<endl;
   print('-',80);
   cout<<endl; cout<<endl; print(' ',10); cout<<"A";
   print(' ',19); cout<<"B"; print(' ',19);
   cout<<"C"<<endl<<endl;
      Hanio::DrawPaletes();
   cout<<endl; cout<<endl;
      print('-',80);
         
   //测试游戏是否结束
   if(Hanio::IsFinished()) 
  {
   cout<<"你好强呀!从今天开始,维护世界和平的任务就交给你那!"<<endl;
   cin.get();
   break;
  }
        //输入命令并左相应的处理
  char szCommand[50];
  cout<<">>";
  cin.getline(szCommand,50);
  if(stricmp(szCommand,"QUIT")==0 || stricmp(szCommand,"Q")==0)
   break;
  if(stricmp(szCommand,"HELP")==0 || stricmp(szCommand,"H")==0)
  {
   cout<<" 本游戏说明  :"<<endl;
   cout<<" 该游戏由DAVID用C++编程,花费了一个多下午的时间呢!!!,由命令行来控制铁饼的移动:"<<endl;
   cout<<"     QUIT / Q   :   退出程序"<<endl;
   cout<<"     HELP / H   :   查看该说明"<<endl;
   cout<<"     XY         :   X,Y的取值为A,B,C,意思时把X木桩最上面的铁饼移到Y木桩"<<endl;
   cout<<"     SOLVE / S  :   显示求解该问题(移动铁饼)的最优路径..."<<endl;
   cin.get();
  }
  
  char ch1=toupper(szCommand[0]);
  char ch2=toupper(szCommand[1]);
     
  if( ch1=='A' && ch2=='B')
   Hanio::MoveFromTo(0,1);
  else if ( ch1=='A' && ch2=='C')
   MoveFromTo(0,2);
  else if ( ch1=='B' && ch2=='A')
   MoveFromTo(1,0);
  else if ( ch1=='B' &&  ch2=='C')
   MoveFromTo(1,2);
  else if ( ch1=='C' &&  ch2=='A')
   MoveFromTo(2,0);
  else if ( ch1=='C' &&  ch2=='B')
   MoveFromTo(2,1);
  else
  {
   cout<<"Bad command !"<<endl;
   cin.get();
  }
         //统计游戏所用时间
         EndTime=GetTickCount();
   m_times=(EndTime-StartTime)/1000;
 }
 
}
int Hanio::Solve(char from,char to,char auxiliary,int n)
{
    if(n==1)
 return 0;
}
//main.cpp
#include<iostream>
#include"hanio.h"
#include<cstdlib>
using namespace std;
int StartPicture();//返回选择的盘数
int main()
{   
 int number;
 number=StartPicture();
    Hanio hanio(number);
 hanio.GameStart();
 return 0;
}

void print(char ch,int n)
{
 for(int i=1;i<=n;i++)
  std::cout<<ch;
}
int StartPicture()
{
 using namespace std;
    int number;
 system("cls");
 system("color fc");
 print(' ',20);
 print('-',25);
 cout<<endl;
 print(' ',20);
 cout<<"       Hanio(汉诺塔)"<<endl;
 print(' ',20);
 print('-',25);
 cout<<endl;
 print(' ',40);
 print('-',5);
 cout<<"By  David"<<endl;
 print('=',80);
 cout<<"  相传在某一座古庙中有3根木桩,有24个铁盘由小到大放置在一根木柱上,庙中流传者一个传说:/"如果能把24个铁盘, 从一根木桩移动到另一个木桩,且必须遵守如下规则:"<<endl;
 cout<<endl;
 print(' ',5);cout<<"1. 每天只能动一个盘,而且只能从最上面的铁盘开始搬动."<<endl;
 print(' ',5);cout<<"2. 必须维持较小的铁盘在上方的原则"<<endl;
 cout<<endl;
 cout<<"这两个原则,则当24个铁盘完全般到另一个木桩时,世界就回永久和平!!"<<endl;
 cout<<"游戏的玩法可以在命令行中输入HELP查看"<<endl;
 cout<<endl;cout<<endl;cout<<endl;cout<<endl;cout<<endl;
 cout<<"再此输入你要搬的铁盘数(建议在1--10值间,太多回花费很长时间的)"<<endl;
 print('=',80);
 cout<<">>";
 cin>>number;
 cin.get();
 system("cls");
 return number;
}

```