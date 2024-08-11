`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    LMS_tap 
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
module LMS_tap(Clk,Reset,Enable,Data_in,Step_size,Delay_out,Tap_out);
	input	Clk,Reset,Enable;//ʱ�ӡ���λ�� ʹ�ܶ�
	input	signed [15:0] Data_in,Step_size;//�����źš�����u
	output	signed [15:0] Delay_out;//�����źŵĵ�λ��ʱ�ź�
	output  signed [31:0] Tap_out;//ģ��ز��ź�

	wire signed [15:0] Weight_in,Weight_out,Product_16;
    wire signed [31:0] Product_32;
/*��λ��ʱ����*/
	DelayUnit Delay_reg (.Clk(Clk),
						.Reset(Reset),
						.Enable(Enable),
						.Data_in(Data_in),
						.Delay_out(Delay_out)
						);

	assign Product_32 = Data_in * Step_size;
    assign Product_16 = Product_32[26:11];//�ض����ӣ��൱�ڸı�����u
    assign Weight_in = (Reset == 1'b0) ? 16'h0000 : (Product_16 + Weight_out);

	DelayUnit Data_reg  (.Clk(Clk),
						.Reset(Reset),
						.Enable(Enable),
						.Data_in(Weight_in),
						.Delay_out(Weight_out)
						);	

	assign Tap_out = Weight_out * Data_in;

endmodule

