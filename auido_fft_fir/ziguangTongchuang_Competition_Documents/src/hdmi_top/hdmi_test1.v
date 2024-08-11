`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//created date:2024/05/16
//version : v1.0
//////////////////////////////////////////////////////////////////////////////////
`define UD  #1


module hdmi_test1
(
    input wire        sys_clk       ,// input system clock 50MHz 
    input             rst_n         ,
    output            rstn_out      ,
    output            iic_tx_scl    ,
    inout             iic_tx_sda    ,
 
    //fft 
    input       [31:0]fft_data         , 
    input             fft_sop          , 
    input             fft_eop          , 
    input             fft_valid        , 
    
    input    [15:0]   audio_data       ,
    input             audio_en         ,
    input             audio_clk        ,
    
    output            pix_clk       ,
    output            led_int       ,
//hdmi_out                         
    output            vs_out        , 
    output            hs_out        , 
    output            de_out        ,
    output     [7:0]  r_out         , 
    output     [7:0]  g_out         , 
    output     [7:0]  b_out         

);

parameter   X_WIDTH = 4'd10;
parameter   Y_WIDTH = 4'd10;    
// the details see  `include "hdmi_timing_sequence.h" 
//*************************640*480@60Hz*25MHz**********************************************
//see hdmi_timing_sequence.h
parameter V_TOTAL = 10'd525;
parameter V_FP = 10'd11;
parameter V_BP = 10'd32;
parameter V_SYNC = 10'd2;
parameter V_ACT = 10'd480;

parameter H_TOTAL = 10'd800;
parameter H_FP = 10'd16;
parameter H_BP = 10'd48;
parameter H_SYNC = 10'd96;
parameter H_ACT = 10'd640;
parameter HV_OFFSET = 10'd0;

// //*************************640*480@85Hz* 36MHz*********************************************

// parameter V_TOTAL = 10'd509;
// parameter V_FP = 10'd1;
// parameter V_BP = 10'd25;
// parameter V_SYNC = 10'd3;
// parameter V_ACT = 10'd480;

// parameter H_TOTAL = 10'd832;
// parameter H_FP = 10'd56;
// parameter H_BP = 10'd80;
// parameter H_SYNC = 10'd56;
// parameter H_ACT = 10'd640;
// parameter HV_OFFSET = 10'd0;







//wire and reg
reg [9:0] wr_address1;
wire [9:0] wr_address;
wire [31:0] rd_data;
wire [31:0] fftram_data;
wire [31:0] audatram_data;
wire [9:0] RAM_address;
wire [9:0] fft_address;
wire [9:0] audiodat_address;
wire cfg_clk;
wire locked;
wire data_req;
reg  [15:0]cnt_sop;
wire en_flag;
//delay the data
reg [31:0] fft_data1;
reg  fft_sop1;
reg  fft_eop1;
reg  fft_valid1;

always@(posedge sys_clk or negedge rst_n)
begin
    if(~rst_n)begin
        fft_data1 <= 32'd0;
        fft_sop1 <= 1'b0;
        fft_eop1 <= 1'b0;
        fft_valid1 <= 1'b0;
    end else begin
        fft_data1 <=  fft_data;
        fft_sop1 <=   fft_sop;
        fft_eop1 <=   fft_eop;
        fft_valid1 <= fft_valid;
    end
end

