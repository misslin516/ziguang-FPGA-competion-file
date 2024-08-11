// revised Created by:          NJUPT
// Created date:        2024/03/28
// Revised data:        2024/04/02
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
    output [31:0] data_modulus
   
);

//para define
wire [23:0] audio_data_w    ;

wire        fifo_rdreq      ;
wire        fifo_rd_empty   ;
wire        o_axi4s_data_tready;
wire [15:0] o_axi4s_data_tuser_s;

wire [31:0] source_real;
wire [31:0] source_imag;


wire o_axi4s_data_tvalid;
wire o_axi4s_data_tlast ;

wire fft_rst_n;
wire fft_valid;

wire fft_sop;
wire fft_eop;




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
    .read         ( fifo_rdreq)  , 
    .data_write   (audio_data )  ,          //input FROM write clock domain
    .data_read    (audio_data_w)  ,       //output TO read clock domain
    .full         (           )  ,
    .empty        ( fifo_rd_empty       )  ,          //full=sync to write domain clk , empty=sync to read domain clk
    .data_count_w (           )  ,
    .data_count_r (           )          //counts number of data left in fifo memory(sync to either write or read clk)
);


                
//inst fft_ctrl 
fft_ctrl u_fft_ctrl(
    .clk_50m        (clk_50m),
    .rst_n          (rst_n  ),
                 
    .fifo_rd_empty  (fifo_rd_empty),
    .fifo_rdreq     (fifo_rdreq),
    
    .fft_ready      (o_axi4s_data_tready),
    .fft_rst_n      (fft_rst_n),
    .fft_valid      (fft_valid),
    .fft_sop        (fft_sop),
    .fft_eop        (fft_eop) 
    );

//inst fft 
ipsxe_fft_core_only 
( 
    .i_aclk               (clk_50m              ) ,
  
    .i_axi4s_data_tvalid  (fft_valid            ) ,
    .i_axi4s_data_tdata_s ({8'b0,audio_data_w2} ) ,    //32
    .i_axi4s_data_tlast   (fft_eop              ) ,
    .o_axi4s_data_tready  (o_axi4s_data_tready  ) ,

    .i_axi4s_cfg_tvalid   (fft_rst_n            ) , // fft,ifft valid
    .i_axi4s_cfg_tdata    (1'b1                 ) , //1-fft 0-ifft
  
    .o_axi4s_data_tvalid  (o_axi4s_data_tvalid  ) ,
    .o_axi4s_data_tdata_s ({source_imag,source_real} ) ,    //64
    .o_axi4s_data_tlast   (o_axi4s_data_tlast   ) ,
    .o_axi4s_data_tuser_s (o_axi4s_data_tuser_s ) ,
 
    .o_alm                (                ) ,
    .o_stat               (                )
);



data_module_fft  data_module_fft_inst
(
   .clk_50m      (clk_50m     ) ,
   .rst_n        (rst_n       ) ,
 
   .source_real  (source_real ) ,
   .source_imag  (source_imag ) ,
   .source_sop   (source_sop  ) ,
   .source_eop   (o_axi4s_data_tlast  ) ,
   .source_valid (o_axi4s_data_tvalid_datamodule2) ,
  
   .data_modulus (data_modulus) ,  
   .data_sop     (data_sop    ) ,
   .data_eop     (data_eop    ) ,
   .data_valid   (data_valid  )
);

wire source_sop;

assign source_sop = ((o_axi4s_data_tuser_s == 0) &&(o_axi4s_data_tvalid == 1)) ? 1'b1:1'b0;

reg o_axi4s_data_tvalid_datamodule1;
wire o_axi4s_data_tvalid_datamodule2;

always@(posedge clk_50m )begin
    o_axi4s_data_tvalid_datamodule1 <= o_axi4s_data_tvalid;
end

assign o_axi4s_data_tvalid_datamodule2 = o_axi4s_data_tvalid;


reg  [23:0] audio_data_w1   ;
always@(posedge clk_50m) begin
    audio_data_w1 <=  audio_data_w;    //delay one clock for fft timing sequence
end

wire [23:0] audio_data_w2;

assign audio_data_w2 = audio_data_w1;


endmodule 