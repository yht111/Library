clear all
ts=0.0025;                      %信号抽样时间间隔
t=0:ts:10-ts;                   %时间向量
fs=1/ts;                        %抽样频率
df=fs/length(t);                %fft的频率分辨率
msg=randint(100,1,[-3,3],123);  %生成消息序列,随机数种子为123
msg1=msg*ones(1,fs/10);         %扩展成取样信号形式
msg2=reshape(msg1.',1,length(t));
Pm=fft(msg2)/fs;                %求消息信号的频谱
f=-fs/2:df:fs/2-df; 
subplot(2,1,1)
plot(f,fftshift(abs(Pm)))       %画出消息信号频谱
title('消息信号频谱')

A=4;
fc=100;                         %载波频率
Sdsb=msg2.*cos(2*pi*fc*t);      %已调信号
Pdsb=fft(Sdsb)/fs;              %已调信号频谱
subplot(2,1,2)
plot(f,fftshift(abs(Pdsb)))     %画出已调信号频谱
title('DSBSC信号频谱')
axis([-200 200 0 2])

Pc=sum(abs(Sdsb).^2)/length(Sdsb)   %已调信号功率
Ps=sum(abs(msg2).^2)/length(msg2)   %消息信号功率
