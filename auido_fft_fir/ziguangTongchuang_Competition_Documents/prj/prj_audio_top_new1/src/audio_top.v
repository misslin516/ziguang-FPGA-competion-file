//created date: 2024/04/19
//version     : v1.0
//revised date:2024/07/11
//revised details:on the basis,intergate with LMS model,you can choose class num
`timescale 1ns/1ps
`define DDR3
`define PC
// `define PCIE    //In the stage of testing
`define HSST
// `define audio_recognization //The resource is not enough
module audio_top
#(
    parameter AUDIO_WIDTH             = 16                            ,
    parameter AUDIO_1slength          = 512                           ,
    parameter AUDIO_BASE_ADDR         = 'd1048576                     , //'h0x100000
 
    parameter MEM_ROW_ADDR_WIDTH      = 15                            ,
    parameter MEM_COL_ADDR_WIDTH      = 10                            ,
    parameter MEM_BADDR_WIDTH         = 3                             ,
    parameter MEM_DQ_WIDTH            = 32                            ,
    parameter MEM_DM_WIDTH            = MEM_DQ_WIDTH/8                ,
    parameter MEM_DQS_WIDTH           = MEM_DQ_WIDTH/8                ,
    parameter M_AXI_BRUST_LEN         = 8                             ,
    parameter RW_ADDR_MAX             = 20'd96000                     , //设置2s一帧    48000 *2 
    parameter RW_ADDR_MIN             = 20'd0                         ,
    parameter WR_BURST_LENGTH         = 4'd8                          , // 写突发长度                8个128bit的数据
    parameter Rr_BURST_LENGTH         = 4'd8                          ,
    parameter CTRL_ADDR_WIDTH         = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH
)
(
    //system io
    input              sys_clk              ,
    input              key                  ,    //按键复位    一直按才复位
    input              key1                 ,    //控制是否使用FIR   按一下
    input              key2                 ,    //控制向PC串口发送数据，并启动LMS 按一下
    input              key3                 ,    //控制PMOD端输出
    input   [3:0]      key4                 ,
    //audio io          
//ES7243E  ADC  in          
    output             es7243_scl           ,/*synthesis PAP_MARK_DEBUG="1"*///CCLK
    inout              es7243_sda           ,/*synthesis PAP_MARK_DEBUG="1"*///CDATA
    output             es0_mclk             ,/*synthesis PAP_MARK_DEBUG="1"*///MCLK  clk_12M
    input              es0_sdin             ,/*synthesis PAP_MARK_DEBUG="1"*///SDOUT i2s数据输入             i2s_sdin
    input              es0_dsclk            ,/*synthesis PAP_MARK_DEBUG="1"*///SCLK  i2s数据时钟             i2s_sck   
    input              es0_alrck            ,/*synthesis PAP_MARK_DEBUG="1"*///LRCK  i2s数据左右信道帧时钟     i2s_ws
//ES8156  DAC   out                         
    output             es8156_scl           ,/*synthesis PAP_MARK_DEBUG="1"*///CCLK
    inout              es8156_sda           ,/*synthesis PAP_MARK_DEBUG="1"*///CDATA 
    output             es1_mclk             ,/*synthesis PAP_MARK_DEBUG="1"*///MCLK  clk_12M
    input              es1_sdin             ,/*synthesis PAP_MARK_DEBUG="1"*///SDOUT 回放信号反馈？
    output             es1_sdout            ,/*synthesis PAP_MARK_DEBUG="1"*///SDIN  DAC i2s数据输出          i2s_sdout
    input              es1_dsclk            ,/*synthesis PAP_MARK_DEBUG="1"*///SCLK  i2s数据位时钟            i2s_sck
    input              es1_dlrc             ,/*synthesis PAP_MARK_DEBUG="1"*///LRCK  i2s数据左右信道帧时钟      i2s_ws
//     test         
    input              lin_test             ,//麦克风插入检测
    input              lout_test            ,//扬声器检测
    output             lin_led              ,
    output             lout_led             ,   
                
    output             adc_dac_int          ,
    
    //udp0 io                                        
    output wire        eth_rst_n_0          ,
    input  wire        eth_rgmii_rxc_0      ,
    input  wire        eth_rgmii_rx_ctl_0   ,
    input  wire [3:0]  eth_rgmii_rxd_0      ,
                                            
    output wire        eth_rgmii_txc_0      ,
    output wire        eth_rgmii_tx_ctl_0   ,
    output wire [3:0]  eth_rgmii_txd_0      ,
    
    //hdmi io
    output            iic_tx_scl            ,
    inout             iic_tx_sda            ,
    // output            led_int               ,       //通过LED检测配置是否完成
                                           
    output            vs_out                ,
    output            hs_out                ,
    output            de_out                ,
    output     [7:0]  r_out                 ,
    output     [7:0]  g_out                 ,
    output     [7:0]  b_out                 ,
    
    output            pix_clk               ,
    output            rstn_out              ,
    
   //udp1 io                                        
    output wire        eth_rst_n_1          ,
    input  wire        eth_rgmii_rxc_1      ,
    input  wire        eth_rgmii_rx_ctl_1   ,
    input  wire [3:0]  eth_rgmii_rxd_1      ,
                                            
    output wire        eth_rgmii_txc_1      ,
    output wire        eth_rgmii_tx_ctl_1   ,
    output wire [3:0]  eth_rgmii_txd_1      ,
    output      [2:0]      led              ,

//uart
    input              uart_rx              ,
    output             uart_tx              ,

//DDR
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
    output                                 ddr_init_done   
    
    //PCIE RST
    //input                                  pcie_perst_n
    
    


);



