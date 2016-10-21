---
layout: post
title: 一个用于显示数值曲线的类
category : Windows
tags : [大学时代, Windows]
date: 2008-06-06 02:50:00 +0800
---

最近在做一个课题，要显示几条数值曲线。不过不想借助其它控件，或其它公司提供的开发包，如MATCOM，用这些的话就太简单不过了。下面是一个自己设计的一个类，用API堆的，这样既可以在基于SDK应用开发应用，又可以在MFC框架中应用。下面几个图是测试时截的。在此声明一下，我是一新手，难免设计的不合理甚至错误百出，敬请见谅！点此下载源代码和示例代码(http://download.csdn.net/detail/future_fighter/485567)。


![显示多条曲线](/images/2008-06-06-1.JPG)

图1  显示多条曲线

![显示坐标提示](/images/2008-06-06-2.JPG)

图2 显示坐标提示

![坐标系显示范围缩放](/images/2008-06-06-3.JPG)

图3 坐标系显示范围缩放
 
    
类名为CChart，其基类为CChartBase。CChartBase主要用于显示，设置坐标系的一些属性，比如x，y轴可以显示的范围、坐标系边框颜色、背景颜色等；而CChart则用于显示坐标系和多条曲线，曲线颜色、线宽、等凡是可见的属性都可以设定。用法如下：
 
1． 将DispChart.h和DispChart.cpp包含至用使用该类的Project中，若为基于MFC项目，则在DispChart.cpp中添加#include ”stdafx.h”。

2． 定义一个该类的变量，CChart chart(hWnd); hWnd是该坐标所在窗口的句柄。

3． （可选）设置相应的属性。如：
   
```

 chart.SetGridColor(RGB(255,0,0));    // 设置网格颜色  
 chart.SetGriddx(10);                 // 设置网格x轴间隔  
 chart.SetClrLabel(RGB(0,0,255));     // 标尺颜色  
 chart.SetXLabel("t/min");            // 轴标文字  
 chart.SetYLabel("V/v");  
 chart.SetRulerXFormat("%.2f");       // x轴标尺显示精度  
 chart.SetGriddy( 0.01);  
 chart.SetXRange( 0, 100);            // x轴可以显示的范围  
 chart.SetYRange( -5, 5);   

```

4． 添加曲线数据连接，曲线数据必须是vector<double>型的。如：

```

   std::vector<double> data[3];
   int length = 1000;
   double amp = 5;
   for(int i=0;i<length;i++)
   {
    double t = (20 * 3.1415926 / length) * i;
    double y1 = amp*sin(t);
    double y2 = (amp/2)*cos(t);
    data[0].push_back(t);
    data[1].push_back(y1);
    data[2].push_back(y2);
   }
   chart.AddMCurves(data,3);
   chart.SetCurveColor(0,RGB(0,0,0));
```   

 
5． 在WM_PAINT消息或其它地方绘制曲线。先设置显示在那个位置，然后绘制。

```
    
case WM_PAINT:  
        hdc = BeginPaint(hWnd, &ps);  
        // TODO: 在此添加任意绘图代码..  
        RECT rect;  
        GetClientRect(hWnd,&rect);  
  
        chart.SetChartDC(hdc);  
   
        chart.SetChartAndWindowPosition(rect);  
          
         chart.ShowCurves();  
  
        EndPaint(hWnd, &ps);  
        break;  
```   
 
6． （可选）若要动态缩放、平移、左键点击显示坐标提示窗口、右键框选缩放，则只需在相应的消息处理处添加相关操作即可。注意：由于我是用该类绘制周期性的曲线的，所以平移和缩放只是x轴的；若要同时平移或缩放，在CChart::OnMouseWheel函数中将ScaleX改变为ScaleCenter即可以完成x，y轴同时缩放，在CChart::OnMouseMove函数中修改Move的第二参数为-(y - m_ptLeftButtonDown.y) * GetYPerPix()即可以完成x，y轴同时移动。

```

if( m_ptLeftButtonDown.x != -1)
{
 Move( -(x - m_ptLeftButtonDown.x) * GetXPerPix() , -(y - m_ptLeftButtonDown.y) * GetYPerPix());
    
 m_ptLeftButtonDown.x = x;
 m_ptLeftButtonDown.y = y;
 
// 绘制曲线和坐标系
 ShowCurves();
}
```   

示例代码：
```

case WM_LBUTTONDOWN:  
          
        chart.OnLeftButtonDown(LOWORD(lParam), HIWORD(lParam));  
        break;  
    case WM_LBUTTONUP:  
        chart.OnLeftButtonUp(LOWORD(lParam), HIWORD(lParam));  
        break;  
    case WM_RBUTTONDOWN:  
        chart.OnRightButtonDown(LOWORD(lParam), HIWORD(lParam));  
        break;  
    case WM_RBUTTONUP:  
        chart.OnRightButtonUp(LOWORD(lParam), HIWORD(lParam));  
        break;  
    case WM_MOUSEMOVE:  
        chart.OnMouseMove(LOWORD(lParam), HIWORD(lParam));  
        break;  
    case 0x020A/*WM_MOUSEWHEEL*/:  
        {  
            POINT pt = { LOWORD(lParam), HIWORD(lParam) };  
            ScreenToClient( hWnd,&pt );  
            chart.OnMouseWheel(wParam, pt.x, pt.y);  
        }  
        break;  
```  

```

#ifndef _DISPCHART_H  
#define _DISPCHART_H  
#include <windows.h></windows.h>  
#include <vector></vector>  
#include <string></string>  
  
// 图表基类:用于绘制坐标系和曲线  
class CChartBase  
{  
protected:  
    HDC       m_hChartDC;       // 图表绘制的DC  
    RECT      m_rtWindow;       // 坐标窗口,其中包含图表显示区和坐标标尺,轴标等      
    RECT      m_rtChart;        // 图标显示区(依赖域m_rtWindow)  
  
    // 坐标显示边界  
    double    m_xStart;         // 实数域内x轴起点  
    double    m_xEnd;           //         x轴终点  
    double    m_yStart;         //         y轴起点  
    double    m_yEnd;           //         y轴终点  
  
    // 显示图表区  
    COLORREF  m_clrChartBg;     // 显示区背景色  
    COLORREF  m_clrChartBorder; //       边框色  
  
    // 网格  
    bool      m_bGridOn;        // 控制网格是否显示  
    double    m_dxGrid;         // 网格单元宽  
    double    m_dyGrid;         // 网格单元高  
    COLORREF  m_clrGrid;        // 网格线颜色  
  
    // 坐标轴,轴标,标尺  
    char      m_xLabel[20];  
    char      m_yLabel[20];  
    bool      m_bxLabelOn;   
    bool      m_byLabelOn;  
  
    bool      m_bxRulerOn;  
    bool      m_byRulerOn;  
    char      m_szRulerXFormat[128];  
    char      m_szRulerYFormat[128];  
  
    COLORREF  m_clrLabel;      // 轴标文字和刻度文字颜色  
  
    // 文字字体  
    LOGFONT     m_logFont;  
  
    // 曲线数据  
  
public:  
  
    // 辅助函数  
    void SetChartDC(HDC hdc);  
    HDC  GetChartDC() const ;  
    void SetChartWindowPosition(RECT rect);  
    void SetChartWindowPosition(int left, int top, int right, int bottom);  
    RECT GetChartWindowPosition() const;  
    void SetChartPosition(RECT rect);  
    void SetChartPosition(int left, int top, int right, int bottom);  
  
    RECT GetChartPosition() const;  
    int  GetChartWidth()const  { return m_rtChart.right - m_rtChart.left ; };  
    int  GetChartHeight()const { return m_rtChart.bottom - m_rtChart.top ; };  
    int  GetChartWindowWidth() const { return m_rtWindow.right - m_rtWindow.left; };  
    int  GetChartWindowHeight() const{ return m_rtWindow.bottom - m_rtWindow.top; };  
  
    // 坐标显示边界  
    double SetXStart(double xStart);  
    double SetXEnd(double xEnd);  
    void   SetXRange(double xStart,double xEnd);  
    double SetYStart(double yStart);  
    double SetYEnd(double yEnd);  
    void   SetYRange(double yStart,double yEnd);  
    double GetXStart()const;  
    double GetXEnd()const;  
    double GetYStart()const;  
    double GetYEnd()const;  
      
    // 显示图表区  
    void      SetClrChartBg(COLORREF clr);  
    COLORREF  GetClrChartGb()const;  
    void      SetClrChartBorder(COLORREF clr);  
    COLORREF  GetClrChartBorder()const;  
  
    // 网格  
    double   SetGriddx(double dxGrid);              // 设置网格宽度,返回前一个值  
    double   SetGriddy(double dyGrid);              // 设置网格高度,返回前一个值  
    void     SetGridxy(double dxGrid,double dyGrid);  
    COLORREF SetGridColor(COLORREF color);          // 设置网格颜色,返回前一个值  
    void SetGridOn();                               // 设置网格为显示状态  
    void SetGridOff();                              // 设置网格为关闭状态  
  
    double   GetGriddx()const;  
    double   GetGriddy()const;  
    COLORREF GetGridColor()const;  
    bool     GetGridStatus()const;  
  
    // 坐标轴,轴标,标尺  
    void    SetXLabel(const char* xLabel);  
    void    SetYLabel(const char* yLabel);  
    void    SetXLabelOn();  
    void    SetXLabelOff();  
    BOOL    GetXLabelStatus()const;  
    void    SetYLabelOn();  
    void    SetYLabelOff();  
    BOOL    GetYLabelStatus()const;  
  
    void    SetXRulerOn();  
    void    SetXRulerOff();  
    BOOL    GetXRulerStatus()const;  
    void    SetYRulerOn();  
    void    SetYRulerOff();  
    BOOL    GetYRulerStatus()const;  
  
    void    SetRulerXFormat(const char str[]) { strcpy(m_szRulerXFormat, str);};  
    void    SetRulerYFormat(const char str[]) { strcpy(m_szRulerXFormat, str);};  
  
    void     SetClrLabel(COLORREF clr);  
    COLORREF GetClrLabel()const;  
  
    // 字体  
    void    SetLogFont(LOGFONT logFont);  
    LOGFONT GetLogFont()const;  
  
  
    // 每一个象素所代表的实数值  
    double GetYPerPix() const;  
    double GetXPerPix() const;  
  
protected:  
    int  ShowChartBg();  
    int  ShowGrid();  
    int  ShowRuler();  
    int  ShowLabel();  
  
public:  
    CChartBase();  
    ~CChartBase();  
  
    int ShowAt(int left, int top, int right, int bottom); // 在rect中显示该图标窗口,外部最好用该函数  
    int ShowAt(RECT rect);  
    int Show();                                           // 通过设置各种参数显示  
  
    // 坐标转换 r--real  s--screen 2--to  
    int rx2sx(double rx);    
    int ry2sy(double ry);  
    double sx2rx(int sx);  
    double sy2ry(int sy);  
  
    // 坐标变换  
    void Move(double drx, double dry);                   // 坐标系平移  
    void ScaleCenter(double times);                      // 坐标以坐标框的中心放缩  
                                                         // times>1时,显示范围扩大,起到缩小的作用  
                                                         // times<1时,显示范围缩小,起到放大的作用  
    void ScaleX(double times);                           // X轴范围缩放（以x轴中心）  
    void ScaleY(double times);                           // Y轴范围缩放（以y轴中心）  
};  
  
class CChart:public CChartBase  
{  
private:  
    HWND       m_hWnd;           // 图表所在的窗口，该窗口可以处理消息（用于实现坐标变换等）  
    HDC        m_memDCWindow;    // 存储整个绘图窗用的内存句柄  
    HBITMAP    m_bmpInDCWindow;    
    HDC        m_memDCChart;     // 存储chart的内存设备句柄  
    HBITMAP    m_bmpInDCChart;   // 图表所对应的位图句柄  
  
    // 曲线数据  
public:  
      
    std::vector  

``` 

