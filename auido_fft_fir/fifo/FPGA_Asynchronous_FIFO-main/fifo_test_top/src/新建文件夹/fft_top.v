// revised Created by:          NJUPT
// Created date:        2024/03/22
//****************************************************************************************//
module fft_top(
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

//wire define
wire [23:0] audio_data_w;
wire        fifo_rdreq;
wire        fifo_rd_empty;

wire        fft_rst_n;
wire        fft_ready;
wire        fft_sop;
wire        fft_eop;
wire        fft_valid;

wire        source_sop;
wire        source_eop;
wire        source_valid;
wire [31:0] source_real;
wire [31:0] source_imag;

wire [8:0] data_count_w;
wire [8:0] data_count_r;


//例化fifo，
asyn_fifo
#(
    .DATA_WIDTH         (24  ),
    .FIFO_DEPTH_WIDTH   (256 )//total depth will then be 2**FIFO_DEPTH_WIDTH
)
asyn_fifo_inst
(
    .rst_n         (rst_n       ) ,
    .clk_write     (audio_clk   ) ,
    .clk_read      (clk_50m     ) , //clock input from both domains
    .write         (audio_valid ) ,
    .read          (fifo_rdreq  ) , 
    .data_write    (audio_data  ) , //input FROM write clock domain
    .data_read     (audio_data_w) , //output TO read clock domain
    .full          (full        ) ,
    .empty         (empty       ) , //full=sync to write domain clk , empty=sync to read domain clk
    .data_count_w  (data_count_w) ,
    .data_count_r  (data_count_r)                //counts number of data left in fifo memory(sync to either write or read clk)
);

            
//FFT控制模块，控制FFT的输入端口
fft_ctrl u_fft_ctrl(
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