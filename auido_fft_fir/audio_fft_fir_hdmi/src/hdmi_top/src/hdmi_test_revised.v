`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//revised by :NJUPT
//  puperpose: only for test
//////////////////////////////////////////////////////////////////////////////////
`define UD #1

module hdmi_test_revised
(
    input wire        sys_clk       ,// input system clock 50MHz 
    input             rst_n         ,
    output            rstn_out      ,
    output            iic_tx_scl    ,
    inout             iic_tx_sda    ,
 
    //fft 
    input       [7:0] fft_point_cnt  , 
    input       [31:0]fft_data       , 
    output            fft_point_done , 
    output            data_req       , 
    
    
    output            led_int       ,
//hdmi_out 
    output            pix_clk       ,//pixclk                           
    output            vs_out        , 
    output            hs_out        , 
    output            de_out        ,
    output     [7:0]  r_out         , 
    output     [7:0]  g_out         , 
    output     [7:0]  b_out         

);

parameter   X_WIDTH = 4'd12;
parameter   Y_WIDTH = 4'd12;    

//MODE_1080p
    parameter V_TOTAL = 12'd1125;
    parameter V_FP = 12'd4;
    parameter V_BP = 12'd36;
    parameter V_SYNC = 12'd5;
    parameter V_ACT = 12'd1080;
    parameter H_TOTAL = 12'd2200;
    parameter H_FP = 12'd88;
    parameter H_BP = 12'd148;
    parameter H_SYNC = 12'd44;
    parameter H_ACT = 12'd1920;
    parameter HV_OFFSET = 12'd0;

    
    wire                        cfg_clk    ;
    wire                        locked     ;
    wire                        rstn       ;
    wire                        init_over  ;
    reg  [15:0]                 rstn_1ms   ;
    wire [X_WIDTH - 1'b1:0]     act_x      ;
    wire [Y_WIDTH - 1'b1:0]     act_y      ;    
    wire                        hs         ;
    wire                        vs         ;
    wire                        de         ;
    reg  [3:0]                  reset_delay_cnt;


// pll u_pll (
  // .clkin1(sys_clk),        // input
  // .pll_lock(locked),    // output
  // .clkout0(pix_clk),      // output
  // .clkout1(cfg_clk)       // output
// );

pll pll_inst 
(
  .clkin1(sys_clk),        // input
  .pll_lock(locked),    // output
  .clkout0(pix_clk),      // output
  .clkout1(cfg_clk)       // output
);



    ms72xx_ctl ms72xx_ctl(
        .clk         (  cfg_clk    ), //input       clk,
        .rst_n       (  rst_n   ), //input       rstn,
                                
        .init_over   (  init_over  ), //output      init_over,
        .iic_tx_scl  (  iic_tx_scl ), //output      iic_scl,
        .iic_tx_sda  (  iic_tx_sda ), //inout       iic_sda
        .iic_scl     (  iic_scl    ), //output      iic_scl,
        .iic_sda     (  iic_sda    )  //inout       iic_sda
    );
   assign    led_int    =     init_over;
    
    always @(posedge cfg_clk)
    begin
    	if(!locked)
    	    rstn_1ms <= 16'd0;
    	else
    	begin
    		if(rstn_1ms == 16'h2710)
    		    rstn_1ms <= rstn_1ms;
    		else
    		    rstn_1ms <= rstn_1ms + 1'b1;
    	end
    end
    
    assign rstn_out = (rstn_1ms == 16'h2710);

    sync_vg_revised #(
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
        .rstn                 (  rst_n                 ),//input                   rstn,                            
        .vs_out               (  vs                   ),//output reg              vs_out,                                                                                                                                      
        .hs_out               (  hs                   ),//output reg              hs_out,            
        .de_out               (  de                   ),//output reg              de_out,             
        .x_act                (  act_x                ),//output reg [X_BITS-1:0] x_out,             
        .y_act                (  act_y                ) //output reg [Y_BITS:0]   y_out,             
    );
    

     pattern_vg_revised 
    #(
       .COCLOR_DEPP(8       ) ,   // number of bits per channel
       .X_BITS     (X_WIDTH ) ,
       .Y_BITS     (Y_WIDTH ) ,
       .H_ACT      (H_ACT   ) ,
       .V_ACT      (V_ACT   ) ,
       .fft_point  ( 9'd256 ) 
    )
    pattern_vg_revised_inst
    (                                       
        .rstn           (rst_n          )  , 
        .pix_clk        (pix_clk        )  ,
        .act_x          (act_x          )  ,
        .act_y          (act_y          )  ,
        .vs_in          (vs             )  , 
        .hs_in          (hs             )  , 
        .de_in          (de             )  ,
        //fft interface
       .fft_point_cnt   (fft_point_cnt  )  ,  
       .fft_data        (fft_data       )  ,    //should be scaled  
       .fft_point_done  (fft_point_done )  ,
       .data_req        (data_req       )  ,
     
       .vs_out          (vs_out         )  , 
       .hs_out          (hs_out         )  , 
       .de_out          (de_out         )  ,
       .r_out           (r_out          )  , 
       .g_out           (g_out          )  , 
       .b_out           (b_out          )
    );




endmodule
