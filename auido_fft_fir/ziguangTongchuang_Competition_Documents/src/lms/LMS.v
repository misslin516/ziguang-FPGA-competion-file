`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//this code is LMS filter
//////////////////////////////////////////////////////////////////////////////////
// `define LMSX8




module LMS
#(
    parameter filter_class = 8
)
(Clk,Reset,Enable,Data_in,Desired_in,Step_size,Error_out,Delay_out_x,Y_out);
	input	Clk,Reset,Enable;
	input   signed [15:0] Data_in,Desired_in,Step_size;
	output	signed [15:0] Error_out,Delay_out_x,Y_out;
  //output  signed [7:0] E_out;
  
  
	wire signed [15:0] Error_in,Data_in_reg,Desired_in_reg,Product_16,Delay_out_1,Y_out;
	wire signed [31:0] Product_32,LMSx8_1_sum_out,LMSx8_2_sum_out;
    wire  signed [7:0] E_out;
	
	//使能位置一后，输出等于输入
	DelayUnit	Data_reg_1	(.Clk(Clk),
							.Reset(Reset),
							.Enable(Enable),
							.Data_in(Data_in),
							.Delay_out(Data_in_reg)
							);
							
	DelayUnit	Data_reg_2	(.Clk(Clk),
							.Reset(Reset),
							.Enable(Enable),
							.Data_in(Desired_in),
							.Delay_out(Desired_in_reg)
							);

	assign Product_32 = Step_size * Error_in;
   assign Product_16 = Product_32[26:11];
   
`ifdef LMSX8
	LMSx8	LMSx8_1   (.Clk(Clk),
					.Reset(Reset),
					.Enable(Enable),
					.Data_in(Data_in_reg),
					.Step_size(Product_16),
					.Sum_in(32'h0000_0000),
					.Delay_out(Delay_out_x),
					.Sum_out(LMSx8_1_sum_out)
					);
`else
    LMSX_selfdefine
    #(
       .self_calss(filter_class)
    )
    LMSX_selfdefine_inst
    (
        .clk           (Clk             )   ,
        .reset         (Reset           )   ,
        .enable        (Enable          )   ,
        .data_in       (Data_in_reg     )   ,
        .Step_size     (Product_16      )   ,
        .Sum_in        (32'h0000_0000   )   ,
     
        .Sum_out       (LMSx8_1_sum_out )   ,
        .Delay_out     (Delay_out_x     ) 
    );
`endif                    
                    
                    
                
	
    assign Error_in = Desired_in_reg - LMSx8_1_sum_out[26:11]; 
    assign Y_out=LMSx8_1_sum_out[26:11];
    assign Delay_out = Delay_out_x;
	DelayUnit	Data_reg_3	(.Clk(Clk),
							.Reset(Reset),
							.Enable(Enable),
							.Data_in(Error_in),
							.Delay_out(Error_out)
							);
//assign E_out = Error_out[7:0];
endmodule

