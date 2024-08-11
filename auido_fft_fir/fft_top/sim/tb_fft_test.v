`timescale 1ns/1ns


module tb_fft_test();
    reg         clk_50m         ;
    reg         rst_n           ;

    reg         audio_clk       ;
    reg         audio_valid     ;
    reg  [23:0] audio_data      ;
                               
    wire        fft_ready       ;
    wire        fft_rst_n       ;
    wire        fft_valid       ;
    wire        fft_sop         ;
    wire        fft_eop         ;
  
  
initial begin
    clk_50m = 1'b0;
    audio_clk = 1'b0;
    rst_n <= 1'b0;
    #40;
    rst_n <= 1'b1;
end
    
    
always #10 clk_50m = ~clk_50m;  // 50 M

always #50 audio_clk = ~audio_clk;// 10 M 

reg [8:0] cnt;  ///255


always@(posedge audio_clk or negedge rst_n)
    if(~rst_n)
        cnt <= 9'd0;
    else if(cnt == 9'd255)
        cnt <= 9'd0;
    else
        cnt <=  cnt+ 1'b1;
        
 always@(posedge audio_clk)    
    if(~rst_n)
        audio_data <= 24'd0;
    else
        audio_data <= cnt;
        
reg audio_valid_reg;
 always@(posedge audio_clk)    
    if(~rst_n)
        audio_valid_reg <= 1'b0;
    else if(cnt == 9'd255)
        audio_valid_reg <= 1'b1;
    else
        audio_valid_reg <=audio_valid_reg;
 
always@(posedge audio_clk)   
    if(~rst_n)
        audio_valid <= 1'b0;
    else
        audio_valid <= audio_valid_reg;
   
   
 assign fft_ready = 1'b1;
        
  
fft_test fft_test_inst
(
   .clk_50m     (clk_50m    )   ,
   .rst_n       (rst_n      )   ,
 
   .audio_clk   (audio_clk  )   ,
   .audio_valid (audio_valid)   ,
   .audio_data  (audio_data )   ,
 
   .fft_ready   (fft_ready  )   ,
   .fft_rst_n   (fft_rst_n  )   ,
   .fft_valid   (fft_valid  )   ,
   .fft_sop     (fft_sop    )   ,
   .fft_eop     (fft_eop    )   
           
);
endmodule

