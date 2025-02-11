%时隙ALOHA协议程序
function [Traffic,S,Delay]=saloha(capture)

%***********  输入参数  *******************
% capture:          是否考虑捕获效应 0:不考虑  1:考虑

%************* 输出参数 ******************
% Traffic:          实际产生的业务量
% S：               吞吐量
% Delay：           平均延迟 


%**********************定义终端状态常数以及仿真结束参数 ********************** 

STANDBY    = 0;         %等待                                
TRANSMIT   = 1;         %传输
COLLISION  = 2;         %碰撞
TOTAL=20000;                                    % 成功传输多少数据包后仿真结束
%**********************定义信道参数  **********************

brate = 6e6;                                  % 比特速率
Srate = 0.25e6;                                  % 符号速率
Plen  = 500;                                    % 包长（符号数）
Ttime = Plen / Srate;                           % 每个数据包的传输时间
Dtime = 0.01;                                   % 归一化传播延迟
alfa  = 3;                                      % 路径损耗指数
sigma = 6;                                      % 阴影衰落标准差 [dB]

%**********************定义接入点信息 **********************

r   = 100;                                      % 服务区域半径 [m]
bxy = [0, 0, 5];                                % 接入点位置坐标 (x,y,z)[m]
tcn = 10;                                       % 接入点进行正确信号解调所需要的最低信号功率 [dBm]

%**********************定义终端信息 ********************** 

Mnum  = 100;                                    % 终端数目
mcn   = 30;                                     % 终端在服务区域边缘时，接入点接收到的信号功率 [dBm]
mpow  = 10^(mcn/10) * sqrt(r^2+bxy(3)^2)^alfa;  % 终端的发射信号功率
h=0;                                            % 终端高度
mxy = [randsrc(2,Mnum,[-r:r]); randsrc(1,Mnum,[0:h])];  % 随机生成终端坐标
while 1
    d=sqrt(sum(mxy(1:2,:).^2));                         % 判断终端与接入点的水平距离是否超过r
    [tmp,indx]=find(d>r);
    if length(indx) == 0                                
        break
    end
    mxy(:,indx)=[randsrc(2,length(indx),[-r:r]);mxy(3,indx)];   %超过r重新生成位置坐标
end
distance=sqrt(sum(((ones(Mnum,1)*bxy).'-mxy).^2));    %终端距离接入点的距离
mrnd = randn(1,Mnum);                           % 每个终端的阴影衰落

G=[0.1:0.1:1,1.2:0.2:4];                        % 理论业务量
for indx=1:length(G)

%**************** 初始化相关参数 ******************************    
    Tint  = -Ttime / log(1-G(indx)/Mnum);       % 数据包产生间隔的期望值
    Rint  = Tint;                               % 数据包重传间隔的期望值
    Spnum = 0;                                  % 成功传输的包个数     
    Splen = 0;                                  % 成功传输的符号的个数
    Tplen = 0;                                  % 待传输的符号数
    Wtime = 0;                                  % 传输延迟时间(s)
    
    slot          = Plen / Srate;                   % 时隙长度
    mgtime        = -Tint * log(1-rand(1,Mnum));    % 初始数据包产生时刻
    mtime         = (fix(mgtime/slot)+1) * slot;    % 数据包传输时刻
    Mstate        = zeros(1,Mnum);                  % 终端状态
    Mplen(1:Mnum) = Plen;                           % 每个终端传输的数据包长度大小
    now_time     = min(mtime);   

%*********************** 仿真循环 **************************************    
    while 1
        
        idx = find(mtime==now_time & Mstate==TRANSMIT);     % 成功传输数据包的终端ID
        
        if length(idx) > 0
            Spnum       = Spnum + 1;
            Splen       = Splen + Mplen(idx);
            Wtime       = Wtime + now_time - mgtime(idx);
            Mstate(idx) = STANDBY;
            mgtime(idx) = now_time - Tint * log(1-rand);    % 下一个数据包产生时刻
            mtime(idx)  = (fix(mgtime(idx)/slot)+1) * slot; % 下一个数据包传输时刻
        end
        
        idx = find(mtime==now_time & Mstate==COLLISION);    % 数据包传输失败的终端ID
        if length(idx) > 0
            Mstate(idx) = STANDBY;
            mtime(idx)  = now_time - Rint * log(1-rand(1,length(idx))); %重传等待时间     
            mtime(idx)  = (fix(mtime(idx)/slot)+1) * slot;  % 重新发送时刻
        end
   
       idx = find(mtime==now_time);                         % 开始传输数据包的终端ID
        if length(idx) > 0
            Mstate(idx) = TRANSMIT;
            mtime(idx)  = now_time + Mplen(idx) / Srate;    % 数据包传输结束时刻
            mtime(idx)  = round(mtime(idx)/slot) * slot;
            Tplen       = Tplen + sum(Mplen(idx));
        end
        
        if Spnum >= TOTAL                                   % 如果成功传输的数据包达到设定条件，仿真结束
            break
        end
        
        idx = find(Mstate==TRANSMIT | Mstate==COLLISION);   % 有数据包传输或发生碰撞的终端ID
        if capture == 0                                     % 不考虑捕获效应
            if length(idx) > 1
                Mstate(idx) = COLLISION;                    % 同时传输数据包的终端数大于1,发生碰撞
            end
        else                                                % 考虑捕获效应
            if length(idx) > 1
                dxy  = distance(idx);                       % 比较发生碰撞的终端的距离
                pow  = mpow * dxy.^-alfa .* 10.^(sigma/10*mrnd(idx));   % 计算接入点接收到的各个终端信号功率，其中考虑了阴影衰落的影响
                [maxp no] = max(pow);
                if Mstate(idx(no)) == TRANSMIT
                    if length(idx) == 1
                        cn = 10 * log10(maxp);
                    else
                        cn = 10 * log10(maxp/(sum(pow)-maxp+1));
                    end
                    Mstate(idx) = COLLISION;
                    if cn >= tcn                            % 接收到的信号功率大于捕获门限
                        Mstate(idx(no)) = TRANSMIT;         % 传输成功
                    end
                else
                    Mstate(idx) = COLLISION;
                end
            end
        end
        now_time = min(mtime);                              % 更新时刻
    end
    
    Traffic(indx) = Tplen / Srate / now_time;               % 计算实际产生的业务量 
    S(indx) = Splen/Srate/now_time;                         % 计算吞吐量
    Delay(indx) = Wtime / TOTAL * Srate / Plen;             % 计算平均延迟

end


%%%%%%%%%%%%%%%%%%%%%% end of file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
