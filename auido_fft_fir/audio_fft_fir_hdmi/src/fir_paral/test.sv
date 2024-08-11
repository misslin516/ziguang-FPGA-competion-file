`timescale 1ps/1ps

module test ;
   //input
   reg          clk ;
   reg          rst_n ;
   reg          en ;
   reg [15:0]   xin ;
   //output
   wire         valid ;
   wire [30:0]  yout ;

   parameter    SIMU_CYCLE   = 64'd2000 ;
   parameter    SIN_DATA_NUM = 200 ;
//=====================================
// 50MHz clk generating
   localparam   TCLK_HALF     = 10_000;
   initial begin
      clk = 1'b0 ;
      forever begin
         # TCLK_HALF ;
         clk = ~clk ;
      end
   end

//============================
//  reset and finish

   initial begin
      rst_n = 1'b0 ;
      # 30 ;
      rst_n = 1'b1 ;
      // # (TCLK_HALF * 2 * SIMU_CYCLE) ;
      // $finish ;
   end

//=======================================
// read sinx.txt to get sin data into register
   reg          [15:0] stimulus [0: SIN_DATA_NUM-1] ;
   integer      i ;
   initial begin
      $readmemh("C:/Users/86151/Desktop/auido_fft_fir/fir_paral/cosx0p25m7p5m12bit.txt", stimulus) ;
      i = 0 ;
      en = 0 ;
      xin = 0 ;
      # 200 ;
      forever begin
         @(negedge clk) begin
            en          = 1'b1 ;
            xin         = stimulus[i] ;
            if (i == SIN_DATA_NUM-1) begin
               i = 0 ;
            end
            else begin
               i = i + 1 ;
            end
         end
      end // forever begin
   end // initial begin

fir_guide u_fir_paral (
    .xin         (xin),
    .clk         (clk),
    .en          (en),
    .rstn        (rst_n),
    .valid       (valid),
    .yout        (yout));



endmodule // test
