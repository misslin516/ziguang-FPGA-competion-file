`timescale 1ns/1ns

module ddr_sim();
   reg                                  sys_clk      ; 
                                             
   wire                                 mem_rst_n    ; 
   wire                                 mem_ck       ; 
   wire                                 mem_ck_n     ; 
   wire                                 mem_cke      ; 
   wire                                 mem_cs_n     ; 
   wire                                 mem_ras_n    ; 
   wire                                 mem_cas_n    ; 
   wire                                 mem_we_n     ; 
   wire                                 mem_odt      ; 
   wire     [MEM_ROW_ADDR_WIDTH-1:0]    mem_a        ; 
   wire     [MEM_BADDR_WIDTH-1:0]       mem_ba       ; 
   wire     [MEM_DQS_WIDTH-1:0]         mem_dqs      ; 
   wire     [MEM_DQS_WIDTH-1:0]         mem_dqs_n    ; 
   wire     [MEM_DQ_WIDTH-1:0]          mem_dq       ; 
   wire     [MEM_DM_WIDTH-1:0]          mem_dm       ; 
   wire                                 ddr_pll_lock ; 
   wire                                 ddr_init_done; 
  
   wire         [2:0]                        led     ;
    
    
parameter AUDIO_WIDTH             = 16                                                              ;
parameter AUDIO_1slength          = 375                                                             ;
parameter AUDIO_BASE_ADDR         = 0                                                               ;
                   
parameter MEM_ROW_ADDR_WIDTH      = 15                                                              ;
parameter MEM_COL_ADDR_WIDTH      = 10                                                              ;
parameter MEM_BADDR_WIDTH         = 3                                                               ;
parameter MEM_DQ_WIDTH            = 32                                                              ;
parameter MEM_DM_WIDTH            = MEM_DQ_WIDTH/8                                                  ;
parameter MEM_DQS_WIDTH           = MEM_DQ_WIDTH/8                                                  ;
parameter M_AXI_BRUST_LEN         = 8                                                               ;
parameter RW_ADDR_MAX             = 24'd5120                                                        ;
parameter RW_ADDR_MIN             = 24'd0                                                           ;
parameter WR_BURST_LENGTH         = 4'd8                                                            ;
parameter Rr_BURST_LENGTH         = 4'd8                                                            ;
parameter CTRL_ADDR_WIDTH         = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH       ;
    
    
    
initial begin
    sys_clk = 1'b0;
end    

always #10 sys_clk = ~sys_clk;
    
    
    
ddr3_test
#(
   .AUDIO_WIDTH         (AUDIO_WIDTH       ),
   .AUDIO_1slength      (AUDIO_1slength    ),
   .AUDIO_BASE_ADDR     (AUDIO_BASE_ADDR   ),
   .MEM_ROW_ADDR_WIDTH  (MEM_ROW_ADDR_WIDTH),
   .MEM_COL_ADDR_WIDTH  (MEM_COL_ADDR_WIDTH),
   .MEM_BADDR_WIDTH     (MEM_BADDR_WIDTH   ),
   .MEM_DQ_WIDTH        (MEM_DQ_WIDTH      ),
   .MEM_DM_WIDTH        (MEM_DM_WIDTH      ),
   .MEM_DQS_WIDTH       (MEM_DQS_WIDTH     ),
   .M_AXI_BRUST_LEN     (M_AXI_BRUST_LEN   ),
   .RW_ADDR_MAX         (RW_ADDR_MAX       ), //
   .RW_ADDR_MIN         (RW_ADDR_MIN       ),
   .WR_BURST_LENGTH     (WR_BURST_LENGTH   ), // 写突发长度                8个128bit的数据
   .Rr_BURST_LENGTH     (Rr_BURST_LENGTH   ),
   .CTRL_ADDR_WIDTH     (CTRL_ADDR_WIDTH   )
)
ddr3_test_inst
(

    .sys_clk        (sys_clk      ) ,   //50MHz

    .mem_rst_n      (mem_rst_n    ) ,                       
    .mem_ck         (mem_ck       ) ,
    .mem_ck_n       (mem_ck_n     ) ,
    .mem_cke        (mem_cke      ) ,
    .mem_cs_n       (mem_cs_n     ) ,
    .mem_ras_n      (mem_ras_n    ) ,
    .mem_cas_n      (mem_cas_n    ) ,
    .mem_we_n       (mem_we_n     ) ,  
    .mem_odt        (mem_odt      ) ,
    .mem_a          (mem_a        ) ,   
    .mem_ba         (mem_ba       ) ,   
    .mem_dqs        (mem_dqs      ) ,
    .mem_dqs_n      (mem_dqs_n    ) ,
    .mem_dq         (mem_dq       ) ,
    .mem_dm         (mem_dm       ) ,
    .ddr_pll_lock   (ddr_pll_lock ) ,           
    .ddr_init_done  (ddr_init_done) ,
   
    .led            (led          )

);
    
    
endmodule
