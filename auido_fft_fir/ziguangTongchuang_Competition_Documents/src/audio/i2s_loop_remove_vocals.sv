`timescale 1ns/1ns
module i2s_loop_remove_vocals
#(
    parameter DATA_WIDTH = 16,
    parameter FILTER_ORDER = 30
)
(
    input                       sck,
    input                       rst_n,

    output reg [DATA_WIDTH - 1:0]  ldata,
    output reg [DATA_WIDTH - 1:0]  rdata,

    input   [DATA_WIDTH - 1:0]  data,
    input                       r_vld,
    input                       l_vld
);

parameter signed [15:0] b [0:FILTER_ORDER] = {
    -16'sd230,   // -0.00701 * 2^15
    -16'sd242,   // -0.00740 * 2^15
    -16'sd287,   // -0.00877 * 2^15
    -16'sd335,   // -0.01024 * 2^15
    -16'sd348,   // -0.01063 * 2^15
    -16'sd286,   // -0.00873 * 2^15
    -16'sd114,   // -0.00347 * 2^15
    16'sd191,   // 0.00581 * 2^15
    16'sd629,   // 0.01919 * 2^15
    16'sd1182,   // 0.03606 * 2^15
    16'sd1809,   // 0.05521 * 2^15
    16'sd2454,   // 0.07490 * 2^15
    16'sd3052,   // 0.09313 * 2^15
    16'sd3536,   // 0.10790 * 2^15
    16'sd3851,   // 0.11753 * 2^15
    16'sd3960,   // 0.12086 * 2^15
    16'sd3851,   // 0.11753 * 2^15
    16'sd3536,   // 0.10790 * 2^15
    16'sd3052,   // 0.09313 * 2^15
    16'sd2454,   // 0.07490 * 2^15
    16'sd1809,   // 0.05521 * 2^15
    16'sd1182,   // 0.03606 * 2^15
    16'sd629,   // 0.01919 * 2^15
    16'sd191,   // 0.00581 * 2^15
    -16'sd114,   // -0.00347 * 2^15
    -16'sd286,   // -0.00873 * 2^15
    -16'sd348,   // -0.01063 * 2^15
    -16'sd335,   // -0.01024 * 2^15
    -16'sd287,   // -0.00877 * 2^15
    -16'sd242,   // -0.00740 * 2^15
    -16'sd230   // -0.00701 * 2^15
};

reg signed [DATA_WIDTH - 1:0] x_left [0:FILTER_ORDER];  
reg signed [DATA_WIDTH - 1:0] x_right [0:FILTER_ORDER]; 

reg signed [31:0] acc_left;
reg signed [31:0] acc_right;

integer i;

reg  [5:0]                 cnt_2000k;
    always @(posedge sck or negedge rst_n)
    begin
    	if(~rst_n)
    	    cnt_2000k <= 6'h0;
    	else
    	begin
    		if(cnt_2000k == 6'd6)
    		    cnt_2000k <= 6'h0;
    		else
    		    cnt_2000k <= cnt_2000k + 1'b1;
    	end
    end


always @(posedge sck or negedge rst_n)
begin
    if(~rst_n)
    begin
        ldata <= {DATA_WIDTH{1'b0}};
        for (i = 0; i <= FILTER_ORDER; i = i + 1)
            x_left[i] <= {DATA_WIDTH{1'b0}};
    end
    else if(l_vld && cnt_2000k == 6'd6)
    begin

        for (i = FILTER_ORDER; i > 0; i = i - 1)
            x_left[i] <= x_left[i - 1];
        x_left[0] <= data;


        acc_left = 0;
        for (i = 0; i <= FILTER_ORDER; i = i + 1)
            acc_left = acc_left + x_left[i] * b[i];

        ldata <= acc_left[31:16]*3; 
end
     else
         ldata <=  ldata;
    
end


always @(posedge sck or negedge rst_n)
begin
    if(~rst_n)
    begin
        rdata <= {DATA_WIDTH{1'b0}};
        for (i = 0; i <= FILTER_ORDER; i = i + 1)
            x_right[i] <= {DATA_WIDTH{1'b0}};
    end
    else if(r_vld && cnt_2000k == 6'd6)
    begin

        for (i = FILTER_ORDER; i > 0; i = i - 1)
            x_right[i] <= x_right[i - 1];
        x_right[0] <= data;


        acc_right = 0;
        for (i = 0; i <= FILTER_ORDER; i = i + 1)
            acc_right = acc_right + x_right[i] * b[i];

        rdata <= acc_right[31:16]*3; 
end
     else
      rdata  <=  rdata;
    
end

endmodule // i2s_loop
