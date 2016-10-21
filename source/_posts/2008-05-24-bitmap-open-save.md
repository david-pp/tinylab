---
layout: post
title: 位图文件的打开和保存
category : Windows
tags : [大学时代, Windows]
date: 2008-05-24 15:12:00 +0800
---

下面是两个函数， SaveBmp函数用于设备相关位图(DIB)保存为bmp格式的文件。DrawBitmapFile则用于将bmp格式的文件打开并显示在指定的设备环境上。
 
```

BOOL SaveBmp(HBITMAP hBitmap, const char *FileName)
{
     HDC     hDC;       
     //当前分辨率下每象素所占字节数       
     int     iBits;       
     //位图中每象素所占字节数       
     WORD    wBitCount;       
    //定义调色板大小，位图中像素字节大小，位图文件大小，写入文件字节数   
     DWORD   dwPaletteSize=0,dwBmBitsSize=0, dwDIBSize=0, dwWritten=0;           
     //位图属性结构           
     BITMAP  Bitmap;               
     //位图文件头结构       
     BITMAPFILEHEADER   bmfHdr;               
     //位图信息头结构           
     BITMAPINFOHEADER   bi;               
     //指向位图信息头结构               
     LPBITMAPINFOHEADER lpbi;               
     //定义文件，分配内存句柄，调色板句柄           
     HANDLE  fh,hDib,hPal,hOldPal=NULL;           
                              
     //计算位图文件每个像素所占字节数           
     hDC=::CreateDC("DISPLAY",NULL, NULL, NULL);  
     iBits=::GetDeviceCaps(hDC,BITSPIXEL)* ::GetDeviceCaps(hDC,PLANES);  
     ::DeleteDC(hDC);  

      if(iBits <= 1)         
          wBitCount = 1;  
      else if(iBits <= 4)
          wBitCount = 4;           
      else if(iBits <= 8)
          wBitCount =  8;           
      else                                                                                                                      wBitCount = 24;           
                              
      ::GetObject(hBitmap,sizeof(Bitmap),(LPSTR)&Bitmap);       
     bi.biSize = sizeof(BITMAPINFOHEADER);       
     bi.biWidth = Bitmap.bmWidth;       
     bi.biHeight = Bitmap.bmHeight;       
     bi.biPlanes = 1;       
     bi.biBitCount = wBitCount;       
     bi.biCompression = BI_RGB;       
     bi.biSizeImage = 0;       
     bi.biXPelsPerMeter = 0;       
     bi.biYPelsPerMeter = 0;       
     bi.biClrImportant = 0;       
     bi.biClrUsed = 0;       
                              
     dwBmBitsSize = ((Bitmap.bmWidth * wBitCount + 31) / 32) * 4 * Bitmap.bmHeight;       
                              
     //为位图内容分配内存           
     hDib = ::GlobalAlloc(GHND,dwBmBitsSize + dwPaletteSize + sizeof(BITMAPINFOHEADER));           
     lpbi =(LPBITMAPINFOHEADER)::GlobalLock(hDib);           
     *lpbi = bi;           
      
     //     处理调色板               
     hPal = GetStockObject(DEFAULT_PALETTE);           
     if(hPal)           
     {           
         hDC = ::GetDC(NULL);           
         hOldPal = ::SelectPalette(hDC,(HPALETTE)hPal,FALSE);           
         RealizePalette(hDC);           
     }       
      
     //     获取该调色板下新的像素值           
     GetDIBits(hDC,hBitmap,0,(UINT)Bitmap.bmHeight,(LPSTR)lpbi + sizeof(BITMAPINFOHEADER) +dwPaletteSize,
               (BITMAPINFO*)lpbi,DIB_RGB_COLORS);           
                              
     //恢复调色板               
     if (hOldPal)           
     {           
         ::SelectPalette(hDC,     (HPALETTE)hOldPal,     TRUE);           
         RealizePalette(hDC);           
         ::ReleaseDC(NULL,hDC);           
     }           
      
     //创建位图文件               
     fh = CreateFile(FileName,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,
                     FILE_ATTRIBUTE_NORMAL|FILE_FLAG_SEQUENTIAL_SCAN,NULL);           
                              
     if(fh == INVALID_HANDLE_VALUE)        
         return     FALSE;           
                              
     //     设置位图文件头           
     bmfHdr.bfType = 0x4D42;     //     "BM"           
     dwDIBSize = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + dwPaletteSize + dwBmBitsSize;               
     bmfHdr.bfSize = dwDIBSize;           
     bmfHdr.bfReserved1 = 0;           
     bmfHdr.bfReserved2 = 0;           
     bmfHdr.bfOffBits = (DWORD)sizeof(BITMAPFILEHEADER) + (DWORD)sizeof(BITMAPINFOHEADER) + dwPaletteSize;           
     //     写入位图文件头           
     WriteFile(fh,(LPSTR)&bmfHdr,sizeof(BITMAPFILEHEADER),&dwWritten,NULL);           
     //     写入位图文件其余内容           
     WriteFile(fh,(LPSTR)lpbi,dwDIBSize,&dwWritten,NULL);           
     //清除               
     GlobalUnlock(hDib);           
     GlobalFree(hDib);           
     CloseHandle(fh);   

     return     TRUE;       
}

```

