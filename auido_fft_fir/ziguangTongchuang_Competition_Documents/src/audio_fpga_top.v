//created date: 2024/04/19
//version    :v1.0
//revised date:2024/05/19


module audio_fpga_top
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
    output             led                  ,
    
    //hdmi io
    output            iic_tx_scl            ,
    inout             iic_tx_sda            ,
    output            led_int               ,       //通过LED检测配置是否完成
                                           
    output            vs_out                ,
    output            hs_out                ,
    output            de_out                ,
    output     [7:0]  r_out                 ,
    output     [7:0]  g_out                 ,
    output     [7:0]  b_out                 ,
    
    output            pix_clk               ,
    output            rstn_out              
    

);

//audio para
wire [15:0] adc_data;
wire [15:0] dac_data;
wire es7243_init;
wire es8156_init;
wire data_valid_voice;
wire rx_l_vld;
wire rx_r_vld;
wire                    rx_r_vld_l          ;
wire                    rx_l_vld_l          ;
wire [15:0] ldata;
wire [15:0] rdata;
wire audio_clk;

//fir para
wire [31:0] fir_out;
assign dac_data = key1? adc_data:fir_out[31:16];

// fft para
wire data_sop    ;
wire data_eop    ;
wire data_valid  ;
wire [31:0] data_modulus;/*synthesis PAP_MARK_DEBUG="1"*/   //防止被优化
 
 //udp para
wire rec_en;
wire [31:0] rec_data;
wire [15:0] rec_byte_num;
wire rgmii_clk;
 
assign rx_r_vld_l = rx_r_vld;
assign rx_l_vld_l = rx_l_vld;

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
   .o_alm  ()     //led5,6,7
);




//inst UDP
udp_top1 udp_top_inst
(
    //audio io
    .audio_en           ( data_valid_voice  )  ,
    .audio_data         ( adc_data          )  ,
                          
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
    .led                (    led            )  ,
    .rec_en             (rec_en             ) ,
    .rec_data           (rec_data           ) ,
    .rec_byte_num       (rec_byte_num       ) ,
    .rgmii_clk_0          ( rgmii_clk         )
);


//此处将 data_modulus的数据保存在RAM中 用于频谱数据HDMI显示
//note: fft_data的位宽为32，在频谱显示上可以进行适当处理后，保证最大幅度不超过hdmi的场有效范围
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
    .led_int     (led_int   )  ,

    .vs_out      (vs_out    )  , 
    .hs_out      (hs_out    )  , 
    .de_out      (de_out    )  ,
    .r_out       (r_out     )  , 
    .g_out       (g_out     )  , 
    .b_out       (b_out     )  

);



endmodule