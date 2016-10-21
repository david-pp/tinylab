---
layout: post
title: 游戏引擎的简单实现
category : 游戏开发
tags : [大学时代, 游戏引擎]
---


游戏引擎负责处理各种琐碎事务：组件游戏，确保它正确运行及关闭它。将游戏分解为事件：

下面这些事件只适用于任何游戏的部分核心事件：

- **初始化**
- **启动**
- **结束**
- **激活**
- **停用**
- **绘制**
- **循环**
 
初始化事件在一开始运行游戏时发生，这时游戏执行重要的初始设置任务，包括创建游戏引擎本身。启动和结束事件对应于游戏的开始和结束，这时很适合执行与特定的游戏会话相关联的初始化和清理任务。在最小化游戏或者将其发送至后台，然后在恢复时，就将发生激活和停用事件。当游戏需要绘制自身时，将发送绘制事件，类似于WINDOWS WM_PAINT 消息。最后，循环事件使游戏执行一个单独的游戏周期，它非常重要。
 
**游戏的计时机制**：

游戏在指定的时间内运行的周期越多，看起来就越平滑。事实上，大多数游戏设置都在15 － 16周期每秒的范围内，最快的速度可能达到30周期每秒，比电影还快。除了极少数的一些情况外，应该力求达到的最低速度设置为12周期每秒。

**游戏引擎的类**：

``` c

#ifndef _GAMEENGINE_H
#define _GAMEENGINE_H
#include <windows.h>

//游戏事件
BOOL GameInitialize(HINSTANCE hInstance);     //初始化
void GameStart(HWND hWnd);                    //启动
void GameEnd();                               //结束
void GameActivate(HWND hWnd);                 //激活
void GameDeactivate(HWND hWnd);               //停用
void GamePaint(HDC hdc);                      //绘制
void GameCycle();                             //循环


//游戏引擎类
class GameEngine
{
protected:
    static GameEngine * m_pGameEngine;        //指向自身的静态指针
    HINSTANCE           m_hInstance;          //实例句柄
    HWND                m_hWnd;               //窗口句柄
    TCHAR               m_szWndClass[32];     //窗口类名
    TCHAR               m_szTitle[32];        //标题
    WORD                m_wIcon,m_wSmallIcon; //大小图标
    int                 m_iWidth,m_iHeight;   //游戏区的宽和高
    int                 m_iFrameDelay;        //帧的延迟时间(ms)
    BOOL                m_bSleep;             //休眠状态
public:
    GameEngine(HINSTANCE hInstance,LPTSTR szWndClass,LPTSTR szTitle,
               WORD wIcon,WORD wSmallIcon,int iWidth=640,int iHeight=480);
    ~GameEngine();

    static GameEngine * GetEngine() { return m_pGameEngine;};
    BOOL   Initialize(int iCmdShow);
    LRESULT HandlEvent(HWND hWnd,UINT msg,WPARAM wParam,LPARAM lParam);
    
    HINSTANCE   GetInstance() { return m_hInstance ;};
    HWND        GetWindow() { return m_hWnd;};
    void        SetWindow(HWND hWnd){ m_hWnd=hWnd ;};
    LPSTR       GetTitle(){ return m_szTitle ;};
    WORD        GetIcon() { return m_wIcon;};
    WORD        GetSmallIcon() { return m_wSmallIcon; };
    int         GetWidth() { return m_iWidth;};
    int         GetHeight() { return m_iHeight;};
    int         GetFrameDelay() { return m_iFrameDelay ;};
    void        SetFrameDelay(int iFrameRate){ m_iFrameDelay=1000/iFrameRate;};
    BOOL        GetSleep(){ return m_bSleep;};
    void        SetSleep(BOOL bSleep){ m_bSleep=bSleep;};

};

LRESULT CALLBACK WndProc(HWND hWnd,UINT msg,WPARAM wParam,LPARAM lParam);

#endif

```

**其实现文件如下：**

