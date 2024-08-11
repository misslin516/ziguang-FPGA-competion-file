clear all;close all;clc;
%=======================================================
% generating  wave data with txt hex format
%=======================================================
info1 =audioinfo('D:/fpga_competition/matlabcode_for_check/A 去噪测试音频/去噪测试音频样本1.m4a');%获取音频文件的信息
[audio1,Fs1] = audioread('D:/fpga_competition/matlabcode_for_check/A 去噪测试音频/去噪测试音频样本1.m4a');%读取音频文件
info2 =audioinfo('D:/fpga_competition/matlabcode_for_check/A 去噪测试音频/去噪测试音频样本2.m4a');%获取音频文件的信息
[audio2,Fs2] = audioread('D:/fpga_competition/matlabcode_for_check/A 去噪测试音频/去噪测试音频样本2.m4a');%读取音频文件





 y = uint16(audio2*2^11);

fid         = fopen('cosx0p25m7p5m12bit.txt', 'wt') ;
fprintf(fid, '%x\n', y) ;
fclose(fid) ;



%% 
fc          = 1500 ;      % 中心频率
Fs          = 50e6 ;        % 采样频率
T           = 1/fc ;        % 信号周期
Num         = Fs * T ;      % 周期内信号采样点数
t           = (0:Num-1)/Fs ;      % 离散时间
cosx        = cos(2*pi*fc*t) ;    % 中心频率正弦信号
noise1 = randn(length(cosx));
y        = cosx + noise1;

cosx1  = mapminmax( cosx);

cosx2 =  floor((2^11-1) * cosx1 + 2^11) ;

fid         = fopen('cosx.hex', 'wt') ;  %写数据文件
fprintf(fid, '%x\n', cosx2) ;
fclose(fid) ;
 
%时域波形
figure(1);
subplot(121);plot(t,cosx);hold on ;
plot(t,y) ;
subplot(122);plot(t,y) ;


%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      LMS自适应滤波算法
%   由于射频前端低噪放、滤波等电路的不一致性，导致相同的接收信号通过接收通道后，
%   信号幅度和相位并不相同。为此，需要对通道的幅相误差进行校正。  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               参数设置
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
count=1024;      % 采样点数
SNR=10;          % 信噪比



