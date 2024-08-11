//----------------------------------------------------------------------------------------
//**********************************
`timescale 1ns/1ns

module udp_top1
#(
    parameter     BOARD_MAC =     48'ha0_b1_c2_d3_e1_e1     ,     //开发板MAC地址
    parameter     BOARD_IP  = {8'd192,8'd168,8'd1,8'd11}    ,     //开发板IP地址
                                                                                
    parameter     DES_MAC   = 48'h08_8F_C3_5E_3A_42         ,     //PC   MAC地址
    parameter     DES_IP    = {8'd192,8'd168,8'd1,8'd103}          //目的 IP  地址
)
(
    //udp io                                                 
    output wire                          eth_rst_n_0            ,
    input  wire                          eth_rgmii_rxc_0        ,
    input  wire                          eth_rgmii_rx_ctl_0     ,
    input  wire [3:0]                    eth_rgmii_rxd_0        ,
                                                               
    output wire                          eth_rgmii_txc_0        ,
    output wire                          eth_rgmii_tx_ctl_0     ,
    output wire [3:0]                    eth_rgmii_txd_0        ,
    
    input   wire                            sys_clk             ,
    input   wire                         rst_n
   
);

/******************************wire********************************************/  






//udp
wire mac_tx_data_valid_0;
wire [7:0] mac_tx_data_0;
wire mac_rx_error_0;
wire mac_rx_data_valid_0;
wire [7:0] mac_rx_data_0;
wire rec_pkt_done;

wire tx_start_en;
wire [31:0] tx_data;
wire [15:0] tx_byte_num;
wire udp_tx_done;
wire tx_req;
// wire rst_n;

wire        rec_en      /*synthesis PAP_MARK_DEBUG="1"*/  ;
wire [7:0]  rec_data     /*synthesis PAP_MARK_DEBUG="1"*/ ;
wire  [15:0]      rec_byte_num  ;
wire   rgmii_clk_0   ;


// assign rst_n = 1'b1;


assign eth_rst_n_0 = rst_n;



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
    
    .tx_start_en   ('d0                 ),  //input       以太网开始发送信号                  
    .tx_data       ('d0                 ),  //input [31:0]以太网待发送数据                    
    .tx_byte_num   (tx_byte_num         ),  //input [15:0]以太网发送的有效字节数 单位:byte   
    .des_mac       (DES_MAC             ),  //input [47:0]发送的目标MAC地址            
    .des_ip        (DES_IP              ),  //input [31:0]发送的目标IP地址              
    .tx_done       (udp_tx_done         ),  //output      以太网发送完成信号                  
    .tx_req        (tx_req              )   //output      读数据请求信号                      
    ); 
    
//测试跨比特fifo

// reg [7:0] cnt;


// always@(posedge sys_clk)
// begin
    // if(~rst_n)
        // cnt <= 1'b0;
    // else
        // cnt <= cnt + 1'b1;
// end 


// reg [7:0] data;
// reg rd_en;


// always@(posedge sys_clk)
// begin
    // if(~rst_n)begin
        // data <= 'd0;
        // rd_en <= 'd0;
    // end else if(cnt >= 1'b1)begin
        // data <= cnt;
        // rd_en <= 1'b1;
    // end else begin
        // data <= data;
        // rd_en <= rd_en;
    // end
// end

wire rs_en1/*synthesis PAP_MARK_DEBUG="1"*/ ;
wire [15:0] rd_data/*synthesis PAP_MARK_DEBUG="1"*/ ;
wire almost_empty;
wire [9:0] rd_water_level/*synthesis PAP_MARK_DEBUG="1"*/ ;

assign rs_en1 = (rd_water_level >= 'd1)?1'b1:1'b0;

cdc_fifo the_instance_name 
(
  .wr_clk(rgmii_clk_0),                // input
  .wr_rst(~rst_n     ),                // input
  .wr_en (rec_en     ),                  // input
  .wr_data(rec_data),              // input [7:0]
  .wr_full(),              // output
  .wr_water_level(),  
  .almost_full(),      // output
  .rd_clk(rgmii_clk_0),                // input
  .rd_rst(~rst_n),                // input
  .rd_en(rs_en1),                  // input
  .rd_data(rd_data),              // output [15:0]
  .rd_empty(),            // output
  .rd_water_level(rd_water_level), 
  .almost_empty()     // output
);






endmodule




