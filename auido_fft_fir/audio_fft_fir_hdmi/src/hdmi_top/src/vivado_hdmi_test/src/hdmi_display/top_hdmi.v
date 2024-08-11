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


module top_hdmi
(
    input         clk50M        ,

    input         rst_n         ,
                    
    output        tmds_clk_n    ,
    output        tmds_clk_p    ,
    output [2:0]  tmds_data_n   ,
    output [2:0]  tmds_data_p
    
    );

//wire define
wire [15:0] line_cnt;
wire [31:0] line_length;
wire        data_req;   
wire        wr_over;

wire        fifo_wr_req;
wire        fifo_rd_req;
wire [31:0] fifo_wr_data;
wire        fifo_empty;

wire        full;
//*****************************************************
//**                    main code
//***************************************************** 
wire locked;

wire clk75M ;
wire clk375M;


clk_wiz_0 instance_name
(
    // Clock out ports
    .clk_out1(clk75M),     // output clk_out1
    .clk_out2(clk375M),     // output clk_out2
    // Status and control signals
    .reset(~rst_n), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk50M)
);      // input clk_in1


reg [8:0] cnt;

always@(posedge clk50M) begin
    if(~rst_n|| ~locked)
        cnt <= 9'd0;
    else if(cnt == 256)
        cnt <= 9'd0;
    else
        cnt <= cnt + 1'b1;
  end 
  
reg [31:0] fft_data_reg;    
wire [31:0] fft_data;
 
always@(posedge  clk50M)begin
    if(~rst_n|| ~locked)
        fft_data_reg <= 32'd0;
    else if(cnt == 0)
        fft_data_reg <= 32'd0;
    else
        fft_data_reg <= cnt * 1000;
        
end 
     
assign fft_data = fft_data_reg;

assign fft_valid = (cnt >=2 ) ?1'b1:1'b0;

assign fft_sop = (cnt == 9'd2) ? 1'b1:1'b0;

assign fft_eop = (cnt == 9'd0) ? 1'b1:1'b0;




//fifo读写控制模块
 fifo_ctrl_hdmi fifo_ctrl_hdmi_inst
 (
    .clk_50m      (clk50M     )  ,
    .lcd_clk      (clk75M      )  ,
    .rst_n        (rst_n && locked)  ,
  
    .fft_data     (fft_data    )  ,
    .fft_sop      (fft_sop     )  ,
    .fft_eop      (fft_eop     )  ,
    .fft_valid    (fft_valid   )  ,
   
    .data_req     (data_req    )  ,     //外部数据请求信号
    .wr_over      (wr_over     )  ,
    .rd_cnt       (line_cnt    )  ,
   
    .fifo_wr_data (fifo_wr_data)  ,
    .fifo_wr_req  (fifo_wr_req )  ,
    .fifo_rd_req  (fifo_rd_req )
);

  
//例化fifo
fifo_generator_0 your_instance_name 
(
  .rst(~rst_n && ~locked),                  // input wire rst
  .wr_clk(clk50M)       ,            // input wire wr_clk
  .rd_clk(clk75M)       ,            // input wire rd_clk
  .din(fifo_wr_data)    ,                  // input wire [31 : 0] din
  .wr_en(fifo_wr_req)   ,              // input wire wr_en
  .rd_en(fifo_rd_req)   ,              // input wire rd_en
  .dout(line_length)    ,                // output wire [31 : 0] dout
  .full(full)           ,                // output wire full
  .empty(fifo_empty)    ,              // output wire empty
  .wr_rst_busy(     )   ,  // output wire wr_rst_busy
  .rd_rst_busy(     )  // output wire rd_rst_busy
);

//HDMI驱动显示模块
hdmi_display hdmi_display_inst
(
    .pixel_clk   (clk75M      ) ,
    .pixel_clk_5x(clk375M     ) ,
	.sys_rst_n   (rst_n && locked) ,
	
    .line_cnt    (line_cnt    ) , 
    .line_length (line_length ) ,
   
    .data_req    (data_req    ) ,
    .wr_over     (wr_over     ) ,
    .tmds_clk_n  (tmds_clk_n  ) ,
    .tmds_clk_p  (tmds_clk_p  ) ,
    .tmds_data_n (tmds_data_n ) ,
    .tmds_data_p (tmds_data_p )
);              
 
endmodule 