clear all;close all;clc;
%=======================================================
% generating  wave data with txt hex format
%=======================================================
info1 =audioinfo('D:/fpga_competition/matlabcode_for_check/A ȥ�������Ƶ/ȥ�������Ƶ����1.m4a');%��ȡ��Ƶ�ļ�����Ϣ
[audio1,Fs1] = audioread('D:/fpga_competition/matlabcode_for_check/A ȥ�������Ƶ/ȥ�������Ƶ����1.m4a');%��ȡ��Ƶ�ļ�
info2 =audioinfo('D:/fpga_competition/matlabcode_for_check/A ȥ�������Ƶ/ȥ�������Ƶ����2.m4a');%��ȡ��Ƶ�ļ�����Ϣ
[audio2,Fs2] = audioread('D:/fpga_competition/matlabcode_for_check/A ȥ�������Ƶ/ȥ�������Ƶ����2.m4a');%��ȡ��Ƶ�ļ�





 y = uint16(audio2*2^11);

fid         = fopen('cosx0p25m7p5m12bit.txt', 'wt') ;
fprintf(fid, '%x\n', y) ;
fclose(fid) ;



%% 
fc          = 1500 ;      % ����Ƶ��
Fs          = 50e6 ;        % ����Ƶ��
T           = 1/fc ;        % �ź�����
Num         = Fs * T ;      % �������źŲ�������
t           = (0:Num-1)/Fs ;      % ��ɢʱ��
cosx        = cos(2*pi*fc*t) ;    % ����Ƶ�������ź�
noise1 = randn(length(cosx));
y        = cosx + noise1;

cosx1  = mapminmax( cosx);

cosx2 =  floor((2^11-1) * cosx1 + 2^11) ;

fid         = fopen('cosx.hex', 'wt') ;  %д�����ļ�
fprintf(fid, '%x\n', cosx2) ;
fclose(fid) ;
 
%ʱ����
figure(1);
subplot(121);plot(t,cosx);hold on ;
plot(t,y) ;
subplot(122);plot(t,y) ;


%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      LMS����Ӧ�˲��㷨
%   ������Ƶǰ�˵���š��˲��ȵ�·�Ĳ�һ���ԣ�������ͬ�Ľ����ź�ͨ������ͨ����
%   �źŷ��Ⱥ���λ������ͬ��Ϊ�ˣ���Ҫ��ͨ���ķ���������У����  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               ��������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
count=1024;      % ��������
SNR=10;          % �����



