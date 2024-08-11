//purpose : this code is for test ddr3
//created data:2024/06/03

`timescale 1ns/1ps
`define DDR3

module ddr3_test
#(
    parameter AUDIO_WIDTH             = 16                            ,
    parameter AUDIO_1slength          = 512                           ,
    parameter AUDIO_BASE_ADDR         = 'd1048576                     ,
 
    parameter MEM_ROW_ADDR_WIDTH      = 15                            ,
    parameter MEM_COL_ADDR_WIDTH      = 10                            ,
    parameter MEM_BADDR_WIDTH         = 3                             ,
    parameter MEM_DQ_WIDTH            = 32                            ,
    parameter MEM_DM_WIDTH            = MEM_DQ_WIDTH/8                ,
    parameter MEM_DQS_WIDTH           = MEM_DQ_WIDTH/8                ,
    parameter M_AXI_BRUST_LEN         = 8                             ,
    parameter RW_ADDR_MAX             = 20'd5120                      , //
    parameter RW_ADDR_MIN             = 20'd0                         ,
    parameter WR_BURST_LENGTH         = 4'd8                          , // 写突发长度                8个128bit的数据
    parameter Rr_BURST_LENGTH         = 4'd8                          ,
    parameter CTRL_ADDR_WIDTH         = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH
)
(

    input                                  sys_clk         ,   //50MHz
    input                                  sys_rst_n       ,
 
    output                                 mem_rst_n       ,                       
    output                                 mem_ck          ,
    output                                 mem_ck_n        ,
    output                                 mem_cke         ,
    output                                 mem_cs_n        ,
    output                                 mem_ras_n       ,
    output                                 mem_cas_n       ,
    output                                 mem_we_n        ,  
    output                                 mem_odt         ,
    output     [MEM_ROW_ADDR_WIDTH-1:0]    mem_a           ,   
    output     [MEM_BADDR_WIDTH-1:0]       mem_ba          ,   
    inout      [MEM_DQS_WIDTH-1:0]         mem_dqs         ,
    inout      [MEM_DQS_WIDTH-1:0]         mem_dqs_n       ,
    inout      [MEM_DQ_WIDTH-1:0]          mem_dq          ,
    output     [MEM_DM_WIDTH-1:0]          mem_dm          ,
    output                                 ddr_pll_lock    ,           
    output                                 ddr_init_done   ,

//test
    output         [2:0]                        led
    
  
);

//parameter
localparam DQ_WIDTH =  MEM_DQ_WIDTH;


 
// para axim_top       
//wire 
wire [3:0]                              M_AXI_AWID   ;
wire [CTRL_ADDR_WIDTH-1 : 0]            M_AXI_AWADDR  /* synthesis PAP_MARK_DEBUG="1" */;
wire                                    M_AXI_AWUSER ;
wire                                    M_AXI_AWVALID;
wire                                    M_AXI_AWREADY/* synthesis PAP_MARK_DEBUG="1" */;
wire [DQ_WIDTH*8-1 : 0]                 M_AXI_WDATA  /* synthesis PAP_MARK_DEBUG="1" */;
wire [DQ_WIDTH-1 : 0]                   M_AXI_WSTRB  ; 
wire                                    M_AXI_WLAST  ; 
wire  [3 : 0]                           M_AXI_WUSER  ; 
wire                                    M_AXI_WREADY /* synthesis PAP_MARK_DEBUG="1" */; 
wire [3 : 0]                            M_AXI_ARID   ;  
wire                                    M_AXI_ARUSER ; 
wire [CTRL_ADDR_WIDTH-1 : 0]            M_AXI_ARADDR  /* synthesis PAP_MARK_DEBUG="1" */;
wire                                    M_AXI_ARVALID ;
wire                                    M_AXI_ARREADY/* synthesis PAP_MARK_DEBUG="1" */;
wire  [3 : 0]                           M_AXI_RID    ; 
wire  [DQ_WIDTH*8-1 : 0]                M_AXI_RDATA  /* synthesis PAP_MARK_DEBUG="1" */;
wire                                    M_AXI_RLAST  ;
wire                                    M_AXI_RVALID  /* synthesis PAP_MARK_DEBUG="1" */ ;
wire [3 : 0]                            M_AXI_AWLEN  ;
wire [3 : 0]                            M_AXI_ARLEN  ;
wire                                    audio_rd_en  ;
wire [15:0]                            audio_data_out;
wire                                       fram0_done;
wire [19:0]                              wr_addr_cnt0;
wire                                       ddr_ip_clk;


