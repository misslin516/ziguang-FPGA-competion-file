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
wire [9:0]  data_count_r;

localparam fft_point = 10'd256;

//inst fifo
asyn_fifo
#(
    .DATA_WIDTH(24     ),
    .FIFO_DEPTH_WIDTH(10)  //total depth will then be 2**FIFO_DEPTH_WIDTH
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
    .data_count_r ( data_count_r        )          //counts number of data left in fifo memory(sync to either write or read clk)
);

reg re_flag1;
wire re_flag;
wire fft_stop;
always@(posedge clk_50m or negedge rst_n)
begin
    if(~rst_n)
        re_flag1 <= 1'b0;
    else if(fft_stop)
        re_flag1 <= 1'b0;
    else if(data_count_r == {fft_point,1'b0}-1'b1)
        re_flag1 <= 1'b1;
    else
        re_flag1 <= re_flag1;
end

assign re_flag = re_flag1;
                
//FFT控制模块，控制FFT的输入端口
fft_ctrl u_fft_ctrl
(
    .clk_50m        (clk_50m),
    .rst_n          (rst_n  ),
                 
    .fifo_rd_empty  (fifo_rd_empty),
    .re_flag        (re_flag)   ,
    .fifo_rdreq     (fifo_rdreq),
    
    .fft_ready      (fft_ready),
    .fft_rst_n      (fft_rst_n),
    .fft_valid      (fft_valid),
    .fft_sop        (fft_sop),
    .fft_eop        (fft_eop) ,
    .fft_stop        (fft_stop) 
    );
    
    






endmodule 