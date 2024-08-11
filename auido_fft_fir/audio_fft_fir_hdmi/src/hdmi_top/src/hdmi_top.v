`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//created by :NJUPT
//created data:2024/04/09
//////////////////////////////////////////////////////////////////////////////////

module hdmi_top
(
    input wire        sys_clk         ,// input system clock 50MHz    
    input             rst_n           ,
    output            rstn_out        ,
    output            iic_tx_scl      ,
    inout             iic_tx_sda      ,
 
    //fft 
    input       [31:0]fft_data         , 
    input             fft_eop          , 
    input             fft_valid        , 
    
    
    output            led_int          ,
//hdmi_out 
    output            pix_clk          ,//pixclk                           
    output            vs_out        , 
    output            hs_out        , 
    output            de_out        ,
    output     [7:0]  r_out         , 
    output     [7:0]  g_out         , 
    output     [7:0]  b_out         

);

wire data_req;
wire fft_point_done;
wire [7:0] fft_point_cnt;
wire [31:0] ram_data_out;



rw_ram_ctrl rw_ram_ctrl_inst
(
    .clk                (sys_clk       )  ,
    .lcd_clk            (pix_clk       )  ,
    .rst_n              (rst_n         )  ,
    //FFT输入数据       
    .fft_data           (fft_data      )  ,        //FFT频谱数据
    .fft_eop            (fft_eop       )  ,         //EOP包结束信号
    .fft_valid          (fft_valid     )  ,       //FFT频谱数据有效信号
   
    .data_req           (data_req      )  ,        //数据请求信号
    .fft_point_done     (fft_point_done)  ,     //FFT当前频谱绘制完成
    .fft_point_cnt      (fft_point_cnt )  ,   //FFT频谱位置
    //ram端口        
    .ram_data_out       (ram_data_out  )   //ram输出有效数据
);


hdmi_test_revised hdmi_test_revised_inst
(
   .sys_clk       (sys_clk       ) ,// input system clock 50MHz    
   .rst_n         (rst_n         ) ,
   .rstn_out      (rstn_out      ) ,
   .iic_tx_scl    (iic_tx_scl    ) ,
   .iic_tx_sda    (iic_tx_sda    ) ,
   
   .fft_point_cnt (fft_point_cnt ) , 
   .fft_data      (ram_data_out  ) , 
   .fft_point_done(fft_point_done) , 
   .data_req      (data_req      ) ,
  
   .led_int       (led_int       ) ,
 
   .pix_clk       (pix_clk       ) ,//pixclk                           
   .vs_out        (vs_out        ) , 
   .hs_out        (hs_out        ) , 
   .de_out        (de_out        ) ,
   .r_out         (r_out         ) ,  
   .g_out         (g_out         ) , 
   .b_out         (b_out         )

);


endmodule


