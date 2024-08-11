// Created by:          njupt
// Created date:        2024/4/21
// Version:             V1.1
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//
`timescale 1ns/1ns

module tb_audio_udp_top_revised
(
    input              sys_clk     ,   //系统时钟  
    
    //以太网接口
    input              eth_rxc     ,   //RGMII接收数据时钟
    input              eth_rx_ctl  ,   //RGMII输入数据有效信号
    input       [3:0]  eth_rxd     ,   //RGMII输入数据
    output             eth_txc     ,   //RGMII发送数据时钟    
    output             eth_tx_ctl  ,   //RGMII输出数据有效信号
    output      [3:0]  eth_txd     ,   //RGMII输出数据          
    output             eth_rst_n     //以太网芯片复位信号，低电平有效   

);
wire rst_n;
wire audio_clk;   //12M
wire [15:0] audio_data;
wire audio_en;


reg [15:0] cnt; 
always@(posedge audio_clk or negedge rst_n)
begin
    if(~rst_n)
        cnt <= 16'd0;
    else 
        cnt <= cnt + 1'b1;
end

assign audio_data = (cnt == 1'b1)?16'd65535:16'd0;
assign audio_en = (cnt == 1'b1) ? 1'b1:1'b0;



pll pll_test 
(
  .clkin1(sys_clk),        // input
  .pll_lock(rst_n),    // output
  .clkout0(audio_clk)       // output
);



audio_udp_top_revised audio_udp_top_revised_inst
(
    .sys_clk    (sys_clk   ),   //系统时钟  
    .sys_rst_n  (rst_n ),   //系统复位信号，低电平有效 
   
    .eth_rxc    (eth_rxc   ),   //RGMII接收数据时钟
    .eth_rx_ctl (eth_rx_ctl),   //RGMII输入数据有效信号
    .eth_rxd    (eth_rxd   ),   //RGMII输入数据
    .eth_txc    (eth_txc   ),   //RGMII发送数据时钟    
    .eth_tx_ctl (eth_tx_ctl),   //RGMII输出数据有效信号
    .eth_txd    (eth_txd   ),   //RGMII输出数据          
    .eth_rst_n  (eth_rst_n ),   //以太网芯片复位信号，低电平有效    
   
    .audio_data (audio_data),
    .audio_en   (audio_en  ),
    .audio_clk  (audio_clk )
);



  
endmodule