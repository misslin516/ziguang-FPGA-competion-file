`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2024/03/30 16:26:46
// Design Name: 
// Module Name: sqrt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module  cordic_jpl
#(
    parameter N = 32
)
(
    input                clk        ,
    input                syn_rst    ,      //active high
    input                valid_in   ,
    input    [N-1:0]     dataa      ,
    input    [N-1:0]     datab      ,
    
    output   wire        valid_out  ,
    output   reg [N-1:0] ampout
    
    
);
      
//reg para
reg [N-1:0]dataa_reg ;
reg [N-1:0]datab_reg ;
wire[N-2:0]dataa_abs ;
wire[N-2:0]datab_abs ;
reg [N-2:0]dataabs_max,dataabs_min ;
reg [N-1:0]absmin_3 ;

   
always@(posedge clk) begin
    if(syn_rst) begin
       dataa_reg <= 'd0 ; 
       datab_reg <= 'd0 ;
    end else begin
        if(valid_in) begin
            dataa_reg <= dataa;
            datab_reg <= datab;
        end
    end
end
            
    
//check the number is positive or not,if negative ,trans it into positive
assign dataa_abs = (dataa_reg[31] == 1'b1) ? (31'd0-dataa_reg[N-2:0]) : dataa_reg[N-2:0] ;
assign datab_abs = (datab_reg[31] == 1'b1) ? (31'd0-datab_reg[N-2:0]) : datab_reg[N-2:0] ;  
 
always @(posedge clk)
   begin
        if(dataa_abs > datab_abs)
             begin
                  dataabs_max <= dataa_abs ;
                  dataabs_min <= datab_abs ;
                  absmin_3 <= {1'b0,datab_abs}+{datab_abs,1'b0} ;        
             end
        else
          begin
                  dataabs_max <= datab_abs ;
                  dataabs_min <= dataa_abs ;
                  absmin_3 <= {1'b0,dataa_abs}+{dataa_abs,1'b0} ;        
             end
   end
   
 always @(posedge clk)
   begin
        if(absmin_3 > {1'b0,dataabs_max})
             ampout <= {1'b0,dataabs_max} - {4'b0,dataabs_max[N-2:3]} + {2'b0,dataabs_min[N-2:1]} ;
        else
          ampout <= {1'b0,dataabs_max} + {4'b0,dataabs_min[N-2:3]} ;
   end    

//three clock delay so the valid should be delay three clock
reg [2:0] valid_out_reg;
//note: if you wanna keep sychronization with output data,you need delay two clock
always@(posedge clk) begin
    if(syn_rst) begin
        valid_out_reg <= 3'b0;
    end else begin
        valid_out_reg <= {valid_out_reg[1:0],valid_in};
    end
end

assign    valid_out =  valid_out_reg[2];
      

endmodule