`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//revised by :NJUPT
//  puperpose: only for test
//////////////////////////////////////////////////////////////////////////////////

module tb_hdmi_test_revised();
    reg             sys_clk       ;// input system clock 50MHz    
    wire            rstn_out      ;
    wire            iic_tx_scl    ;
    wire            iic_tx_sda    ;
    //for data respository        
    reg   [31:0]    fft_data      ;
    reg             data_valid    ;
    
    wire            led_int       ;
//hdmi_out                      
    wire            pix_clk       ; //pixclk                           
    wire            vs_out        ; 
    wire            hs_out        ; 
    wire            de_out        ;
    wire     [7:0]  r_out         ; 
    wire     [7:0]  g_out         ; 
    wire     [7:0]  b_out         ;
    
    wire [23:0]      rgb          ;
    
    reg   rstn;
//clock  
initial begin
    sys_clk = 1'b0;
    rstn <= 1'b0;
    #60;
    rstn <= 1'b1;
   
end    
    
 always #10 sys_clk = ~sys_clk;   
 
 //cnt
 reg [8:0] cnt;
 
 always@(posedge sys_clk) begin
    if(~rstn)
        cnt <= 9'd0;
    else if(cnt == 256)
        cnt <= 9'd0;
    else
        cnt <= cnt + 1'b1;
 end
 
 
 always@(posedge sys_clk)  begin
    if(~rstn)
        fft_data <= 32'd0 ;
    else
        fft_data <=  cnt; 
 end

 
 
 
 always@(posedge sys_clk) begin
    if(~rstn)
       data_valid <= 1'b0;
    else if(cnt == 1)
       data_valid <= 1'b1;
    else if(cnt == 256)
       data_valid <= 1'b0;
    else
       data_valid <= data_valid;   
 end
 
    
hdmi_test_revised hdmi_test_revised_inst
(
    .sys_clk     (sys_clk   ) ,
    .rstn_out    (rstn_out  ) ,
    .iic_tx_scl  (iic_tx_scl) ,
    .iic_tx_sda  (iic_tx_sda) ,
 
    .fft_data    (fft_data  ) ,
    .data_valid  (data_valid) ,
   
    .led_int     (led_int   ) ,

    .pix_clk     (pix_clk   ) ,                  
    .vs_out      (vs_out    ) , 
    .hs_out      (hs_out    ) , 
    .de_out      (de_out    ) ,
    .r_out       (r_out     ) , 
    .g_out       (g_out     ) , 
    .b_out       (b_out     ) 

);    
    
assign rgb = {r_out,g_out,b_out} ;   
    
    

endmodule