``` c

#include "GameEngine.h"

//静态成员初始化
GameEngine * GameEngine::m_pGameEngine=NULL;
//构造成员函数
GameEngine::GameEngine(HINSTANCE hInstance,LPSTR szWndClass,LPSTR szTitle,
                       WORD wIcon,WORD wSmallIcon,int iWidth,int iHeight)
{
    m_pGameEngine=this;
    m_hInstance=hInstance;
    m_hWnd=NULL;
    if(lstrlen(szWndClass)>0)
        lstrcpy(m_szWndClass,szWndClass);
    if(lstrlen(szTitle)>0)
        lstrcpy(m_szTitle,szTitle);
    m_wIcon=wIcon;
    m_wSmallIcon=wSmallIcon;
    m_iWidth=iWidth;
    m_iHeight=iHeight;
    m_iFrameDelay=50;  //默认为20帧每妙
    m_bSleep=TRUE;
}
//析构成员函数
GameEngine::~GameEngine()
{
}
//引擎初始化
BOOL GameEngine::Initialize(int iCmdShow)
{
    WNDCLASSEX  wc;

    //创建主窗口的类
    wc.cbSize=sizeof(WNDCLASSEX);
    wc.style=CS_HREDRAW|CS_VREDRAW;
    wc.lpfnWndProc=WndProc;
    wc.cbClsExtra=0;
    wc.cbWndExtra=0;
    wc.hbrBackground=(HBRUSH)(COLOR_WINDOW+1);
    wc.hCursor=LoadCursor(NULL,IDC_ARROW);
    wc.hIcon=LoadIcon(m_hInstance,MAKEINTRESOURCE(GetIcon()));
    wc.hIconSm=LoadIcon(m_hInstance,MAKEINTRESOURCE(GetSmallIcon()));
    wc.hInstance=m_hInstance;
    wc.lpszClassName=m_szWndClass;
    wc.lpszMenuName=NULL;

    //注册窗口类
    if(!RegisterClassEx(&wc))
        return FALSE;
    
    //根据游戏大小计算窗口大小和位置
    int iWindowWidth=m_iWidth+GetSystemMetrics(SM_CXFIXEDFRAME)*2;
    int iWindowHeight=m_iHeight+GetSystemMetrics(SM_CYFIXEDFRAME)*2+GetSystemMetrics(SM_CYCAPTION);
    if(wc.lpszMenuName!=NULL)
        iWindowHeight+=GetSystemMetrics(SM_CYMENU);
    int iXWindowPos=(GetSystemMetrics(SM_CXSCREEN)-iWindowWidth)/2;
    int iYWindowPos=(GetSystemMetrics(SM_CYSCREEN)-iWindowHeight)/2;

    //创建窗口
    m_hWnd=CreateWindow(m_szWndClass,m_szTitle,WS_POPUPWINDOW|WS_CAPTION|WS_MINIMIZEBOX,iXWindowPos,iYWindowPos,
                        iWindowWidth,iWindowHeight,NULL,NULL,m_hInstance,NULL);
    if(!m_hWnd)
        return FALSE;
    //显示和更新窗口
    ShowWindow(m_hWnd,iCmdShow);
    UpdateWindow(m_hWnd);
    
    return TRUE;
}
//游戏消息处理函数
LRESULT GameEngine::HandlEvent(HWND hWnd,UINT msg,WPARAM wParam,LPARAM lParam)
{
    switch(msg)
    {
    case WM_CREATE:
        //设置游戏窗口并开始游戏
        SetWindow(hWnd);
        GameStart(hWnd);
        return 0;
    case WM_SETFOCUS:
        //激活游戏并更新休眠状态
        GameActivate(hWnd);
        SetSleep(FALSE);
        return 0;
    case WM_KILLFOCUS:
        //停用游戏并更新休眠状态
        GameDeactivate(hWnd);
        SetSleep(TRUE);
        return 0;
    case WM_PAINT:
        HDC hDc;
        PAINTSTRUCT ps;
        hDc=BeginPaint(hWnd,&ps);
        //绘制游戏
        GamePaint(hDc);
        EndPaint(hWnd,&ps);
        return 0;
    case WM_DESTROY:
        //结束游戏
        GameEnd();
        PostQuitMessage(0);
        return 0;
    }
    return DefWindowProc(hWnd,msg,wParam,lParam);
}


LRESULT CALLBACK WndProc(HWND hWnd,UINT msg,WPARAM wParam,LPARAM lParam)
{
    return GameEngine::GetEngine()->HandlEvent(hWnd,msg,wParam,lParam);
}
//主函数入口
int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPreInstance,PSTR szCommandLine,int iCmdShow )
{   
    MSG msg;
    static int  iTickTriger=0;
    int         iTickCount;

    if(GameInitialize(hInstance))
    {
        if(!GameEngine::GetEngine()->Initialize(iCmdShow))
            return FALSE;
        while(TRUE)
        {
            if(PeekMessage(&msg,NULL,0,0,PM_REMOVE))
            {
                if(msg.message==WM_QUIT)
                    break;
                TranslateMessage(&msg);
                DispatchMessage(&msg);
            }
            else
            {   
                //确保游戏引擎没有休眠
                if(!GameEngine::GetEngine()->GetSleep())
                {
                    //检查滴答计数,查看是否经历了一个周期
                    iTickCount=GetTickCount();
                    if(iTickCount>iTickTriger)
                    {
                        iTickTriger=iTickCount+GameEngine::GetEngine()->GetFrameDelay();
                        //游戏循环
                        GameCycle();
                    }
                }
            }
        }
    }
    //游戏结束
    GameEnd();
    return TRUE;
}

```
 
**其使用方法：**

xxx.h文件要先声明一个全局游戏引擎指针。

``` c

#include "resource.h"
#include "GameEngine.h"

GameEngine * g_pGame; //全局游戏引擎指针

```

然后xxx.cpp文件包含该xxx.h文件，在实现相应的游戏事件：

``` c

#include "Blizzard.h"

BOOL GameInitialize(HINSTANCE hInstance)
{
    g_pGame=new GameEngine(hInstance,TEXT("PRIZE"),TEXT("PRIZE"),IDI_PRIZE,IDI_PRIZE);
    if(g_pGame==NULL)
        return FALSE;
    g_pGame->SetFrameDelay(15);
    return TRUE;
}
void GameStart(HWND hWnd)
{
    srand(GetTickCount());
}
void GameEnd()
{
}
void GameActivate(HWND hWnd)
{
    HDC hDc;
    RECT rect;
    GetClientRect(hWnd,&rect);
    hDc=GetDC(hWnd);
    DrawText(hDc,"Here comes ....",-1,&rect,DT_SINGLELINE|DT_CENTER|DT_VCENTER);
    ReleaseDC(hWnd,hDc);
}
void GameDeactivate(HWND hWnd){}
void GamePaint(HDC hdc){}
void GameCycle()
{
    HDC hDc;
    HWND hWnd=g_pGame->GetWindow();
    hDc=GetDC(hWnd);
    DrawIcon(hDc,rand()%g_pGame->GetWidth(),rand()%g_pGame->GetHeight(),(HICON)(WORD)GetClassLong(hWnd,GCL_HICON));
    ReleaseDC(hWnd,hDc);
}

```