//delay 
reg [31:0] audio_data1;
reg  audio_en1;
always@(posedge audio_clk or negedge rst_n)
begin
    if(~rst_n)begin
        audio_data1 <= 32'd0;
        audio_en1 <= 1'b0;
    end else begin
        audio_data1 <= {16'b0,audio_data};
        audio_en1 <=  audio_en;
    end
end



//做抽帧处理来缓解刷新过快
always@(posedge sys_clk or negedge rst_n)
begin
    if(~rst_n)
        cnt_sop <= 16'd0;
    else if((cnt_sop == 16'd128) &&(fft_sop1 == 1'b1))
        cnt_sop <= 16'd0;
    else if(fft_sop1 == 1'b1)
        cnt_sop <=  cnt_sop + 1'b1;
    else
        cnt_sop <=  cnt_sop;
end



always@(posedge sys_clk or negedge rst_n)
begin
    if(~rst_n)
        wr_address1 <= 10'd0;
    else if(fft_sop1)
        wr_address1 <= 10'd0;
    else if((fft_valid1) && (cnt_sop == 16'd128))
        wr_address1 <= wr_address1 + 1'b1;
    else
        wr_address1 <= 10'd0;
end

assign wr_address = wr_address1;



//inst ram
ram2 ram2_fft 
(
  .wr_data(fft_data1  ),    // input [31:0]
  .wr_addr(wr_address ),    // input [9:0]
  .rd_addr(fft_address),    // input [9:0]
  .wr_clk (sys_clk    ),      // input
  .rd_clk (pix_clk    ),      // input
  .wr_en  (fft_valid1 ),        // input
  .rst    (rst_n      ),            // input
  .rd_data(fftram_data    )     // output [31:0]
);


ram2 ram2_audio_data
(
  .wr_data(audio_data1),    // input [31:0]
  .wr_addr(wr_address + 256),    // input [9:0]
  .rd_addr(audiodat_address),    // input [9:0]
  .wr_clk (audio_clk  ),      // input
  .rd_clk (pix_clk    ),      // input
  .wr_en  (audio_en1 ),        // input
  .rst    (rst_n      ),            // input
  .rd_data(audatram_data    )     // output [31:0]
);



assign fft_address = ~en_flag ? RAM_address : 10'd0;
assign audiodat_address = en_flag ? RAM_address : 10'd0;

assign rd_data     = ~en_flag ? fftram_data:audatram_data;


pll pll_inst 
(
  .clkin1(sys_clk),        // input  50
  .pll_lock(locked),    // output
  .clkout0(pix_clk),      // output   1080 - 148.5M   720 - 74.25M   480 - 25M
  .clkout1(cfg_clk)       // output    10
);

    

    wire                        init_over  ;
    reg  [15:0]                 rstn_1ms   ;
    wire [X_WIDTH - 1'b1:0]     act_x      ;
    wire [Y_WIDTH - 1'b1:0]     act_y      ;    
    wire                        hs         ;
    wire                        vs         ;
    wire                        de         ;
    reg  [3:0]                  reset_delay_cnt;

    




    ms72xx_ctl ms72xx_ctl(
        .clk         (  cfg_clk    ), //input       clk,
        .rst_n       (  rstn_out   ), //input       rstn,
                                
        .init_over   (  init_over  ), //output      init_over,
        .iic_tx_scl  (  iic_tx_scl ), //output      iic_scl,
        .iic_tx_sda  (  iic_tx_sda ), //inout       iic_sda
        .iic_scl     (  iic_scl    ), //output      iic_scl,
        .iic_sda     (  iic_sda    )  //inout       iic_sda
    );
   assign    led_int    =     init_over;
    
    
    assign rstn_out = rst_n & locked;
    

    sync_vg_revised1 #(
        .X_BITS               (  X_WIDTH              ), 
        .Y_BITS               (  Y_WIDTH              ),
        .V_TOTAL              (  V_TOTAL              ),//                        
        .V_FP                 (  V_FP                 ),//                        
        .V_BP                 (  V_BP                 ),//                        
        .V_SYNC               (  V_SYNC               ),//                        
        .V_ACT                (  V_ACT                ),//                        
        .H_TOTAL              (  H_TOTAL              ),//                        
        .H_FP                 (  H_FP                 ),//                        
        .H_BP                 (  H_BP                 ),//                        
        .H_SYNC               (  H_SYNC               ),//                        
        .H_ACT                (  H_ACT                ) //                        
 
    ) sync_vg                                         
    (                                                 
        .clk                  (  pix_clk               ),//input                   clk,                                 
        .rstn                 (  rstn_out                 ),//input                   rstn,                            
        .vs_out               (  vs                   ),//output reg              vs_out,                                                                                                                                      
        .hs_out               (  hs                   ),//output reg              hs_out,            
        .de_out               (  de                   ),//output reg              de_out,             
        .x_act                (  act_x                ),//output reg [X_BITS-1:0] x_out,             
        .y_act                (  act_y                ) //output reg [Y_BITS:0]   y_out,     
          
    );
    
pattern_vg_revised # 
(
    .COCLOR_DEPP (8 )      , // number of bits per channel
    .X_BITS      (X_WIDTH      ),
    .Y_BITS      (Y_WIDTH      )  ,
    .H_ACT       (H_ACT       )  ,
    .V_ACT       (V_ACT       )  ,
    .fft_point   (256   )    
)
pattern_vg_revised_inst
(                                       
    .rstn          (rstn_out          )  , 
    .pix_clk       (pix_clk           )  ,
    .act_x         (act_x         )  ,
    .act_y         (act_y         )  ,
    .vs_in         (vs         )   , 
    .hs_in         (hs           )    , 
    .de_in         (de           )  ,
   
   
    .fft_data      (rd_data )  ,    //should be scaled  
    .data_req      (data_req      )  ,
    .RAM_address   (RAM_address   )  ,
    .en_flag       (  en_flag     )  ,
    .vs_out        (vs_out        )  , 
    .hs_out        (hs_out        )  , 
    .de_out        (de_out        )  ,
    .r_out         (r_out         )  , 
    .g_out         (g_out         )  , 
    .b_out         (b_out         )
);



endmodule
