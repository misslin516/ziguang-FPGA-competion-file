//created date:2024/07/25
//version:v1
module data_comparator
#(
    parameter DW = 'd10

)
(
    input                 sys_clk          ,
    input                 sys_rst_n        ,
                                        
    input                 data_vld_in      ,
    input   signed [DW-1'b1:0]   data_a           ,
    input   signed [DW-1'b1:0]   data_b           ,
                                
    output reg               data_vld_out     ,
    output reg signed [DW-1'b1:0]   data_out

);

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)
        data_out <= 'd0;
    else
        data_out <= (data_a > data_b)?data_a:data_b;
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)
        data_vld_out <= 'd0;
    else
        data_vld_out <= data_vld_in;
end


endmodule

