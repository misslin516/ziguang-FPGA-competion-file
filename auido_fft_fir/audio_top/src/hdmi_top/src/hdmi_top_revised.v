`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
//created by :NJUPT
//created data:2024/04/09
//////////////////////////////////////////////////////////////////////////////////
module hdmi_top_revised
(
    input wire        sys_clk         ,// input system clock 50MHz    
    input             rst_n           ,
    output            rstn_out        ,
    output            iic_tx_scl      ,
    inout             iic_tx_sda      ,
 
    //fft 
    input       [31:0]fft_data         , 
    input             fft_sop          , 
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

//wire define
wire data_req;
wire fft_point_done;
wire [7:0] fft_point_cnt;
wire [31:0] fifo_data_out;
wire cfg_clk;
wire        fifo_wr_req;
wire        fifo_rd_req;
wire [31:0] fifo_wr_data;
wire        fifo_empty;

pll pll_inst 
(
  .clkin1(sys_clk),        // input  50
  .pll_lock(locked),    // output
  .clkout0(pix_clk),      // output   148.5
  .clkout1(cfg_clk)       // output    10
);

 
 
//fifo读写控制模块
fifo_ctrl_hdmi fifo_ctrl_inst1
(
    .clk_50m        (sys_clk),
    .lcd_clk        (pix_clk),
    .rst_n          (rst_n & locked),
        
    .fft_data       (fft_data),
    .fft_sop        (fft_sop),
    .fft_eop        (fft_eop),
    .fft_valid      (fft_valid),
        
    .data_req       (data_req),
    .wr_over        (fft_point_done),
    .rd_cnt         (fft_point_cnt),         //频谱的序号
        
    .fifo_wr_data   (fifo_wr_data),
    .fifo_wr_req    (fifo_wr_req),
    .fifo_rd_req    (fifo_rd_req)
);
  
//例化fifo
asyn_fifo
#(
    .DATA_WIDTH(32     ),
    .FIFO_DEPTH_WIDTH(10)  
)
asyn_fifo_inst1
(
    .rst_n        (rst_n & locked)  ,
    .clk_write    (sys_clk  )  ,
    .clk_read     (pix_clk    )  ,         
    .write        (fifo_wr_req)  ,
    .read         ( fifo_rd_req)  , 
    .data_write   (fifo_wr_data )  ,         
    .data_read    (fifo_data_out)  ,      
    .full         (           )  ,
    .empty        ( fifo_empty)  ,          
    .data_count_w (           )  ,
    .data_count_r (           )   
);    
  
  
  

hdmi_test_revised hdmi_test_revised_inst
(
   .sys_clk       (sys_clk       ) ,// input system clock 50MHz    
   .rst_n         (locked & rst_n & ~fifo_empty ) ,
   .cfg_clk       (cfg_clk       ),
   .rstn_out      (rstn_out      ) ,
   .iic_tx_scl    (iic_tx_scl    ) ,
   .iic_tx_sda    (iic_tx_sda    ) ,
   
   .fft_point_cnt (fft_point_cnt ) , 
   .fft_data      (fifo_data_out[9:0]  ) , 
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