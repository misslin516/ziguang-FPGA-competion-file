//created date:2024/05/26
module udp_loop
(                                               
    output wire                          eth_rst_n_0            ,
    input  wire                          eth_rgmii_rxc_0        ,
    input  wire                          eth_rgmii_rx_ctl_0     ,
    input  wire [3:0]                    eth_rgmii_rxd_0        ,
                                                               
    output wire                          eth_rgmii_txc_0        ,
    output wire                          eth_rgmii_tx_ctl_0     ,
    output wire [3:0]                    eth_rgmii_txd_0        ,
                    
    input                                sys_clk                              
);


//开发板MAC地址     
parameter  BOARD_MAC =  48'ha0_b1_c2_d3_e1_e1;     
//开发板IP地址 192.168.1.11     
parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd11};// ip 32'hC0_A8_01_0B

// 以下参数换成自己电脑的
//目的MAC地址 ff_ff_ff_ff_ff_ff
parameter  DES_MAC   = 48'h84_A9_38_BF_C9_A0;
//目的IP地址 169.254.51.120
parameter  DES_IP    = {8'd169,8'd254,8'd51,8'd120};

/******************************wire********************************************/  
//rst_n
reg [16:0] cnt = 'd0;

always@(posedge sys_clk)
begin
    if(cnt == 'd2048)
        cnt <= cnt;
    else
        cnt <= cnt + 1'b1;
end




//rst_n
wire rst_n;

assign rst_n = (cnt == 'd2048)?1'b1:1'b0;

//gmii
wire rgmii_clk_0;
wire mac_rx_error_0;
wire mac_rx_data_valid_0;
wire [7:0] mac_rx_data_0;

//para
wire  [31:0]	  rec_data			  ;
wire		        rec_en			  ;
wire		        tx_req			  ;
wire  [31:0]	  tx_data	    	  ;



//para udp
wire          udp_gmii_tx_en	  ; //UDP GMII输出数据有效信号 
wire  [7:0]   udp_gmii_txd  	  ; //UDP GMII输出数据
wire          rec_pkt_done  	  ; //UDP单包数据接收完成信号
wire          udp_rec_en    	  ; //UDP接收的数据使能信号
wire  [31:0]  udp_rec_data  	  ; //UDP接收的数据
wire  [15:0]  rec_byte_num  	  ; //UDP接收的有效字节数 单位:byte 
wire  [15:0]  tx_byte_num   	  ; //UDP发送的有效字节数 单位:byte 
wire          udp_tx_done   	  ; //UDP发送完成信号
wire          udp_tx_req    	  ; //UDP读数据请求信号
wire  [31:0]  udp_tx_data   	  ; //UDP待发送数据
wire          tx_start_en   	  ; //UDP发送开始使能信号

//para gmii
wire          gmii_tx_en 		  ; //GMII发送数据使能信号
wire  [7:0]   gmii_txd   		  ; //GMII发送数据
  

//para icmp
wire          icmp_gmii_tx_en	  ; //ICMP GMII输出数据有效信号 
wire  [7:0]   icmp_gmii_txd  	  ; //ICMP GMII输出数据
wire          icmp_rec_pkt_done   ; //ICMP单包数据接收完成信号
wire          icmp_rec_en         ; //ICMP接收的数据使能信号
wire  [ 7:0]  icmp_rec_data       ; //ICMP接收的数据
wire  [15:0]  icmp_rec_byte_num   ; //ICMP接收的有效字节数 单位:byte 
wire  [15:0]  icmp_tx_byte_num    ; //ICMP发送的有效字节数 单位:byte 
wire          icmp_tx_done   	  ; //ICMP发送完成信号
wire          icmp_tx_req         ; //ICMP读数据请求信号
wire  [7:0]  icmp_tx_data         ; //ICMP待发送数据
wire          icmp_tx_start_en    ; //ICMP发送开始使能信号

 //para arp 
 wire arp_gmii_tx_en              ;
 wire [7:0] arp_gmii_txd          ;
 wire          arp_rx_done   	  ; //ARP接收完成信号
 wire          arp_rx_type   	  ; //ARP接收类型 0:请求  1:应答
 wire  [47:0]  src_mac       	  ; //接收到目的MAC地址
 wire  [31:0]  src_ip        	  ; //接收到目的IP地址    
 wire          arp_tx_en     	  ; //ARP发送使能信号
 wire          arp_tx_type   	  ; //ARP发送类型 0:请求  1:应答
 wire  [47:0]  des_mac       	  ; //发送的目标MAC地址
 wire  [31:0]  des_ip        	  ; //发送的目标IP地址   
 wire          arp_tx_done   	  ; //ARP发送完成信号
 
 






assign eth_rst_n_0 = rst_n;
assign icmp_tx_start_en = icmp_rec_pkt_done;
assign icmp_tx_byte_num = icmp_rec_byte_num;

assign tx_start_en = rec_pkt_done;
assign tx_byte_num = rec_byte_num;
assign des_mac = src_mac;
assign des_ip = src_ip;


//ETH0_GMII_RGMII
gmii_to_rgmii eth0_gmii_to_rgmii(
   .rgmii_clk             (rgmii_clk_0       ),    // output GMII时钟，供数据使用      
   .rst                   (rst_n             ),    // input        
    //mac输入的数据由gmii转化为rgmii，时钟为rgmii_clk
   .mac_tx_data_valid     (gmii_tx_en),    // input        
   .mac_tx_data           (gmii_txd      ),    // input [7:0]  
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


//ARP通信 -- 解析地址
arp                                             
   #(
    .BOARD_MAC     (BOARD_MAC),      //参数例化
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   )
    )
   u_arp(
    .rst_n         (rst_n  	  ),
                    
    .gmii_rx_clk   (rgmii_clk_0	  ),
    .gmii_rx_dv    (mac_rx_data_valid_0 	  ),
    .gmii_rxd      (mac_rx_data_0   	  ),
    .gmii_tx_clk   (rgmii_clk_0	  ),
    .gmii_tx_en    (arp_gmii_tx_en),
    .gmii_txd      (arp_gmii_txd  ),
                    
    .arp_rx_done   (arp_rx_done	  ),
    .arp_rx_type   (arp_rx_type	  ),
    .src_mac       (src_mac    	  ),
    .src_ip        (src_ip     	  ),
    .arp_tx_en     (arp_tx_en  	  ),
    .arp_tx_type   (arp_tx_type	  ),
    .des_mac       (des_mac    	  ),
    .des_ip        (des_ip     	  ),
    .tx_done       (arp_tx_done	  )
    );
    
    


//ICMP通信 --- 报告错误
icmp                                             
   #(
    .BOARD_MAC     (BOARD_MAC),      //参数例化
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   )
    )
   u_icmp(
    .rst_n         (rst_n   	 ),  
		 
    .gmii_rx_clk   (rgmii_clk_0 	 ),           
    .gmii_rx_dv    (mac_rx_data_valid_0  	 ),         
    .gmii_rxd      (mac_rx_data_0    	 ),                   
    .gmii_tx_clk   (rgmii_clk_0 	 ), 
    .gmii_tx_en    (icmp_gmii_tx_en	 ),         
    .gmii_txd      (icmp_gmii_txd	 ),  

    .rec_pkt_done  (icmp_rec_pkt_done),    
    .rec_en        (icmp_rec_en      ), 		  
    .rec_data      (icmp_rec_data    ),   	    
    .rec_byte_num  (icmp_rec_byte_num),      
    .tx_start_en   (icmp_tx_start_en ),        
    .tx_data       (icmp_tx_data     ),       
    .tx_byte_num   (icmp_tx_byte_num ),  
    .des_mac       (des_mac     	 ),
    .des_ip        (des_ip      	 ),    
    .tx_done       (icmp_tx_done	 ),        
    .tx_req        (icmp_tx_req      )        
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
    .gmii_tx_en    (udp_gmii_tx_en ),  //output      GMII输出数据有效信号                  
    .gmii_txd      (udp_gmii_txd       ),  //output[7:0] GMII输出数据              
    //用户接口                                  
    .rec_pkt_done  (rec_pkt_done        ),  //output      以太网单包数据接收完成信号          
    .rec_en        (udp_rec_en              ),  //output      以太网接收的数据使能信号            
    .rec_data      (udp_rec_data            ),  //output[31:0]以太网接收的数据                    
    .rec_byte_num  (rec_byte_num        ),  //output[15:0]以太网接收的有效字节数 单位:byte  
    
    .tx_start_en   (tx_start_en         ),  //input       以太网开始发送信号                  
    .tx_data       (udp_tx_data),  //input [31:0]以太网待发送数据                    
    .tx_byte_num   (tx_byte_num         ),  //input [15:0]以太网发送的有效字节数 单位:byte   
    .des_mac       (des_mac             ),  //input [47:0]发送的目标MAC地址            
    .des_ip        (des_ip              ),  //input [31:0]发送的目标IP地址              
    .tx_done       (udp_tx_done         ),  //output      以太网发送完成信号                  
    .tx_req        (udp_tx_req              )   //output      读数据请求信号                      
    ); 
    

