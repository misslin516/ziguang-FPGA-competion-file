// Created date:        2024/4/18
// Version:             V1.2
// revised data:        2024/4/23
// Descriptions:        The original version
//   the ping function is not included  in this code
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module audio_udp_top
(
    output wire                          eth_rst_n_0        , //以太网复位信号
    input  wire                          eth_rgmii_rxc_0    ,
    input  wire                          eth_rgmii_rx_ctl_0 ,
    input  wire [3:0]                    eth_rgmii_rxd_0    ,  
                        
    output wire                          eth_rgmii_txc_0    ,
    output wire                          eth_rgmii_tx_ctl_0 ,
    output wire [3:0]                    eth_rgmii_txd_0    ,
    input                                clk_50m            ,
    output wire                           led                

);
//开发板MAC地址 192.168.1.11     
parameter  BOARD_MAC =  48'ha0_b1_c2_d3_e1_e1;     
//开发板IP地址 192.168.1.11     
parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd11};// ip 32'hC0_A8_01_0B

// 以下参数换成自己电脑的
//目的MAC地址 ff_ff_ff_ff_ff_ff
parameter  DES_MAC   = 48'h84_A9_38_BF_C9_A0;
// parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;
//目的IP地址 169.254.51.120
parameter  DES_IP    = {8'd169,8'd254,8'd51,8'd120};

/******************************wire********************************************/  
//audio    
wire        audio_clk ;
wire        rst_n     ; 
wire        audio_en  ;
wire [15:0] audio_data;
//test for this para

reg [15:0] data_reg;
reg [3:0]  cnt_clk_12M;
reg clk_12M;

always@(posedge clk_50m or negedge rst_n)
begin
    if(~rst_n)
        cnt_clk_12M <= 4'd0;
    else if(cnt_clk_12M == 4'd4)
        cnt_clk_12M <= 4'd0;
    else
        cnt_clk_12M <= cnt_clk_12M + 1'b1;
end

always@(posedge clk_50m or negedge rst_n)
begin
    if(~rst_n)
        clk_12M <= 1'b0;
    else if(cnt_clk_12M == 4'd4)
        clk_12M <=  ~clk_12M ;
    else
        clk_12M <=  clk_12M ;
end

always@(posedge clk_12M or negedge rst_n)
begin
    if(~rst_n)
        data_reg <= 16'd0;
    else if(data_reg == 16'd9999)
        data_reg <= data_reg;
    else
        data_reg <= data_reg + 16'd1;
end

reg [15:0] audio_data_reg;
reg audio_en_reg;

always@(posedge clk_12M or negedge rst_n)
begin
    if(~rst_n)
        audio_data_reg <= 16'd0000;
    else if(data_reg == 16'd9999)
        audio_data_reg <= 16'd0000;
    else
        audio_data_reg <= audio_data_reg + 16'd1;
end

always@(posedge clk_12M or negedge rst_n)
begin
    if(~rst_n)
        audio_en_reg <= 1'b0;
    else if(data_reg == 16'd1)
        audio_en_reg <= 1'b1;
    else if(data_reg == 16'd9999)
         audio_en_reg <= 1'b0;
    else;
end
assign audio_data = audio_data_reg;
assign audio_en = audio_en_reg;
assign audio_clk = clk_12M;


//gmii
wire rgmii_clk_0;


//udp
wire mac_tx_data_valid_0;
wire [7:0] mac_tx_data_0;
wire mac_rx_error_0;
wire mac_rx_data_valid_0;
wire [7:0] mac_rx_data_0;
wire rec_pkt_done;
wire rec_en;
wire [31:0] rec_data;
wire [15:0] rec_byte_num;
wire tx_start_en;
wire [31:0] tx_data;
wire [15:0] tx_byte_num;
wire udp_tx_done;
wire tx_req;

//for test;
localparam max_1ms = 16'd49;

reg [15:0] cnt_1ms = 16'd0;
always@(posedge clk_50m)
begin
    if(cnt_1ms == max_1ms)
        cnt_1ms <= cnt_1ms;
    else
        cnt_1ms <= cnt_1ms +1'b1;
end

assign rst_n = (cnt_1ms == max_1ms)?1'b1:1'b0;
assign eth_rst_n_0 = rst_n;

assign led = (tx_start_en == 1'b1)?1'b0:1'b1;

// assign transfer_flag = (rst_n == 1) ? 1'b1:(data_reg == 16'd9999)?1'b0:transfer_flag;




audio_data_pkt1_revised audio_udp_pk2_inst
(
    .rst_n          (rst_n          ),
   
    .audio_clk      (audio_clk      ),
    .audio_en       (audio_en       ),
    .audio_data     (audio_data     ),
   
    .transfer_flag  (1'b1  ),  //音频开始传输标志,1:开始传输 0:停止传输
   
    .eth_tx_clk     (rgmii_clk_0     ),   //以太网发送时钟
    .udp_tx_req     (tx_req     ),   //udp发送数据请求信号
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