//para data
//wire 
wire                                       wr_en     ;
wire    [15:0]                             wr_data   ;
wire                                       rd_en     ;
wire    [15:0]                             rd_data   ;
wire    [19:0]                             data_max  ;
wire                                       error_flag;
wire                                     ddr_ip_rst_n; 

assign data_max  = RW_ADDR_MAX - RW_ADDR_MIN;
assign led[2] = sys_rst_n;

ddr_data_inandout ddr_test_inst1
(
    .clk_50m       (sys_clk       ) ,   //时钟
    .rst_n         (sys_rst_n     ) ,   //复位,低有效
 
    .wr_en         (wr_en         ) ,   //写使能
    .wr_data       (wr_data       ) ,   //写数据
    .rd_en         (rd_en         ) ,   //读使能
    .rd_data       (rd_data       ) ,   //读数据
    .data_max      (data_max      ) ,   //写入ddr的最大数据量

    .ddr3_init_done(ddr_init_done ) ,   //ddr3初始化完成信号
    .error_flag    (error_flag    )    //ddr3读写错误
    );


 axi_m_top
#(
    .AUDIO_WIDTH     (AUDIO_WIDTH    )                           ,
    .AUDIO_1slength  (AUDIO_1slength )                           ,
  
	.CTRL_ADDR_WIDTH (CTRL_ADDR_WIDTH)                           ,
	.DQ_WIDTH	     (DQ_WIDTH	     )                           ,
    .M_AXI_BRUST_LEN (M_AXI_BRUST_LEN)                           ,
    .AUDIO_BASE_ADDR (AUDIO_BASE_ADDR)                           ,
    .WR_BURST_LENGTH (WR_BURST_LENGTH)                           , // 写突发长度                8个128bit的数据
    .Rr_BURST_LENGTH (Rr_BURST_LENGTH)
)
axi_m_top_inst
(
	.DDR_INIT_DONE       (ddr_init_done                 )   /* synthesis PAP_MARK_DEBUG="1" */,
	.M_AXI_ACLK          (ddr_ip_clk                    )   /* synthesis PAP_MARK_DEBUG="1" */,
	.M_AXI_ARESETN       (ddr_ip_rst_n &&  ddr_init_done)   /* synthesis PAP_MARK_DEBUG="1" */,
    .audio_clk_out       (sys_clk                       )   ,
	//写地址通道↓                                                     
	.M_AXI_AWID          (M_AXI_AWID      )   ,
	.M_AXI_AWADDR        (M_AXI_AWADDR    )   ,
    .M_AXI_AWLEN         (M_AXI_AWLEN     )   ,
  
	.M_AXI_AWUSER        (M_AXI_AWUSER    )   ,
	.M_AXI_AWVALID       (M_AXI_AWVALID   )   ,
	.M_AXI_AWREADY       (M_AXI_AWREADY   )   ,
	//写数据通道↓                                              
	.M_AXI_WDATA         (M_AXI_WDATA     )   ,
	.M_AXI_WSTRB         (M_AXI_WSTRB     )   ,
	.M_AXI_WLAST         (M_AXI_WLAST     )   ,
	.M_AXI_WUSER         (M_AXI_WUSER     )   ,
	.M_AXI_WREADY        (M_AXI_WREADY    )   ,
    
	//读地址通道↓                                               
	.M_AXI_ARID          (M_AXI_ARID      )   ,
    .M_AXI_ARUSER        (M_AXI_ARUSER    )   ,
	.M_AXI_ARADDR        (M_AXI_ARADDR    )   ,
  
	.M_AXI_ARVALID       (M_AXI_ARVALID   )   ,
	.M_AXI_ARREADY       (M_AXI_ARREADY   )   ,
    .M_AXI_ARLEN         (M_AXI_ARLEN     )   ,
	//读数据通道↓                                         
	.M_AXI_RID           (M_AXI_RID       )   ,
	.M_AXI_RDATA         (M_AXI_RDATA     )   ,
	.M_AXI_RLAST         (M_AXI_RLAST     )   ,
	.M_AXI_RVALID        (M_AXI_RVALID    )   ,
   
    //fifo0信号          
    .audio_clk_in        (sys_clk         )      ,
    .audio_de_in         (wr_en           )  /* synthesis PAP_MARK_DEBUG="1" */,
    .audio_data_in       (wr_data         )  /* synthesis PAP_MARK_DEBUG="1" */,
    .audio_rd_en         (rd_en           )      ,
    .audio_data_out      (rd_data         )  /* synthesis PAP_MARK_DEBUG="1" */,
 
    //其他             
    .wr_addr_min         (RW_ADDR_MIN     )   ,//写数据ddr最小地址0地址开始算
    .wr_addr_max         (RW_ADDR_MAX     )   ,
    .fram0_done          (fram0_done      )   ,
    .wr_addr_cnt0        (   wr_addr_cnt0 )
   );