fifo_udp_loop fifo_udp_loop 
(
  .wr_data          (rec_data   ),                  // input [31:0]
  .wr_en            (rec_en     ),                      // input
  .wr_clk           (rgmii_clk_0),                    // input
  .full             (           ),                        // output
  .wr_rst           (~rst_n     ),                    // input
  .almost_full      (           ),          // output
  .wr_water_level   (           ),    // output [10:0]
  .rd_data          (tx_data    ),                  // output [31:0]
  .rd_en            (tx_req     ),                      // input
  .rd_clk           (rgmii_clk_0),                    // input
  .empty            (           ),                      // output
  .rd_rst           (~rst_n     ),                    // input
  .almost_empty     (           ),        // output
  .rd_water_level   (           )     // output [10:0]
);

//以太网控制模块
eth_ctrl u_eth_ctrl(
    .clk            	(rgmii_clk_0	 ),
    .rst_n          	(rst_n		     ),
										 
    .arp_rx_done    	(arp_rx_done   	 ),
    .arp_rx_type    	(arp_rx_type   	 ),
    .arp_tx_en      	(arp_tx_en     	 ),
    .arp_tx_type    	(arp_tx_type   	 ),
    .arp_tx_done    	(arp_tx_done   	 ),
    .arp_gmii_tx_en 	(arp_gmii_tx_en	 ),
    .arp_gmii_txd   	(arp_gmii_txd  	 ),
										 
    .icmp_tx_start_en	(icmp_tx_start_en),
    .icmp_tx_done		(icmp_tx_done	 ),
    .icmp_gmii_tx_en	(icmp_gmii_tx_en ),
    .icmp_gmii_txd		(icmp_gmii_txd	 ),
										 
	.icmp_rec_en       	(icmp_rec_en     ),
	.icmp_rec_data     	(icmp_rec_data   ),
	.icmp_tx_req       	(icmp_tx_req     ),
	.icmp_tx_data      	(icmp_tx_data    ),
										 
    .udp_tx_start_en	(tx_start_en   	 ),
    .udp_tx_done    	(udp_tx_done   	 ),    
    .udp_gmii_tx_en 	(udp_gmii_tx_en	 ),
    .udp_gmii_txd   	(udp_gmii_txd  	 ),
										 
	.udp_rec_data		(udp_rec_data	 ),		
	.udp_rec_en			(udp_rec_en		 ),    
	.udp_tx_req			(udp_tx_req		 ),    
	.udp_tx_data		(udp_tx_data	 ),		
										 
	.rec_data			(rec_data	     ),	
	.rec_en	        	(rec_en	         ),
    .tx_req	        	(tx_req	         ),
	.tx_data	    	(tx_data	     ),
										 
    .gmii_tx_en     	(gmii_tx_en    	 ),
    .gmii_txd       	(gmii_txd      	 )
    );



    
endmodule