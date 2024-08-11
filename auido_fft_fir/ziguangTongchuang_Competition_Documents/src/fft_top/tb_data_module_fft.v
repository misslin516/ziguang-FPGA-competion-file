`timescale 1ns/1ns



module  tb_data_module_fft();
    reg             clk_50m       ;
    reg             rst_n         ;
    
    reg   [31:0]    source_real   ;
    reg   [31:0]    source_imag   ;
    reg             source_sop    ;
    reg             source_eop    ;
    reg             source_valid  ;
    
    wire [31:0]     data_modulus  ;  
    wire            data_sop      ;
    wire            data_eop      ;
    wire            data_valid    ;



initial begin
   clk_50m = 1'b0;
   rst_n <= 1'b0;
   #40 rst_n <= 1'b1;
end

always #10 clk_50m = ~clk_50m;

reg [8:0] cnt;

always@(posedge clk_50m) begin
    if(~rst_n) begin
        cnt <= 9'd0;
    end else if(cnt == 9'd255) begin
        cnt <=  9'd0;
    end else  begin
        cnt <= cnt + 1'b1;
    end
end
        
always@(posedge clk_50m) begin
    if(~rst_n) begin
        source_real <= 31'd0;  
        source_imag <= 31'd0;
    end else if(cnt >= 9'd1) begin
        source_real <= cnt;
        source_imag <= cnt;
    end else begin
        source_real <= 31'd0;
        source_imag <= 31'd0;
    end
end

// module 250 number
always@(posedge clk_50m) begin
    if(~rst_n) begin 
        source_sop     <= 1'b0;
        source_eop     <= 1'b0;
        source_valid   <= 1'b0;
    end else if(cnt == 9'd1) begin
        source_sop     <= 1'b1;
        source_valid   <= 1'b1;
        source_eop     <= 1'b0;
    end else if(cnt == 9'd255) begin
        source_sop     <= 1'b0;
        source_valid   <= 1'b0;
        source_eop     <= 1'b1;
    end else begin
        source_sop     <= 1'b0;
        source_valid   <= source_valid;
        source_eop     <= 1'b0;
    end
end
       

data_module_fft data_module_fft_inst
(
    .clk_50m      (clk_50m      ),
    .rst_n        (rst_n        ),
    
    .source_real  (source_real  ),
    .source_imag  (source_imag  ),
    .source_sop   (source_sop   ),
    .source_eop   (source_eop   ),
    .source_valid (source_valid ),
    
    .data_modulus (data_modulus ),  
    .data_sop     (data_sop     ),
    .data_eop     (data_eop     ),
    .data_valid   (data_valid   )
);












endmodule