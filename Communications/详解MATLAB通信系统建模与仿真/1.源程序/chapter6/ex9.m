clear all
Fd=1;           %符号采样频率
Fs=10;          %滤波器采样频率
r=0.2;          %滤波器滚降系数
delay=4;        %滤波器时延
[num,den]=rcosine(Fd,Fs,'default',r,delay); %设计滤波器
figure; impz(num,1);    %滤波器的冲激响应
title('滤波器的冲激响应')
x=randint(1,30);        %二进制数据
[y,ty]=rcosflt(x,Fd,Fs,'filter',num,den);   %对二进制数据进行脉冲成形
figure
t=delay:length(x)+delay-1;
stem(t,x,'-r');hold on  %画出二进制数据
plot(ty,y)              %画出脉冲成形后的数据
legend('二进制数据','脉冲成形后的数据')
axis([-1 40 -0.5 2])