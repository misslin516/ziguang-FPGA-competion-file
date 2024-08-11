//created by : njupt
//created data: 2024/04/19
//version    :v1.0


module udp_audio_test
(
    //system io
    input              sys_clk         ,
    input              key             ,
       
    //audio io 
//ES7243E  ADC  in 
    output             es7243_scl      ,/*synthesis PAP_MARK_DEBUG="1"*///CCLK
    inout              es7243_sda      ,/*synthesis PAP_MARK_DEBUG="1"*///CDATA
    output             es0_mclk        ,/*synthesis PAP_MARK_DEBUG="1"*///MCLK  clk_12M
    input              es0_sdin        ,/*synthesis PAP_MARK_DEBUG="1"*///SDOUT i2s数据输入             i2s_sdin
    input              es0_dsclk       ,/*synthesis PAP_MARK_DEBUG="1"*///SCLK  i2s数据时钟             i2s_sck   
    input              es0_alrck       ,/*synthesis PAP_MARK_DEBUG="1"*///LRCK  i2s数据左右信道帧时钟     i2s_ws
//ES8156  DAC   out                    
    output             es8156_scl      ,/*synthesis PAP_MARK_DEBUG="1"*///CCLK
    inout              es8156_sda      ,/*synthesis PAP_MARK_DEBUG="1"*///CDATA 
    output             es1_mclk        ,/*synthesis PAP_MARK_DEBUG="1"*///MCLK  clk_12M
    input              es1_sdin        ,/*synthesis PAP_MARK_DEBUG="1"*///SDOUT 回放信号反馈？
    output             es1_sdout       ,/*synthesis PAP_MARK_DEBUG="1"*///SDIN  DAC i2s数据输出          i2s_sdout
    input              es1_dsclk       ,/*synthesis PAP_MARK_DEBUG="1"*///SCLK  i2s数据位时钟            i2s_sck
    input              es1_dlrc        ,/*synthesis PAP_MARK_DEBUG="1"*///LRCK  i2s数据左右信道帧时钟      i2s_ws
//     
    input              lin_test        ,//麦克风插入检测
    input              lout_test       ,//扬声器检测
    output             lin_led         ,
    output             lout_led        ,   
       
    output             adc_dac_int     ,
    
    //udp io
    input              eth_rxc         ,   //RGMII接收数据时钟
    input              eth_rx_ctl      ,   //RGMII输入数据有效信号
    input       [3:0]  eth_rxd         ,   //RGMII输入数据
    output             eth_txc         ,   //RGMII发送数据时钟    
    output             eth_tx_ctl      ,   //RGMII输出数据有效信号
    output      [3:0]  eth_txd         ,   //RGMII输出数据          
    output             eth_rst_n           //以太网芯片复位信号，低电平有效    
    
 
);

//audio para
wire [15:0] adc_data;
wire [15:0] dac_data;

wire data_valid_voice;

assign dac_data = adc_data;

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
   .rx_l_vld   (    ) ,
   .rx_r_vld   (    ) ,
   .data_valid (data_valid_voice  ) ,
   .es7243_init (),
   .es8156_init ()
);

 audio_udp_top_revised audio_udp_top_revised_inst
(
   .sys_clk    (sys_clk   ),  
   .sys_rst_n  (adc_dac_int ),  
  
   .eth_rxc    (eth_rxc   ),  
   .eth_rx_ctl (eth_rx_ctl),  
   .eth_rxd    (eth_rxd   ),  
   .eth_txc    (eth_txc   ),  
   .eth_tx_ctl (eth_tx_ctl),  
   .eth_txd    (eth_txd   ),  
   .eth_rst_n  (eth_rst_n ),     
   
   .audio_data (adc_data),
   .audio_en   (data_valid_voice  ),
   .audio_clk  (es0_dsclk )
);





endmodule

