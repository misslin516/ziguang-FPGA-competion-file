// Created by:          njupt
// Created date:        2024/4/18
// Version:             V1.1
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module audio_udp_top_revised
(
    input              sys_clk     ,   //系统时钟  
    input              sys_rst_n   ,   //系统复位信号，低电平有效 
    //以太网接口
    input              eth_rxc     ,   //RGMII接收数据时钟
    input              eth_rx_ctl  ,   //RGMII输入数据有效信号
    input       [3:0]  eth_rxd     ,   //RGMII输入数据
    output             eth_txc     ,   //RGMII发送数据时钟    
    output             eth_tx_ctl  ,   //RGMII输出数据有效信号
    output      [3:0]  eth_txd     ,   //RGMII输出数据          
    output             eth_rst_n   ,   //以太网芯片复位信号，低电平有效    

    //PMOD 音频数据接口                
    input   [15:0]     audio_data  ,
    input              audio_en    ,
    input              audio_clk
);

//parameter define
//开发板MAC地址 
parameter  BOARD_MAC = 48'ha0_b1_c2_d3_e1_e1;     
//开发板IP地址 192.168.1.11
parameter  BOARD_IP  = 32'hC0_A8_01_0B;//192.168.1.11;  
//目的MAC地址  
parameter  DES_MAC   = 48'h84_A9_38_BF_C9_A0;    

parameter  DES_IP    =  32'hA9_FE_33_78;              //169.254.51.120;


//wire define
wire            clk_50m         ;   //50Mhz时钟
wire            clk_200m        ;   //200Mhz时钟
wire            eth_tx_clk      ;   //以太网发送时钟
wire            locked          ; 
wire            rst_n           ; 



wire            eth_rx_clk      ;   //以太网接收时钟
wire            udp_tx_start_en ;   //以太网开始发送信号
wire   [15:0]   udp_tx_byte_num ;   //以太网发送的有效字节数
wire   [31:0]   udp_tx_data     ;   //以太网发送的数据    
wire            udp_rec_pkt_done;   //以太网单包数据接收完成信号
wire            udp_rec_en      ;   //以太网接收使能信号
wire   [31:0]   udp_rec_data    ;   //以太网接收到的数据
wire   [15:0]   udp_rec_byte_num;   //以太网接收到的字节个数
wire            udp_tx_req      ;   //以太网发送请求数据信号
wire            udp_tx_done     ;   //以太网发送完成信号

//*****************************************************
//**                    main code
//*****************************************************

assign  rst_n = sys_rst_n;
    
   
    
//音频封装模块    
audio_data_pkt audio_data_pkt_inst
(
   .rst_n          (rst_n          ),
  
   .audio_clk      (audio_clk      ),
   .audio_en       (audio_en       ),
   .audio_data     (audio_data     ),
 
   .transfer_flag  (1'b1           ),  //音频开始传输标志,1:开始传输 0:停止传输
  
   .eth_tx_clk     (eth_tx_clk     ),   //以太网发送时钟
   .udp_tx_req     (udp_tx_req     ),   //udp发送数据请求信号
   .udp_tx_done    (udp_tx_done    ),   //udp发送数据完成信号                               
   .udp_tx_start_en(udp_tx_start_en),   //udp开始发送信号
   .udp_tx_data    (udp_tx_data    ),   //udp发送的数据
   .udp_tx_byte_num(udp_tx_byte_num)    //udp单包发送的有效字节数
);

wire gmii_tx_en;
wire [7:0] gmii_txd;
wire mac_rx_error_0;
wire gmii_rx_dv;

wire [7:0] gmii_rxd;
wire mac_rx_error;

//ETH0_GMII_RGMII
gmii_to_rgmii eth0_gmii_to_rgmii(
   .rgmii_clk             (eth_tx_clk       ),    // output GMII时钟，供数据使用      
   .rst                   (rst_n         ),    // input        
    //mac输入的数据由gmii转化为rgmii，时钟为rgmii_clk
   .mac_tx_data_valid     (gmii_tx_en),    // input        
   .mac_tx_data           (gmii_txd      ),    // input [7:0]  
    //eth输入的数据由rgmii转化为gmii，时钟为rgmii_clk
   .mac_rx_error          (   mac_rx_error   ),    //output reg       
   .mac_rx_data_valid     (gmii_rx_dv),    //output reg       
   .mac_rx_data           (gmii_rxd      ),    //output reg [7:0] 
   //eth接收                
   .rgmii_rxc             (eth_rxc    ),    //input        
   .rgmii_rx_ctl          (eth_rx_ctl ),    //input        
   .rgmii_rxd             (eth_rxd    ),    //input [3:0]  
   //eth发送                                    
   .rgmii_txc             (eth_txc    ),    //output       
   .rgmii_tx_ctl          (eth_tx_ctl ),    //output       
   .rgmii_txd             (eth_txd    )     //output [3:0] 
);


wire rec_pkt_done;
wire rec_en;
wire [31:0] rec_data;
wire [15:0] rec_byte_num;
wire udp_tx_done;

//UDP通信
udp                                             
   #(
    .BOARD_MAC     (BOARD_MAC),      //参数例化
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   )
    )
u_udp(
    .rst_n         (rst_n   ),  //input       复位信号，低电平有效            
    //GMII接口                                
    .gmii_rx_clk   (eth_tx_clk         ),  //input       GMII接收数据时钟                    
    .gmii_rx_dv    (gmii_rx_dv ),  //input       GMII输入数据有效信号                
    .gmii_rxd      (gmii_rxd       ),  //input [7:0] GMII输入数据                              
    .gmii_tx_clk   (eth_tx_clk         ),  //input       GMII发送数据时钟            
    .gmii_tx_en    (gmii_tx_en ),  //output      GMII输出数据有效信号                  
    .gmii_txd      (gmii_txd       ),  //output[7:0] GMII输出数据              
    //用户接口                                  
    .rec_pkt_done  (rec_pkt_done        ),  //output      以太网单包数据接收完成信号          
    .rec_en        (rec_en              ),  //output      以太网接收的数据使能信号            
    .rec_data      (rec_data            ),  //output[31:0]以太网接收的数据                    
    .rec_byte_num  (rec_byte_num        ),  //output[15:0]以太网接收的有效字节数 单位:byte  
    
    .tx_start_en   (udp_tx_start_en         ),  //input       以太网开始发送信号                  
    .tx_data       (udp_tx_data             ),  //input [31:0]以太网待发送数据                    
    .tx_byte_num   (udp_tx_byte_num         ),  //input [15:0]以太网发送的有效字节数 单位:byte   
    .des_mac       (DES_MAC             ),  //input [47:0]发送的目标MAC地址            
    .des_ip        (DES_IP              ),  //input [31:0]发送的目标IP地址              
    .tx_done       (udp_tx_done         ),  //output      以太网发送完成信号                  
    .tx_req        (udp_tx_req              )   //output      读数据请求信号                      
    ); 
    
endmodule