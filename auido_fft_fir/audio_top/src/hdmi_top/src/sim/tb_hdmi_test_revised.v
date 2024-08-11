`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//revised by :NJUPT
//  puperpose: only for test
//////////////////////////////////////////////////////////////////////////////////

module tb_hdmi_test_revised();
 
    wire        sys_clk              ;
    wire        rst_n                ;
    wire        cfg_clk              ;
    reg            rstn_out          ;
    reg            iic_tx_scl        ;
    reg            iic_tx_sda        ;
   
    //fft                            
    wire       [7:0] fft_point_cnt   ;
    wire       [31:0]fft_data        ;
    reg            fft_point_done    ;
    reg            data_req          ;
   
    reg            led_int           ;

   wire          pix_clk            ;      
   reg            vs_out             ;
   reg            hs_out             ;
   reg            de_out             ;
   reg     [7:0]  r_out              ;
   reg     [7:0]  g_out              ;
   reg     [7:0]  b_out              ;



//clock  
initial begin
    sys_clk = 1'b0;
    cfg_clk = 1'b0;
    pix_clk = 1'b0;
    rst_n <= 1'b0;
    #60;
    rst_n <= 1'b1;
   
end    
    
 
always #10 sys_clk = ~sys_clk;   

always #50 cfg_clk = ~cfg_clk;

always #3 pix_clk = ~pix_clk;
 
 //cnt
 reg [15:0] cnt;
always@(posedge sys_clk or negedge rst_n) begin
    if(~rst_n)
        cnt <= 9'd0;
    else
        cnt <= cnt + 1'b1;
 end
 
 
 always@(posedge sys_clk or negedge rst_n)  begin
    if(~rst_n)
        fft_data <= 32'd0 ;
    else
        fft_data <=  cnt; 
 end

 
 
 
always@(posedge sys_clk or negedge rst_n) begin
    if(~rst_n)
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
    .sys_clk        (sys_clk        )  ,
    .rst_n          (rst_n          )  ,
    .cfg_clk        (cfg_clk        )  ,
    .rstn_out       (rstn_out       )  ,
    .iic_tx_scl     (iic_tx_scl     )  ,
    .iic_tx_sda     (iic_tx_sda     )  ,
   
    .fft_point_cnt  (fft_point_cnt  )  , 
    .fft_data       (fft_data       )  , 
    .fft_point_done (fft_point_done )  , 
    .data_req       (data_req       )  , 
   
    .led_int        (led_int        )  ,

    .pix_clk        (pix_clk        )  ,                       
    .vs_out         (vs_out         )  , 
    .hs_out         (hs_out         )  , 
    .de_out         (de_out         )  ,
    .r_out          (r_out          )  , 
    .g_out          (g_out          )  , 
    .b_out          (b_out          )

);
  

endmodule

