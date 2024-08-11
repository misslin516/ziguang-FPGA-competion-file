`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:Meyesemi 
// Engineer: Will
// 
// Create Date: 2023-01-29 20:31  
// Design Name:  
// Module Name: 
// Project Name: 
// Target Devices: Pango
// Tool Versions: 
// Description: 
//      
// Dependencies: 
// 
// Revision:
// Revision 1.0 - File Created
// Additional Comments:
// revised by  : NJUPT
// revised data: 2024/04/08
//////////////////////////////////////////////////////////////////////////////////
`define UD #0

module pattern_vg_row # (
    parameter                            COCLOR_DEPP=8, // number of bits per channel
    parameter                            X_BITS=13,
    parameter                            Y_BITS=13,
    parameter                            H_ACT = 12'd1280,
    parameter                            V_ACT = 12'd720,
    parameter                            fft_point = 9'd256
)(                                       
    input                                rstn               , 
    input                                pix_clk            ,
    input [X_BITS-1:0]                   act_x              ,
    input [Y_BITS-1:0]                   act_y              ,

    input                                vs_in              , 
    input                                hs_in              , 
    input                                de_in              ,
    //fft interface
    input       [7:0]                    fft_point_cnt      ,  
    input       [11:0]                   fft_data           ,    //should be scaled  
    output  reg                          fft_point_done     ,
    output  reg                          data_req           ,
    
    output reg                           vs_out             , 
    output reg                           hs_out             , 
    output reg                           de_out             ,
    output reg [COCLOR_DEPP-1:0]         r_out              , 
    output reg [COCLOR_DEPP-1:0]         g_out              , 
    output reg [COCLOR_DEPP-1:0]         b_out          
);

    localparam step = H_ACT[11:8]; // /2^8  256
    parameter RED   = 24'hFF0000 ;  //红色
    parameter WHITE = 24'hFFFFFF ;  //白色
    localparam H_OFFSET  = 8'd64;    
    localparam V_OFFSET  = 8'd44; 



    always @(posedge pix_clk)
    begin
        vs_out <= `UD vs_in;
        hs_out <= `UD hs_in;
        de_out <= `UD de_in;
    end
        
  
  
//1行结束，拉高done信号，表示此次的频谱显示已完成
    always @(posedge pix_clk) 
    begin
        if(de_in) begin
            if((act_x == H_ACT-1) && (act_y == {fft_point_cnt + 1'b1,1'b0}))
                fft_point_done <= 1'b1;
            else
                fft_point_done <= 1'b0;      
        end else
            fft_point_done <= 1'b0;      
    end
 

//产生请求数据信号
    always @(posedge pix_clk)
    begin
        if(de_in) begin
            if((act_x  == H_ACT-1) && act_y == ({fft_point_cnt+ 1'b1,1'b0}-1))
                data_req <= 1'b1;
            else
                data_req <= 1'b0; 
        end else
            data_req <= 1'b0; 
    end
    
    
    always@(posedge pix_clk) 
    begin
        if(de_in) begin
            if((act_x <= fft_data) && (act_y == {fft_point_cnt + 1'b1,1'b0}))
                {r_out,g_out,b_out} <=  RED;
            else 
                {r_out,g_out,b_out} <=  WHITE;
        end else
            {r_out,g_out,b_out} <=  WHITE;
    end
                    
endmodule