% LMS�㷨��ز���
M=50;       % �˲�����ϵ��
Num_iteration=count; % ��������



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               ���ؿ��޷���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Monte_Times=50; % ���ؿ��޴���
sum_w=0;
sum_en=0;
sum_yn=0;
for p=1:Monte_Times
    %----��һ���ź�
    dn = cosx';% �����ź�
    noise = randn(1,length(dn)); % ��˹������
    un = dn+noise;          % �����ź�


    dn=real(dn); % �õ��źŵ�ʵ��
    un=real(un);

    un = un.';   % ת��Ϊ������
    dn = dn.'; 

    % ����������
    lamda_max = max(eig(un*un.'));%�������xn������ؾ�����������ֵ,A = eig(B),��Ϊ������B������ֵ�������A
    mu = 2*(1/lamda_max);



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %               LMS�㷨
    % ���������
    %     un                �����ź�       ������
    %     dn                �ο��ź�       ������
    %     mu                ��������       ����
    %     Num_iteration     ��������       ����
    %     M                 �˲�������     ����
    % ���������
    %     w    �˲�����ϵ������    M��Num_iteration  �˲�����ϵ����һ��M�е���ʸ����Num_iteration��ʾ����������ÿһ�ε�������һ����ʸ��
    %     en   ����ź�            1��Num_iteration  ÿһ�ε�������������
    %     yn   �˲���������ź�    1��Num_iteration  ������
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
%               ��ͼ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);
plot(t*1e6,dn);hold on;
plot(t*1e6,un);hold on;
xlabel('ʱ��/us');ylabel('����');
legend('�����ź�','�����ź�');


figure(2);
plot(t*1e6,dn,'-r');hold on;
plot(t*1e6,mean_yn,'-b');hold on;
plot(t*1e6,mean_en,'-k');
xlabel('ʱ��/us');ylabel('����');
legend('�����ź�','����ź�','����ź�');
title('�����źŵıȽ�');

figure(3);
plot(mean_w(1,:),'-r');hold on;
plot(mean_w(2,:),'-b');hold on;
plot(mean_w(3,:),'-k');hold on;
xlabel('��������');ylabel('����');
legend('��һ��ϵ��','�ڶ���ϵ��','������ϵ��');
title('�˲�����ϵ��');


%% 
info1 =audioinfo('D:/fpga_competition/matlabcode_for_check/A ȥ�������Ƶ/ȥ�������Ƶ����1.m4a');%��ȡ��Ƶ�ļ�����Ϣ
[audio1,Fs1] = audioread('D:/fpga_competition/matlabcode_for_check/A ȥ�������Ƶ/ȥ�������Ƶ����1.m4a');%��ȡ��Ƶ�ļ�
info2 =audioinfo('D:/fpga_competition/matlabcode_for_check/A ȥ�������Ƶ/ȥ�������Ƶ����2.m4a');%��ȡ��Ƶ�ļ�����Ϣ
[audio2,Fs2] = audioread('D:/fpga_competition/matlabcode_for_check/A ȥ�������Ƶ/ȥ�������Ƶ����2.m4a');%��ȡ��Ƶ�ļ�



% sound(audio,Fs);%������Ƶ�ļ�
audiolength1 = length(audio1);%��ȡ��Ƶ�ļ������ݳ���
audiolength2 = length(audio2);%
t1 = 1:1:audiolength1;
t2 = 1:1: audiolength2;
% L = 20;     % �˲�������
% Mu = 0.005;   % �̵ķ�ΧΪ0��1
% xn = y;     % �����ź�
% dn = x;     % �����ź�
% [yn, W, en] = LMS(audio2',audio1',L,Mu);
% 
% sound(yn*20,Fs1);%������Ƶ�ļ�
% 
% sound(audio2,Fs1);%������Ƶ�ļ�
figure;
plot(t2,audio2(1:audiolength2));
xlabel('Time');
ylabel('Audio Signal');
title('ȥ�������Ƶ����2.m4a');





audio1 = audio1(:,1);
audio1 = audio1';
y_fir = bandpass(audio1,[300 3400],Fs1); 
N = length(audio1);%��ȡ��������
t1 = (0:N-1)/Fs1;%��ʾʵ��ʱ��
y1 = fft(y_fir);%���źŽ��и���Ҷ�任
y2 = fft(audio1);
f = Fs1/N*(0:round(N/2)-1);%��ʾʵ��Ƶ���һ�룬Ƶ��ӳ�䣬ת��ΪHZ


plot(t1,y_fir);%����ʱ����
hold on;
plot(t1,audio1);
xlabel('Time/s');ylabel('Amplitude');
title('ȥ�������Ƶ����1.m4a');
legend('ȥ���','ȥ��ǰ')
grid;




subplot(212);

figure;


plot(f,abs(y1(1:round(N/2))),'r');
hold on;plot(f,abs(y2(1:round(N/2))),'g');
xlabel('Frequency/Hz');ylabel('Amplitude');
title('ȥ�������Ƶ����1.m4a');
grid;
legend('ȥ���','ȥ��ǰ')



%% LMS FIR etc

clc;%���������
clear;%��������

t = 0.1:0.1:100; %ʱ����
signal_len = length(t);%�źų���
d = sin(t);%�����ź�

noise = 0.1*randn(1,signal_len);%����
d_noise =  d+noise;%Ҫ���˵��ź�-�����������ź�

filter_len = 50;  %�˲�������
W = zeros(1,filter_len); %��ʼ���˲���
x = zeros(1,filter_len); %��ʼ���������
After_filter = zeros(1,signal_len);%���ڴ洢�˲�֮����ź�
e = zeros(1,signal_len); %��ʼ�����
mull = 0.03; %����


for k =1:signal_len
    x = [d_noise(k) x(1:filter_len-1)]; %���Ծ��������
    After_filter(k) = W*x';
    e(k) =d(k) - After_filter(k);%�������
    W = W + 2*mull*e(k)*x; %����������Ȩ��
end

figure(1)
subplot(411)
plot(t,d)
xlabel('�����ź�')

subplot(412)
plot(t,d_noise)
xlabel('����ԭ�ź�')

subplot(413)
plot(t,e)
xlabel('���')

subplot(414)
plot(t,After_filter)
xlabel('ȥ���ź�')

















