
`timescale 1ns/1ns


module tb_audio_data_pkt();
    reg               rst_n          ;
 
    reg               audio_clk      ;
    reg               audio_en       ;
    reg [15:0]        audio_data     ;
  
    reg               transfer_flag  ;
   
    reg               eth_tx_clk     ;
    reg               udp_tx_req     ;
    reg               udp_tx_done    ;
    wire         udp_tx_start_en     ;
    wire  [31:0] udp_tx_data         ;
    wire  [15:0] udp_tx_byte_num     ;


initial begin
    audio_clk  = 1'b0;
    eth_tx_clk = 1'b0;
    rst_n <= 1'b0;
    #40;
    rst_n <= 1'b1;

end


always #50 audio_clk = ~audio_clk;

always #7  eth_tx_clk =~eth_tx_clk;

reg [15:0] cnt;

always@(posedge audio_clk or negedge rst_n)
begin
    if(~rst_n)
       cnt <= 1'b0;
    else
       cnt <= cnt + 1'b1;
end

always@(posedge audio_clk or negedge rst_n)
begin
    if(~rst_n)
        audio_en <= 1'b0;
    else if(cnt == 'd2)
        audio_en <= 1'b1;
    else
        audio_en <= audio_en;
end

always@(posedge audio_clk or negedge rst_n)
begin
    if(~rst_n)
        audio_data <= 16'd0;
    else
        audio_data <= cnt;
end

always@(posedge audio_clk or negedge rst_n)
begin
    if(~rst_n)
        transfer_flag <= 1'd0;
    else
        transfer_flag <= 1'b1;
end


always@(posedge eth_tx_clk or negedge rst_n)
begin
    if(~rst_n) 
        udp_tx_req <= 1'b0;
    else if((audio_data == 'd560)||(audio_data == 'd900))
        udp_tx_req <= 1'b1;
    else
        udp_tx_req <= udp_tx_req;
  
end




    
always@(posedge eth_tx_clk or negedge rst_n)
begin
    if(~rst_n) 
        udp_tx_done <= 1'b0;
    else if(audio_data == 'd2300)
        udp_tx_done <= 1'b1;
    else
        udp_tx_done <= 1'b0;
end    

audio_data_pkt2 audio_data_pkt_inst
(
    .rst_n          (rst_n          ),
  
    .audio_clk      (audio_clk      ),
    .audio_en       (audio_en       ),
    .audio_data     (audio_data     ),

    .transfer_flag  (transfer_flag  ),  
  
    .eth_tx_clk     (eth_tx_clk     ),   
    .udp_tx_req     (udp_tx_req     ),   
    .udp_tx_done    (udp_tx_done    ),          
    .udp_tx_start_en(udp_tx_start_en),   
    .udp_tx_data    (udp_tx_data    ),   
    .udp_tx_byte_num(udp_tx_byte_num)    
);


endmodule

