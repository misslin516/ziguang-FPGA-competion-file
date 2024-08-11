`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2023-01-29 20:31  
// Design Name:  
// Module Name: 
// Project Name: 
// Target Devices: Pango
// Tool Versions: 
// Description: 
//      
// Dependencies: 
// 
// Revision:
// Revision 1.0 - File Created
// Additional Comments:
// revised date: 2024/04/08
//////////////////////////////////////////////////////////////////////////////////
`define UD #0

module pattern_vg_revised # (
    parameter                            COCLOR_DEPP=8, // number of bits per channel
    parameter                            X_BITS=13,
    parameter                            Y_BITS=13,
    parameter                            H_ACT = 12'd1280,
    parameter                            V_ACT = 12'd720,
    parameter                            fft_point = 9'd256
)(                                       
    input                                rstn               , 
    input                                pix_clk            ,
    input [X_BITS-1:0]                   act_x              ,
    input [Y_BITS-1:0]                   act_y              ,
    input                                vs_in              , 
    input                                hs_in              , 
    input                                de_in              ,
    //fft interface
    input       [31:0]                   fft_data           ,    //should be scaled  
    output  reg                          data_req           ,
    output  reg  [9:0]                   RAM_address        ,
    output  reg                          en_flag            ,
            
    
    //hdmi output
    output reg                           vs_out             , 
    output reg                           hs_out             , 
    output reg                           de_out             ,
    output reg [COCLOR_DEPP-1:0]         r_out              , 
    output reg [COCLOR_DEPP-1:0]         g_out              , 
    output reg [COCLOR_DEPP-1:0]         b_out              
);
    parameter RED   = 24'hFF0000 ;  //红色
    parameter GREEN = 24'h00FF00 ;  //白色
    parameter BLUE  = 24'h0000FF ;  //白色
   

reg [7:0] red1   = 'd0;
reg [7:0] green1 = 'd0;
reg [7:0] blue1  = 'd0;
wire [31:0] fftdata;

    always @(posedge pix_clk)
    begin
        vs_out <= `UD vs_in;
        hs_out <= `UD hs_in;
        de_out <= `UD de_in;
    end
        
    always@(posedge pix_clk)
    begin
       if(act_y == V_ACT -1) begin
            if(de_in) begin
                data_req <= 1'b1;
                RAM_address <= act_x;
            end else
                data_req <= 1'b0;            
        end else
            data_req <= 1'b0;      
    end
    
    always@(posedge pix_clk)
    begin
        if(de_in) begin
            r_out <= red1  ;
            g_out <= green1;
            b_out <= blue1 ;
        end else begin
            r_out <= 8'd0;
            g_out <= 8'd0;
            b_out <= 8'd0;
        end
    end
    
    always@(posedge pix_clk)
    begin
        if(act_x == 256)
            green1 <= GREEN[15:8];
        else
            green1 <= 8'd0;
        
        if(act_x < 256) begin
            if(act_y < fftdata[31:5]) begin
                red1 <= RED[23:16];
                blue1 <= 8'd0;
            end else begin
                red1 <= 8'd0;
                blue1 <= BLUE[7:0];
            end
        end else begin
            if(act_y < fftdata[31:8]) begin
                red1 <= RED[23:16];
                blue1 <= 8'd0;
            end else begin
                red1 <= 8'd0;
                blue1 <= BLUE[7:0];
            end
        end
    end
 
always@(posedge pix_clk)
begin
    if(act_x >= 256)
        en_flag <= 1'b1;
    else
        en_flag <= 1'b0;
end

    dpram dpram
    (
        .data       (fft_data),
        .read_addr  (act_x),
        .write_addr (act_x),
        .we(data_req),
        .clk(pix_clk),
        .q(fftdata)
    );  
    
    
endmodule