/********************************global para***************************************/
//网口0
parameter     BOARD_MAC_UDP0 =     48'h00_11_22_33_44_55    ;    //开发板MAC地址
parameter     BOARD_IP_UDP0  = {8'd192,8'd168,8'd1,8'd10}   ;    //开发板IP地址      
//PC or other FPGA                                           
parameter     DES_MAC_UDP0   = 48'h84_A9_38_BF_C9_A0        ;    //PC   MAC地址
parameter     DES_IP_UDP0    = {8'd192,8'd168,8'd1,8'd102}  ;    //目的 IP  地址

//网口1
parameter     BOARD_MAC_UDP1 =     48'ha0_b1_c2_d3_e1_e1    ;    //开发板MAC地址
parameter     BOARD_IP_UDP1  = {8'd192,8'd168,8'd1,8'd11}   ;    //开发板IP地址   
//PC or other FPGA                                               
parameter     DES_MAC_UDP1   = 48'h84_A9_38_BF_C9_A0        ;    //PC   MAC地址(wzk's MAC)
parameter     DES_IP_UDP1    = {8'd192,8'd168,8'd1,8'd102}  ;    //目的 IP  地址


/********************************local para***************************************/

localparam DQ_WIDTH =  MEM_DQ_WIDTH;
/********************************wire***************************************/
//audio para
wire             [15:0] adc_data            ;
wire             [15:0] dac_data            ;

wire                    es7243_init         ;
wire                    es8156_init         ;
wire                    data_valid_voice    ;
wire                    rx_l_vld            ;
wire                    rx_r_vld            ;
wire                    rx_r_vld_l          ;
wire                    rx_l_vld_l          ;
wire             [15:0] ldata               ;
wire             [15:0] rdata               ;
wire                    audio_clk           ;
//fir para
wire             [31:0] fir_out             ;
wire                    fir_valid           ;

// fft para
wire                    data_sop            ;
wire                    data_eop            ;
wire                    data_valid          ;
wire             [31:0] data_modulus        ;/*synthesis PAP_MARK_DEBUG="1"*/   //防止被优化
 
 //udp0 para
wire                    rgmii_clk0          ;

 //udp1 para
wire  [15:0] udp1_data            /* synthesis PAP_MARK_DEBUG="1" */       ;
wire         udp1_en               /* synthesis PAP_MARK_DEBUG="1" */      ;
wire rgmii_clk_1 /* synthesis PAP_MARK_DEBUG="1" */ ;


//key
wire                    key_en              ; 
wire                    key_flag1           ; 
wire                    key_flag2           ; 
wire                    key_flag3           ; 
//lms para
wire                [15:0] y_lms            ;
wire                flag_audio              ;
wire                flag_udp                ;
 
 
// para axim_top       
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
wire                                       fram0_done/* synthesis PAP_MARK_DEBUG="1" */;
wire [19:0]                              wr_addr_cnt0;
wire                                       ddr_ip_clk; 
wire                                     ddr_ip_rst_n; 
wire                                    rd_en        ;
wire                                   [31:0] rd_data;
      


//para PCIE
wire        pclk             ;
wire        pclk_div2        ;
wire        pcie_ref_clk     ;
wire        ref_clk_n        ;
wire        ref_clk_p        ;
wire        power_up_rst_n   ;
wire        perst_n          ;
wire        s_pclk_div2_rstn ;


wire   [3:0]    rxn          ;
wire   [3:0]    rxp          ;
wire   [3:0]    txn          ;
wire   [3:0]    txp          ;


wire            axis_master_tvalid;   
wire            axis_master_tready;   
wire   [127:0]  axis_master_tdata ; 
wire    [3:0]   axis_master_tkeep ;
wire            axis_master_tlast ; 
wire   [7:0]    axis_master_tuser ;  


wire            axis_slave0_tready;   
wire            axis_slave0_tvalid;   
wire   [127:0]  axis_slave0_tdata ; 
wire            axis_slave0_tlast ;
wire            axis_slave0_tuser ; 


   
wire           axis_slave1_tready;   
wire           axis_slave1_tvalid;   
wire   [127:0] axis_slave1_tdata ; 
wire           axis_slave1_tlast ;
wire           axis_slave1_tuser ; 


wire            axis_slave2_tready      ;
wire            axis_slave2_tvalid      ;
wire    [127:0] axis_slave2_tdata       ;
wire            axis_slave2_tlast       ;
wire            axis_slave2_tuser       ;

