`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/30 16:26:46
// Design Name: 
// Module Name: sqrt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cordic_newton
#(     
        parameter                                   d_width = 32            ,
        parameter                                   q_width = d_width/2 - 1 ,
        parameter                                   r_width = q_width + 1    
)
(
        input            wire                                    clk    ,
        input            wire                                    rst    ,   //active high
        input            wire                                    i_vaild,
        input            wire            [d_width-1:0]           data_i ,//data_21,data_12,data_22, //输入

        output        reg                                   o_vaild    ,
        output        reg            [q_width:0]            data_o      , //输出
        output        reg            [r_width:0]            data_r  //余数
);

//--------------------------------------------------------------------------------

    reg                             [d_width-1:0]         D                [r_width:1]; //被开方数
    reg                             [q_width:0]         Q_z            [r_width:1]; //临时
    reg                             [q_width:0]         Q_q            [r_width:1]; //确认
    reg                                                     ivalid_t        [r_width:1];
//--------------------------------------------------------------------------------
    always@(posedge    clk or posedge    rst)
        begin
            if(rst)
                begin
                    D[r_width] <= 0;
                    Q_z[r_width] <= 0;
                    Q_q[r_width] <= 0;
                    ivalid_t[r_width] <= 0;
                end
            else    if(i_vaild)
                begin
                    D[r_width] <= data_i;//data_11+data_21+data_12+data_22;  //被开方数据
                    Q_z[r_width] <= {1'b1,{q_width{1'b0}}}; //实验值设置
                    Q_q[r_width] <= 0; //实际计算结果
                    ivalid_t[r_width] <= 1;
                end
            else
                begin
                    D[r_width] <= 0;
                    Q_z[r_width] <= 0;
                    Q_q[r_width] <= 0;
                    ivalid_t[r_width] <= 0;
                end
        end
//-------------------------------------------------------------------------------

//        迭代计算过程

//-------------------------------------------------------------------------------
        generate
            genvar i;
                for(i=r_width-1;i>=1;i=i-1)
                    begin:U
                        always@(posedge clk or posedge    rst)
                            begin
                                if(rst)
                                    begin
                                        D[i] <= 0;
                                        Q_z[i] <= 0;
                                        Q_q[i] <= 0;
                                        ivalid_t[i] <= 0;
                                    end
                                else    if(ivalid_t[i+1])
                                    begin
                                        if(Q_z[i+1]*Q_z[i+1] > D[i+1])
                                            begin
                                                Q_z[i] <= {Q_q[i+1][q_width:i],1'b1,{{i-1}{1'b0}}};
                                                Q_q[i] <= Q_q[i+1];
                                            end
                                        else
                                            begin
                                                Q_z[i] <= {Q_z[i+1][q_width:i],1'b1,{{i-1}{1'b0}}};
                                                Q_q[i] <= Q_z[i+1];
                                            end
                                        D[i] <= D[i+1];
                                        ivalid_t[i] <= 1;
                                    end
                                else
                                    begin
                                        ivalid_t[i] <= 0;
                                        D[i] <= 0;
                                        Q_q[i] <= 0;
                                        Q_z[i] <= 0;
                                    end
                            end
                    end
        endgenerate
//--------------------------------------------------------------------------------

//    计算余数与最终平方根

//--------------------------------------------------------------------------------
        always@(posedge    clk or posedge    rst) 
            begin
                if(rst)
                    begin
                        data_o <= 0;
                        data_r <= 0;
                        o_vaild <= 0;
                    end
                else    if(ivalid_t[1])
                    begin
                        if(Q_z[1]*Q_z[1] > D[1])
                            begin
                                data_o <= Q_q[1];
                                data_r <= D[1] - Q_q[1]*Q_q[1];
                                o_vaild <= 1;
                            end
                        else
                            begin
                                data_o <= {Q_q[1][q_width:1],Q_z[1][0]};
                                data_r <= D[1] - {Q_q[1][q_width:1],Q_z[1][0]}*{Q_q[1][q_width:1],Q_z[1][0]};
                                o_vaild <= 1;
                            end
                    end
                else
                    begin
                        data_o <= 0;
                        data_r <= 0;
                        o_vaild <= 0;
                    end
            end
//--------------------------------------------------------------------------------
endmodule