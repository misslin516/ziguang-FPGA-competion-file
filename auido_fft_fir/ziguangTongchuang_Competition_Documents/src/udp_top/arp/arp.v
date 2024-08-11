
module arp(
    input                rst_n      , //��λ�źţ��͵�ƽ��Ч
    //GMII�ӿ�
    input                gmii_rx_clk, //GMII��������ʱ��
    input                gmii_rx_dv , //GMII����������Ч�ź�
    input        [7:0]   gmii_rxd   , //GMII��������
    input                gmii_tx_clk, //GMII��������ʱ��
    output               gmii_tx_en , //GMII���������Ч�ź�
    output       [7:0]   gmii_txd   , //GMII�������          

    //�û��ӿ�
    output               arp_rx_done, //ARP��������ź�
    output               arp_rx_type, //ARP�������� 0:����  1:Ӧ��
    output       [47:0]  src_mac    , //���յ�Ŀ��MAC��ַ
    output       [31:0]  src_ip     , //���յ�Ŀ��IP��ַ    
    input                arp_tx_en  , //ARP����ʹ���ź�
    input                arp_tx_type, //ARP�������� 0:����  1:Ӧ��
    input        [47:0]  des_mac    , //���͵�Ŀ��MAC��ַ
    input        [31:0]  des_ip     , //���͵�Ŀ��IP��ַ
    output               tx_done      //��̫����������ź�    
    );

//parameter define
//������MAC��ַ 192.168.1.11     
parameter  BOARD_MAC =  48'ha0_b1_c2_d3_e1_e1;     
//������IP��ַ 192.168.1.11     
parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd11};// ip 32'hC0_A8_01_0B

// ���²��������Լ����Ե�
//Ŀ��MAC��ַ ff_ff_ff_ff_ff_ff
parameter  DES_MAC   = 48'h84_A9_38_BF_C9_A0;
//Ŀ��IP��ַ 169.254.51.120
parameter  DES_IP    = {8'd169,8'd254,8'd51,8'd120};

//wire define
wire           crc_en  ; //CRC��ʼУ��ʹ��
wire           crc_clr ; //CRC���ݸ�λ�ź� 
wire   [7:0]   crc_d8  ; //�����У��8λ����
wire   [31:0]  crc_data; //CRCУ������
wire   [31:0]  crc_next; //CRC�´�У���������

//*****************************************************
//**                    main code
//*****************************************************

assign  crc_d8 = gmii_txd;

//ARP����ģ��    
arp_rx 
   #(
    .BOARD_MAC       (BOARD_MAC),         //��������
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

//ARP����ģ��
arp_tx
   #(
    .BOARD_MAC       (BOARD_MAC),         //��������
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

//��̫������CRCУ��ģ��
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