wire    [7:0]   cfg_pbus_num            ;
wire    [4:0]   cfg_pbus_dev_num        ;
wire    [2:0]   cfg_max_rd_req_size     ;
wire    [2:0]   cfg_max_payload_size    ;
wire            cfg_rcb                 ;
//system signal
wire    [4:0]   smlh_ltssm_state       /* synthesis PAP_MARK_DEBUG="1" */;
wire            core_rst_n             /* synthesis PAP_MARK_DEBUG="1" */;
wire            sync_button_rst_n      /* synthesis PAP_MARK_DEBUG="1" */;
wire            sync_perst_n           /* synthesis PAP_MARK_DEBUG="1" */;  
wire            smlh_link_up           /* synthesis PAP_MARK_DEBUG="1" */;
wire            rdlh_link_up           /* synthesis PAP_MARK_DEBUG="1" */; 

wire     [7:0]     udp_trans_data ; 
wire               udp_trans_valid;

wire               udp_trasn_start;
wire               udp_trasn_end  ;
// hsst
wire [1:0] o_wtchdg_st_0            ;
wire       o_pll_done_0             ;
wire       o_txlane_done_2          ;
wire       o_txlane_done_3          ;
wire       o_rxlane_done_2          ;
wire       o_rxlane_done_3          ;
wire       i_p_refckn_0             ;
wire       i_p_refckp_0             ;
wire       o_p_pll_lock_0           ;
wire       o_p_rx_sigdet_sta_2      ;
wire       o_p_rx_sigdet_sta_3      ;
wire       o_p_lx_cdr_align_2       ;
wire       o_p_lx_cdr_align_3       ;
wire       o_p_pcs_lsm_synced_2     ;
wire       o_p_pcs_lsm_synced_3     ;
wire       i_p_l2rxn                ;
wire       i_p_l2rxp                ;
wire       i_p_l3rxn                ;
wire       i_p_l3rxp                ;
wire       o_p_l2txn                ;
wire       o_p_l2txp                ;
wire       o_p_l3txn                ;
wire       o_p_l3txp                ;
wire    [2:0]   o_rxstatus_2        ;
wire    [2:0]   o_rxstatus_3        ;
wire    [3:0]   o_rdisper_2         ;
wire    [3:0]   o_rdecer_2          ;
wire    [3:0]   o_rdisper_3         ;
wire    [3:0]   o_rdecer_3          ;

wire    [3:0]   o_pl_err            ;
wire    [1:0]   tx_disable          ;


wire    [39:0]  o_rxd_2             ;
wire    [3:0]   o_rxk_2             ;
wire    [31:0]  hsst_data_v         ;
wire            hsst_dv             ;
wire            hsst_clk            ;
wire    key41;
wire    key42;
wire    key43;
wire    key44;
wire [3:0] compare_result;
wire    compare_result_v1;

/********************************reg***************************************/ 
reg            [2:0]                  rd_en_delay   ;  //需要延迟320ns,details see debug   
//uart para
reg                    cnt_keyen0            ; 
reg                    cnt_keyen1            ; 
reg                    cnt_keyen2            ; 
reg    key411;
reg    key422;
reg    key433;
reg    key444;
//********************************assign************************************/ 
assign fir_fft_valid = cnt_keyen0?fir_valid:data_valid_voice;


assign key_en = flag_audio;




//for test
assign led[0] = cnt_keyen0 || compare_result_v1;       //FIR输出标志信号（compare_result用于测试）
assign led[1] = cnt_keyen1;       //lms启动标志
assign led[2] = cnt_keyen2;       //1----输出LMS处理后的信号    0----FIR信号（sequence is key3-->key4）


//因为插入音频线，会一直有信号输出，所以可以不用延迟以下有效信号
assign rx_r_vld_l = rx_r_vld;
assign rx_l_vld_l = rx_l_vld;



assign dac_data = cnt_keyen0? fir_out[31:16]:cnt_keyen1?y_lms:adc_data;

assign rd_en = fram0_done?1'b1:1'b0;

assign axis_slave0_tvalid      = 'd0;
assign axis_slave0_tlast       = 'd0;
assign axis_slave0_tuser       = 'd0;
assign axis_slave0_tdata       = 'd0;
assign axis_slave1_tvalid      = 'd0;
assign axis_slave1_tlast       = 'd0;
assign axis_slave1_tuser       = 'd0;
assign axis_slave1_tdata       = 'd0;

assign hsst_data_v = (o_rxk_2 == 4'b0 && o_rxd_2 !=  40'hffffffffff)?o_rxd_2[31:0]:'d0;
assign hsst_dv     = (o_rxk_2 == 4'b0 && o_rxd_2 !=  40'hffffffffff)?1'b1:1'b0;
//********************************model inst************************************/ 
//inst key_filter
key_filter
#(
    .CNT_MAX    (20'd999_999) 
)
key_filter_inst0
(
    .sys_clk    (sys_clk    )  , 
    .sys_rst_n  (adc_dac_int)  , 
    .key_in     (key1       )  , 
   
    .key_flag   (key_flag1  )     
);

key_filter
#(
    .CNT_MAX    (20'd999_999) 
)
key_filter_inst1
(
    .sys_clk    (sys_clk    )  , 
    .sys_rst_n  (adc_dac_int)  , 
    .key_in     (key2       )  , 
   
    .key_flag   (key_flag2  )     
);

