//****************************************************************************************//
// Created date:        2025/05/08
// version     ：       v2.0    
//****************************************************************************************//

`timescale 1ns/1ns


module tb_audio_fft_top();
    reg         sys_clk               ;
    reg         rst_n                 ;
                                 

    wire         data_valid           ;
    wire         [31:0] data_modulus  ;


wire         data_sop             ;
wire         data_eop             ;
initial begin
    sys_clk = 1'b0;
    rst_n <= 1'b0;
    #40;
    rst_n <= 1'b1;
end

always #10 sys_clk = ~sys_clk;


audio_fft_top audio_fft_top_inst
(
    .sys_clk       (sys_clk       )         ,
    .rst_n         (rst_n         )         ,
  
    .data_sop      (data_sop      )         ,
    .data_eop      (data_eop      )         ,
    .data_valid    (data_valid    )         ,
    .data_modulus  (data_modulus  )  
);


endmodule

