`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:  
// Design Name:   LMS
// Module Name:   
// Project Name:  
// Target Device:  
// Tool versions:  
// Description: 
//
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module LMS_sim;

reg eachvec;
// test vector input registers
reg Clk;
//reg [15:0] Data_in;
//reg [15:0] Desired_in;
reg Enable;
reg Reset;
//reg [15:0] Step_size;
reg  [15:0] Data_in,Desired_in,Step_size,Sine_display;
	reg  [15:0] sine[0:999],noise[0:999];

// wires                                               
wire [15:0]  Delay_out_x;
wire [15:0]  Y_out;
//wire [7:0]  E_out;
wire [15:0]  Error_out;
parameter CYCLE = 10;
integer i;
                     
LMS i1 (
 
	.Clk(Clk),
	.Data_in(Data_in),
	.Delay_out_x(Delay_out_x),
	.Desired_in(Desired_in),
	//.E_out(E_out),
	.Enable(Enable),
	.Y_out(Y_out),
	.Error_out(Error_out),
	.Reset(Reset),
	.Step_size(Step_size)
);
always #(CYCLE/2) Clk = ~Clk;
	initial begin
		Clk = 1'b0;
		Reset = 1'b1;
		Enable = 1'b1;
		#(CYCLE) Reset = 1'b0;
		#(CYCLE) Reset = 1'b1;
	end
	always begin
		Step_size = 16'h000a; //Q11 S5.11 so u=0.0078  0.0078 *(2**11),À©´ó11±¶
		$readmemh("C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/fir_paral/sine.hex",sine);
		$readmemh("C:/Users/86151/Desktop/auido_fft_fir/ziguangTongchuang_Competition_Documents/src/fir_paral/noise.hex",noise);

		for(i=0;i<1000;i=i+1) begin
			#(CYCLE) Data_in = sine[i] ;  //x(n)
				  Sine_display = sine[i];
				  Desired_in = sine[i] + noise[i];  //d(n)  ²Î¿¼ÐÅºÅ
			  
				 
		end
		 $stop;
	end
                        
endmodule

