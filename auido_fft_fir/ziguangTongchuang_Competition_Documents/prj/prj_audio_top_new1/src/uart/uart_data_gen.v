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
// 
//////////////////////////////////////////////////////////////////////////////////

`define UD #1
module uart_data_gen(
    input               clk             ,
    input      [7:0]    read_data       ,
    input               tx_busy         ,
    input      [7:0]    write_max_num   ,
    input               key             ,
    output reg [7:0]    write_data      ,
    output reg          write_en
);
    reg [25:0] time_cnt=0;  
    reg [ 7:0] data_num;
    
    // 设置串口发射工作区间
    reg        work_en=0;
    reg        work_en_1d=0;
    
    always @(posedge clk)
    begin
        time_cnt <= `UD time_cnt + 26'd1;
    end
    
    always @(posedge clk)
    begin
        if((key == 1'b1) &&(time_cnt == 26'd2048))
            work_en <= `UD 1'b1;
        else if(data_num == write_max_num-1'b1)
            work_en <= `UD 1'b0;
    end
    
    always @(posedge clk)
    begin
        work_en_1d <= `UD work_en;
    end

    // get the tx_busy‘s falling edge   获取tx_busy的下降沿
    reg            tx_busy_reg=0;
    wire           tx_busy_f;
    always @ (posedge clk) tx_busy_reg <= `UD tx_busy;
    
    assign tx_busy_f = (!tx_busy) && (tx_busy_reg);
    
    // 串口发射数据触发信号
    reg write_pluse;
    always @ (posedge clk)
    begin
        if(work_en)
        begin
            if(~work_en_1d || tx_busy_f)
                write_pluse <= `UD 1'b1;
            else
                write_pluse <= `UD 1'b0;
        end
        else
            write_pluse <= `UD 1'b0;
    end
    
    always @ (posedge clk)
    begin
        if(~work_en & tx_busy_f)
            data_num   <= 7'h0;
        else if(write_pluse)
            data_num   <= data_num + 8'h1;
    end
    
    always @(posedge clk)
    begin
        write_en <= `UD write_pluse;
    end
    
    //  字符的对应ASCII码
    always @ (posedge clk)
    begin
        case(data_num)
            8'h0  ,
            8'h1  :	write_data <= `UD 8'h75;// ASCII code is U
            8'h2  :	write_data <= `UD 8'h64;// ASCII code is D
            8'h3  :	write_data <= `UD 8'h70;// ASCII code is P
            8'h4  :	write_data <= `UD 8'h2E;// ASCII code is .
            8'h5  :	write_data <= `UD 8'h73;// ASCII code is S
            8'h6  :	write_data <= `UD 8'h74;// ASCII code is T
            8'h7  :	write_data <= `UD 8'h61;// ASCII code is A
            8'h8  :	write_data <= `UD 8'h72;// ASCII code is R
            8'h9  :	write_data <= `UD 8'h74;// ASCII code is T
            8'ha  :	write_data <= `UD 8'h2E;// ASCII code is .
            8'hb  :	write_data <= `UD 8'h74;// ASCII code is T
            8'hc  :	write_data <= `UD 8'h72;// ASCII code is R  
            8'hd  :	write_data <= `UD 8'h61;// ASCII code is A  
            8'he  :	write_data <= `UD 8'h6E;// ASCII code is N    
            8'hf  :	write_data <= `UD 8'h73;// ASCII code is S
            8'h10 ,
            8'h11 :	write_data <= `UD 8'h0d;
            8'h12 :	write_data <= `UD 8'h0a;
            default :	write_data <= `UD read_data;
        endcase
    end
  //udp.start.trans
  //ASCII = 117 100 112 46
  // 75 64 70 2E
        //  115 116 97 114 116 46 
  //73  74  61 72  74 2E
        //   116 114 97 110 115
  //74 72 61 6E 73    
    
    

endmodule
