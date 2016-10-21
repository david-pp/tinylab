---
layout: post
title: 已知进程句柄，如何知道此进程的主窗口句柄
category : Windows
tags : [大学时代, Windows]
date: 2008-06-11 13:06:00 +0800
---

已知进程句柄，如何知道此进程的主窗口句柄,在此说明两种方法:

1. 调用FindWindow(),前提是必须知道该进程中窗口类名和窗口名,返回后的句柄可以通过IsWindow()函数来验证是否是有效的窗口句柄.

```

HWND hWnd = ::FindWindow(szClassName, szWndName);  
if(::IsWindow(hWnd))  
{  
      //  处理该窗口  
}  

```

2.先枚举全部窗口,再枚举回调函数中调用GetWindowThreadProcessID()得到窗口得进程ID,再与以前得到得ID比较.如果不一致,不处理,若一致,循环调用GetParent()一直到返回NULL, 最后得hwnd即为顶层窗口句柄

```
BOOL   CALLBACK   EnumWindowsProc(HWND   hwnd,       LPARAM   lParam   )     
 {     
     unsigned   long   id;     
      HWND   thwnd;     
     
      id=GetWindowThreadProcessId(hwnd,NULL);     
      if   (id==lParam)     
     {     
            while((thwnd=GetParent(hwnd))!=NULL)     
                  hwnd=thwnd;     
            CString   x;     
            x.Format("HWND   =   %x",hwnd);     
            MessageBox(NULL,x,NULL,MB_OK);     
            return   false;       
      }     
      return   true;     
 }     
       
     
 void   CMt2Dlg::OnButton1()       
 {     
 //   TODO:   Add   your   control   notification   handler   code   here     
   STARTUPINFO   StartInfo;     
   PROCESS_INFORMATION     ProceInfo;     
   ZeroMemory(&StartInfo,sizeof(StartInfo));     
   StartInfo.cb=sizeof(StartInfo);     
     
   CreateProcess(NULL,   //lpApplicationName:   PChar     
         "calc.exe",   //lpCommandLine:   PChar     
         NULL,   //lpProcessAttributes:   PSecurityAttributes     
         NULL,   //lpThreadAttributes:   PSecurityAttributes     
         true,   //bInheritHandles:   BOOL     
         CREATE_NEW_CONSOLE,     
         NULL,     
        NULL,     
         &StartInfo,     
         &ProceInfo);     
     
   Sleep(100);     //这是必须的,因为   CreateProcess   不能马上Active   windows     
   EnumWindows(EnumWindowsProc,ProceInfo.dwThreadId);     
}

```