%ex3.m
%分别对存在捕获效应和不存在捕获效应时的np-CSMA协议性能进行仿真。
clear all
[Traffic1,S1,Delay1] = npcsma(0);        % 无捕获效应吞吐量
[Traffic2,S2,Delay2] = npcsma(1);        % 有捕获效应吞吐量
S = Traffic1 .* exp(-0.1*Traffic1) ./ (Traffic1*(1+2*0.1)+exp(-0.1*Traffic1));       % 理论吞吐量
 
semilogx(Traffic1,S1,'-ko',Traffic1,S,'-kv',Traffic2,S2,'-k*')
title('np-CSMA协议信道吞吐量与业务量关系')
xlabel('业务量')
ylabel('吞吐量')
legend('无捕获效应仿真结果','无捕获效应理论值','有捕获效应仿真结果')

figure
semilogx(Traffic1,Delay1,'-ko',Traffic2,Delay2,'-k*')
title('np-CSMA协议延迟与业务量关系')
xlabel('业务量')
ylabel('延迟(数据包个数)')
legend('无捕获效应仿真结果','有捕获效应仿真结果')