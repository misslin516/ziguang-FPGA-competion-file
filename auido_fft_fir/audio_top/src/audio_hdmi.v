//****************************************************************************************//
// Created date:        2024/05/08
// version     ：       v2.0    
//****************************************************************************************//


`timescale 1ns/1ns


module audio_hdmi
(
    input       wire         sys_clk         ,
    
    input       wire            key          ,
// S7243E  ADC  in                          
    output      wire         es7243_scl      ,
    inout       wire         es7243_sda      ,
    output      wire         es0_mclk        ,
    input       wire         es0_sdin        ,
    input       wire         es0_dsclk       ,
    input       wire         es0_alrck       ,
//S8156  DAC   out                         
    output      wire         es8156_scl      ,
    inout       wire         es8156_sda      ,
    output      wire         es1_mclk        ,
    input       wire         es1_sdin        ,
    output      wire         es1_sdout       ,
    input       wire         es1_dsclk       ,
    input       wire         es1_dlrc        ,
                                            
    input       wire         lin_test        ,
    input       wire         lout_test       ,
    output      wire         lin_led         ,
    output      wire         lout_led        ,
                                          
    output      wire         adc_dac_int     ,
                                           
//hdmi interface                             
    output            iic_tx_scl             ,
    inout             iic_tx_sda             ,
    output            led_int                ,       //通过LED检测配置是否完成
                                           
    output            vs_out                 ,
    output            hs_out                 ,
    output            de_out                 ,
    output     [7:0]  r_out                  ,
    output     [7:0]  g_out                  ,
    output     [7:0]  b_out                  ,
    
    output            pix_clk                ,
    output            rstn_out               ,    
    
    //fft_test    
    output     [2:0]   o_alm          //c5,a5,f7
    
    
  
);
// data in and out   and valid  
wire  [15:0]  adc_data       ;
wire  [15:0]  dac_data       ;
wire             rx_l_vld    ;
wire             rx_r_vld    ;
wire             data_valid_voice  ;
wire          es7243_init;   //rx
wire          es8156_init;  //tx
wire           clk_12M;
 
 
 
assign dac_data = adc_data;
//inst audio chip
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
   .rx_l_vld   (rx_l_vld    ) ,
   .rx_r_vld   (rx_r_vld    ) ,
   .data_valid ( data_valid_voice) ,
   .es7243_init (es7243_init),
   .es8156_init (es8156_init),
   .clk_12M (clk_12M),
   .ldata   (ldata  ),
   .rdata   (rdata  ),
   .rx_done ()
);


// fft para
wire data_sop    ;
wire data_eop    ;
wire data_valid  ;
wire [31:0] data_modulus;/*synthesis PAP_MARK_DEBUG="1"*/   //防止被优化
 
fft_top fft_top_inst
(
   .clk_50m       (sys_clk     ) ,
   .rst_n         (adc_dac_int    ) ,
 
   .audio_clk     (clk_12M    ) ,
   .audio_valid   (data_valid_voice       ) ,
   .audio_data    ({8'b0,adc_data}) ,
 
   .data_sop      (data_sop    ) ,
   .data_eop      (data_eop    ) ,
   .data_valid    (data_valid  ) ,
   .data_modulus  (data_modulus) ,
   .o_alm  (o_alm)     //led5,6,7
);




//此处将 data_modulus的数据保存在RAM中 用于频谱数据HDMI显示
//note: fft_data的位宽为32，在频谱显示上可以进行适当处理后，保证最大幅度不超过hdmi的场有效范围

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
    
    .audio_data  ( adc_data)    ,
    .audio_en    (  data_valid_voice       )   ,
    
    .pix_clk     (pix_clk   )  ,
    .led_int     (led_int   )  ,

    .vs_out      (vs_out    )  , 
    .hs_out      (hs_out    )  , 
    .de_out      (de_out    )  ,
    .r_out       (r_out     )  , 
    .g_out       (g_out     )  , 
    .b_out       (b_out     )  

);


endmodule