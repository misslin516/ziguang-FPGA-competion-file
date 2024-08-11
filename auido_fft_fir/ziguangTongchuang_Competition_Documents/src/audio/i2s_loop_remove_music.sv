`timescale 1ns/1ns
module i2s_loop_remove_music
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
    16'sd120,   // 0.00368 * 2^15
    16'sd276,   // 0.00843 * 2^15
    16'sd466,   // 0.01423 * 2^15
    16'sd634,   // 0.01935 * 2^15
    16'sd637,   // 0.01943 * 2^15
    16'sd320,   // 0.00978 * 2^15
    -16'sd372,   // -0.01134 * 2^15
    -16'sd1320,   // -0.04027 * 2^15
    -16'sd2226,   // -0.06794 * 2^15
    -16'sd2710,   // -0.08269 * 2^15
    -16'sd2460,   // -0.07507 * 2^15
    -16'sd1390,   // -0.04242 * 2^15
    16'sd289,   // 0.00881 * 2^15
    16'sd2111,   // 0.06442 * 2^15
    16'sd3513,   // 0.10721 * 2^15
    16'sd4038,   // 0.12324 * 2^15
    16'sd3513,   // 0.10721 * 2^15
    16'sd2111,   // 0.06442 * 2^15
    16'sd289,   // 0.00881 * 2^15
    -16'sd1390,   // -0.04242 * 2^15
    -16'sd2460,   // -0.07507 * 2^15
    -16'sd2710,   // -0.08269 * 2^15
    -16'sd2226,   // -0.06794 * 2^15
    -16'sd1320,   // -0.04027 * 2^15
    -16'sd372,   // -0.01134 * 2^15
    16'sd320,   // 0.00978 * 2^15
    16'sd637,   // 0.01943 * 2^15
    16'sd634,   // 0.01935 * 2^15
    16'sd466,   // 0.01423 * 2^15
    16'sd276,   // 0.00843 * 2^15
    16'sd120   // 0.00368 * 2^15
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