key_filter
#(
    .CNT_MAX    (20'd999_999) 
)
key_filter_inst2
(
    .sys_clk    (sys_clk    )  , 
    .sys_rst_n  (adc_dac_int)  , 
    .key_in     (key3       )  , 
   
    .key_flag   (key_flag3  )     
);


//
key_filter
#(
    .CNT_MAX    (20'd999_999) 
)
key_filter_inst3
(
    .sys_clk    (sys_clk    )  , 
    .sys_rst_n  (adc_dac_int)  , 
    .key_in     (key4[0]    )  , 
   
    .key_flag   (key41      )     
);

key_filter
#(
    .CNT_MAX    (20'd999_999) 
)
key_filter_inst4
(
    .sys_clk    (sys_clk    )  , 
    .sys_rst_n  (adc_dac_int)  , 
    .key_in     (key4[1]       )  , 
   
    .key_flag   (key42  )     
);

key_filter
#(
    .CNT_MAX    (20'd999_999) 
)
key_filter_inst5
(
    .sys_clk    (sys_clk    )  , 
    .sys_rst_n  (adc_dac_int)  , 
    .key_in     (key4[2]       )  , 
   
    .key_flag   (key43  )     
);

key_filter
#(
    .CNT_MAX    (20'd999_999) 
)
key_filter_inst6
(
    .sys_clk    (sys_clk    )  , 
    .sys_rst_n  (adc_dac_int)  , 
    .key_in     (key4[3]    )  , 
   
    .key_flag   (key44  )     
);


always@(posedge sys_clk)
    if(!adc_dac_int)
        cnt_keyen0 <= 1'b0;
    else if(key_flag1)
        cnt_keyen0 <= ~cnt_keyen0;
    else
        cnt_keyen0 <= cnt_keyen0;
        
always@(posedge sys_clk)
    if(!adc_dac_int)
        cnt_keyen1 <= 1'b0;
    else if(key_flag2)
        cnt_keyen1 <= ~cnt_keyen1;
    else
        cnt_keyen1 <= cnt_keyen1;        
        
always@(posedge sys_clk)
    if(!adc_dac_int)
        cnt_keyen2 <= 1'b0;
    else if(key_flag3)
        cnt_keyen2 <= ~cnt_keyen2;
    else
        cnt_keyen2 <= cnt_keyen2;

//
always@(posedge sys_clk)
    if(!adc_dac_int)
        key411 <= 1'b0;
    else if(key41)
        key411 <= ~key411;
    else
        key411 <= key411;

always@(posedge sys_clk)
    if(!adc_dac_int)
        key422 <= 1'b0;
    else if(key42)
        key422 <= ~key422;
    else
        key422 <= key422;

always@(posedge sys_clk)
    if(!adc_dac_int)
        key433 <= 1'b0;
    else if(key43)
        key433 <= ~key433;
    else
        key433 <= key433;

always@(posedge sys_clk)
    if(!adc_dac_int)
        key444 <= 1'b0;
    else if(key44)
        key444 <= ~key444;
    else
        key444 <= key444;





always@(posedge es0_dsclk) 
begin
    if(~adc_dac_int)
        rd_en_delay <= 'd0;
    else
        rd_en_delay <= {rd_en_delay[1:0],rd_en};
end               
      
//inst pmod
voice_loop voice_loop_test_inst
(
  .sys_clk     (sys_clk    )   ,
  .key         (key        )   ,
  .key_diff    ({key444,key433,key422,key411}),              
//ES7243E  ADC  in
  .es7243_scl  (es7243_scl )   ,
  .es7243_sda  (es7243_sda )   ,
  .es0_mclk    (es0_mclk   )   ,
  .es0_sdin    (es0_sdin   )   ,
  .es0_dsclk   (es0_dsclk  )   ,
  .es0_alrck   (es0_alrck  )   ,
//ES8156  DAC   out       
  .es8156_scl  (es8156_scl )   ,
  .es8156_sda  (es8156_sda )   ,
  .es1_mclk    (es1_mclk   )   ,
  .es1_sdin    (es1_sdin   )   ,
  .es1_sdout   (es1_sdout  )   ,
  .es1_dsclk   (es1_dsclk  )   ,
  .es1_dlrc    (es1_dlrc   )   ,
// test 
  .lin_test    (lin_test   )   ,
  .lout_test   (lout_test  )   ,
  .lin_led     (lin_led    )   ,
  .lout_led    (lout_led   )   ,   

  .adc_dac_int (adc_dac_int)   ,
    
    
   // data in and out
   .adc_data   (adc_data    ) ,
   .dac_data   (dac_data    ) ,
   .rx_l_vld   ( rx_l_vld   ) ,
   .rx_r_vld   ( rx_r_vld   ) ,
   .rx_r_vld_l (  rx_r_vld_l) ,
   .rx_l_vld_l (  rx_l_vld_l) ,
   .data_valid ( data_valid_voice ) ,
   .es7243_init (es7243_init),   //rx_rst
   .es8156_init (es8156_init),               //tx_rst
   .clk_12M(audio_clk),
   .ldata(ldata),
   .rdata(rdata),
   .rx_done()
);


