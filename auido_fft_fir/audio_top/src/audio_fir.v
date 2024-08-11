//****************************************************************************************//
// Created date:        2024/05/08
// version     ：       v2.0    
//****************************************************************************************//


`timescale 1ns/1ns
module audio_fir
(
    input       wire         sys_clk         ,
    
    input       wire            key          ,
    input       wire            key1         ,
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
                                          
    output      wire         adc_dac_int     
                                         
  
);
// data in and out   and valid  
wire  [15:0]  adc_data       ;
wire  [15:0]  dac_data       ;
wire             rx_l_vld    ;
wire             rx_r_vld    ;
wire             data_valid_voice  ;
wire          es7243_init;   //rx
wire          es8156_init;  //tx
    
 // fir para 
wire          valid;
wire [31:0] fir_out;
wire clk_12M;
wire [15:0] ldata;
wire [15:0] rdata;
 
assign dac_data = (key1 == 1) ? adc_data:fir_out[31:16]; //此处将FIR数据/2**4
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
   .data_valid (data_valid_voice  ) ,
   .es7243_init (es7243_init),
   .es8156_init (es8156_init),
   .clk_12M (clk_12M),
   .ldata   (ldata  ),
   .rdata   (rdata  ) 
);


//inst fir 并行滤波器设计 -- 简单FIR滤波器除噪（低通范围 stop :3500   正常人声音 300-3400）
fir_guide   fir_guide_inst
( 
   .rstn    (adc_dac_int),
   .clk     (clk_12M  ),  //es0_mclk = es1_mclk
   .en      (data_valid_voice  ),
   .xin     (adc_data  ),
   .valid   (valid     ),
   .yout    (fir_out   )    //31   [31:11]
);

endmodule