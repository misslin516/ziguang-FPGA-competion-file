`timescale 1ns/1ns

module tb_top_hdmi();
    reg         clk50M      ;
  
    reg         rst_n       ;
       
    wire        tmds_clk_n  ;
    wire        tmds_clk_p  ;
    wire [2:0]  tmds_data_n ;
    wire [2:0]  tmds_data_p ;


initial begin
    clk50M= 1'b0;
    rst_n <= 1'b0;
    #40;
    rst_n <= 1'b1;
end

always #10 clk50M = ~clk50M;


 top_hdmi top_hdmi_inst
(
  .clk50M     (clk50M     )  ,
 
  .rst_n      (rst_n      )  ,

  .tmds_clk_n (tmds_clk_n )  ,
  .tmds_clk_p (tmds_clk_p )  ,
  .tmds_data_n(tmds_data_n)  ,
  .tmds_data_p(tmds_data_p)
    
);

endmodule
