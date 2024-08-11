//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2022 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module ipsxe_fft_onboard_top_tb ();

GTP_GRS GRS_INST(
    .GRS_N (1'b1)
);

reg clk, rstn;

reg  i_start_test  ;
wire o_err         ;
wire o_chk_finished;

parameter   CLK_P             = 10      ; // 10ns
initial begin
    clk = 1'b1;
    forever 
        #(CLK_P/2) clk = ~clk;
end

ipsxe_fft_onboard_top u_onboard_top ( 
    .i_clk              (clk                ),
    .i_rstn             (rstn               ),
    .i_start_test       (i_start_test       ),      
    .o_err              (o_err              ),
    .o_chk_finished     (o_chk_finished     )
);
   
//------------------------------------------------------
initial begin
    rstn = 1'b0;
    #100
    rstn = 1'b1;
    
    i_start_test = 1'b0;
    #100
    i_start_test = 1'b1;
    #(10000*CLK_P)
    wait(o_chk_finished)
    
    #1000
    
    if (o_err)
        $display("Simulation is failed.");
    else
        $display("Simulation is successful.");
        
    $finish;
end    

initial begin
    rstn = 1'b0;
    #100
    rstn = 1'b1;
    
    i_start_test = 1'b0;
    #100
    i_start_test = 1'b1;
    #(10000*CLK_P)
    wait(o_chk_finished)
    
    #1000
    
    if (o_err)
        $display("Simulation is failed.");
    else
        $display("Simulation is successful.");
        
    $finish;
end  

reg  [25-1:0]  i_re_test;
reg  [25-1:0]  i_im_test;
reg       [15:0]    twiddle_re_test ;
reg       [15:0]    twiddle_im_test ;

always @(posedge clk or negedge rstn) begin
    if (~rstn)begin
        i_re_test <= {25{1'b0}};
        i_im_test <= {25{1'b0}};
        twiddle_re_test <= {16{1'b0}};
        twiddle_im_test <= {16{1'b0}};
    end
    else begin
        i_re_test <= i_re_test+'d5;
        i_im_test <= i_im_test+'d10;
        twiddle_re_test <= twiddle_re_test+'d15;
        twiddle_im_test <= twiddle_im_test+'d20;
    end
end 


reg       [25-1:0]  i_a_re_test;
reg       [25-1:0]  i_a_im_test;
reg       [25-1:0]  i_b_re_test;
reg       [25-1:0]  i_b_im_test;



always @(posedge clk or negedge rstn) begin
    if (~rstn)begin
        i_a_re_test <= {25{1'b0}};
        i_a_im_test <= {25{1'b0}};
        i_b_re_test <= {25{1'b0}};
        i_b_im_test <= {25{1'b0}};
    end
    else begin
        i_a_re_test <= i_a_re_test+'d5;
        i_a_im_test <= i_a_im_test+'d10;
        i_b_re_test <= i_b_re_test+'d15;
        i_b_im_test <= i_b_im_test+'d20;
    end
end

// initial
// begin
    // force ipsxe_fft_onboard_top_tb.u_onboard_top.u_fft_wrapper.use_radix2_burst.u_radix2_burst_core.r2_dit_bf.u_r2_dit_mult_by_twiddle.u_comp_mult.i_a_re = i_re_test;
    // force ipsxe_fft_onboard_top_tb.u_onboard_top.u_fft_wrapper.use_radix2_burst.u_radix2_burst_core.r2_dit_bf.u_r2_dit_mult_by_twiddle.u_comp_mult.i_a_im = i_im_test;
    // force ipsxe_fft_onboard_top_tb.u_onboard_top.u_fft_wrapper.use_radix2_burst.u_radix2_burst_core.r2_dit_bf.u_r2_dit_mult_by_twiddle.u_comp_mult.i_b_re = twiddle_re_test;
    // force ipsxe_fft_onboard_top_tb.u_onboard_top.u_fft_wrapper.use_radix2_burst.u_radix2_burst_core.r2_dit_bf.u_r2_dit_mult_by_twiddle.u_comp_mult.i_b_im = twiddle_im_test;
    // force ipsxe_fft_onboard_top_tb.u_onboard_top.u_fft_wrapper.use_radix2_burst.u_radix2_burst_core.r2_dit_bf.u_r2bf_as_core.i_a_re = i_a_re_test;
    // force ipsxe_fft_onboard_top_tb.u_onboard_top.u_fft_wrapper.use_radix2_burst.u_radix2_burst_core.r2_dit_bf.u_r2bf_as_core.i_a_im = i_a_im_test;
    // force ipsxe_fft_onboard_top_tb.u_onboard_top.u_fft_wrapper.use_radix2_burst.u_radix2_burst_core.r2_dit_bf.u_r2bf_as_core.i_b_re = i_b_re_test;
    // force ipsxe_fft_onboard_top_tb.u_onboard_top.u_fft_wrapper.use_radix2_burst.u_radix2_burst_core.r2_dit_bf.u_r2bf_as_core.i_b_im = i_b_im_test;
	
// end

endmodule