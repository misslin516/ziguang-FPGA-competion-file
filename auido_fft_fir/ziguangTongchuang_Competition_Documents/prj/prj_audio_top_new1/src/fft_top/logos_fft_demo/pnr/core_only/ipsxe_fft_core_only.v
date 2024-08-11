
//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2022 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////

module ipsxe_fft_core_only ( 
    i_aclk                 ,

    
    i_axi4s_data_tvalid    ,
    i_axi4s_data_tdata_s   ,
    i_axi4s_data_tlast     ,
    o_axi4s_data_tready    ,
        
    i_axi4s_cfg_tvalid     ,
    i_axi4s_cfg_tdata      ,
    
    o_axi4s_data_tvalid    ,
    o_axi4s_data_tdata_s   ,
    o_axi4s_data_tlast     ,
    o_axi4s_data_tuser_s   ,
    
    o_alm                  ,
    o_stat
);


localparam  LOG2_FFT_LEN      = ("256" == "8"    ) ? 3  :
                                ("256" == "16"   ) ? 4  :  
                                ("256" == "32"   ) ? 5  :
                                ("256" == "64"   ) ? 6  :
                                ("256" == "128"  ) ? 7  :
                                ("256" == "256"  ) ? 8  :
                                ("256" == "512"  ) ? 9  :
                                ("256" == "1024" ) ? 10 :
                                ("256" == "2048" ) ? 11 :
                                ("256" == "4096" ) ? 12 :
                                ("256" == "8192" ) ? 13 :
                                ("256" == "16384") ? 14 :
                                ("256" == "32768") ? 15 :
                                                    16 ;

localparam  SCALE_MODE        = ("Unscaled" == "Block Floating Point") ? 1 : 0; 


localparam  INPUT_WIDTH       = 16;

localparam  DATAIN_BYTE_NUM   = ((INPUT_WIDTH%8)==0) ? INPUT_WIDTH/8 : INPUT_WIDTH/8 + 1;
localparam  DATAIN_WIDTH      = DATAIN_BYTE_NUM*8;

localparam  UNSCALED_WIDTH    = INPUT_WIDTH + LOG2_FFT_LEN + 1;
localparam  OUTPUT_WIDTH      = SCALE_MODE ? INPUT_WIDTH : UNSCALED_WIDTH;
localparam  DATAOUT_BYTE_NUM  = ((OUTPUT_WIDTH%8)==0) ? OUTPUT_WIDTH/8 : OUTPUT_WIDTH/8 + 1;
localparam  DATAOUT_WIDTH     = DATAOUT_BYTE_NUM * 8;
localparam  USER_BYTE_NUM     = ((LOG2_FFT_LEN%8)==0) ? LOG2_FFT_LEN/8 + 1: LOG2_FFT_LEN/8 + 2; // blk_exp and index
localparam  USER_WIDTH        = USER_BYTE_NUM * 8;

input                         i_aclk               ;

input                         i_axi4s_data_tvalid  ;
input                         i_axi4s_data_tdata_s ;
input                         i_axi4s_data_tlast   ;
output                        o_axi4s_data_tready  ;
input                         i_axi4s_cfg_tvalid   ;
input                         i_axi4s_cfg_tdata    ;
output                        o_axi4s_data_tvalid  ;
output                        o_axi4s_data_tdata_s ;
output                        o_axi4s_data_tlast   ;
output                        o_axi4s_data_tuser_s ;
output [2:0]                  o_alm                ;
output                        o_stat               ;
                                                   
reg    [DATAIN_WIDTH*2-1:0]   i_axi4s_data_tdata   ;
wire   [DATAOUT_WIDTH*2-1:0]  o_axi4s_data_tdata   ;
wire   [USER_WIDTH-1:0]       o_axi4s_data_tuser   ;


always @(posedge i_aclk) begin
   i_axi4s_data_tdata <= {i_axi4s_data_tdata[DATAIN_WIDTH*2-2:0], i_axi4s_data_tdata_s};
end
  
 
assign o_axi4s_data_tdata_s = |o_axi4s_data_tdata;
assign o_axi4s_data_tuser_s = |o_axi4s_data_tuser;    

fft_demo_00  u_fft_wrapper (
    .i_aclk                 (i_aclk              ),

    .i_axi4s_data_tvalid    (i_axi4s_data_tvalid ),
    .i_axi4s_data_tdata     (i_axi4s_data_tdata  ),
    .i_axi4s_data_tlast     (i_axi4s_data_tlast  ),
    .o_axi4s_data_tready    (o_axi4s_data_tready ),
    .i_axi4s_cfg_tvalid     (i_axi4s_cfg_tvalid  ),
    .i_axi4s_cfg_tdata      (i_axi4s_cfg_tdata   ),
    .o_axi4s_data_tvalid    (o_axi4s_data_tvalid ),
    .o_axi4s_data_tdata     (o_axi4s_data_tdata  ),
    .o_axi4s_data_tlast     (o_axi4s_data_tlast  ),
    .o_axi4s_data_tuser     (o_axi4s_data_tuser  ),
    .o_alm                  (o_alm               ),
    .o_stat                 (o_stat              )
);

endmodule
