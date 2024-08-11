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

module  video_display
(    
    input             pixel_clk,                 //hdmi驱动时钟
    input             sys_rst_n,                //复位信号
    
    input      [10:0] pixel_xpos,               //像素点横坐标
    input      [10:0] pixel_ypos,               //像素点纵坐标
    
    input      [15:0] fft_point_cnt,                 //频点
    input      [31:0] fft_data,              //频谱数据
    output     reg       data_req,            //请求频谱数据
    output     reg      fft_point_done,                  //绘制频谱完成
    output    reg  [23:0] lcd_data                  //hdmi像素点数据 RGB888
    
    );    


//parameter define    
parameter  H_DISP  = 11'd1280;                  //分辨率--行
parameter  V_DISP  = 11'd720;                   //分辨率--列


localparam WHITE   = 24'hffffff;    			// 白色
localparam BLACK   = 24'h000000;    			// 黑色
localparam RED     = 24'hFF0000;//红色


localparam GREEN = 24'h00FF00;  //绿色
localparam BLUE  = 24'h0000FF;  //蓝色


//*****************************************************
//**                    main code
//*****************************************************

  
//产生一个采样点的频谱宽度，本次的显示的点是256个，所以采用高4位作为宽度  
wire [3:0] fft_step;    
assign fft_step = H_DISP[10:8] - 1;    


//产生请求数据信号
always @(posedge pixel_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        data_req <= 1'b0;
    else begin
        if((pixel_xpos  == (fft_point_cnt  + 1) * fft_step - 1) 
		    && (pixel_ypos >= 'b0) )
            data_req <= 1'b1;
       else
            data_req <= 1'b0;           
    end
end

//1行结束，拉高done信号，表示此次的频谱显示已完成
always @(posedge pixel_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        fft_point_done <= 1'b0;
    else begin
       if (pixel_xpos == H_DISP - 1)
            fft_point_done <= 1'b1;
       else
            fft_point_done <= 1'b0;           
    end
end   


always@(posedge pixel_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
       lcd_data <= 24'b0;
    end else begin
        if(pixel_xpos >= (fft_point_cnt * fft_step ) && (pixel_xpos <= ((fft_point_cnt + 1) * fft_step ))) begin 
            if (fft_data == 0) begin
              lcd_data <= WHITE; 
            end else if ((pixel_ypos >= V_DISP - fft_data) && (pixel_ypos <= V_DISP)) begin
               lcd_data <= RED;
            end else begin
               lcd_data <= WHITE; 
            end
    end
end 
end

endmodule