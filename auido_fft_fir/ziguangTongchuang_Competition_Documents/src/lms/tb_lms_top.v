//created date:2024/05/22
//version:v1.0

`timescale 1ns/1ns

module tb_lms_top();
   reg             sys_clk     ;
   reg             rst_n       ;
   
   reg             audio_clk   ;
   reg             data_valid  ;
   reg [15:0]      adc_data    ;
  
   reg             rgmii_clk   ;
   reg             rec_en      ;
   reg [31:0]      rec_data    ;
          
   wire [15:0]      y_lms      ;
    

initial begin
    sys_clk = 1'b0;
    audio_clk = 1'b0;
    rgmii_clk = 1'b0;
    rst_n <= 1'b0;
    #40;
    rst_n <= 1'b1;

end

always #10 sys_clk = ~sys_clk;

always #50 audio_clk = ~audio_clk;

always #16  rgmii_clk = ~rgmii_clk;

reg [15:0] cnt;

always@(posedge audio_clk or negedge rst_n)
    if(~rst_n)
        cnt <= 16'd0;
    else
        cnt <= cnt + 1'b1;
        
always@(posedge audio_clk or negedge rst_n)
    if(~rst_n)
        adc_data <= 16'b0;
    else
        adc_data <= cnt;
       
always@(posedge audio_clk or negedge rst_n)
    if(~rst_n)
        data_valid <= 1'b0;
    else if(cnt == 'd1)
        data_valid  <= 1'b1;
    else
        data_valid  <= data_valid;
       
reg [15:0] cnt1;  
     
always@(posedge rgmii_clk or negedge rst_n)
    if(~rst_n)
        cnt1 <= 16'd0;
    else
        cnt1 <= cnt1 + 1'b1;
        
always@(posedge rgmii_clk or negedge rst_n)
    if(~rst_n)
        rec_data <= 32'd0;
    else
        rec_data <= cnt1;
        
always@(posedge rgmii_clk or negedge rst_n)
    if(~rst_n)
        rec_en <= 1'b0;
    else if(cnt1 == 1'b1)
        rec_en <= 1'b1;
    else
        rec_en <= rec_en;
        
    
lms_top
#(
   .Step_size( 16'h000f  )
)
lms_top_inst
(
   .sys_clk   (sys_clk   ) ,
   .rst_n     (rst_n     ) ,
  
   .audio_clk (audio_clk ) ,
   .data_valid(data_valid) ,
   .adc_data  (adc_data  ) ,
 
   .rgmii_clk (rgmii_clk ) ,
   .rec_en    (rec_en    ) ,
   .rec_data  (rec_data  ) , 
  
   .y_lms     (y_lms     )
);
    
    
    



endmodule




