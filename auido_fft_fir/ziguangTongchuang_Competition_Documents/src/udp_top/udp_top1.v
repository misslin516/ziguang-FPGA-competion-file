// Created date:        2024/4/29
// Version:             V1.0
// revised data:        2024/4/29
// Descriptions:        The original version
// purpose     :   connect to python
//----------------------------------------------------------------------------------------
//**********************************
`timescale 1ns/1ns

module udp_top1
#(
    parameter     BOARD_MAC =     48'ha0_b1_c2_d3_e1_e1     ,     //开发板MAC地址
    parameter     BOARD_IP  = {8'd192,8'd168,8'd1,8'd11}    ,     //开发板IP地址
                                                                                
    parameter     DES_MAC   = 48'h84_A9_38_BF_C9_A0         ,     //PC   MAC地址
    parameter     DES_IP    = {8'd192,8'd168,8'd1,8'd10}          //目的 IP  地址
)
(
    //audio io
    
    input  wire                          audio_en               ,
    input  wire    [15:0]                audio_data             ,
    input  wire                          key                    ,
    
    //udp io                                                 
    output wire                          eth_rst_n_0            ,
    input  wire                          eth_rgmii_rxc_0        ,
    input  wire                          eth_rgmii_rx_ctl_0     ,
    input  wire [3:0]                    eth_rgmii_rxd_0        ,
                                                               
    output wire                          eth_rgmii_txc_0        ,
    output wire                          eth_rgmii_tx_ctl_0     ,
    output wire [3:0]                    eth_rgmii_txd_0        ,
    
    //system clk
    input                                clk_50m                ,
    input                                audio_clk              ,
    input                                rst_n                  ,
    
    //test   io
    output wire                           led                   ,
    output                                rec_en                ,
    output      [31:0]                    rec_data              ,
    output      [15:0]                    rec_byte_num          ,
    output                                rgmii_clk_0
);

/******************************wire********************************************/  



//gmii
// wire rgmii_clk_0;


//udp
wire mac_tx_data_valid_0;
wire [7:0] mac_tx_data_0;
wire mac_rx_error_0;
wire mac_rx_data_valid_0;
wire [7:0] mac_rx_data_0;
wire rec_pkt_done;
// wire rec_en;
// wire [31:0] rec_data;
// wire [15:0] rec_byte_num;
wire tx_start_en;
wire [31:0] tx_data;
wire [15:0] tx_byte_num;
wire udp_tx_done;
wire tx_req;

assign eth_rst_n_0 = rst_n;

assign led = (tx_start_en == 1'b1)?1'b0:1'b1;



reg [31:0] audio_data1;
reg [1:0] audio_en1;

///delay the audio_en and data  two clock

always@(posedge audio_clk or negedge rst_n)
begin
    if(~rst_n) begin
        audio_data1 <= 32'd0;
        audio_en1 <= 2'd0;
    end else begin
        audio_data1 <= {audio_data1[15:0],audio_data};
        audio_en1 <= {audio_en1[0],audio_en};
    end
end

reg [15:0] cnt_trans_valid;
reg [15:0] wait_cnt;
always@(posedge audio_clk or negedge rst_n)
begin
    if(~rst_n) begin
        cnt_trans_valid <= 16'd0;
        wait_cnt <= 16'd0;
    end else if(audio_en) begin
        cnt_trans_valid <= cnt_trans_valid + 1'b1;
        wait_cnt <= 16'd0;
    end else begin
        cnt_trans_valid <= cnt_trans_valid ;
        if(wait_cnt == 16'd300)  //debug display max  = 248
            wait_cnt <= 16'hffff;
        else
            wait_cnt <= wait_cnt + 1'b1;
    end
          
end

wire transfer_flag;
assign transfer_flag = key ?((~rst_n || wait_cnt == 16'hffff)?1'b0:1'b1):1'b0;

audio_data_pkt1_revised audio_data_pkt1_revised_inst
(
    .rst_n          (rst_n          ),
   
    .audio_clk      (audio_clk      ),
    .audio_en       (audio_en1[1]   ),
    .audio_data     (audio_data1[31:16]     ),
   
    .transfer_flag  (transfer_flag           ),  //音频开始传输标志,1:开始传输 0:停止传输
   
    .eth_tx_clk     (rgmii_clk_0     ),   //以太网发送时钟
    .udp_tx_req     (tx_req          ),   //udp发送数据请求信号
    .udp_tx_done    (udp_tx_done    ),   //udp发送数据完成信号                               
    .udp_tx_start_en(tx_start_en),   //udp开始发送信号
    .udp_tx_data    (tx_data    ),   //udp发送的数据
    .udp_tx_byte_num(tx_byte_num)    //udp单包发送的有效字节数  --65535 maxbytes
);


//ETH0_GMII_RGMII
gmii_to_rgmii eth0_gmii_to_rgmii(
   .rgmii_clk             (rgmii_clk_0       ),    // output GMII时钟，供数据使用      
   .rst                   (rst_n         ),    // input        
    //mac输入的数据由gmii转化为rgmii，时钟为rgmii_clk
   .mac_tx_data_valid     (mac_tx_data_valid_0),    // input        
   .mac_tx_data           (mac_tx_data_0      ),    // input [7:0]  
    //eth输入的数据由rgmii转化为gmii，时钟为rgmii_clk
   .mac_rx_error          (mac_rx_error_0     ),    //output reg       
   .mac_rx_data_valid     (mac_rx_data_valid_0),    //output reg       
   .mac_rx_data           (mac_rx_data_0      ),    //output reg [7:0] 
   //eth接收                
   .rgmii_rxc             (eth_rgmii_rxc_0    ),    //input        
   .rgmii_rx_ctl          (eth_rgmii_rx_ctl_0 ),    //input        
   .rgmii_rxd             (eth_rgmii_rxd_0    ),    //input [3:0]  
   //eth发送                                    
   .rgmii_txc             (eth_rgmii_txc_0    ),    //output       
   .rgmii_tx_ctl          (eth_rgmii_tx_ctl_0 ),    //output       
   .rgmii_txd             (eth_rgmii_txd_0    )     //output [3:0] 
);

//UDP通信
udp_top                                             
   #(
    .BOARD_MAC     (BOARD_MAC),      //参数例化
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   )
    )
u_udp(
    .rst_n         (rst_n   ),  //input       复位信号，低电平有效            
    //GMII接口                                
    .gmii_rx_clk   (rgmii_clk_0         ),  //input       GMII接收数据时钟                    
    .gmii_rx_dv    (mac_rx_data_valid_0 ),  //input       GMII输入数据有效信号                
    .gmii_rxd      (mac_rx_data_0       ),  //input [7:0] GMII输入数据                              
    .gmii_tx_clk   (rgmii_clk_0         ),  //input       GMII发送数据时钟            
    .gmii_tx_en    (mac_tx_data_valid_0 ),  //output      GMII输出数据有效信号                  
    .gmii_txd      (mac_tx_data_0       ),  //output[7:0] GMII输出数据              
    //用户接口                                  
    .rec_pkt_done  (rec_pkt_done        ),  //output      以太网单包数据接收完成信号          
    .rec_en        (rec_en              ),  //output      以太网接收的数据使能信号            
    .rec_data      (rec_data            ),  //output[31:0]以太网接收的数据                    
    .rec_byte_num  (rec_byte_num        ),  //output[15:0]以太网接收的有效字节数 单位:byte  
    
    .tx_start_en   (tx_start_en         ),  //input       以太网开始发送信号                  
    .tx_data       (tx_data             ),  //input [31:0]以太网待发送数据                    
    .tx_byte_num   (tx_byte_num         ),  //input [15:0]以太网发送的有效字节数 单位:byte   
    .des_mac       (DES_MAC             ),  //input [47:0]发送的目标MAC地址            
    .des_ip        (DES_IP              ),  //input [31:0]发送的目标IP地址              
    .tx_done       (udp_tx_done         ),  //output      以太网发送完成信号                  
    .tx_req        (tx_req              )   //output      读数据请求信号                      
    ); 




endmodule




