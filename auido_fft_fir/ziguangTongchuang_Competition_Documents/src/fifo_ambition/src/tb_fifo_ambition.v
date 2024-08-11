//created date:2024/06/12

`timescale 1ns/1ps
module tb_fifo_ambition();
   reg  sys_clk     ;
   reg  sys_rst_n   ;
 
   reg  wr_clk      ;
   reg [15:0] wr_data     ;
   reg  wr_en       ;

   reg  rd_clk      ;
   reg  rd_en       ;
   wire [15:0]  rd_data     ;
   wire empty;

initial begin
    sys_clk = 1'b0;
    wr_clk = 1'b0;
    rd_clk = 1'b0;
    sys_rst_n <= 1'b0;
    #40;
    sys_rst_n <= 1'b1;
end


always #10 sys_clk = ~sys_clk;

always #14   wr_clk = ~wr_clk;

always #42  rd_clk = ~rd_clk;

reg [15:0] cnt_count;

always@(posedge wr_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)
        cnt_count <= 16'd0;
    else 
        cnt_count <= cnt_count + 1'b1;
end

always@(posedge wr_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)
        wr_data <= 16'd0;
    else
        wr_data <= cnt_count;
end


always@(posedge wr_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)
        wr_en <= 1'b0;
    else if(cnt_count == 'd1)
        wr_en <= 1'b1;
    else
        wr_en <= wr_en;
end

always@(posedge rd_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)
        rd_en <= 1'b0;
    else if(cnt_count >= 'd2)
        rd_en <= 1'b1;
    else
        rd_en <= rd_en;
end

fifo_ambition_top fifo_ambition_inst
(
   .sys_clk    (sys_clk  )  ,
   .sys_rst_n  (sys_rst_n)  ,
  
   .wr_clk     (wr_clk   )  ,
   .wr_data    (wr_data  )  ,
   .wr_en      (wr_en    )  ,
  
   .rd_clk     (rd_clk   )  ,
   .rd_en      (rd_en    )  ,
   .rd_data    (rd_data  ) 


);

endmodule
