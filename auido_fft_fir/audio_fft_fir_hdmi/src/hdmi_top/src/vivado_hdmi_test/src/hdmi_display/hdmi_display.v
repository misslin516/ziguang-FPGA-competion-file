//****************************************Copyright (c)***********************************//                        
//----------------------------------------------------------------------------------------
// original Created by:          正点原子
// Created date:        2018/11/27 13:58:23
// Version:             V1.0
// Descriptions:        The original version
//  
// revised Created by:          NJUPT
// Created date:        2024/03/20 
//****************************************************************************************//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module  hdmi_display
(
    input          pixel_clk    ,
    input          pixel_clk_5x ,
	input          sys_rst_n    ,
	
    input  [15:0]   line_cnt    , 
    input  [31:0]  line_length  ,
    
    output         data_req     ,
    output         wr_over      ,
    output         tmds_clk_n   ,
    output         tmds_clk_p   ,
    output  [2:0]  tmds_data_n  ,
    output  [2:0]  tmds_data_p
);

//*****************************************************
//**                    main code
//*****************************************************

//wire define
// wire          pixel_clk;
// wire          pixel_clk_5x;
wire  [10:0]  pixel_xpos_w;
wire  [10:0]  pixel_ypos_w;
wire  [23:0]  pixel_data_w;
wire          video_hs;
wire          video_vs;
wire          video_de;
wire  [23:0]  video_rgb;


//例化RGB数据驱动模块
video_driver  u_video_driver
(
    .pixel_clk      ( pixel_clk ),
    .sys_rst_n      ( sys_rst_n ),

    .video_hs       ( video_hs ),
    .video_vs       ( video_vs ),
    .video_de       ( video_de ),
    .video_rgb      ( video_rgb),

    .pixel_xpos     ( pixel_xpos_w ),
    .pixel_ypos     ( pixel_ypos_w ),
	.pixel_data     ( pixel_data_w )
);

//例化RGB数据显示模块
 video_display video_display_inst
 (    
    .pixel_clk     (pixel_clk     ),                 //hdmi驱动时钟
    .sys_rst_n     (sys_rst_n     ),                //复位信号
   
    .pixel_xpos    (pixel_xpos_w    ),               //像素点横坐标
    .pixel_ypos    (pixel_ypos_w    ),               //像素点纵坐标
    
    .fft_point_cnt (line_cnt ),                 //频点
    .fft_data      (line_length      ),              //频谱数据
    .data_req      (data_req      ),                 //请求频谱数据
    .fft_point_done(wr_over),                  //绘制频谱完成
    .lcd_data      (pixel_data_w   )           //hdmi像素点数据 RGB888
    
    );    





//例化HDMI驱动模块
dvi_transmitter_top u_rgb2dvi_0(
    .pclk           (pixel_clk),
    .pclk_x5        (pixel_clk_5x),
    .reset_n        (sys_rst_n ),
                
    .video_din      (video_rgb),
    .video_hsync    (video_hs), 
    .video_vsync    (video_vs),
    .video_de       (video_de),
                
    .tmds_clk_p     (tmds_clk_p),
    .tmds_clk_n     (tmds_clk_n),
    .tmds_data_p    (tmds_data_p),
    .tmds_data_n    (tmds_data_n), 
    .tmds_oen       ()                    //预留的端口，本次未用到
    );

endmodule