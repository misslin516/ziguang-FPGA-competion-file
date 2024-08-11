//****************************************************************************************//
// Created by:          NJUPT
// Created date:        2024/04/02
// version     ：       v1.0    
// note        :整体模块未通过在线debug调试（没板子） +  时序没有约束（主要是针对于各个时钟的约束，路径约束暂不考虑---最大时钟148MHz）
//****************************************************************************************//


`timescale 1ns/1ns


module task1
(
    input       wire         sys_clk         ,
    input       wire         sys_rstn        ,
    
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
    output     [7:0]  b_out                  
    
    
  
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
   .rstn    (es7243_init),
   .clk     (es0_mclk  ),  //es0_mclk = es1_mclk
   .en      (data_valid_voice  ),
   .xin     (adc_data  ),
   .valid   (valid     ),
   .yout    (fir_out   )    //31   [31:11]
);

// fft para
wire data_sop    ;
wire data_eop    ;
wire data_valid  ;
wire [31:0] data_modulus;

//note: 各个端口已测试，加入fft后的总端口未测试，时序按照熊桑发的fft_demo时序文件编写。
fft_top fft_top_inst
(
   .clk_50m       (clk_50m     ) ,
   .rst_n         (sys_rstn    ) ,
 
   .audio_clk     (es0_mclk    ) ,
   .audio_valid   (valid       ) ,
   .audio_data    ({8'b0,dac_data}) ,
 
   .data_sop      (data_sop    ) ,
   .data_eop      (data_eop    ) ,
   .data_valid    (data_valid  ) ,
   .data_modulus  (data_modulus)   
);
//此处将 data_modulus的数据保存在RAM中 用于频谱数据HDMI显示
//note: fft_data的位宽为32，在频谱显示上可以进行适当处理后，保证最大幅度不超过hdmi的场有效范围


wire pix_clk;
wire rstn_out;

hdmi_top hdmi_top_inst
(
    .sys_clk      (sys_clk     )   ,// input system clock 50MHz    
    .rst_n        (sys_rstn    )   ,
    .rstn_out     (rstn_out    )   ,
    .iic_tx_scl   (iic_tx_scl  )   ,
    .iic_tx_sda   (iic_tx_sda  )   ,
   
    .fft_data     (data_modulus)   , 
    .fft_eop      (data_eop    )   , 
    .fft_valid    (data_valid  )   , 
    
    .led_int      (led_int     )   ,
     
    .pix_clk      (pix_clk     )   ,//pixclk        采用内部时钟提供，不分配引脚                     
    .vs_out       (vs_out      )   , 
    .hs_out       (hs_out      )   , 
    .de_out       (de_out      )   ,
    .r_out        (r_out       )   , 
    .g_out        (g_out       )   , 
    .b_out        (b_out       )

);
endmodule