//inst fir
fir_guide   fir_guide_inst
( 
   .rstn    (adc_dac_int        ),
   .clk     (es0_dsclk          ),  //es0_mclk = es1_mclk
   .en      (data_valid_voice   ), //or rx_r_vld_l
   .xin     (adc_data           ),
   .valid   (fir_valid          ),
   .yout    (fir_out            )    //31   [31:11]
);



//inst fft_top
fft_top fft_top_inst
(
   .clk_50m       (sys_clk     ) ,
   .rst_n         (adc_dac_int ) ,
 
   .audio_clk     (es0_dsclk   ) ,
   .audio_valid   (fir_fft_valid  ) ,
   .audio_data    ({8'b0,dac_data}) ,
 
   .data_sop      (data_sop    ) ,
   .data_eop      (data_eop    ) ,
   .data_valid    (data_valid  ) ,
   .data_modulus  (data_modulus) ,
   .o_alm         (            )     //led5,6,7
);



//inst for UDP
fifo_ctrl_eth u_fifo_ctrl_adc_eth
(
    .clk		(es0_dsclk		),
    .clk_eth	(rgmii_clk0	    ),
    .rst_n		(adc_dac_int    ),
    .rx_data	(adc_data	    ),	
    .rx_l_vld	(rx_l_vld	    ),
    .rx_r_vld	(rx_r_vld	    ),
    .data_out	(udp_trans_data ),	
    .vld		(udp_trans_valid),
    .start_rd   (udp_trasn_start),
    .ram_w_end  (udp_trasn_end  )
);

//inst UDP0
ethernet_test 
#(
    .LOCAL_MAC(BOARD_MAC_UDP0),
    .LOCAL_IP (BOARD_IP_UDP0 ),			//192.168.1.10
    .LOCL_PORT(16'hd80	     ),         //3456
    .DEST_IP  (DES_IP_UDP0   ),			//192.168.1.102
    .DEST_PORT(16'hd80       )          //3456
    )
ethernet_test_inst0
(
    .clk_50m		    (sys_clk		    ),
    .phy_rstn		    (eth_rst_n_1        ),
    .rst_n              (adc_dac_int        ),
                        
    .rgmii_rxc		    (eth_rgmii_rxc_1    ),
    .rgmii_rx_ctl	    (eth_rgmii_rx_ctl_1	),
    .rgmii_rxd		    (eth_rgmii_rxd_1	),
        
	.data_in_vld	    (udp_trans_valid	),
	.rd_data		    (udp_trans_data     ),
        
    .rgmii_txc		    (eth_rgmii_txc_1	),
    .rgmii_tx_ctl	    (eth_rgmii_tx_ctl_1	),
    .rgmii_txd          (eth_rgmii_txd_1    ),
	.rgmii_clk		    (rgmii_clk0         ),
	.start_rd		    (udp_trasn_start    ),
	.ram_w_end		    (udp_trasn_end      ),
    .udp_rec_data_valid (                   ),
    .udp_rec_rdata      (                   )   
);



//1.此处将 data_modulus的数据保存在RAM中 用于频谱数据HDMI显示
//2.fft_data的位宽为32，在频谱显示上可以进行适当处理后，保证最大幅度不超过hdmi的场有效范围
//3.同时采用抽帧的方式，缓解刷新率过快
//inst HDMI
hdmi_test1 hdmi_test1_inst
(
    .sys_clk     (sys_clk   )  ,// input system clock 50MHz 
    .rst_n       (adc_dac_int)  ,
    .rstn_out    (rstn_out  )  ,
    .iic_tx_scl  (iic_tx_scl)  ,
    .iic_tx_sda  (iic_tx_sda)  ,
   
    .fft_data    (data_modulus)     , 
    .fft_sop     (data_sop   )     , 
    .fft_eop     (data_eop   )     , 
    .fft_valid   (data_valid )     , 
    
    .audio_data  ( dac_data)    ,
    .audio_en    (  data_valid_voice )   ,
    .audio_clk   (es0_dsclk)    ,
    
    .pix_clk     (pix_clk   )  ,
    .led_int     (          )  ,

    .vs_out      (vs_out    )  , 
    .hs_out      (hs_out    )  , 
    .de_out      (de_out    )  ,
    .r_out       (r_out     )  , 
    .g_out       (g_out     )  , 
    .b_out       (b_out     )  
);






//inst UDP1
 udp_rec_top
#(
   .BOARD_MAC (BOARD_MAC_UDP1),
   .BOARD_IP  (BOARD_IP_UDP1 ),//192.168.1.11
                                                 
   .DES_MAC   (DES_MAC_UDP1  ),
   .DES_IP    (DES_IP_UDP1   )//192.168.1.102
)
udp_rec_top_inst
(
  .eth_rst_n_0       (eth_rst_n_0       )   ,
  .eth_rgmii_rxc_0   (eth_rgmii_rxc_0   )   ,
  .eth_rgmii_rx_ctl_0(eth_rgmii_rx_ctl_0)   ,
  .eth_rgmii_rxd_0   (eth_rgmii_rxd_0   )   ,
  
  .eth_rgmii_txc_0   (eth_rgmii_txc_0   )   ,
  .eth_rgmii_tx_ctl_0(eth_rgmii_tx_ctl_0)   ,
  .eth_rgmii_txd_0   (eth_rgmii_txd_0   )   ,
  
  .rgmii_clk_0       (rgmii_clk_1       )   ,
  .rst_n             (adc_dac_int       )   ,
 
  .rs_en1            (udp1_en           )   ,
  .rd_data           (udp1_data         )
   
);






//inst uart                    ------当PC接收到串口发送的udp.start.trans时，会自动发送音频数据文件
uart_top uart_top_inst
(

   .clk      (sys_clk ) ,
   .uart_rx  (uart_rx ) ,
   .key      (key_en  ) ,
   .uart_tx  (uart_tx )
);

`ifdef PC
    //inst lms
    lms_top
    #(
        .Step_size     (16'h000f) ,   //0.0073 *(2**11)  = 15
        .filter_class  (10       )     //class = 8,you can change it 
    )
    lms_top_inst
    (
        .sys_clk   (sys_clk                     ) ,
        .rst_n     (adc_dac_int &cnt_keyen2     ) ,
        
        .audio_clk (es0_dsclk                   ) ,
        .data_valid(data_valid_voice            ) ,
        .adc_data  (adc_data                    ) ,
                    
        .rgmii_clk (es0_dsclk                   ) ,
        .rec_en    (rd_en                       ) ,
        .rec_data  (rd_data                     ) , 
                
        .y_lms     (y_lms                       ) ,
        .flag_audio(flag_audio                  ) ,
        .flag_udp  (flag_udp                    )
    );


    //inst sequence AXI4 -- > DDR
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
        .audio_clk_out       (es0_dsclk                     )   ,
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
       
        //fifo0信号     -------- The input signal use PC ETH or another PH50H collection---------     
        .audio_clk_in        (rgmii_clk_1     )      ,
        .audio_de_in         (udp1_en         )  /* synthesis PAP_MARK_DEBUG="1" */,
        .audio_data_in       (udp1_data       )  /* synthesis PAP_MARK_DEBUG="1" */,
        .audio_rd_en         (rd_en_delay[2]  )      ,
        .audio_data_out      (rd_data         )  /* synthesis PAP_MARK_DEBUG="1" */,
     
        //其他             
        .wr_addr_min         (RW_ADDR_MIN     )   ,//写数据ddr最小地址0地址开始算
        .wr_addr_max         (RW_ADDR_MAX     )   ,
        .fram0_done          (fram0_done      )   ,
        .wr_addr_cnt0        (   wr_addr_cnt0 )
       );



    ipsxb_rst_sync_v1_1 u_core_clk_rst_sync(
        .clk                        (ddr_ip_clk     ),
        .rst_n                      (adc_dac_int    ),
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
       .resetn                 (adc_dac_int            ),  //复位
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
`endif

  
  
  
  
  
//inst PCIE,The core PCIE have some problem in my device,maybe it's the difference of version
/******************************PCIE**************************************/
`ifdef PCIE
    hsst_rst_cross_sync_v1_0 #(
        `ifdef IPSL_PCIE_SPEEDUP_SIM
        .RST_CNTR_VALUE     (16'h10             )
        `else
        .RST_CNTR_VALUE     (16'hC000           )
        `endif
    )
    u_refclk_buttonrstn_debounce(
        .clk                (pcie_ref_clk       ),
        .rstn_in            (adc_dac_int        ),
        .rstn_out           (sync_button_rst_n  )
    );

    hsst_rst_cross_sync_v1_0 #(
        `ifdef IPSL_PCIE_SPEEDUP_SIM
        .RST_CNTR_VALUE     (16'h10             )
        `else
        .RST_CNTR_VALUE     (16'hC000           )
        `endif
    )
    u_refclk_perstn_debounce(
        .clk                (pcie_ref_clk            ),
        .rstn_in            (pcie_perst_n            ),
        .rstn_out           (sync_perst_n       )
    );

    ipsl_pcie_sync_v1_0  u_ref_core_rstn_sync    (
        .clk                (pcie_ref_clk            ),
        .rst_n              (core_rst_n         ),
        .sig_async          (1'b1               ),
        .sig_synced         (ref_core_rst_n     )
    );

    ipsl_pcie_sync_v1_0  u_pclk_core_rstn_sync   (
        .clk                (pclk               ),
        .rst_n              (core_rst_n         ),
        .sig_async          (1'b1               ),
        .sig_synced         (s_pclk_rstn        )
    );

    ipsl_pcie_sync_v1_0  u_pclk_div2_core_rstn_sync   (
        .clk                (pclk_div2          ),
        .rst_n              (core_rst_n         ),
        .sig_async          (1'b1               ),
        .sig_synced         (s_pclk_div2_rstn   )
    );


//construct TLP header
    pcie_dma_ctrl pcie_dma_ctrl_inst
    (
        .clk              (pclk_div2           ) ,
        .audio_clk_out    (es0_dsclk           ) ,
        .rstn             (adc_dac_int         ) ,
        .axis_master_tvali(axis_master_tvalid  ) ,    
        .axis_master_tread(axis_master_tready  ) ,    
        .axis_master_tdata(axis_master_tdata   ) ,    
        .axis_master_tkeep(axis_master_tkeep   ) ,    
        .axis_master_tlast(axis_master_tlast   ) ,    
        .axis_master_tuser(axis_master_tuser   ) ,     

        .ep_bus_num       (cfg_pbus_num        ) ,
        .ep_dev_num       (cfg_pbus_dev_num    ) ,
      
        .AXIS_S_TREADY    (axis_slave2_tready  ) ,
        .AXIS_S_TVALID    (axis_slave2_tvalid  ) ,
        .AXIS_S_TDATA     (axis_slave2_tdata   ) ,
        .AXIS_S_TLAST     (axis_slave2_tlast   ) ,
        .AXIS_S_TUSER     (axis_slave2_tuser   ) ,
       
        .audio_data_in    (data_valid_voice    ) ,
        . de_in           ( adc_data           )  
          
       );                                    





    pcie_test1 pcie1_inst
    (
     //clk and rst
        .free_clk         (sys_clk          )  ,
        .pclk             (pclk             )  ,
        .pclk_div2        (pclk_div2        )  ,
        .ref_clk          (pcie_ref_clk     )  ,
        .ref_clk_n        (ref_clk_n        )  ,
        .ref_clk_p        (ref_clk_p        )  ,
        .button_rst_n     (sync_button_rst_n)  ,
        .power_up_rst_n   (sync_perst_n     )  ,
        .perst_n          (sync_perst_n     )  ,
        .core_rst_n       (core_rst_n       )  ,

        //APB interface to  DBI cfg
    //    input                           p_clk               ,
       .p_sel             (                 )  ,
       .p_strb            (                 )  ,
       .p_addr            (                 )  ,
       .p_wdata           (                 )  ,
       .p_ce              (                 )  ,
       .p_we              (                 )  ,
       .p_rdy             (                 )  ,
       .p_rdata           (                 )  ,

        //PHY diff signals

       .rxn               (rxn              ) ,
       .rxp               (rxp              ) ,
       .txn               (txn              ) ,
       .txp               (txp              ) ,
       .pcs_nearend_loop  ({2{1'b0}}        ) ,
       .pma_nearend_ploop ({2{1'b0}}        ) ,
       .pma_nearend_sloop ({2{1'b0}}        ) ,

        //AXIS master interface
        .axis_master_tvalid (axis_master_tvalid) ,
        .axis_master_tready (axis_master_tready) ,
        .axis_master_tdata  (axis_master_tdata ) ,
        .axis_master_tkeep  (axis_master_tkeep ) ,
        .axis_master_tlast  (axis_master_tlast ) ,
        .axis_master_tuser  (axis_master_tuser ) ,

        //axis slave 0 interface
        .axis_slave0_tready (axis_slave0_tready) ,
        .axis_slave0_tvalid (axis_slave0_tvalid) ,
        .axis_slave0_tdata  (axis_slave0_tdata ) ,
        .axis_slave0_tlast  (axis_slave0_tlast ) ,
        .axis_slave0_tuser  (axis_slave0_tuser ) ,

        //axis slave 1 interface
       .axis_slave1_tready  (axis_slave0_tready),
       .axis_slave1_tvalid  (axis_slave0_tvalid),
       .axis_slave1_tdata   (axis_slave0_tdata ),
       .axis_slave1_tlast   (axis_slave0_tlast ),
       .axis_slave1_tuser   (axis_slave0_tuser ),
        //axis slave 2 interface
       .axis_slave2_tready  (axis_slave2_tready),
       .axis_slave2_tvalid  (axis_slave2_tvalid),
       .axis_slave2_tdata   (axis_slave2_tdata ),
       .axis_slave2_tlast   (axis_slave2_tlast ),
       .axis_slave2_tuser   (axis_slave2_tuser ),
     
       .pm_xtlh_block_tlp   (                   ),     //ask about the processing latency
                        
       .cfg_send_cor_err_mux(                   ) ,
       .cfg_send_nf_err_mux (                   ) ,
       .cfg_send_f_err_mux  (                   ) ,
       .cfg_sys_err_rc      (                   ) ,
       .cfg_aer_rc_err_mux  (                   ) ,
                        
        //radm timeout                  
       .radm_cpl_timeout    (                   ) ,
                        
       .cfg_pbus_num        (   cfg_pbus_num    ) ,
       .cfg_pbus_dev_num    (   cfg_pbus_dev_num) ,

        //configuration signals
       .cfg_max_rd_req_size  (cfg_max_rd_req_size),
       .cfg_bus_master_en    (                    ),
       .cfg_max_payload_size (cfg_max_payload_size),
       .cfg_ext_tag_en       (                    ),
       .cfg_rcb              (cfg_rcb             ),
       .cfg_mem_space_en     (                    ),
       .cfg_pm_no_soft_rst   (                    ),
       .cfg_crs_sw_vis_en    (                    ),
       .cfg_no_snoop_en      (                    ),
       .cfg_relax_order_en   (                    ),
       .cfg_tph_req_en       (                    ),
       .cfg_pf_tph_st_mode   (                    ),
       .rbar_ctrl_update     (                    ),
       .cfg_atomic_req_en    (                    ),

        //debug signals
      .radm_idle                (                   ),
      .radm_q_not_empty         (                   ),
      .radm_qoverflow           (                   ),
      .diag_ctrl_bus            (2'b0               ),
      .cfg_link_auto_bw_mux     (                   ), //merge cfg_link_auto_bw_msi and cfg_link_auto_bw_int
      .cfg_bw_mgt_mux           (                   ), //merge cfg_bw_mgt_int and cfg_bw_mgt_msi
      .cfg_pme_mux              (                   ), //merge cfg_pme_int and cfg_pme_msi
      .app_ras_des_sd_hold_ltssm(1'b0               ),
      .app_ras_des_tba_ctrl     (2'b0               ),
                    
      .dyn_debug_info_sel       (4'b0               ),
      .debug_info_mux           (                   ),

        //system signal
      .smlh_link_up              (smlh_link_up    ),
      .rdlh_link_up              (rdlh_link_up    ),
      .smlh_ltssm_state          (smlh_ltssm_state)
    );
`endif







//NOTE:1.o_rxd_2 is valid when o_rxk_2 equals to 'd0,if o_rxk_2 equals to 0101,it represents o_rxd_2 = C5BCC5BC
//     2.when fifo is empty in hsst_test_dut_top,the payload is 40'hffffffffff
/***************************HSST************************************/
`ifdef HSST  
    hsst_test_dut_top  hsst_test_dut_top_inst
    (
    
        .i_free_clk            (sys_clk              )     ,
        .rst_n                 (adc_dac_int          )     ,
                                
        .o_wtchdg_st_0         (o_wtchdg_st_0        )     ,
        .o_pll_done_0          (o_pll_done_0         )     ,
        .o_txlane_done_2       (o_txlane_done_2      )     ,
        .o_txlane_done_3       (o_txlane_done_3      )     ,
        .o_rxlane_done_2       (o_rxlane_done_2      )     ,
        .o_rxlane_done_3       (o_rxlane_done_3      )     ,
        .i_p_refckn_0          (i_p_refckn_0         )     ,
        .i_p_refckp_0          (i_p_refckp_0         )     ,
        .o_p_pll_lock_0        (o_p_pll_lock_0       )     ,
        .o_p_rx_sigdet_sta_2   (o_p_rx_sigdet_sta_2  )     ,
        .o_p_rx_sigdet_sta_3   (o_p_rx_sigdet_sta_3  )     ,
        .o_p_lx_cdr_align_2    (o_p_lx_cdr_align_2   )     ,
        .o_p_lx_cdr_align_3    (o_p_lx_cdr_align_3   )     ,
        .o_p_pcs_lsm_synced_2  (o_p_pcs_lsm_synced_2 )     ,
        .o_p_pcs_lsm_synced_3  (o_p_pcs_lsm_synced_3 )     ,
        .i_p_l2rxn             (i_p_l2rxn            )     ,
        .i_p_l2rxp             (i_p_l2rxp            )     ,
        .i_p_l3rxn             (i_p_l3rxn            )     ,
        .i_p_l3rxp             (i_p_l3rxp            )     ,
        .o_p_l2txn             (o_p_l2txn            )     ,
        .o_p_l2txp             (o_p_l2txp            )     ,
        .o_p_l3txn             (o_p_l3txn            )     ,
        .o_p_l3txp             (o_p_l3txp            )     ,
        .o_rxstatus_2          (o_rxstatus_2         )     ,
        .o_rxstatus_3          (o_rxstatus_3         )     ,
        .o_rdisper_2           (o_rdisper_2          )     ,
        .o_rdecer_2            (o_rdecer_2           )     ,
        .o_rdisper_3           (o_rdisper_3          )     ,
        .o_rdecer_3            (o_rdecer_3           )     , 




        .o_pl_err              (o_pl_err             )    ,
        .tx_disable            (tx_disable           )    ,
    //user IO
        .data_clk              (es0_dsclk            )    ,
        .data_en               (data_valid_voice     )    ,
        .data_in               ({16'b0,adc_data}     )    ,
        .o_rxd_2               (o_rxd_2              )    ,          
        .o_rxk_2               (o_rxk_2              )    ,
        .o_p_clk2core_rx_2     (hsst_clk             )
);
`endif

/*********************Audio recognization**************************/



`ifdef audio_recognization
    auido_recognization_top
    #(
        .Dlength('d192)
    )
    auido_recognization_inst
    (
        .sys_clk          (rgmii_clk_1      ) ,
        .sys_rst_n        (adc_dac_int      ) ,
      
        .feature_in       (udp1_en          ) ,
        .feature_in_en    (udp1_data        ) ,
        
        .compare_result   (compare_result   ) ,
        .compare_result_v1(compare_result_v1)
    );
`endif



endmodule