```
  
BOOL DrawBitmapFile(HDC hdc, int left, int top, char *szFilename)
{
    // 打开要映射的位图文件
    HANDLE   hFile = CreateFile( szFilename, GENERIC_READ, FILE_SHARE_READ,
        NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL , NULL ) ;
    if( hFile == INVALID_HANDLE_VALUE )
        return FALSE ;

    // 创建内存映象对象
    HANDLE   hMap = CreateFileMapping( hFile , NULL, PAGE_READONLY, NULL, NULL, NULL ) ;

    // 映射整个位图文件到内存，返回内存的首地址
    LPVOID   lpBase = MapViewOfFile( hMap , FILE_MAP_READ, 0, 0, 0 ) ;

    // 获取BMP文件信息
    BITMAPFILEHEADER     *pFileHeader ;
    BITMAPINFO           *pInfoHeader ;

    // 获取位图象素
    pFileHeader  =  (BITMAPFILEHEADER *) lpBase ;
    if( pFileHeader->bfType != MAKEWORD( 'B' , 'M' ) )
    {
        UnmapViewOfFile( lpBase ) ;
        CloseHandle( hMap ) ;
        CloseHandle( hFile ) ;
        return FALSE ;
    }

    BYTE *pBits = (BYTE *)lpBase + pFileHeader->bfOffBits ;

    // 获取文件大小
    pInfoHeader  =  (BITMAPINFO *)( (BYTE *)lpBase + sizeof(BITMAPFILEHEADER) ) ;
    LONG  width  =  pInfoHeader->bmiHeader.biHeight ;
    LONG  height =  pInfoHeader->bmiHeader.biWidth  ;

    // 显示位图文件至hdc指定的设备
    HDC        hMemDC   = CreateCompatibleDC( hdc ) ;
    HBITMAP    hBitmap  = CreateCompatibleBitmap( hdc, width, height ) ;
    SelectObject( hMemDC, hBitmap ) ;

    // 把图象数据放到建立的内存设备中
    int nRet = SetDIBitsToDevice( hMemDC, 0, 0, width, height, 
        0, 0, 0, height , pBits, pInfoHeader, DIB_RGB_COLORS ) ;

    // 绘制图象到hdc中
    BitBlt( hdc, left, top, width, height, hMemDC , 0 , 0, SRCCOPY ) ;

    DeleteObject( hBitmap ) ;
    UnmapViewOfFile( lpBase ) ;
    DeleteDC ( hMemDC ) ;
    CloseHandle( hMap ) ;
    CloseHandle( hFile ) ;
}

```

