//created by : martin
//created data:2024/04/18
//purpose : test the asyn_fifo function and timing sequence

`timescale 1ns/1ns


module tb_fifo_test();
    reg                           rst_n         ;
	reg                           clk_write     ;
    reg                           clk_read      ;
	reg                           write         ;
    reg                           read          ;
	reg   [DATA_WIDTH-1:0]        data_write    ;
	wire  [DATA_WIDTH-1:0]        data_read     ;
	wire                          full          ;
    wire                          empty         ;
	wire   [FIFO_DEPTH_WIDTH-1:0] data_count_w  ;
    wire   [FIFO_DEPTH_WIDTH-1:0] data_count_r  ;
    
    
parameter   DATA_WIDTH       = 5'd8;
parameter   FIFO_DEPTH_WIDTH = 5'd8; 
    
    
initial begin
    clk_write = 1'b0;
    clk_read = 1'b0;
    rst_n <= 1'b0;
    #40;
    rst_n <= 1'b1;
end    

always #10 clk_write = ~clk_write;//50M

always #20 clk_read  = ~clk_read;//25M
    
reg [8:0] cnt;  
  
always@(posedge clk_write or negedge rst_n)    
begin
    if(~rst_n)
        cnt <= 9'd0;
    else if(cnt == 'd255)
        cnt <= 9'd0;
    else
        cnt <= cnt + 1'b1;
end
    
always@(posedge clk_write or negedge rst_n)
begin
    if(~rst_n)
        data_write <= 'd0;
    else
        data_write <= cnt;
end

always@(posedge clk_write or negedge rst_n)
begin
    if(~rst_n)
        write <= 1'b0;
    else if(cnt == 'd255)
         write <= 1'b0;
    else if(cnt == 'd1)
         write <= 1'b1;
    else
        write <= write; 
end


always@(posedge clk_write or negedge rst_n)
begin
    if(~rst_n)
        read <= 1'b0;
    else if(cnt == 'd100)
        read <= 1'b1;
    else
        read <= read;
end




asyn_fifo
#(
    .DATA_WIDTH       (DATA_WIDTH) ,
    .FIFO_DEPTH_WIDTH (FIFO_DEPTH_WIDTH)
)
asyn_fifo_inst2
(
    .rst_n         (rst_n       )  ,
    .clk_write     (clk_write   )  ,
    .clk_read      (clk_read    )  , 
    .write         (write       )  ,
    .read          (read        )  , 
    .data_write    (data_write  )  ,
    .data_read     (data_read   )  ,
    .full          (full        )  ,
    .empty         (empty       )  , 
    .data_count_w  (data_count_w)  ,
    .data_count_r  (data_count_r)
);
	 


endmodule


