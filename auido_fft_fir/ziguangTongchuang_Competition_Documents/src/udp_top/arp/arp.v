
module arp(
    input                rst_n      , //复位信号，低电平有效
    //GMII接口
    input                gmii_rx_clk, //GMII接收数据时钟
    input                gmii_rx_dv , //GMII输入数据有效信号
    input        [7:0]   gmii_rxd   , //GMII输入数据
    input                gmii_tx_clk, //GMII发送数据时钟
    output               gmii_tx_en , //GMII输出数据有效信号
    output       [7:0]   gmii_txd   , //GMII输出数据          

    //用户接口
    output               arp_rx_done, //ARP接收完成信号
    output               arp_rx_type, //ARP接收类型 0:请求  1:应答
    output       [47:0]  src_mac    , //接收到目的MAC地址
    output       [31:0]  src_ip     , //接收到目的IP地址    
    input                arp_tx_en  , //ARP发送使能信号
    input                arp_tx_type, //ARP发送类型 0:请求  1:应答
    input        [47:0]  des_mac    , //发送的目标MAC地址
    input        [31:0]  des_ip     , //发送的目标IP地址
    output               tx_done      //以太网发送完成信号    
    );

//parameter define
//开发板MAC地址 192.168.1.11     
parameter  BOARD_MAC =  48'ha0_b1_c2_d3_e1_e1;     
//开发板IP地址 192.168.1.11     
parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd11};// ip 32'hC0_A8_01_0B

// 以下参数换成自己电脑的
//目的MAC地址 ff_ff_ff_ff_ff_ff
parameter  DES_MAC   = 48'h84_A9_38_BF_C9_A0;
//目的IP地址 169.254.51.120
parameter  DES_IP    = {8'd169,8'd254,8'd51,8'd120};

//wire define
wire           crc_en  ; //CRC开始校验使能
wire           crc_clr ; //CRC数据复位信号 
wire   [7:0]   crc_d8  ; //输入待校验8位数据
wire   [31:0]  crc_data; //CRC校验数据
wire   [31:0]  crc_next; //CRC下次校验完成数据

//*****************************************************
//**                    main code
//*****************************************************

assign  crc_d8 = gmii_txd;

//ARP接收模块    
arp_rx 
   #(
    .BOARD_MAC       (BOARD_MAC),         //参数例化
    .BOARD_IP        (BOARD_IP )
    )
   u_arp_rx(
    .clk             (gmii_rx_clk),
    .rst_n           (rst_n),

    .gmii_rx_dv      (gmii_rx_dv),
    .gmii_rxd        (gmii_rxd  ),
    .arp_rx_done     (arp_rx_done),
    .arp_rx_type     (arp_rx_type),
    .src_mac         (src_mac    ),
    .src_ip          (src_ip     )
    );                                           

//ARP发送模块
arp_tx
   #(
    .BOARD_MAC       (BOARD_MAC),         //参数例化
    .BOARD_IP        (BOARD_IP ),
    .DES_MAC         (DES_MAC  ),
    .DES_IP          (DES_IP   )
    )
   u_arp_tx(
    .clk             (gmii_tx_clk),
    .rst_n           (rst_n),

    .arp_tx_en       (arp_tx_en ),
    .arp_tx_type     (arp_tx_type),
    .des_mac         (des_mac   ),
    .des_ip          (des_ip    ),
    .crc_data        (crc_data  ),
    .crc_next        (crc_next[31:24]),
    .tx_done         (tx_done   ),
    .gmii_tx_en      (gmii_tx_en),
    .gmii_txd        (gmii_txd  ),
    .crc_en          (crc_en    ),
    .crc_clr         (crc_clr   )
    );     

//以太网发送CRC校验模块
crc32_d8   u_crc32_d8(
    .clk             (gmii_tx_clk),                      
    .rst_n           (rst_n      ),                          
    .data            (crc_d8     ),            
    .crc_en          (crc_en     ),                          
    .crc_clr         (crc_clr    ),                         
    .crc_data        (crc_data   ),                        
    .crc_next        (crc_next   )                         
    );

endmodule
