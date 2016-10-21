---
layout: post
title: 应用程序的消息循环
category : Windows
tags : [大学时代, Windows]
---

Windows是消息驱动的，它的消息循环部分主要是通过GetMessage函数来处理消息的。操作系统为每一个创建的窗口维护着一个消息队列，当在该窗口上有事件发生时，操作系统就把该事件所对应的消息放入该窗口的消息队列中。应用程序要处理事件消息的话，就必须先将消息取出来，主要有两个函数可以实现：GetMessage和PeekMessage。
 
它们两者的功能有所不同：当消息队列中没有消息的时候GetMessage会挂起，将CPU资源让给其他应用程序，当有消息可以处理时，才获得CPU资源并处理。而PeekMessage则不管消息队列有无消息立即返回。
 
一般情况下，GetMessage可以在非FPS（Frame Per Second）应用程序中高效运行。但是当它在FPS（如：游戏）应用中运行时，有时回出现闪屏。故在FPS程序中最好还是用PeekMessage函数。
 
其用法如下：

- **GetMessage**
 
``` 
// 主消息循环:
while (GetMessage(&msg, NULL, 0, 0)) 
{
      if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg)) 
      {
             TranslateMessage(&msg);
             DispatchMessage(&msg);
      }
}
```
 
- **PeekMessage**

```
// 主消息循环:
ZeroMemory(&msg,sizeof(MSG));
while (msg.message != WM_QUIT) 
{
     if(PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
            {
            if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg)) 
            {
                   TranslateMessage(&msg);
                   DispatchMessage(&msg);
            }
     }
     if(!DoFrame()) // 帧处理
            break;
}
```

