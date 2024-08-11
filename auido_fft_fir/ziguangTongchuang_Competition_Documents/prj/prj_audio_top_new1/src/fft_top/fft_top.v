// Created date:        2024/03/28
// Revised data:        2024/05/10
//****************************************************************************************//


module fft_top
(
    input         clk_50m         ,
    input         rst_n           ,
     
    input         audio_clk       ,
    input         audio_valid     ,
    input  [23:0] audio_data      ,
   
    output        data_sop        ,
    output        data_eop        ,
    output        data_valid      ,
    output [31:0] data_modulus    ,
    output  [2:0] o_alm
   
);

localparam fft_point = 9'd256;

//para define
wire [23:0] audio_data_w    ;

wire        fifo_rdreq      ;
wire        fifo_rd_empty   ;
wire [9:0]  data_count_w;
wire [9:0]  data_count_r;
wire        o_axi4s_data_tready;
wire [15:0] o_axi4s_data_tuser_s;

wire [31:0] source_real;/*synthesis PAP_MARK_DEBUG="1"*/   //防止被优化
wire [31:0] source_imag;/*synthesis PAP_MARK_DEBUG="1"*/   //防止被优化


wire o_axi4s_data_tvalid;
wire o_axi4s_data_tlast ;

wire fft_rst_n;
wire fft_valid;

wire fft_sop;
wire fft_eop;
wire fft_stop;

wire source_sop;

assign source_sop = ((o_axi4s_data_tuser_s == 0) &&(o_axi4s_data_tvalid == 1)) ? 1'b1:1'b0;

reg re_flag1;
wire re_flag;
always@(posedge clk_50m or negedge rst_n)
begin
    if(~rst_n)
        re_flag1 <= 1'b0;
    else if(fft_stop)
        re_flag1 <= 1'b0;
    else if(data_count_w == {fft_point,1'b0})
        re_flag1 <= 1'b1;
    else
        re_flag1 <= re_flag1;
end

assign re_flag = re_flag1;
                



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
    .read         ( fifo_rdreq)  , 
    .data_write   (audio_data )  ,          //input FROM write clock domain
    .data_read    (audio_data_w)  ,       //output TO read clock domain
    .full         (           )  ,
    .empty        ( fifo_rd_empty )  ,          //full=sync to write domain clk , empty=sync to read domain clk
    .data_count_w ( data_count_w  )  ,
    .data_count_r ( data_count_r  )          //counts number of data left in fifo memory(sync to either write or read clk)
);


                
//inst fft_ctrl 
fft_ctrl u_fft_ctrl(
    .clk_50m        (clk_50m),
    .rst_n          (rst_n  ),
                 
    .fifo_rd_empty  (fifo_rd_empty),
    .re_flag        (re_flag    )   ,
    .fifo_rdreq     (fifo_rdreq),
    
    .fft_ready      (o_axi4s_data_tready),
    .fft_rst_n      (fft_rst_n),
    .fft_valid      (fft_valid),
    .fft_sop        (fft_sop),
    .fft_eop        (fft_eop) ,
    .fft_stop       (fft_stop) 
    );

//inst fft    -该FFT仅支持数据连续输入，所以这里针对FIFO就不能一个一个读 达到要求的FFT点数一起输入
//hold up violate 0.1ns
fft_demo_00  u_fft_wrapper 
(
    .i_aclk                 (clk_50m              ),

    .i_axi4s_data_tvalid    (fft_valid            ),
    .i_axi4s_data_tdata     ({8'b0,audio_data_w}  ),
    .i_axi4s_data_tlast     (fft_eop              ),
    .o_axi4s_data_tready    (o_axi4s_data_tready  ),
    .i_axi4s_cfg_tvalid     (fft_rst_n            ),
    .i_axi4s_cfg_tdata      (1'b1                 ),
    .o_axi4s_data_tvalid    (o_axi4s_data_tvalid  ),
    .o_axi4s_data_tdata     ({source_imag,source_real} ),
    .o_axi4s_data_tlast     (o_axi4s_data_tlast  ),
    .o_axi4s_data_tuser     (o_axi4s_data_tuser_s  ),
    .o_alm                  (o_alm               ),
    .o_stat                 (              )
);



data_module_fft  data_module_fft_inst
(
   .clk_50m      (clk_50m     ) ,
   .rst_n        (rst_n       ) ,
 
   .source_real  (source_real ) ,
   .source_imag  (source_imag ) ,
   .source_sop   (source_sop  ) ,
   .source_eop   (o_axi4s_data_tlast  ) ,
   .source_valid (o_axi4s_data_tvalid) ,
  
   .data_modulus (data_modulus) ,  
   .data_sop     (data_sop    ) ,
   .data_eop     (data_eop    ) ,
   .data_valid   (data_valid  )
);




endmodule 