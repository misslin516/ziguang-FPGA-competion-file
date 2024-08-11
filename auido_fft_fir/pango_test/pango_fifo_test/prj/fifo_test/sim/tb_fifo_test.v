`timescale 1ns/1ns

module tb_fifo_test();
    //write
   reg        sys_clk    ;
   reg        sys_rstn   ;
   reg        wr_en      ;
   reg [30:0] wr_data    ;
   // read               ;
   wire [30:0] rd_data   ;
   
   initial begin
    sys_clk  = 1'b0;
    sys_rstn <= 1'b0;
    #40;
    sys_rstn <= 1'b1;
   end
   always #10 sys_clk = ~sys_clk;

always@(posedge sys_clk or negedge sys_rstn)
    if(~sys_rstn)
        wr_data <=31'd0;
    else if(wr_data == 255)
        wr_data <=31'd0;
    else
        wr_data <= wr_data + 1'b1;
    
   

            


   
   
   fifo_test fifo_test_inst
(

//write
    .sys_clk (sys_clk ) ,
    .sys_rstn(sys_rstn) ,
    .wr_en   (wr_en   ) ,
    .wr_data (wr_data ) ,

    .rd_data (rd_data )
);
   
   
   
    
    
    
    


endmodule