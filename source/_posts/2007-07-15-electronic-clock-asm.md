---
layout: post
title: 51汇编做的电子时钟
tagline: 被老师鄙视，一气之下还是做出来了
category : 课程设计
tags : [大学时代]
---

```

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SECOND EQU 20H      ;当前秒
MINUTE EQU 21H      ;当前分
HOUR   EQU 22H      ;当前时
ALAMINU EQU 23H     ;闹钟分钟
ALAHOUR EQU 24H     ;闹钟小时
DAY    EQU 25H      ;当前日
MONTH  EQU 26H      ;当前月
YEAR  EQU 27H      ;当前年   
WEEK   EQU 29H      ;星期
STATE  EQU 30H      ;状态
INTNUM EQU 31H      ;中断次数
MONTHDAYS EQU 32H   ;月所对应的天数
ALAON     EQU 33H   ;闹钟开关状态
TEMP       EQU 34H  ;临时变量
ALARM     EQU 35H   ;实事报时,该处存放的变量为1时报时
;液晶模块的寄存器地址
LCD_CMD_WR EQU  0
LCD_DATA_WR EQU 1
LCD_BUSY_RD EQU 2
LCD_DATA_RD EQU 3
;显示命令
LCD_CLS  EQU 1            ;清楚屏幕并且置AC为0
LCD_HOME EQU 2            ;显示返回到原始位置
LCD_SETMODE EQU 4            ;设置模式
LCD_SETVISIBLE EQU 8            ;开关控制
LCD_SHIFT EQU 16           ;光标移位
LCD_SETFUNCTION EQU 32           ;功能设置
LCD_SETCGADDR EQU 64           ;设置CGRAM
LCD_SETDDADDR EQU 128          ;设置DDRAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ORG 0000H
 LJMP MAIN                     ;跳往主程序
 ORG 0003H
 LJMP KEYDOWN                  ;键盘中断
 ORG 000BH
 LJMP TIMER                    ;定时中断
MAIN: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;月份所对应的天数表  
DAYNUM: DB    1FH,1CH,1FH,1EH,1FH,1EH,1FH,1FH,1EH,1FH,1EH,1FH
;显示星期字符串
MON:    DB  'MON',0
TUE:    DB  'TUE',0
WED:    DB  'WED',0
THU:    DB  'THU',0
FRI:    DB  'FRI',0
SAT:    DB  'SAT',0
SUN:    DB  'SUN',0 
ON :    DB  'ON' ,0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 MOV   SP ,#40H
 MOV   TMOD,#01H               ;设置为T0
 LCALL INITIAL                 ;初始化内存数据
        LCALL DIS_INI                 ;液晶显示初始化
        MOV   A,#38H
 LCALL WRCMD
 SETB  ET0                     ;允许TO中断
 SETB  EX0                     ;允许INTRO中断
 MOV   IP,#02H                 ;设置定时器的中断优先于键盘中断
 SETB  EA                      ;CPU 开中断
 MOV   TH0,#3CH                ;装初始值
 MOV   TL0,#0B0H
 SETB  TCON.4                  ;启动T0
HERE:
        LCALL DISPLAY                 ;根据模式不同在LCD上显示
        LJMP HERE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;初始化子程序
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INITIAL:
        PUSH ACC
 MOV   INTNUM,#0AH              ;装入中断次数
 CLR A                         ;初始化时间:00:00:00
 MOV SECOND,A
 MOV MINUTE,A
 MOV HOUR  ,A                 
 MOV ALAMINU ,A
 MOV ALAHOUR ,A
 MOV DAY ,#4                 ;初始化日期为:2007-7-4 星期3
 MOV MONTH,#7
 MOV YEAR,#7H               
 MOV WEEK ,#3H
        MOV STATE ,#0H               ;初始化状态为0
 MOV ALAON,#00H               ;初始化闹钟关闭
 MOV ALARM,#00H               ;初始化不报时
 POP ACC
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;键盘中断程序
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
KEYDOWN:
       PUSH ACC
       MOV A,P1                      ;读键盘的状态
       ANL A,#1FH                    ;屏蔽高三位
       MOV TEMP,A
       LCALL D_10MS                  ;延时10ms
       MOV A,P1                      ;再次读入按键状态
       ANL A,#1FH
       CJNE A,TEMP,RET_KEY           ;两次不等,则是抖动引起的
       CJNE A,#1EH,KEYDOWN1
       LCALL KEY_0
       AJMP RET_KEY
KEYDOWN1:
       CJNE A,#1DH,KEYDOWN2
       LCALL KEY_1
       AJMP RET_KEY
KEYDOWN2:
       CJNE A,#1BH,KEYDOWN3
       LCALL KEY_2
       AJMP RET_KEY
KEYDOWN3:
       CJNE A,#17H,KEYDOWN4
       LCALL KEY_3
       AJMP RET_KEY
KEYDOWN4:
       CJNE A,#0FH,RET_KEY
       LCALL KEY_4
       AJMP RET_KEY
RET_KEY:
       POP  ACC
RETI
;;;;;延时程序10MS
D_10MS:
      MOV R5,#0FFH
D_10MS1:
      MOV R6,#0EEH
D_10MS2:
      NOP
      DJNZ R6,D_10MS2
      DJNZ R5,D_10MS1
RET
;;;;;;功能键按下,设置状态
KEY_0:
       PUSH ACC
MOV P0,#00H
       MOV A,STATE
       INC A
       CJNE A,#05H,KEY_0_RET
       MOV A,#00H
KEY_0_RET:
       MOV STATE,A
       POP ACC
RET
;;;;;;;;;;;;;;;
KEY_1:
;MOV P0,#01H
       MOV R7,#01H             ;设置为增加(子程序的入口参数)
       MOV A,STATE
       CJNE A,#00H,KEY_1_1     
       AJMP KEY_1_RET          ;状态0下无作用
KEY_1_1: 
       CJNE A,#01H,KEY_1_2
       LCALL INC_DEC_HOUR      ;状态1下小时加一
       AJMP KEY_1_RET
KEY_1_2:
       CJNE A,#02H,KEY_1_3
       LCALL INC_DEC_ALAHOUR   ;状态2下闹钟小时加一
       AJMP KEY_1_RET
KEY_1_3:
       CJNE A,#03H,KEY_1_4
       LCALL INC_DEC_MONTH     ;状态3下月加一
       AJMP KEY_1_RET
KEY_1_4:
       CJNE A,#04H,KEY_1_RET
       LCALL INC_DEC_YEAR      ;状态4下年加一
KEY_1_RET:
RET
;;;;;;;;;;;;;
KEY_2:
;MOV P0,#02H
       MOV R7,#01H             ;设置为增加(子程序的入口参数)
       MOV A,STATE
       CJNE A,#00H,KEY_2_1     
       AJMP KEY_2_RET          ;状态0下无作用
KEY_2_1: 
       CJNE A,#01H,KEY_2_2
       LCALL INC_DEC_MINUTE    ;状态1下分钟加一
       AJMP KEY_2_RET
KEY_2_2:
       CJNE A,#02H,KEY_2_3
       LCALL INC_DEC_ALAMINU   ;状态2下闹钟分钟加一
       AJMP KEY_2_RET
KEY_2_3:
       CJNE A,#03H,KEY_2_4
       LCALL INC_DEC_DAY       ;状态3下日加一
       AJMP KEY_2_RET
KEY_2_4:
       CJNE A,#04H,KEY_2_RET
       LCALL INC_DEC_WEEK     ;状态4下星期加一
KEY_2_RET:
RET
;;;;;;;;;;;;;
KEY_3:
;MOV P0,#03H
       MOV R7,#00H             ;设置为减少(子程序的入口参数)
       MOV A,STATE
       CJNE A,#00H,KEY_3_1    
       MOV ALARM,#01H          ;状态0下报时:设定报时开关
       AJMP KEY_3_RET          
KEY_3_1: 
       CJNE A,#01H,KEY_3_2
       LCALL INC_DEC_HOUR      ;状态1下小时减一
       AJMP KEY_3_RET
KEY_3_2:
       CJNE A,#02H,KEY_3_3
       LCALL INC_DEC_ALAHOUR   ;状态2下闹钟小时减一
       AJMP KEY_3_RET
KEY_3_3:
       CJNE A,#03H,KEY_3_4
       LCALL INC_DEC_MONTH     ;状态3下月减一
       AJMP KEY_3_RET
KEY_3_4:
       CJNE A,#04H,KEY_3_RET
       LCALL INC_DEC_YEAR      ;状态4下年减一
KEY_3_RET:
RET
;;;;;;;;;;;;;
KEY_4:
;MOV P0,#04H
       MOV R7,#00H             ;设置为减(子程序的入口参数)
       MOV A,STATE
       CJNE A,#00H,KEY_4_1  
       MOV R6,ALAON             ;状态0下,设定闹钟开关
       CJNE R6,#01H,SET_ALAON_0
       MOV  R6,#00H
       AJMP SET_RET
SET_ALAON_0:
       MOV  R6,#01H
SET_RET:
       MOV  ALAON,R6
       AJMP KEY_4_RET          
KEY_4_1: 
       CJNE A,#01H,KEY_4_2
       LCALL INC_DEC_MINUTE    ;状态1下分钟减一
       AJMP KEY_4_RET
KEY_4_2:
       CJNE A,#02H,KEY_4_3
       LCALL INC_DEC_ALAMINU   ;状态2下闹钟分钟减一
       AJMP KEY_4_RET
KEY_4_3:
       CJNE A,#03H,KEY_4_4
       LCALL INC_DEC_DAY       ;状态3下日减一
       AJMP KEY_4_RET
KEY_4_4:
       CJNE A,#04H,KEY_4_RET
       LCALL INC_DEC_WEEK     ;状态4下星期减一
KEY_4_RET:
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;定时器中断服务程序
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TIMER:
        PUSH PSW
 PUSH ACC
 MOV  A,SECOND
 MOV  TH0,#3CH                ;T0装初始值
 MOV  TL0,#0B0H
 DJNZ INTNUM,RETURN           ;1秒未到,返回
 MOV  INTNUM,#0AH             ;重置中断次数
 INC  A
 CJNE A,#60,RETURN            ;是否到60秒,未到返回
        MOV  A,#00H          ;秒计满清零
 MOV  R7,#01H                 ;分钟加一
 LCALL INC_DEC_MINUTE
RETURN:
        MOV  SECOND,A
 POP  ACC
 POP  PSW
RETI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;入口参数:R7
;         R7=1时,增加年 
;         R7=0时,减少年
;         年的范围: 2000-2099
;用途:
;    1.作为INC_DEC_MONTH的子程序被调用
;    2.用于调整年
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INC_DEC_YEAR:
        PUSH ACC
 CJNE R7,#01,DEC_YEAR
INC_YEAR:
        MOV A,YEAR
 INC A
 CJNE A,#100,RET_YEAR         ;到达100年时复位到00年
 MOV A,0
 AJMP RET_YEAR
DEC_YEAR:
        MOV A,YEAR
        JZ DEC_YEAR1                 ;当前为0时,再减少则跳到99年
 DEC A
 AJMP RET_YEAR
DEC_YEAR1:
        MOV A,#99
RET_YEAR:
        MOV YEAR,A
 POP ACC
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;入口参数:R7
;         R7=1时,增加一月,若大于12月时相应的增加一年
;         R7=0时,减少一月,若当前为1月时,再减少一月
;                则是12月,同时年减一
;用途:
;    1.作为INC_DEC_DAY的子程序被调用
;    2.用于调整月,同时可以改变年
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INC_DEC_MONTH:
        PUSH ACC
 CJNE R7,#01,DEC_MONTH
INC_MONTH:
        MOV A,MONTH
 INC A
 CJNE A,#13,RET_MONTH
 MOV R7,#01H
 LCALL INC_DEC_YEAR
 MOV A,#01H
 AJMP RET_MONTH
DEC_MONTH:
        MOV A,MONTH
 DEC A
 CJNE A,#0H,RET_MONTH
 MOV R7,#00H
 LCALL INC_DEC_YEAR
 MOV A,#12
RET_MONTH:
        MOV MONTH,A
 POP ACC
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;入口参数:R7
;         R7=1时,星期加一
;         R7=0时,星期减一
;         不影响其他
;用途:
;    1.作为INC_DEC_DAY的子程序被调用
;    2.用于调整星期
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INC_DEC_WEEK:
       PUSH ACC
       CJNE R7,#01,DEC_WEEK
INC_WEEK:
       MOV A,WEEK
       INC A
       CJNE A,#08H,RET_WEEK
       MOV A,#01H
       AJMP RET_WEEK
DEC_WEEK:
       MOV A,WEEK
       DEC A
       CJNE A,#0H,RET_WEEK
       MOV A,#07H
RET_WEEK:
       MOV WEEK,A
       POP ACC
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;入口参数:R7
;         R7=1时,日加一,根据当前的年月来改变月份
;                同时星期加一.
;         R7=0时,日减一,同时改变月份,年.星期
;用途:
;    1.作为INC_DEC_HOUR的子程序被调用
;    2.用于调整日
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INC_DEC_DAY:
       PUSH ACC
       CJNE R7,#01H,DEC_DAY
INC_DAY:
       MOV R7,#01H
       LCALL INC_DEC_WEEK
       MOV A,DAY
       INC A
       LCALL SETMONTHDAYS
       MOV TEMP,MONTHDAYS
       INC TEMP
       CJNE A,TEMP,RET_DAY
       MOV R7,#01H
       LCALL INC_DEC_MONTH
       MOV A,#01H
       AJMP RET_DAY
DEC_DAY:
       MOV R7,#00H
       LCALL INC_DEC_WEEK
       MOV A,DAY
       DEC A
       CJNE A,#0H,RET_DAY
       MOV A,#00H
       LCALL INC_DEC_MONTH
       LCALL SETMONTHDAYS
       MOV A,MONTHDAYS
RET_DAY:
       MOV DAY,A
       POP ACC
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;入口参数:R7
;         R7=1时,增加一小时,同时有需要则改变日(星期),月,年
;         R7=0时,减少一小时,同时有需要则改变日(星期),月,年  
;用途:
;    1.作为INC_DEC_MINUTE的子程序被调用
;    2.用于调整当前小时        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INC_DEC_HOUR:
       PUSH ACC
       CJNE R7,#01H,DEC_HOUR
INC_HOUR:
       MOV A,HOUR
       INC A
       CJNE A,#24,RET_HOUR
       MOV R7,#01H
       LCALL INC_DEC_DAY
       MOV A,#00H
       AJMP RET_HOUR
DEC_HOUR:
       MOV A,HOUR
       JZ DEC_HOUR1
       DEC A
       AJMP RET_HOUR
DEC_HOUR1:
       MOV R7,#00H
       LCALL INC_DEC_DAY
       MOV A,#23
RET_HOUR:
       MOV HOUR,A
       POP ACC
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;入口参数:R7
;         R7=1时,增加一分钟,同时按需要改变小时...
;         R7=0时,减少一分钟................
;用途:
;    1.作为定时服务程序的子程序被调用
;    2.用于调整当前的分钟
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INC_DEC_MINUTE:
      PUSH ACC 
      CJNE R7,#01H,DEC_MINUTE
INC_MINUTE:
      MOV A,MINUTE
      INC A
      CJNE A,#60,RET_MINUTE
      MOV R7,#01H
      LCALL INC_DEC_HOUR
      MOV A,#00H
      AJMP RET_MINUTE
DEC_MINUTE:
      MOV A,MINUTE
      JZ DEC_MINUTE1
      DEC A
      AJMP RET_MINUTE
DEC_MINUTE1:
      MOV R7,#00H
      LCALL INC_DEC_HOUR
      MOV A,#59
RET_MINUTE:
      MOV MINUTE,A
      POP ACC
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;入口参数: R7
;         R7=1时,闹钟小时增加一,不影响其他
;         R7=1时,闹钟小时减少一.......
;用途:
;    1.作为INC_DEC_ALAMINU的子程序被调用
;    2.用于调整闹钟的小时
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INC_DEC_ALAHOUR:
       PUSH ACC
       CJNE R7,#01H,DEC_ALAHOUR
INC_ALAHOUR:
       MOV A,ALAHOUR
       INC A
       CJNE A,#24,RET_ALAHOUR
       MOV A,#00H
       AJMP RET_ALAHOUR
DEC_ALAHOUR:
       MOV A,ALAHOUR
       JZ DEC_ALAHOUR1
       DEC A
       AJMP RET_ALAHOUR
DEC_ALAHOUR1:
       MOV A,#23
RET_ALAHOUR:
       MOV ALAHOUR,A
       POP ACC
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;入口参数:R7
;         R7=1时,闹钟分钟加一,同时该改变闹钟小时
;         R7=0时,闹钟分钟减一,..................
;用途:
;    1.用于调整闹钟的分钟
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INC_DEC_ALAMINU:
      PUSH ACC 
      CJNE R7,#01H,DEC_ALAMINU
INC_ALAMINU:
      MOV A,ALAMINU
      INC A
      CJNE A,#60,RET_ALAMINU
      MOV R7,#01H
      LCALL INC_DEC_ALAHOUR
      MOV A,#00H
      AJMP RET_ALAMINU
DEC_ALAMINU:
      MOV A,ALAMINU
      JZ DEC_ALAMINU1
      DEC A
      AJMP RET_ALAMINU
DEC_ALAMINU1:
      MOV R7,#00H
      LCALL INC_DEC_ALAHOUR
      MOV A,#59
RET_ALAMINU:
      MOV ALAMINU,A
      POP ACC
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;求得当前月份所对应的天数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SETMONTHDAYS:
        PUSH ACC
        PUSH DPH
 PUSH DPL
        MOV  DPTR,#DAYNUM        ;获得月天数的表地址
 MOV  A,MONTH             ;获得当前月份
 MOV  R0,MONTH
 DEC  A                   ;生成下标
 MOVC A,@A+DPTR           ;取表中的值
 MOV  MONTHDAYS,A         
 CJNE R0,#2H,CONTINUE     ;不是二月份则取表中的值
 MOV  A,YEAR              ;是二月份判断是否是闰年
        MOV  B,#4H
 DIV  AB
 MOV  A,#00H
 CJNE A,B,CONTINUE        ;是平年则跳转
        INC  MONTHDAYS           ;是闰年二月份为29天
CONTINUE:
 POP  DPL
 POP  DPH
 POP  ACC
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;显示子程序
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY:
       PUSH ACC
       MOV A,#LCD_SETVISIBLE+4 
       LCALL WRCMD
       MOV A,#LCD_HOME
       LCALL WRCMD
       MOV R5,STATE
       CJNE R5,#00H,DIS_1
       LCALL DISPLAY_0
       AJMP DIS_RET
DIS_1: 
       CJNE R5,#01H,DIS_2
       LCALL DISPLAY_1
       AJMP DIS_RET
DIS_2:
       CJNE R5,#02H,DIS_3
       LCALL DISPLAY_2
       AJMP DIS_RET
DIS_3:
       CJNE R5,#03H,DIS_4
       LCALL DISPLAY_3
       AJMP DIS_RET
DIS_4: 
       CJNE R5,#04H,DIS_RET
       LCALL DISPLAY_4
DIS_RET:
       POP ACC
RET
;;;;;;;;;;;;;;;
DISPLAY_0:
       PUSH ACC
       ;显示时间
       MOV A,#20H
       LCALL WRCHAR
       MOV R3,HOUR
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR
       
       MOV A,#3AH
       LCALL WRCHAR
       MOV R3,MINUTE
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR
       MOV A,#3AH
       LCALL WRCHAR
       MOV R3,SECOND
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR
       ;显示年
       MOV A,#20H
       LCALL WRCHAR
       MOV A,#20H
       LCALL WRCHAR
       MOV A,#32H
       LCALL WRCHAR
       MOV A,#30H
       LCALL WRCHAR
       MOV R3,YEAR
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR
       
       ;显示星期
       MOV A,#LCD_SETDDADDR+64
       LCALL WRCMD
       MOV A,#20H
       LCALL WRCHAR
       MOV A,#20
       LCALL WRCHAR
       
           MOV A,WEEK
       CJNE A,#01H,DIS_0_W1
       MOV DPTR,#MON
       AJMP DIS_0_RET
DIS_0_W1:
       CJNE A,#02H,DIS_0_W2
       MOV DPTR,#TUE
       AJMP DIS_0_RET
DIS_0_W2:
       CJNE A,#03H,DIS_0_W3
       MOV DPTR,#WED
       AJMP DIS_0_RET
DIS_0_W3:
       CJNE A,#04H,DIS_0_W4
       MOV DPTR,#THU
       AJMP DIS_0_RET
DIS_0_W4:
       CJNE A,#05H,DIS_0_W5
       MOV DPTR,#FRI
       AJMP DIS_0_RET
DIS_0_W5:
       CJNE A,#06H,DIS_0_W6
       MOV DPTR,#SAT
       AJMP DIS_0_RET
DIS_0_W6:
       CJNE A,#07H,DIS_0_RET
       MOV DPTR,#SUN
DIS_0_RET:
       LCALL WRSTR
       ;显示日期
       MOV A,#20H
       LCALL WRCHAR
       MOV A,#20H
       LCALL WRCHAR
       MOV R3,MONTH
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR
       
       MOV A,#2DH
       LCALL WRCHAR
       MOV R3,DAY
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR
       ;显示状态
       MOV A,#20H
       LCALL WRCHAR
       MOV A,ALAON
       CJNE A,#01H,RET_DSP_0
       MOV DPTR,#ON
       LCALL WRSTR
RET_DSP_0:
       
       POP ACC
RET
;;;;;;;;;;;;;;;
DISPLAY_1:
       PUSH ACC
       MOV A,#LCD_CLS
       LCALL WRCMD
       ;显示时间
       MOV A,#20H
       LCALL WRCHAR
       MOV R3,HOUR
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR
       
       MOV A,#3AH
       LCALL WRCHAR
       MOV R3,MINUTE
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR
       MOV A,#3AH
       LCALL WRCHAR
       MOV R3,SECOND
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR

       POP ACC
RET
;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY_2:
       PUSH ACC
       MOV A,#LCD_CLS
       LCALL WRCMD
       ;显示时间
       MOV A,#20H
       LCALL WRCHAR
       MOV R3,ALAHOUR
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR
       MOV A,#3AH
       LCALL WRCHAR
       MOV R3,ALAMINU
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR
       
       POP  ACC
   
RET
;;;;;;;;;;;;;;;;;;;;
DISPLAY_3:
       PUSH ACC
       MOV A,#LCD_CLS
       LCALL WRCMD
       ;;;;;;;;;;;;;;;
       ;显示日期
       MOV A,#20H
       LCALL WRCHAR
       MOV A,#20H
       LCALL WRCHAR
       MOV R3,MONTH
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR
       
       MOV A,#2DH
       LCALL WRCHAR
       MOV R3,DAY
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR
 
       POP ACC
RET
;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY_4:
       PUSH ACC
       MOV A,#LCD_CLS
       LCALL WRCMD
       MOV A,#8BH
       LCALL WRCMD
       MOV A,#32H
       LCALL WRCHAR
       MOV A,#30H
       LCALL WRCHAR
       MOV R3,YEAR
       LCALL GETCHAR
       MOV A,R3
       LCALL WRCHAR
       MOV A,R4
       LCALL WRCHAR
       MOV A,#0C2H
       LCALL WRCMD
              MOV A,WEEK
       CJNE A,#01H,DIS_4_W1
       MOV DPTR,#MON
       AJMP DIS_4_RET
DIS_4_W1:
       CJNE A,#02H,DIS_4_W2
       MOV DPTR,#TUE
       AJMP DIS_4_RET
DIS_4_W2:
       CJNE A,#03H,DIS_4_W3
       MOV DPTR,#WED
       AJMP DIS_4_RET
DIS_4_W3:
       CJNE A,#04H,DIS_4_W4
       MOV DPTR,#THU
       AJMP DIS_4_RET
DIS_4_W4:
       CJNE A,#05H,DIS_4_W5
       MOV DPTR,#FRI
       AJMP DIS_4_RET
DIS_4_W5:
       CJNE A,#06H,DIS_4_W6
       MOV DPTR,#SAT
       AJMP DIS_4_RET
DIS_4_W6:
       CJNE A,#07H,DIS_4_RET
       MOV DPTR,#SUN
DIS_4_RET:
       LCALL WRSTR
       POP ACC 
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;获得x的显示码:
; 入口参数: R3:存放要被转换的数字
; 出口参数: R3:高位对应的显示码
;           R4:低微对应的显示码
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GETCHAR:
       PUSH ACC
       MOV  A,R3
       MOV  B,#10
       DIV  AB
       ADD  A,#30H
       MOV  R3,A
       MOV  A,B
       ADD  A,#30H
       MOV  R4,A
       POP  ACC
RET
;;;;;;;;;;;;;;;;;;;;;;;
;写以零结尾的字符串
;  首地址在DPTR中
wrstr: mov R0,#LCD_DATA_WR
wrstr1: clr A
 movc A,@A+DPTR
 jz wrstr2
 movx @R0,A
 call wtbusy
 inc DPTR
 push DPL
 push DPH
 pop DPH
 pop DPL 
 jmp wrstr1
wrstr2: ret
;;;;;;;;;;;;;;;;;;;;;;;
;写命令,命令控制字在A中
wrcmd: mov R0,#LCD_CMD_WR
 movx @R0,A
 jmp wtbusy

;写字字符,字符的代码放在A中
wrchar: mov R0,#LCD_DATA_WR
 movx @R0,A
;忙则等待
wtbusy: mov R1,#LCD_BUSY_RD
 movx A,@r1
 jb ACC.7,wtbusy
 ret
;;;;;;;;;;;;;;;
;液晶显示初始化
;;;;;;;;;;;;;;;
DIS_INI:
       ACALL D_15MS
       MOV A,30H
       MOV R0,#LCD_CMD_WR
       MOVX @R0,A
       ACALL D_5MS
       MOV A,#30H
       MOV R0,#LCD_CMD_WR
       MOVX @R0,A
       ACALL D_5MS
       MOV A,#30H
       MOV R0,#LCD_CMD_WR
       MOVX @R0,A
       MOV A,#38H       ;功能设置
       ACALL WRCMD
       MOV A,#08H       ;关显示
       ACALL WRCMD
       MOV A,#01H       ;清屏
       ACALL WRCMD
       MOV A,#06H       ;设定输入方式
       ACALL WRCMD
       ACALL D_40US    
       
       MOV A,#10H      ;光标移位
       ACALL WRCMD
       MOV A,#0C0H     ;开显示
       ACALL WRCMD
RET
;;;;;;;;
D_40US:
      MOV R1,#10
D_40US_1:
      NOP
      DJNZ R1,D_40US_1     
RET
;;;;;;;
D_5MS:
     MOV R1,#10
D_5MS_1:
     MOV R2,#125
D_5MS_2:
     NOP
     DJNZ R2,D_5MS_2
     DJNZ R1,D_5MS_1
RET
;;;;;;
D_15MS:
     MOV R0,#3
D_15MS_1:
     NOP
     DJNZ R0,D_15MS_1
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
END

```