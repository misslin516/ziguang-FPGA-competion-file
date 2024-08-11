`timescale 1ns/1ns

module fifo_test
(

//write
    input       wire        sys_clk    ,
    input       wire        sys_rstn   ,
    input       wire        wr_en      ,
    input       wire [30:0] wr_data    ,
   // read
    output      wire [30:0] rd_data
 
);
//w
wire wr_full;
wire [9:0] wr_water_level;
wire almost_full;


//r
wire rd_empty;
wire [9:0] rd_water_level;
wire almost_empty;
wire rd_clk;
reg rd_clk_reg;
//we define the read clk is 10M

reg [2:0] cnt;

localparam CNT_max = 5;


always@(posedge sys_clk)
    if(!sys_rstn)
        cnt <= 3'd0;
    else
        cnt <=  cnt + 1'b1;
       
always@(posedge sys_clk)
    if(!sys_rstn)
        rd_clk_reg <= 1'b0;
    else if(cnt == CNT_max)
        rd_clk_reg <= ~rd_clk_reg ;
    else
        rd_clk_reg <= rd_clk_reg ;


assign rd_clk = rd_clk_reg;

reg rd_en1;

assign rd_en = rd_en1 ;

always@(posedge sys_clk )
    if(~sys_clk)
        rd_en1 <= 1'b0;
    else if(almost_empty)
        rd_en1 <= 1'b0;
    else if(almost_full)
        rd_en1 <= 1'b1;
    else
        rd_en1 <= rd_en1;
        
        



fifo1 the_instance_name (
  .wr_clk(sys_clk),                // input
  .wr_rst(sys_rstn),                // input
  .wr_en(wr_en),                  // input
  .wr_data(wr_data),              // input [30:0]
  .wr_full(wr_full),              // output
  .almost_full(almost_full),      // output
  .rd_clk(rd_clk),                // input
  .rd_rst(1'b1),                // input
  .rd_en(rd_en),                  // input
  .rd_data(rd_data),              // output [30:0]
  .rd_empty(rd_empty),            // output
  .almost_empty(almost_empty)     // output
);

endmodule


