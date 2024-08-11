`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
//created by :NJUPT
//created data:2024/04/09
//////////////////////////////////////////////////////////////////////////////////
module tb_hdmi_top();
    reg         sys_clk      ;
    reg         rst_n        ;
    wire        rstn_out     ;
    wire        iic_tx_scl   ;
    wire        iic_tx_sda   ;
  
    reg   [31:0]fft_data     ;
    reg         fft_eop      ;
    reg         fft_valid    ;
   
    wire        led_int      ;
  
    wire        pix_clk      ;
    wire         vs_out      ;
    wire         hs_out      ;
    wire         de_out      ;
    wire  [7:0]  r_out       ;
    wire  [7:0]  g_out       ;
    wire  [7:0]  b_out       ;
    
initial begin
    sys_clk = 1'b0;
    rst_n <= 1'b0;
    #40;
    rst_n <= 1'b1;
end

always #10 sys_clk = ~sys_clk;


//data follow the datamodule timing sequence

reg [15:0] cnt;

always@(posedge sys_clk or negedge rst_n)
    if(~rst_n)
        cnt <= 9'd0;
    else
        cnt <= cnt + 1'b1;
        
always@(posedge sys_clk or negedge rst_n)
    if(~rst_n)
        fft_valid <= 1'b0;
    else if ((cnt == 9'd0) &&(fft_eop == 1))
        fft_valid <= 1'b0;
    else if(cnt == 9'd1)
        fft_valid <= 1'b1;
    else
        fft_valid <= fft_valid; 
     
always@(posedge sys_clk or negedge rst_n)
    if(~rst_n)
        fft_eop <= 1'b0;
    else if(cnt % 9'd256 == 0) 
        fft_eop <= 1'b1;
    else
        fft_eop <= 1'b0;
        
always@(posedge sys_clk or negedge rst_n)
    if(~rst_n)
        fft_data <= 32'd0;
    else 
        fft_data <= cnt;
        
//delay 20 clk
reg [639:0] data_reg;
reg [19:0] fft_eop_reg;
reg [19:0] fft_valid_reg;

always@(posedge sys_clk or negedge rst_n)    
begin
    if(~rst_n) begin
        data_reg <= 640'd0;
        fft_eop_reg <= 20'd0;
        fft_valid_reg <= 20'd0;
    end else begin
        data_reg <= {data_reg[607:0],fft_data};
        fft_eop_reg <= {fft_eop_reg[18:0],fft_eop};
        fft_valid_reg <={fft_valid_reg[18:0],fft_valid};
    end
end    

wire  [31:0] data_reg1;
wire  fft_eop_reg1;
wire  fft_valid_reg1;

assign  data_reg1 =  data_reg[639:608];
assign  fft_eop_reg1 =  fft_eop_reg[19];
assign  fft_valid_reg1 =  fft_valid_reg[19];

hdmi_top hdmi_top_inst
(
   .sys_clk    (sys_clk   ),  
   .rst_n      (rst_n     ),
   .rstn_out   (rstn_out  ),
   .iic_tx_scl (iic_tx_scl),
   .iic_tx_sda (iic_tx_sda),
  
   .fft_data   (data_reg1  ), 
   .fft_eop    (fft_eop_reg1   ), 
   .fft_valid  (fft_valid_reg1 ), 

   .led_int    (led_int   ),

   .pix_clk    (pix_clk   ),                          
   .vs_out     (vs_out    ), 
   .hs_out     (hs_out    ), 
   .de_out     (de_out    ),
   .r_out      (r_out     ), 
   .g_out      (g_out     ), 
   .b_out      (b_out     )
);








endmodule