//****************************************************************************************//
// Created date:        2025/05/08
// version     ：       v2.0    
//****************************************************************************************//



// this file is for debugger

`timescale 1ns/1ns


module audio_fft_top
(
    input       wire         sys_clk                ,
    input                    rst_n                  ,
    
    output      wire         data_valid             ,
    output      wire  [31:0] data_modulus  
    
    

);


wire  data_sop                ;
wire  data_eop                ;

 

 

reg clk_12M; 
reg [3:0] cnt; 

always@(posedge sys_clk or negedge rst_n)
    if(~rst_n)
        cnt <= 4'd0;
    else if(cnt == 4'd4)
        cnt <= 4'd0;
    else 
        cnt <= cnt + 1'b1;
 
always@(posedge sys_clk or negedge rst_n)
    if(~rst_n)
        clk_12M <= 1'b0;
    else if(cnt == 4'd4)
        clk_12M <=~clk_12M;
    else
        clk_12M <= clk_12M;


//test for data

reg [15:0] cnt_data;

always@(posedge clk_12M or negedge rst_n)
    if(~rst_n)
        cnt_data <= 16'd0;
    else if(cnt_data == 'd1024)
        cnt_data <= 16'd0;
    else 
        cnt_data <= cnt_data + 1'b1;
        

wire data_valid_voice;
wire [15:0] dac_data;


assign data_valid_voice  = (cnt_data >= 16'd1 && cnt_data <= 16'd960) ? 1'b1:1'b0;
assign dac_data = 16'd1;


        
fft_top fft_top_inst
(
   .clk_50m       (sys_clk     ) ,
   .rst_n         (rst_n       ) ,
 
   .audio_clk     (clk_12M     ) ,
   .audio_valid   (data_valid_voice) ,
   .audio_data    (dac_data     ) ,
 
   .data_sop      (data_sop     ) ,
   .data_eop      (data_eop     ) ,
   .data_valid    (data_valid   ) ,
   .data_modulus  (data_modulus )   
);


endmodule