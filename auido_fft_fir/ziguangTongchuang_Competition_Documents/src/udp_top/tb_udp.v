

`timescale  1ns/1ns                     //�������ʱ�䵥λ1ns�ͷ���ʱ�侫��Ϊ1ns

module  tb_udp;

//parameter  define
parameter  T = 8;                       //ʱ������Ϊ8ns
parameter  OP_CYCLE = 100;              //��������(�������ڼ��)

//������MAC��ַ 00-11-22-33-44-55
parameter  BOARD_MAC = 48'h00_11_22_33_44_55;     
//������IP��ַ 192.168.1.10     
parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd10};
//Ŀ��MAC��ַ ff_ff_ff_ff_ff_ff
parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;
//Ŀ��IP��ַ 192.168.1.102
parameter  DES_IP    = {8'd192,8'd168,8'd1,8'd10};

//reg define
reg           gmii_clk;    //ʱ���ź�
reg           sys_rst_n;   //��λ�ź�

reg           tx_start_en;
reg   [15:0]  tx_data    ;
reg   [15:0]  tx_byte_num;
reg   [47:0]  des_mac    ;
reg   [31:0]  des_ip     ;

reg   [3:0]   flow_cnt   ;
reg   [13:0]  delay_cnt  ;

wire          gmii_rx_clk; //GMII����ʱ��
wire          gmii_rx_dv ; //GMII����������Ч�ź�
wire  [7:0]   gmii_rxd   ; //GMII��������
wire          gmii_tx_clk; //GMII����ʱ��
wire          gmii_tx_en ; //GMII��������ʹ���ź�
wire  [7:0]   gmii_txd   ; //GMII��������
              
wire          tx_done    ; 
wire          tx_req     ;

//*****************************************************
//**                    main code
//*****************************************************

assign gmii_rx_clk = gmii_clk   ;
assign gmii_tx_clk = gmii_clk   ;
assign gmii_rx_dv  = gmii_tx_en ;
assign gmii_rxd    = gmii_txd   ;

//�������źų�ʼֵ
initial begin
    gmii_clk           = 1'b0;
    sys_rst_n          = 1'b0;     //��λ
    #(T+1)  sys_rst_n  = 1'b1;     //�ڵ�(T+1)ns��ʱ��λ�ź��ź�����
end

//125Mhz��ʱ�ӣ�������Ϊ1/125Mhz=8ns,����ÿ4ns����ƽȡ��һ��
always #(T/2) gmii_clk = ~gmii_clk;

always @(posedge gmii_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        tx_start_en <= 1'b0;
        tx_data <= 16'h00;
        tx_byte_num <= 1'b0;
        des_mac <= 1'b0;
        des_ip <= 1'b0;
        delay_cnt <= 1'b0;
        flow_cnt <= 1'b0;
    end
    else begin
        case(flow_cnt)
            'd0 : flow_cnt <= flow_cnt + 1'b1;
            'd1 : begin
                tx_start_en <= 1'b1;  //���߿�ʼ����ʹ���ź�
                tx_byte_num <= 16'd10;//���÷��͵��ֽ���
                flow_cnt <= flow_cnt + 1'b1;
            end
            'd2 : begin 
                tx_start_en <= 1'b0;
                flow_cnt <= flow_cnt + 1'b1;
            end    
            'd3 : begin
                if(tx_req)
                    tx_data <= tx_data + 16'h1111;
                if(tx_done) begin
                    flow_cnt <= flow_cnt + 1'b1;
                    tx_data <= 16'h00;
                end    
            end
            'd4 : begin
                delay_cnt <= delay_cnt + 1'b1;
                if(delay_cnt == OP_CYCLE - 1'b1)
                    flow_cnt <= flow_cnt + 1'b1;
            end
            'd5 : begin
                tx_start_en <= 1'b1;  //���߿�ʼ����ʹ���ź�
                tx_byte_num <= 16'd30;//���÷��͵��ֽ���
                flow_cnt <= flow_cnt + 1'b1;               
            end
            'd6 : begin 
                tx_start_en <= 1'b0;
                flow_cnt <= flow_cnt + 1'b1;
            end 
            'd7 : begin
                if(tx_req)
                    tx_data <= tx_data + 16'h1111;
                if(tx_done) begin
                    flow_cnt <= flow_cnt + 1'b1;
                    tx_data <= 16'h00;
                end  
            end
            default:;
        endcase    
    end
end

//����UDPģ��
udp_top                                             
   #(
    .BOARD_MAC     (BOARD_MAC),      //��������
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   )
    )
   u_udp(
    .rst_n         (sys_rst_n   ),  
    
    .gmii_rx_clk   (gmii_rx_clk ),           
    .gmii_rx_dv    (gmii_rx_dv  ),         
    .gmii_rxd      (gmii_rxd    ),                   
    .gmii_tx_clk   (gmii_tx_clk ), 
    .gmii_tx_en    (gmii_tx_en),         
    .gmii_txd      (gmii_txd),  

    .rec_pkt_done  (),    
    .rec_en        (),     
    .rec_data      (),         
    .rec_byte_num  (),      
    .tx_start_en   (tx_start_en),        
    .tx_data       ({16'b0,tx_data}    ),         
    .tx_byte_num   (tx_byte_num),  
    .des_mac       (des_mac    ),
    .des_ip        (des_ip     ), 
    .tx_done       (tx_done    ),        
    .tx_req        (tx_req)           
    );

endmodule