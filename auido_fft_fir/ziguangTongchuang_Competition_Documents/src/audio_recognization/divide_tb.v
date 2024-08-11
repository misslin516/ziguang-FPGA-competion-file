//created date:2024/7/24
`timescale 1ns/1ns
module divide_tb();
    reg clk                 ;
    reg reset               ;
    reg valid_i             ;
    reg [49:0] dividend  ;
    reg [37:0] divisor   ;

    wire valid_o            ;
    wire [11:0] quotient    ;
    wire [37:0] remaind	;

parameter I_W = 'd50;
parameter D_W = 'd38;
parameter O_W = 'd12;

initial begin
    clk = 1'b0;
    reset <= 1'b1;
    #40 reset <= 1'b0;
end

always #10 clk = ~clk;

reg [49:0] cnt;


always@(posedge clk)
begin
    if(reset)
        cnt <=50'd0;
    else 
        cnt <=  cnt + 1'b1;
end


always@(posedge clk)
begin
    if(reset)begin
        valid_i <= 'd0;
        dividend <= 'd0;
        divisor <= 'd0;
    end else if(cnt >= 1'b1)begin
        valid_i <= 'd1;
        dividend <= cnt;
        divisor <= 'd2;
    end else begin
        valid_i <= 'd0;
        dividend <= 'd0;
        divisor <= 'd0;
    end 
end








divide#(
   .I_W(I_W  ),
   .D_W(D_W  ),
   .O_W(O_W  )
)
divide_inst1
(
    .clk      (clk                  )  ,
    .reset    (reset                )  ,		   
	.valid_i  (valid_i              )  ,   //有效信号
    .dividend (dividend             )  ,   //被除数
    .divisor  (   divisor             )  ,   //除数 	 
    .valid_o  (   valid_o         )  ,	  
    .quotient (    quotient      )  ,	//商
    .remaind  (        remaind                 )   //余数 
    );
    
endmodule


