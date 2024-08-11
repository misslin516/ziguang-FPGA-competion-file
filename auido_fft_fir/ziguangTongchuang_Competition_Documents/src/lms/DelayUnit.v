`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    DelayUnit 
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
module DelayUnit(Clk,Reset,Enable,Data_in,Delay_out);
	input	Clk,Reset,Enable;
	input	[15:0] Data_in;
	output	[15:0] Delay_out;

	reg[15:0] Delay_out;

	always @(posedge Clk or negedge Reset)
	 begin
		if (Reset ==0) begin
			Delay_out <= 0;
		end
		else begin
			if (Enable == 1'b1) begin
				Delay_out <= Data_in;
			end
		end
	end

endmodule
