`timescale 1ns / 1ps
//created date:2024/05/22
//version : v1.0
//created by :   XXXXX

module LMSX_selfdefine
#(
    parameter self_calss = 8
)
(
    input                       clk              ,
    input                       reset            ,
    input                       enable           ,
    input   signed  [15:0]      data_in          ,
    input   signed  [15:0]      Step_size        ,
    input   signed  [31:0]      Sum_in           ,
                                          
    output  signed  [31:0]      Sum_out          ,
    output  signed  [15:0]      Delay_out
      
);

localparam CLASS = LOG2(self_calss);

wire signed [(CLASS << 4) -1 :0] LMS_tap_delay_out;
wire signed [(CLASS << 5) -1 :0] LMS_tap_out;





genvar i;
generate 
    for(i =0;i <CLASS;i = i+1 ) 
        begin:class1
        if (i == 0) 
            LMS_tap  LMS_tap_1	
            (
                .Clk      (clk                      ),
                .Reset    (reset                    ),
                .Enable   (enable                   ),
                .Data_in  (data_in                  ), 
                .Step_size(Step_size                ),
                .Delay_out(LMS_tap_delay_out[15:0]  ),
                .Tap_out  (LMS_tap_out[31:0]        )
            );
        else
            LMS_tap  LMS_tap_2	
            (
                .Clk      (clk                                        ),
                .Reset    (reset                                      ),
                .Enable   (enable                                     ),
                .Data_in  (LMS_tap_delay_out[(i << 4) -1:(i-1) << 4]  ), 
                .Step_size(Step_size                                  ),
                .Delay_out(LMS_tap_delay_out[((i+1) << 4) -1:i << 4]  ),
                
                .Tap_out  (LMS_tap_out[((i+1) << 5) -1:i << 5]        )   
            );
        end
   
endgenerate



assign Delay_out = LMS_tap_delay_out[((CLASS - 1)  << 4) - 1:(CLASS - 2) << 4];

wire signed [31:0] sum_reg [CLASS:0];


generate 
    genvar j;
    for(j= 0;j < CLASS; j = j +1)begin
        if(j == 0)
           assign  sum_reg[0] = Sum_in;
        assign sum_reg[j+1] = sum_reg[j] + LMS_tap_out[((j+1) << 5) -1:j << 5];
    end
endgenerate


assign Sum_out   = sum_reg[CLASS];




function integer LOG2;
    input integer dep;
    begin
        LOG2 = 0;
        while (dep > 1)
        begin
            dep  = dep >> 1;
            LOG2 = LOG2 + 1;   //compute width
        end
    end
endfunction

endmodule


