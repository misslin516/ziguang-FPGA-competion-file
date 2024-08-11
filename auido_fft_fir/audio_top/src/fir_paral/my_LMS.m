function [w,en,yn] = my_LMS(un,dn,mu,Num_iteration,M)
    %---------------LMS算法
    
    
    % 滤波器的系数是一个列矢量，Num_iteration表示迭代次数，每一次迭代都是一个列矢量
    w  = zeros(M,Num_iteration);  % 滤波器系数的初始值  
    en = zeros(1,Num_iteration); % 误差信号的初始值


    %---迭代更新滤波器的参数
    for k = M:Num_iteration     % 保证输入延时后的信号有效，所以实际的迭代次数只有（Num_iteration-M）次，
        % 输入信号 向量U(n)=[u(n)  u(n-1) ...  u(n-M+1)]'  现代数字信号处理及应用的P134 式（4.1.4）
        U = un(k:-1:k-M+1);     % 将输入信号延迟，使得滤波器的每个抽头都有输入  式（4.1.4）
        
        yn(k) = w(:,k)'*U;     % 滤波器的输出信号  式（4.4.6）  共轭转置，不是转置
        
        en(k) = dn(k)-yn(k);    % 误差信号   式（4.4.7）
        
        w(:,k+1) = w(:,k)+mu*U*conj(en(k));% 滤波器权向量的更新方程  式（4.4.8） conj 共轭
    end
    
 
end


