//created date: 2024/04/19
//version    :v1.0
//revised date:2024/05/19


module audio_lms_test
(
    //system io
    input              sys_clk              ,
    input              key                  ,
    input              key1                 ,
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
    
    //udp io                                        
    output wire        eth_rst_n_0          ,
    input  wire        eth_rgmii_rxc_0      ,
    input  wire        eth_rgmii_rx_ctl_0   ,
    input  wire [3:0]  eth_rgmii_rxd_0      ,
                                            
    output wire        eth_rgmii_txc_0      ,
    output wire        eth_rgmii_tx_ctl_0   ,
    output wire [3:0]  eth_rgmii_txd_0      ,
    output      [3:0]      led              ,

//uart
    input              uart_rx              ,
    output             uart_tx              

);




//audio para
wire [15:0] adc_data;
wire [15:0] dac_data;
wire es7243_init;
wire es8156_init;
wire data_valid_voice;
wire rx_l_vld;
wire rx_r_vld;
wire rx_r_vld_l;
wire rx_l_vld_l;
wire [15:0] ldata;
wire [15:0] rdata;
wire audio_clk;

 //udp para
wire rec_en;
wire [31:0] rec_data;
wire [15:0] rec_byte_num;
wire rgmii_clk;
 
//uart para
reg  cnt_keyen;
wire  key_en  ; 
 
//lms para
wire [15:0] y_lms;
wire flag_audio;
wire flag_udp;

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



//inst UDP
udp_top1 udp_top_inst
(
    //audio io
    .audio_en           ( data_valid_voice  )  ,
    .audio_data         ( adc_data          )  ,
    .key                ( ~key_en           )  ,                                
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
    .led                (    led[0]         )  ,
    .rec_en             (rec_en             ) ,
    .rec_data           (rec_data           ) ,
    .rec_byte_num       (rec_byte_num       ) ,
    .rgmii_clk_0        ( rgmii_clk         )
);

//inst key_filter
key_filter
#(
    .CNT_MAX    (20'd999_999) 
)
key_filter_inst
(
    .sys_clk    (sys_clk    )  , 
    .sys_rst_n  (adc_dac_int)  , 
    .key_in     (key1       )  , 
   
    .key_flag   (key_flag   )     
);


always@(posedge sys_clk or negedge adc_dac_int)
    if(!adc_dac_int)
        cnt_keyen <= 1'b0;
    else if(key_flag)
        cnt_keyen <= ~cnt_keyen;
    else
        cnt_keyen <= cnt_keyen;
        
assign key_en = flag_audio;
assign led[1] = flag_audio;
assign led[2] = cnt_keyen ;

//通过串口进行控制
assign dac_data = ~key_en?adc_data:y_lms;  //key 按下为低电平

//inst uart
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
    .filter_class  (8       )
)
lms_top_inst
(
    .sys_clk   (sys_clk                     ) ,
    .rst_n     (adc_dac_int &cnt_keyen      ) ,
    
    .audio_clk (audio_clk                   ) ,
    .data_valid(data_valid_voice            ) ,
    .adc_data  (adc_data                    ) ,
                
    .rgmii_clk (rgmii_clk                   ) ,
    .rec_en    (rec_en                      ) ,
    .rec_data  (rec_data                    ) , 
            
    .y_lms     (y_lms                       ) ,
    .flag_audio(flag_audio                  ) ,
    .flag_udp  (flag_udp                    )
);
assign led[3] = flag_udp;


//因为插入音频线，会一直有信号输出，所以可以不用延迟以下有效信号
assign rx_r_vld_l =rx_r_vld;
assign rx_l_vld_l =rx_l_vld;


endmodule