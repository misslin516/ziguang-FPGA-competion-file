`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
//created date:2024/04/09
//////////////////////////////////////////////////////////////////////////////////
`define DL #600
module tb_hdmi_test1();
   reg        sys_clk            ;
   reg        rst_n              ;
   wire            rstn_out      ;
   wire            iic_tx_scl    ;
   wire            iic_tx_sda    ;
                       
   reg       [31:0]fft_data      ;
   reg             fft_sop       ;
   reg             fft_eop       ;
   reg             fft_valid     ;
                            
                               
    wire            led_int    ;
                              
    wire            vs_out       ;
    wire            hs_out       ;
    wire            de_out       ;
    wire     [7:0]  r_out        ;
    wire     [7:0]  g_out        ;
    wire     [7:0]  b_out        ;
    wire            pix_clk     ;
    
    reg    [15:0]   audio_data       ;
    reg             audio_en         ;
   
   
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
    if(~rst_n) begin
        fft_valid <= 1'b0;
        audio_en <= 1'b0;
    end else if ((cnt == 9'd0) &&(fft_eop == 1)) begin
        fft_valid <= 1'b0;
        audio_en <= 1'b0;
    end else if(cnt == 9'd1)begin
        fft_valid <= 1'b1;
        audio_en <= 1'b1;
    end else begin
        fft_valid <= fft_valid; 
        audio_en <= audio_en;
    end
     
always@(posedge sys_clk or negedge rst_n)
    if(~rst_n)
        fft_eop <= 1'b0;
    else if(cnt % 9'd256 == 0) 
        fft_eop <= 1'b1;
    else
        fft_eop <= 1'b0;
    
always@(posedge sys_clk or negedge rst_n)
    if(~rst_n)
        fft_sop <= 1'b0;
    else if((cnt == 1) ||(cnt-1)%256 ==0)
        fft_sop <= 1'b1;
    else
        fft_sop <= 1'b0;



    
always@(posedge sys_clk or negedge rst_n)
    if(~rst_n) begin
        fft_data <= 32'd0;
        audio_data <= 16'd0;
    end else  begin
        fft_data <= cnt;
        audio_data <= cnt;
    end
       






hdmi_test1 hdmi_test1_inst
(
    .sys_clk    (sys_clk   )   ,// input system clock 50MHz 
    .rst_n      (rst_n     )   ,
    .rstn_out   (rstn_out  )   ,
    .iic_tx_scl (iic_tx_scl)   ,
    .iic_tx_sda (iic_tx_sda)   ,

    .fft_data   (fft_data  )      , 
    .fft_sop    (fft_sop   )      , 
    .fft_eop    (fft_eop   )      , 
    .fft_valid  (fft_valid )      , 
    
        
    .audio_data (audio_data) ,
    .audio_en   (audio_en ) ,

    .pix_clk    (pix_clk),
    .led_int    (led_int   )   ,                  
    .vs_out     (vs_out    )   , 
    .hs_out     (hs_out    )   , 
    .de_out     (de_out    )   ,
    .r_out      (r_out     )   , 
    .g_out      (g_out     )   , 
    .b_out      (b_out     )   

);



endmodule