---
layout: post
title: LMS算法MatLab实现 
category : 课程设计
tags : [大学时代, LMS]
date: 2008-04-27 06:00:00 +0800
---

LMS自适应滤波器是使滤波器的输出信号与期望响应之间的误差的均方值为最小，因此称为最小均方（LMS）自适应滤波器。其原理及推导见http://download.csdn.net/source/432206。


```
       
function [yn,W,en]=LMS(xn,dn,M,mu,itr)
% LMS(Least Mean Squre)算法
% 输入参数:
%     xn   输入的信号序列      (列向量)
%     dn   所期望的响应序列    (列向量)
%     M    滤波器的阶数        (标量)
%     mu   收敛因子(步长)      (标量)     要求大于0,小于xn的相关矩阵最大特征值的倒数    
%     itr  迭代次数            (标量)     默认为xn的长度,M<itr<length(xn)
% 输出参数:
%     W    滤波器的权值矩阵     (矩阵)
%          大小为M x itr,
%     en   误差序列(itr x 1)    (列向量)  
%     yn   实际输出序列             (列向量)

% 参数个数必须为4个或5个
if nargin == 4                 % 4个时递归迭代的次数为xn的长度 
    itr = length(xn);
elseif nargin == 5             % 5个时满足M<itr<length(xn)
    if itr>length(xn) | itr<M
        error('迭代次数过大或过小!');
    end
else
    error('请检查输入参数的个数!');
end


% 初始化参数
en = zeros(itr,1);             % 误差序列,en(k)表示第k次迭代时预期输出与实际输入的误差
W  = zeros(M,itr);             % 每一行代表一个加权参量,每一列代表-次迭代,初始为0

% 迭代计算
for k = M:itr                  % 第k次迭代
    x = xn(k:-1:k-M+1);        % 滤波器M个抽头的输入
    y = W(:,k-1).' * x;        % 滤波器的输出
    en(k) = dn(k) - y ;        % 第k次迭代的误差
    
    % 滤波器权值计算的迭代式
    W(:,k) = W(:,k-1) + 2*mu*en(k)*x;
end

% 求最优时滤波器的输出序列
yn = inf * ones(size(xn));
for k = M:length(xn)
    x = xn(k:-1:k-M+1);
    yn(k) = W(:,end).'* x;
end
    
        LMS函数的一个实例：
%function main()
close  all

% 周期信号的产生 
t=0:99;
xs=10*sin(0.5*t);
figure;
subplot(2,1,1);
plot(t,xs);grid;
ylabel('幅值');
title('it{输入周期性信号}');

% 噪声信号的产生
randn('state',sum(100*clock));
xn=randn(1,100);
subplot(2,1,2);
plot(t,xn);grid;
ylabel('幅值');
xlabel('时间');
title('it{随机噪声信号}');

% 信号滤波
xn = xs+xn;
xn = xn.' ;   % 输入信号序列
dn = xs.' ;   % 预期结果序列
M  = 20   ;   % 滤波器的阶数

rho_max = max(eig(xn*xn.'));   % 输入信号相关矩阵的最大特征值
mu = rand()*(1/rho_max)   ;    % 收敛因子 0 < mu < 1/rho

[yn,W,en] = LMS(xn,dn,M,mu);

% 绘制滤波器输入信号
figure;
subplot(2,1,1);
plot(t,xn);grid;
ylabel('幅值');
xlabel('时间');
title('it{滤波器输入信号}');

% 绘制自适应滤波器输出信号
subplot(2,1,2);
plot(t,yn);grid;
ylabel('幅值');
xlabel('时间');
title('it{自适应滤波器输出信号}');

% 绘制自适应滤波器输出信号,预期输出信号和两者的误差
figure 
plot(t,yn,'b',t,dn,'g',t,dn-yn,'r');grid;
legend('自适应滤波器输出','预期输出','误差');
ylabel('幅值');
xlabel('时间');
title('it{自适应滤波器}');

```

运行后的结果如下：

![LMS](/images/2008-04-27-1.bmp)
![LMS](/images/2008-04-27-2.bmp)
![LMS](/images/2008-04-27-3.bmp)





