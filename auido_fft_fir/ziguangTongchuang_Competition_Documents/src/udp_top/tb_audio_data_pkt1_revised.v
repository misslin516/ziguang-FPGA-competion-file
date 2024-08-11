// Created date:        2024/4/18
// Version:             V1.4
// revised date:        2024/4/30
// Descriptions:        The original version
`timescale 1ns/1ns

module tb_audio_data_pkt1_revised();
    reg               rst_n             ;
   
    reg               audio_clk         ;
    reg               audio_en          ;
    reg [15:0]        audio_data        ;
  
    reg               transfer_flag     ;
    
    reg               eth_tx_clk        ;
    reg               udp_tx_req        ;
    reg               udp_tx_done       ;
    wire              udp_tx_start_en   ;
    wire [31:0]       udp_tx_data       ;
    wire  [15:0]      udp_tx_byte_num   ; 


initial begin
    audio_clk = 1'b0;
    eth_tx_clk = 1'b0;
    rst_n <= 1'b0;
    #40;
    rst_n <= 1'b1;
end


always #10 audio_clk = ~audio_clk;
always #5  eth_tx_clk = ~eth_tx_clk;

always@(posedge audio_clk or negedge rst_n)
    if(~rst_n)
        transfer_flag <= 1'b0;
    else
        transfer_flag <= 1'b1;
        
    
reg [9:0] cnt;

always@(posedge audio_clk or negedge rst_n)
    if(~rst_n)
        cnt <= 10'd0;
    else 
        cnt <= cnt + 1'b1;
        
always@(posedge audio_clk or negedge rst_n)
    if(~rst_n) 
        audio_en <= 1'b0;
    else if(cnt == 1'b1)
        audio_en <= 1'b1;
    else
        audio_en <= audio_en;
      
always@(posedge audio_clk or negedge rst_n)
    if(~rst_n)
        audio_data <= 16'd0;
    else
        audio_data <= cnt ;
        
        
always@(posedge eth_tx_clk or negedge rst_n)
    if(~rst_n)
        udp_tx_req <= 1'b0;
    else
        udp_tx_req <= 1'b1;
        
always@(posedge eth_tx_clk or negedge rst_n)
    if(~rst_n)
        udp_tx_done <= 1'b0;
    else if(udp_tx_done %2048 == 0)
        udp_tx_done <= 1'b1;
    else
        udp_tx_done <= 1'b0;
      

audio_data_pkt1_revised audio_data_pkt1_revised_inst
(
    .rst_n           (rst_n           ),
  
    .audio_clk       (audio_clk       ),
    .audio_en        (audio_en        ),
    .audio_data      (audio_data      ),
   
    .transfer_flag   (transfer_flag   ),  //音频开始传输标志,1:开始传输 0:停止传输

    .eth_tx_clk      (eth_tx_clk      ),   //以太网发送时钟
    .udp_tx_req      (udp_tx_req      ),   //udp发送数据请求信号
    .udp_tx_done     (udp_tx_done     ),   //udp发送数据完成信号                               
    .udp_tx_start_en (udp_tx_start_en ),   //udp开始发送信号
    .udp_tx_data     (udp_tx_data     ),   //udp发送的数据
    .udp_tx_byte_num (udp_tx_byte_num )    //udp单包发送的有效字节数  
);       

endmodule