`timescale 1ns/1ns

`define clk_cnt 20
`define DATAIN_WIDTH 16
`define DATAOUT_WIDTH 32

module tb_ipsxe_fft_core_only();
    reg                         i_aclk             ;
    reg
    reg                         i_axi4s_data_tvalid;
    reg  [DATAIN_WIDTH*2-1:0]   i_axi4s_data_tdata ;
    reg                         i_axi4s_data_tlast ;
   
    reg                         i_axi4s_cfg_tvalid ;
    reg                         i_axi4s_cfg_tdata  ;
    
    
    
    wire                        o_axi4s_data_tready;
    wire                        o_axi4s_data_tvalid;
    wire [DATAOUT_WIDTH*2-1:0]  o_axi4s_data_tdata ;
    wire                        o_axi4s_data_tlast ;
    wire [USER_WIDTH-1:0]       o_axi4s_data_tuser ;
    wire [2:0]                  o_alm              ;
    wire                        o_stat             ;





reg [8:0] cnt;
localparam cnt_max = 9'd255;


initial begin // clk
    i_aclk = 1'b0;  
    i_axi4s_data_tdata = 32'd1;  //this place we set the value 1 for easy test
end

initial begin // data and valid
    i_axi4s_data_tdata <= 32'd0; 
    i_axi4s_data_tvalid <= 1'b0;

    #50 i_axi4s_data_tdata <= 32'd1;
    #10 i_axi4s_data_tvalid <= 1'b1;
    if(cnt == 9'd254)  begin      //this place we dont kown whether it's sychro with data
        i_axi4s_data_tlast <= 1'b1;
    else
        i_axi4s_data_tlast <= 1'b0;
    end
end
 
 
    
    
always #(clk_cnt/2)   i_aclk = ~i_aclk;
  
  
  
  
initial begin // for config
    i_axi4s_cfg_tvalid <= 1'b1;  // FFTvalid
    i_axi4s_cfg_tdata <= 1'b1;  //for FFT set


end
  

    
 always@(posedge i_aclk) begin  
    if(~i_axi4s_data_tvalid)
        cnt <= 9'd0;
    else if(cnt == cnt_max)
        cnt <= 9'd0;
    else if(i_axi4s_data_tvalid)
        cnt <=  cnt + 1'b1;
    else
        cnt <=  cnt;
end
        


    
    
ipsxe_fft_core_only ipsxe_fft_core_only_inst
( 
   . i_aclk               ( i_aclk               ) ,
   
   . i_axi4s_data_tvalid  ( i_axi4s_data_tvalid  ) ,
   . i_axi4s_data_tdata_s ( i_axi4s_data_tdata_s ) ,
   . i_axi4s_data_tlast   ( i_axi4s_data_tlast   ) ,
   . o_axi4s_data_tready  ( o_axi4s_data_tready  ) ,
  
   . i_axi4s_cfg_tvalid   ( i_axi4s_cfg_tvalid   ) ,
   . i_axi4s_cfg_tdata    ( i_axi4s_cfg_tdata    ) ,
  
   . o_axi4s_data_tvalid  ( o_axi4s_data_tvalid  ) ,
   . o_axi4s_data_tdata_s ( o_axi4s_data_tdata_s ) ,
   . o_axi4s_data_tlast   ( o_axi4s_data_tlast   ) ,
   . o_axi4s_data_tuser_s ( o_axi4s_data_tuser_s ) ,
  
   . o_alm                ( o_alm                ) ,
   . o_stat               ( o_stat               )
);    
    



endmodule