ipsxb_rst_sync_v1_1 u_core_clk_rst_sync(
    .clk                        (ddr_ip_clk     ),
    .rst_n                      (sys_rst_n      ),
    .sig_async                  (1'b1           ),
    .sig_synced                 (ddr_ip_rst_n   )
); 
 
 
 
 ddr_test  #
  (
   //***************************************************************************
   // The following parameters are Memory Feature
   //***************************************************************************
   .MEM_ROW_WIDTH          (MEM_ROW_ADDR_WIDTH),     //行宽度    2**15 =  32768
   .MEM_COLUMN_WIDTH       (MEM_COL_ADDR_WIDTH),     //列宽度    2** 10 = 1024
   .MEM_BANK_WIDTH         (MEM_BADDR_WIDTH   ),     //bank宽度  2** 3 = 8
   .MEM_DQ_WIDTH           (MEM_DQ_WIDTH      ),     //数据宽度  32
   .MEM_DM_WIDTH           (MEM_DM_WIDTH      ),     
   .MEM_DQS_WIDTH          (MEM_DQS_WIDTH     ),     
   .CTRL_ADDR_WIDTH        (CTRL_ADDR_WIDTH   )     //地址宽度 = 2**(行宽度+列宽度+bank地址)
  )
  ddr_test_inst2(
   .ref_clk                (sys_clk                ),  //参考时钟
   .resetn                 (sys_rst_n              ),  //复位
   .ddr_init_done          (ddr_init_done          ),  //IP初始化完成
   .ddrphy_clkin           (ddr_ip_clk             ), 
   .pll_lock               (ddr_pll_lock           ), 
    //写地址                                          
   .axi_awaddr             (M_AXI_AWADDR           ), //AXI 写地址。
   .axi_awuser_ap          (M_AXI_AWUSER           ), //AXI 写并自动 precharge。
   .axi_awuser_id          (M_AXI_AWID             ), //AXI 写地址 ID
   .axi_awlen              (M_AXI_AWLEN            ), //AXI 写突发长度。
   .axi_awready            (M_AXI_AWREADY          ), //AXI 写地址 ready
   .axi_awvalid            (M_AXI_AWVALID          ), //AXI 写地址 valid。
    //写数据                                          
   .axi_wdata              (M_AXI_WDATA            ), //AXI 写数据
   .axi_wstrb              (M_AXI_WSTRB            ), //AXI 写数据 strobes
   .axi_wready             (M_AXI_WREADY           ), //AXI 写数据 ready。
   .axi_wusero_id          (M_AXI_WUSER            ), //AXI 写数据 ID。
   .axi_wusero_last        (M_AXI_WLAST            ), //AXI 写数据 last。
    //读地址                                          //
   .axi_araddr             (M_AXI_ARADDR           ), //AXI 读地址
   .axi_aruser_ap          (M_AXI_ARUSER           ), //AXI 读并自动 precharge。
   .axi_aruser_id          (M_AXI_ARID             ), //AXI 读地址 ID。
   .axi_arlen              (M_AXI_ARLEN            ), //AXI 读突发长度。
   .axi_arready            (M_AXI_ARREADY          ), //AXI 读地址 ready。
   .axi_arvalid            (M_AXI_ARVALID          ), //AXI 读地址 valid
    //读数据                                          //
   .axi_rdata              (M_AXI_RDATA            ), //AXI 读数据。
   .axi_rid                (M_AXI_RID              ), //AXI 读数据 ID。
   .axi_rlast              (M_AXI_RLAST            ), //AXI 读数据 last 信号。
   .axi_rvalid             (M_AXI_RVALID           ), //AXI 读数据 valid。

   .apb_clk                (1'b0                   ),  //APB 时钟
   .apb_rst_n              (1'b0                   ),  //APB 复位。
   .apb_sel                (1'b0                   ),  //APB 复位。
   .apb_enable             (1'b0                   ),  //APB 端口 enable。
   .apb_addr               (8'b0                   ),  //APB 地址总线。
   .apb_write              (1'b0                   ),  //APB 读写方向，高电平写，低电平读。
   .apb_ready              (                       ),  //APB 端口 Ready。
   .apb_wdata              (16'b0                  ),  //APB 写数据。
   .apb_rdata              (                       ),  //APB 读数据
   .apb_int                (                       ),  //
   .debug_data             (                       ),
   .debug_slice_state      (                       ),
   .debug_calib_ctrl       (                       ),
   .ck_dly_set_bin         (                       ),
   .force_ck_dly_en        (1'b0                   ),
   .force_ck_dly_set_bin   (8'h05                  ),
   .dll_step               (                       ),
   .dll_lock               (                       ),
   .init_read_clk_ctrl     (2'b0                   ),                                                       
   .init_slip_step         (4'b0                   ), 
   .force_read_clk_ctrl    (1'b0                   ),  
   .ddrphy_gate_update_en  (1'b0                   ),
   .update_com_val_err_flag(                       ),
   .rd_fake_stop           (1'b0                   ),
    //内存接口
   .mem_rst_n              (mem_rst_n              ),
   .mem_ck                 (mem_ck                 ),
   .mem_ck_n               (mem_ck_n               ),
   .mem_cke                (mem_cke                ),
   .mem_cs_n               (mem_cs_n               ),
   .mem_ras_n              (mem_ras_n              ),
   .mem_cas_n              (mem_cas_n              ),
   .mem_we_n               (mem_we_n               ),
   .mem_odt                (mem_odt                ),
   .mem_a                  (mem_a                  ),
   .mem_ba                 (mem_ba                 ),
   .mem_dqs                (mem_dqs                ),
   .mem_dqs_n              (mem_dqs_n              ),
   .mem_dq                 (mem_dq                 ),
   .mem_dm                 (mem_dm                 )
  );
  
  
 
 
 
led_disp led_disp_inst
 (
   .clk_50m          (sys_clk          ), //系统时钟
   .rst_n            (sys_rst_n        ), //系统复位
  
   .ddr3_init_done   (ddr_init_done    ), //ddr3初始化完成信号
   .error_flag       (error_flag       ), //错误标志信号
   .led_error        (led[0]           ), //读写错误led灯
   .led_ddr_init_done(led[1]           )  //ddr3初始化完成led灯             
);
 
 
 
endmodule
