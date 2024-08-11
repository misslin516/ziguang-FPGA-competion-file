`timescale 1ns/1ns


module tb_fir_guide();
    reg           rstn   ;
    reg           clk    ;
    reg           en     ;
    reg [15:0]    xin    ;
    wire          valid  ;
    wire[30:0]    yout   ;
    
    
initial begin
    clk = 1'b0;
    rstn <= 1'b0;
    #40;
    rstn <= 1'b1;
end

always #10 clk = ~clk;

localparam SIN_DATA_NUM = 25'd40000;

 reg          [15:0] stimulus [0: SIN_DATA_NUM-1] ;
 reg          [15:0] noise [0: SIN_DATA_NUM-1] ;
 integer      i ;
   initial begin
      $readmemh("C:/Users/86151/Desktop/ziguangTongchuang_Competition_Documents/src/fir_paral/noise.hex",noise) ;
      $readmemh("C:/Users/86151/Desktop/ziguangTongchuang_Competition_Documents/src/fir_paral/sine.hex",stimulus);
      i = 0 ;
      en = 0 ;
      xin = 0 ;
      # 200 ;
      forever begin
         @(negedge clk) begin
            en          = 1'b1 ;
            xin         = stimulus[i] + noise[i] ;
            if (i == SIN_DATA_NUM-1) begin
               i = 0 ;
            end
            else begin
               i = i + 1 ;
            end
         end
      end // forever begin
   end // initial begin  
    
fir_guide fir_guide_inst
( 
    .rstn   (rstn  ) ,
    .clk    (clk   ) ,
    .en     (en    ) ,
    .xin    (xin   ) ,
    .valid  (valid ) ,
    .yout   (yout  )
);    
    
endmodule