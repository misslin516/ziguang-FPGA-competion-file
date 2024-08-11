//****************************************Copyright (c)***********************************//                        
//----------------------------------------------------------------------------------------
// original Created by:          正点原子
// Created date:        2018/11/27 13:58:23
// Version:             V1.0
// Descriptions:        The original version
//  
// revised Created by:          NJUPT
// Created date:        2024/03/22
//****************************************************************************************//
module fft_test
(
    input         clk_50m         ,
    input         rst_n           ,
     
    input         audio_clk       ,
    input         audio_valid     ,
    input  [23:0] audio_data      ,
   
    output        fft_ready       ,
    output        fft_rst_n       ,
    output        fft_valid       ,
    output        fft_sop         ,
    output        fft_eop         
   
);

//wire define
wire [23:0] audio_data_w;
wire        fifo_rdreq;
wire        fifo_rd_empty;



//inst fifo
asyn_fifo
#(
    .DATA_WIDTH(24     ),
    .FIFO_DEPTH_WIDTH(9)  //total depth will then be 2**FIFO_DEPTH_WIDTH
)
asyn_fifo_inst
(
    .rst_n        (rst_n      )  ,
    .clk_write    (audio_clk  )  ,
    .clk_read     (clk_50m    )  ,         //clock input from both domains
    .write        (audio_valid)  ,
    .read         (fifo_rdreq )  , 
    .data_write   (audio_data )  ,          //input FROM write clock domain
    .data_read    (audio_data_w)  ,       //output TO read clock domain    maybe need delay one clock
    .full         (           )  ,
    .empty        ( fifo_rd_empty       )  ,          //full=sync to write domain clk , empty=sync to read domain clk
    .data_count_w (           )  ,
    .data_count_r (           )          //counts number of data left in fifo memory(sync to either write or read clk)
);

     
                
//FFT控制模块，控制FFT的输入端口
fft_ctrl u_fft_ctrl
(
    .clk_50m        (clk_50m),
    .rst_n          (rst_n  ),
                 
    .fifo_rd_empty  (fifo_rd_empty),
    .fifo_rdreq     (fifo_rdreq),
    
    .fft_ready      (fft_ready),
    .fft_rst_n      (fft_rst_n),
    .fft_valid      (fft_valid),
    .fft_sop        (fft_sop),
    .fft_eop        (fft_eop) 
    );






endmodule 