% LMS算法相关参数
M=50;       % 滤波器的系数
Num_iteration=count; % 迭代次数



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               蒙特卡罗仿真
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Monte_Times=50; % 蒙特卡罗次数
sum_w=0;
sum_en=0;
sum_yn=0;
for p=1:Monte_Times
    %----第一种信号
    dn = cosx';% 期望信号
    noise = randn(1,length(dn)); % 高斯白噪声
    un = dn+noise;          % 输入信号


    dn=real(dn); % 得到信号的实部
    un=real(un);

    un = un.';   % 转置为列向量
    dn = dn.'; 

    % 求收敛常数
    lamda_max = max(eig(un*un.'));%求解输入xn的自相关矩阵的最大特征值,A = eig(B),意为将矩阵B的特征值组成向量A
    mu = 2*(1/lamda_max);



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %               LMS算法
    % 输入参数：
    %     un                输入信号       列向量
    %     dn                参考信号       列向量
    %     mu                步长因子       标量
    %     Num_iteration     迭代次数       标量
    %     M                 滤波器阶数     标量
    % 输出参数：
    %     w    滤波器的系数矩阵    M×Num_iteration  滤波器的系数是一个M列的列矢量，Num_iteration表示迭代次数，每一次迭代都是一个列矢量
    %     en   误差信号            1×Num_iteration  每一次迭代后产生的误差
    %     yn   滤波器的输出信号    1×Num_iteration  行向量
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [w,en,yn] = my_LMS(un,dn,mu,Num_iteration,M);

    
    sum_w=sum_w+w;
    sum_en=sum_en+en;
    sum_yn=sum_yn+yn;
end
mean_w=sum_w/Monte_Times;
mean_en=sum_en/Monte_Times;
mean_yn=sum_yn/Monte_Times;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               绘图
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);
plot(t*1e6,dn);hold on;
plot(t*1e6,un);hold on;
xlabel('时间/us');ylabel('幅度');
legend('期望信号','输入信号');


figure(2);
plot(t*1e6,dn,'-r');hold on;
plot(t*1e6,mean_yn,'-b');hold on;
plot(t*1e6,mean_en,'-k');
xlabel('时间/us');ylabel('幅度');
legend('期望信号','输出信号','误差信号');
title('三种信号的比较');

figure(3);
plot(mean_w(1,:),'-r');hold on;
plot(mean_w(2,:),'-b');hold on;
plot(mean_w(3,:),'-k');hold on;
xlabel('迭代次数');ylabel('幅度');
legend('第一个系数','第二个系数','第三个系数');
title('滤波器的系数');


%% 
info1 =audioinfo('D:/fpga_competition/matlabcode_for_check/A 去噪测试音频/去噪测试音频样本1.m4a');%获取音频文件的信息
[audio1,Fs1] = audioread('D:/fpga_competition/matlabcode_for_check/A 去噪测试音频/去噪测试音频样本1.m4a');%读取音频文件
info2 =audioinfo('D:/fpga_competition/matlabcode_for_check/A 去噪测试音频/去噪测试音频样本2.m4a');%获取音频文件的信息
[audio2,Fs2] = audioread('D:/fpga_competition/matlabcode_for_check/A 去噪测试音频/去噪测试音频样本2.m4a');%读取音频文件



% sound(audio,Fs);%播放音频文件
audiolength1 = length(audio1);%获取音频文件的数据长度
audiolength2 = length(audio2);%
t1 = 1:1:audiolength1;
t2 = 1:1: audiolength2;
% L = 20;     % 滤波器阶数
% Mu = 0.005;   % μ的范围为0到1
% xn = y;     % 输入信号
% dn = x;     % 期望信号
% [yn, W, en] = LMS(audio2',audio1',L,Mu);
% 
% sound(yn*20,Fs1);%播放音频文件
% 
% sound(audio2,Fs1);%播放音频文件
figure;
plot(t2,audio2(1:audiolength2));
xlabel('Time');
ylabel('Audio Signal');
title('去噪测试音频样本2.m4a');





audio1 = audio1(:,1);
audio1 = audio1';
y_fir = bandpass(audio1,[300 3400],Fs1); 
N = length(audio1);%求取抽样点数
t1 = (0:N-1)/Fs1;%显示实际时间
y1 = fft(y_fir);%对信号进行傅里叶变换
y2 = fft(audio1);
f = Fs1/N*(0:round(N/2)-1);%显示实际频点的一半，频域映射，转化为HZ


plot(t1,y_fir);%绘制时域波形
hold on;
plot(t1,audio1);
xlabel('Time/s');ylabel('Amplitude');
title('去噪测试音频样本1.m4a');
legend('去噪后','去噪前')
grid;




subplot(212);

figure;


plot(f,abs(y1(1:round(N/2))),'r');
hold on;plot(f,abs(y2(1:round(N/2))),'g');
xlabel('Frequency/Hz');ylabel('Amplitude');
title('去噪测试音频样本1.m4a');
grid;
legend('去噪后','去噪前')



%% LMS FIR etc

clc;%清除工作区
clear;%清除命令窗口

t = 0.1:0.1:100; %时间轴
signal_len = length(t);%信号长度
d = sin(t);%理想信号

noise = 0.1*randn(1,signal_len);%噪声
d_noise =  d+noise;%要过滤的信号-加了噪声的信号

filter_len = 50;  %滤波器长度
W = zeros(1,filter_len); %初始化滤波器
x = zeros(1,filter_len); %初始化卷积输入
After_filter = zeros(1,signal_len);%用于存储滤波之后的信号
e = zeros(1,signal_len); %初始化误差
mull = 0.03; %步长


for k =1:signal_len
    x = [d_noise(k) x(1:filter_len-1)]; %线性卷积的输入
    After_filter(k) = W*x';
    e(k) =d(k) - After_filter(k);%计算误差
    W = W + 2*mull*e(k)*x; %计算误差更新权重
end

figure(1)
subplot(411)
plot(t,d)
xlabel('理想信号')

subplot(412)
plot(t,d_noise)
xlabel('含噪原信号')

subplot(413)
plot(t,e)
xlabel('误差')

subplot(414)
plot(t,After_filter)
xlabel('去噪信号')

















