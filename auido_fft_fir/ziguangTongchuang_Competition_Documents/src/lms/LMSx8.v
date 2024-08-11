`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    LMSx8 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module LMSx8(Clk,Reset,Enable,Data_in,Step_size,Sum_in,Sum_out,Delay_out);
	input	Clk,Reset,Enable;
	input   signed [15:0] Data_in,Step_size;
	input   signed [31:0] Sum_in;
	output signed [15:0] Delay_out;
	output  signed [31:0] Sum_out;

	wire signed [15:0] LMS_tap_1_delay_out,LMS_tap_2_delay_out,LMS_tap_3_delay_out,
				       LMS_tap_4_delay_out,LMS_tap_5_delay_out,LMS_tap_6_delay_out,LMS_tap_7_delay_out,Delay_out;
	wire signed [31:0] LMS_tap_1_out,LMS_tap_2_out,LMS_tap_3_out,LMS_tap_4_out,
				       LMS_tap_5_out,LMS_tap_6_out,LMS_tap_7_out,LMS_tap_8_out;

	LMS_tap		LMS_tap_1	(.Clk(Clk),
							.Reset(Reset),
							.Enable(Enable),
							.Data_in(Data_in), 
							.Step_size(Step_size),
							.Delay_out(LMS_tap_1_delay_out),
							.Tap_out(LMS_tap_1_out)
							);

	LMS_tap		LMS_tap_2	(.Clk(Clk),
							.Reset(Reset),
							.Enable(Enable),
							.Data_in(LMS_tap_1_delay_out), 
							.Step_size(Step_size),
							.Delay_out(LMS_tap_2_delay_out),
							.Tap_out(LMS_tap_2_out)
							);
	LMS_tap		LMS_tap_3	(.Clk(Clk),
							.Reset(Reset),
							.Enable(Enable),
							.Data_in(LMS_tap_2_delay_out), 
							.Step_size(Step_size),
							.Delay_out(LMS_tap_3_delay_out),
							.Tap_out(LMS_tap_3_out)
							);
	LMS_tap		LMS_tap_4	(.Clk(Clk),
							.Reset(Reset),
							.Enable(Enable),
							.Data_in(LMS_tap_3_delay_out), 
							.Step_size(Step_size),
							.Delay_out(LMS_tap_4_delay_out),
							.Tap_out(LMS_tap_4_out)
							);
	LMS_tap		LMS_tap_5	(.Clk(Clk),
							.Reset(Reset),
							.Enable(Enable),
							.Data_in(LMS_tap_4_delay_out), 
							.Step_size(Step_size),
							.Delay_out(LMS_tap_5_delay_out),
							.Tap_out(LMS_tap_5_out)
							);
	LMS_tap		LMS_tap_6	(.Clk(Clk),
							.Reset(Reset),
							.Enable(Enable),
							.Data_in(LMS_tap_5_delay_out), 
							.Step_size(Step_size),
							.Delay_out(LMS_tap_6_delay_out),
							.Tap_out(LMS_tap_6_out)
							);
	LMS_tap		LMS_tap_7	(.Clk(Clk),
							.Reset(Reset),
							.Enable(Enable),
							.Data_in(LMS_tap_6_delay_out), 
							.Step_size(Step_size),
							.Delay_out(LMS_tap_7_delay_out),
							.Tap_out(LMS_tap_7_out)
							);
	LMS_tap		LMS_tap_8	(.Clk(Clk),
							.Reset(Reset),
							.Enable(Enable),
							.Data_in(LMS_tap_7_delay_out), 
							.Step_size(Step_size),
							.Tap_out(LMS_tap_8_out)
							);
							
  assign Delay_out = LMS_tap_7_delay_out;
	assign Sum_out = Sum_in + LMS_tap_1_out + LMS_tap_2_out +
					 LMS_tap_3_out + LMS_tap_4_out + LMS_tap_5_out +
					 LMS_tap_6_out + LMS_tap_7_out + LMS_tap_8_out;

endmodule


