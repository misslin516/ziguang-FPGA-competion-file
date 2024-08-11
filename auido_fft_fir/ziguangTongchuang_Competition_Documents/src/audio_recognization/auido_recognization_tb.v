//created date:2024/7/20
`timescale 1ns/1ns
module auido_recognization_tb();

  reg           sys_clk        ;     
  reg           sys_rst_n      ;     
 
  reg  signed [15:0]   feature_in     ;     
  reg           feature_in_en  ;     
     
  wire [3:0] compare_result    ;  
  wire       compare_result_v1  ;
  
  
  
initial begin
    sys_clk = 1'b0;
    sys_rst_n <= 1'b0;
    #20;
    sys_rst_n <= 1'b1;
end 

always #10 sys_clk = ~sys_clk;

reg signed [15:0] cnt;
always@(posedge sys_clk)
begin
    if(~sys_rst_n)
        cnt <= 'd0;
    else
        cnt <= cnt + 1'b1;
end


always@(posedge sys_clk)
begin
    if(~sys_rst_n)begin
        feature_in <= 'd0;
        feature_in_en <= 1'b0;
    end else if(cnt >= 'd1 && cnt <= 'd4)begin
        feature_in <= 'd1;
        feature_in_en <= 1'b1;
    end else begin
        feature_in <= 'd0;
        feature_in_en <= 1'b0;
    end
end



auido_recognization
#(
    .Dlength ('d192)
)
auido_recognization_inst
(
   .sys_clk           (sys_clk         )    ,
   .sys_rst_n         (sys_rst_n       )    ,
 
   .feature_in        (feature_in      )    ,
   .feature_in_en     (feature_in_en   )    ,
  
   .compare_result    (compare_result  )  ,
   .compare_result_v1  (compare_result_v1)
);

endmodule