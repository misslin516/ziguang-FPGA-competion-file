//created date: 2024/04/19
//version     : v1.0
//revised date:2024/06/26
//revised details:on the basis,intergate with LMS model,you can choose class num
`timescale 1ns/1ps
`define DDR3
`define PC



module audio_top_test
(
    //system io
    input              sys_clk              ,
    input              key                  ,    //按键复位    一直按才复位
    input              key1                 ,    //控制是否使用FIR   按一下
    input              key2                 ,    //控制向PC串口发送数据，并启动LMS 按一下
    input              key3                 ,    //控制PMOD端输出
    //audio io          
//ES7243E  ADC  in          
    output             es7243_scl           ,/*synthesis PAP_MARK_DEBUG="1"*///CCLK
    inout              es7243_sda           ,/*synthesis PAP_MARK_DEBUG="1"*///CDATA
    output             es0_mclk             ,/*synthesis PAP_MARK_DEBUG="1"*///MCLK  clk_12M
    input              es0_sdin             ,/*synthesis PAP_MARK_DEBUG="1"*///SDOUT i2s数据输入             i2s_sdin
    input              es0_dsclk            ,/*synthesis PAP_MARK_DEBUG="1"*///SCLK  i2s数据时钟             i2s_sck   
    input              es0_alrck            ,/*synthesis PAP_MARK_DEBUG="1"*///LRCK  i2s数据左右信道帧时钟     i2s_ws
//ES8156  DAC   out                         
    output             es8156_scl           ,/*synthesis PAP_MARK_DEBUG="1"*///CCLK
    inout              es8156_sda           ,/*synthesis PAP_MARK_DEBUG="1"*///CDATA 
    output             es1_mclk             ,/*synthesis PAP_MARK_DEBUG="1"*///MCLK  clk_12M
    input              es1_sdin             ,/*synthesis PAP_MARK_DEBUG="1"*///SDOUT 回放信号反馈？
    output             es1_sdout            ,/*synthesis PAP_MARK_DEBUG="1"*///SDIN  DAC i2s数据输出          i2s_sdout
    input              es1_dsclk            ,/*synthesis PAP_MARK_DEBUG="1"*///SCLK  i2s数据位时钟            i2s_sck
    input              es1_dlrc             ,/*synthesis PAP_MARK_DEBUG="1"*///LRCK  i2s数据左右信道帧时钟      i2s_ws
//     test         
    input              lin_test             ,//麦克风插入检测
    input              lout_test            ,//扬声器检测
    output             lin_led              ,
    output             lout_led             ,   
                
    output             adc_dac_int          ,
    
    //udp0 io                                        
    output wire        eth_rst_n_0          ,
    input  wire        eth_rgmii_rxc_0      ,
    input  wire        eth_rgmii_rx_ctl_0   ,
    input  wire [3:0]  eth_rgmii_rxd_0      ,
                                            
    output wire        eth_rgmii_txc_0      ,
    output wire        eth_rgmii_tx_ctl_0   ,
    output wire [3:0]  eth_rgmii_txd_0      ,
    
    //hdmi io
    output            iic_tx_scl            ,
    inout             iic_tx_sda            ,
    // output            led_int               ,       //通过LED检测配置是否完成
                                           
    output            vs_out                ,
    output            hs_out                ,
    output            de_out                ,
    output     [7:0]  r_out                 ,
    output     [7:0]  g_out                 ,
    output     [7:0]  b_out                 ,
    
    output            pix_clk               ,
    output            rstn_out              ,
    
   //udp1 io                                        
    output wire        eth_rst_n_1          ,
    input  wire        eth_rgmii_rxc_1      ,
    input  wire        eth_rgmii_rx_ctl_1   ,
    input  wire [3:0]  eth_rgmii_rxd_1      ,
                                            
    output wire        eth_rgmii_txc_1      ,
    output wire        eth_rgmii_tx_ctl_1   ,
    output wire [3:0]  eth_rgmii_txd_1      ,
    output      [2:0]      led              ,

//uart
    input              uart_rx              ,
    output             uart_tx              

//DDR
  
    
    


);



/********************************global para***************************************/
//网口0
parameter     BOARD_MAC_UDP0 =     48'h00_11_22_33_44_55    ;    //开发板MAC地址
parameter     BOARD_IP_UDP0  = {8'd192,8'd168,8'd1,8'd10}   ;    //开发板IP地址      
//PC or other FPGA                                           
parameter     DES_MAC_UDP0   = 48'h84_A9_38_BF_C9_A0        ;    //PC   MAC地址
parameter     DES_IP_UDP0    = {8'd192,8'd168,8'd1,8'd102}   ;    //目的 IP  地址

//网口1
parameter     BOARD_MAC_UDP1 =     48'ha0_b1_c2_d3_e1_e1    ;    //开发板MAC地址
parameter     BOARD_IP_UDP1  = {8'd192,8'd168,8'd1,8'd11}   ;    //开发板IP地址   
//PC or other FPGA                                               
parameter     DES_MAC_UDP1   = 48'h84_A9_38_BF_C9_A0        ;    //PC   MAC地址
parameter     DES_IP_UDP1    = {8'd192,8'd168,8'd1,8'd102}   ;    //目的 IP  地址

/********************************local para***************************************/

/********************************wire***************************************/
//audio para
wire             [15:0] adc_data            ;
wire             [15:0] dac_data            ;
wire             [15:0] dac_data0           ;
wire             [15:0] dac_data1           ;
wire                    es7243_init         ;
wire                    es8156_init         ;
wire                    data_valid_voice    ;
wire                    rx_l_vld            ;
wire                    rx_r_vld            ;
wire                    rx_r_vld_l          ;
wire                    rx_l_vld_l          ;
wire             [15:0] ldata               ;
wire             [15:0] rdata               ;
wire                    audio_clk           ;
//fir para
wire             [31:0] fir_out             ;


// fft para
wire                    data_sop            ;
wire                    data_eop            ;
wire                    data_valid          ;
wire             [31:0] data_modulus        ;/*synthesis PAP_MARK_DEBUG="1"*/   //防止被优化
 
 //udp0 para
wire                    rec_en0             ;
wire                [31:0] rec_data0        ;
wire                [15:0] rec_byte_num0    ;
wire                    rgmii_clk0          ;

 //udp1 para
wire                    rec_en1             ;
wire                [31:0] rec_data1        ;
wire                [15:0] rec_byte_num1    ;
wire                    rgmii_clk1          ;



//key
wire                    key_en              ; 
wire                    key_flag1           ; 
wire                    key_flag2           ; 
wire                    key_flag3           ; 
//lms para
wire                [15:0] y_lms            ;
wire                flag_audio              ;
wire                flag_udp                ;
 
 

/********************************reg***************************************/ 

//uart para
reg                    cnt_keyen0            ; 
reg                    cnt_keyen1            ; 
reg                    cnt_keyen2            ; 
 
//********************************assign************************************/ 

assign dac_data0 = key1? fir_out[31:16]:adc_data;

assign key_en = flag_audio;


//通过串口进行控制
assign dac_data1 = key2?adc_data:y_lms;  //key 按下为低电平


//for test
assign led[0] = cnt_keyen0;       //FIR输出标志信号
assign led[1] = cnt_keyen1;       //lms启动标志
assign led[2] = cnt_keyen2;       //1----输出LMS处理后的信号    0----FIR信号


//因为插入音频线，会一直有信号输出，所以可以不用延迟以下有效信号
assign rx_r_vld_l = rx_r_vld;
assign rx_l_vld_l = rx_l_vld;


assign dac_data = key3 ? dac_data1:dac_data0;

assign rd_en = 1'b1;
//********************************model inst************************************/ 
//inst key_filter
key_filter
#(
    .CNT_MAX    (20'd999_999) 
)
key_filter_inst0
(
    .sys_clk    (audio_clk    )  , 
    .sys_rst_n  (adc_dac_int)  , 
    .key_in     (key1       )  , 
   
    .key_flag   (key_flag1  )     
);

key_filter
#(
    .CNT_MAX    (20'd999_999) 
)
key_filter_inst1
(
    .sys_clk    (audio_clk    )  , 
    .sys_rst_n  (adc_dac_int)  , 
    .key_in     (key2       )  , 
   
    .key_flag   (key_flag2  )     
);

key_filter
#(
    .CNT_MAX    (20'd999_999) 
)
key_filter_inst2
(
    .sys_clk    (audio_clk    )  , 
    .sys_rst_n  (adc_dac_int)  , 
    .key_in     (key3       )  , 
   
    .key_flag   (key_flag3  )     
);







always@(posedge audio_clk or negedge adc_dac_int)
    if(!adc_dac_int)
        cnt_keyen0 <= 1'b0;
    else if(key_flag1)
        cnt_keyen0 <= ~cnt_keyen0;
    else
        cnt_keyen0 <= cnt_keyen0;
        
always@(posedge audio_clk or negedge adc_dac_int)
    if(!adc_dac_int)
        cnt_keyen1 <= 1'b0;
    else if(key_flag2)
        cnt_keyen1 <= ~cnt_keyen1;
    else
        cnt_keyen1 <= cnt_keyen1;        
        
always@(posedge audio_clk or negedge adc_dac_int)
    if(!adc_dac_int)
        cnt_keyen2 <= 1'b0;
    else if(key_flag3)
        cnt_keyen2 <= ~cnt_keyen2;
    else
        cnt_keyen2 <= cnt_keyen2;


        
        
      
//inst pmod
voice_loop voice_loop_test_inst
(
  .sys_clk     (sys_clk    )   ,
  .key         (key        )   ,
//ES7243E  ADC  in
  .es7243_scl  (es7243_scl )   ,
  .es7243_sda  (es7243_sda )   ,
  .es0_mclk    (es0_mclk   )   ,
  .es0_sdin    (es0_sdin   )   ,
  .es0_dsclk   (es0_dsclk  )   ,
  .es0_alrck   (es0_alrck  )   ,
//ES8156  DAC   out       
  .es8156_scl  (es8156_scl )   ,
  .es8156_sda  (es8156_sda )   ,
  .es1_mclk    (es1_mclk   )   ,
  .es1_sdin    (es1_sdin   )   ,
  .es1_sdout   (es1_sdout  )   ,
  .es1_dsclk   (es1_dsclk  )   ,
  .es1_dlrc    (es1_dlrc   )   ,
// test 
  .lin_test    (lin_test   )   ,
  .lout_test   (lout_test  )   ,
  .lin_led     (lin_led    )   ,
  .lout_led    (lout_led   )   ,   

  .adc_dac_int (adc_dac_int)   ,
    
    
   // data in and out
   .adc_data   (adc_data    ) ,
   .dac_data   (dac_data    ) ,
   .rx_l_vld   ( rx_l_vld   ) ,
   .rx_r_vld   ( rx_r_vld   ) ,
   .rx_r_vld_l (  rx_r_vld_l) ,
   .rx_l_vld_l (  rx_l_vld_l) ,
   .data_valid ( data_valid_voice ) ,
   .es7243_init (es7243_init),   //rx_rst
   .es8156_init (es8156_init),               //tx_rst
   .clk_12M(audio_clk),
   .ldata(ldata),
   .rdata(rdata),
   .rx_done()
);


//inst fir
fir_guide   fir_guide_inst
( 
   .rstn    (adc_dac_int),
   .clk     (audio_clk  ),  //es0_mclk = es1_mclk
   .en      (data_valid_voice  ),
   .xin     (adc_data  ),
   .valid   (valid     ),
   .yout    (fir_out   )    //31   [31:11]
);



//inst fft_top
fft_top fft_top_inst
(
   .clk_50m       (sys_clk     ) ,
   .rst_n         (adc_dac_int    ) ,
 
   .audio_clk     (audio_clk    ) ,
   .audio_valid   (data_valid_voice       ) ,
   .audio_data    ({8'b0,dac_data}) ,
 
   .data_sop      (data_sop    ) ,
   .data_eop      (data_eop    ) ,
   .data_valid    (data_valid  ) ,
   .data_modulus  (data_modulus) ,
   .o_alm         (            )     //led5,6,7
);




//inst UDP0
udp_top1 
#(
   .BOARD_MAC(BOARD_MAC_UDP0),     //开发板MAC地址
   .BOARD_IP (BOARD_IP_UDP0 ),     //开发板IP地址
                
   .DES_MAC  ( DES_MAC_UDP0 ),     //PC   MAC地址
   .DES_IP   (DES_IP_UDP0   )      //目的 IP  地址
)
udp_top_inst0
(
    //audio io
    .audio_en           ( data_valid_voice  )  ,
    .audio_data         ( adc_data          )  ,
    .key                ( 1'b1              )  ,     //默认该UDP进行外传输                 
    //udp io                                  
    .eth_rst_n_0        ( eth_rst_n_0       )  ,
    .eth_rgmii_rxc_0    ( eth_rgmii_rxc_0   )  ,
    .eth_rgmii_rx_ctl_0 ( eth_rgmii_rx_ctl_0)  ,
    .eth_rgmii_rxd_0    ( eth_rgmii_rxd_0   )  ,
   
    .eth_rgmii_txc_0    ( eth_rgmii_txc_0   )  ,
    .eth_rgmii_tx_ctl_0 ( eth_rgmii_tx_ctl_0)  ,
    .eth_rgmii_txd_0    ( eth_rgmii_txd_0   )  ,
   
    //system clk       
    .clk_50m            ( sys_clk           )  ,
    .audio_clk          ( audio_clk         )  ,
    .rst_n              ( adc_dac_int       )  ,
    
    //test   io        
    .led                (                   )  ,
    .rec_en             (rec_en0            ) ,
    .rec_data           (rec_data0          ) ,
    .rec_byte_num       (rec_byte_num0      ) ,
    .rgmii_clk_0        ( rgmii_clk0        )
);




//1.此处将 data_modulus的数据保存在RAM中 用于频谱数据HDMI显示
//2.fft_data的位宽为32，在频谱显示上可以进行适当处理后，保证最大幅度不超过hdmi的场有效范围
//3.同时采用抽帧的方式，缓解刷新率过快
//inst HDMI
hdmi_test1 hdmi_test1_inst
(
    .sys_clk     (sys_clk   )  ,// input system clock 50MHz 
    .rst_n       (adc_dac_int)  ,
    .rstn_out    (rstn_out  )  ,
    .iic_tx_scl  (iic_tx_scl)  ,
    .iic_tx_sda  (iic_tx_sda)  ,
   
    .fft_data    (data_modulus)     , 
    .fft_sop     (data_sop   )     , 
    .fft_eop     (data_eop   )     , 
    .fft_valid   (data_valid )     , 
    
    .audio_data  ( dac_data)    ,
    .audio_en    (  data_valid_voice       )   ,
    .audio_clk    (audio_clk)    ,
    
    .pix_clk     (pix_clk   )  ,
    .led_int     (          )  ,

    .vs_out      (vs_out    )  , 
    .hs_out      (hs_out    )  , 
    .de_out      (de_out    )  ,
    .r_out       (r_out     )  , 
    .g_out       (g_out     )  , 
    .b_out       (b_out     )  
);


//inst UDP1
udp_top1
#(
   .BOARD_MAC (BOARD_MAC_UDP1),     //开发板MAC地址
   .BOARD_IP  (BOARD_IP_UDP1 ),     //开发板IP地址

   .DES_MAC   ( DES_MAC_UDP1 ),     //PC   MAC地址
   .DES_IP    (DES_IP_UDP1   )      //目的 IP  地址
)
udp_top_inst1
(
    //audio io
    .audio_en           ( data_valid_voice  )  ,
    .audio_data         ( adc_data          )  ,
    .key                ( ~key_en           )  ,                                
    //udp io                                  
    .eth_rst_n_0        ( eth_rst_n_1       )  ,
    .eth_rgmii_rxc_0    ( eth_rgmii_rxc_1   )  ,
    .eth_rgmii_rx_ctl_0 ( eth_rgmii_rx_ctl_1)  ,
    .eth_rgmii_rxd_0    ( eth_rgmii_rxd_1   )  ,
   
    .eth_rgmii_txc_0    ( eth_rgmii_txc_1   )  ,
    .eth_rgmii_tx_ctl_0 ( eth_rgmii_tx_ctl_1)  ,
    .eth_rgmii_txd_0    ( eth_rgmii_txd_1   )  ,
   
    //system clk       
    .clk_50m            ( sys_clk           )  ,
    .audio_clk          ( audio_clk         )  ,
    .rst_n              ( adc_dac_int       )  ,
    
    //test   io        
    .led                (                   )  ,
    .rec_en             (rec_en1            ) ,
    .rec_data           (rec_data1          ) ,
    .rec_byte_num       (rec_byte_num1      ) ,
    .rgmii_clk_0        ( rgmii_clk1        )
);





//inst uart                    ------当PC接收到串口发送的udp.start.trans时，会自动发送音频数据文件
uart_top uart_top_inst
(

   .clk      (sys_clk ) ,
   .uart_rx  (uart_rx ) ,
   .key      (key_en  ) ,
   .uart_tx  (uart_tx )
);


//inst lms
lms_top
#(
    .Step_size     (16'h000f) ,   //0.0073 *(2**11)  = 15
    .filter_class  (10       )     //class = 8,you can change it 
)
lms_top_inst
(
    .sys_clk   (sys_clk                     ) ,
    .rst_n     (adc_dac_int &~key2     ) ,
    
    .audio_clk (audio_clk                   ) ,
    .data_valid(data_valid_voice            ) ,
    .adc_data  (adc_data                    ) ,
                
    .rgmii_clk (audio_clk                   ) ,
    .rec_en    (rd_en                       ) ,
    .rec_data  (rd_data                     ) , 
            
    .y_lms     (y_lms                       ) ,
    .flag_audio(flag_audio                  ) ,
    .flag_udp  (flag_udp                    )
);

  
  
//ins PCIE
  
  

  




endmodule