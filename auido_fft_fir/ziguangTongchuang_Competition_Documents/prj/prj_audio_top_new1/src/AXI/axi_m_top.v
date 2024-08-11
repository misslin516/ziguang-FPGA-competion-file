module axi_m_top
#(
    parameter integer AUDIO_WIDTH       = 16                              ,
    parameter integer AUDIO_1slength    = 375                             ,

	parameter integer CTRL_ADDR_WIDTH   = 28                              ,
	parameter integer DQ_WIDTH	        = 32                              ,
    parameter integer M_AXI_BRUST_LEN   = 8                               ,
    parameter integer AUDIO_BASE_ADDR   = 28'h0100000                     ,
    parameter integer WR_BURST_LENGTH   = 8'd8                            , // 写突发长度                64个128bit的数据
    parameter integer Rr_BURST_LENGTH   = 8'd8       
)
(
	input wire                                    DDR_INIT_DONE           /* synthesis PAP_MARK_DEBUG="1" */,
	input wire                                    M_AXI_ACLK              /* synthesis PAP_MARK_DEBUG="1" */,
	input wire                                    M_AXI_ARESETN           /* synthesis PAP_MARK_DEBUG="1" */,
    input wire                                    audio_clk_out           ,
	//写地址通道↓                                                              
	output wire [3 : 0]                           M_AXI_AWID              ,
	output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_AWADDR          /* synthesis PAP_MARK_DEBUG="1" */   ,
    output wire [3 : 0]                           M_AXI_AWLEN             ,
	output wire                                   M_AXI_AWUSER            ,
	output wire                                   M_AXI_AWVALID           ,
	input wire                                    M_AXI_AWREADY           ,
	//写数据通道↓                                                              
	output wire [DQ_WIDTH*8-1 : 0]                M_AXI_WDATA             ,
	output wire [DQ_WIDTH-1 : 0]                  M_AXI_WSTRB             ,
	input wire                                    M_AXI_WLAST             ,
	input wire  [3 : 0]                           M_AXI_WUSER             ,
	input wire                                    M_AXI_WREADY            ,
                                                             
	//读地址通道↓                                                              
	output wire [3 : 0]                           M_AXI_ARID              ,
    output wire                                   M_AXI_ARUSER            ,
	output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_ARADDR         /* synthesis PAP_MARK_DEBUG="1" */    ,

	output wire                                   M_AXI_ARVALID         /* synthesis PAP_MARK_DEBUG="1" */    ,
	input wire                                    M_AXI_ARREADY           ,
    output  wire [3 : 0]                          M_AXI_ARLEN             ,
        
	//读数据通道↓                                                              
	input wire  [3 : 0]                           M_AXI_RID               ,
	input wire  [DQ_WIDTH*8-1 : 0]                M_AXI_RDATA             ,
	input wire                                    M_AXI_RLAST             ,
	input wire                                    M_AXI_RVALID            ,
 
 
 
    //fifo0信号
    input wire                                    audio_clk_in             ,
    input wire                                    audio_de_in            /* synthesis PAP_MARK_DEBUG="1" */,
    input wire [31 : 0]                           audio_data_in          /* synthesis PAP_MARK_DEBUG="1" */,
    input wire                                    audio_rd_en            ,
    output wire [31 : 0]                          audio_data_out         /* synthesis PAP_MARK_DEBUG="1" */,

   
    //其他
    input       [19 : 0]                          wr_addr_min             ,//写数据ddr最小地址0地址开始算
    input       [19 : 0]                          wr_addr_max             ,//写数据ddr最大地址
    
    output                                        fram0_done               ,
    output      [19 : 0]                          wr_addr_cnt0
   );
//********************************wire**********************************


     
wire                               rfifo0_wr_req        /* synthesis PAP_MARK_DEBUG="1" */;
wire [10: 0]                       rfifo0_wr_water_level/* synthesis PAP_MARK_DEBUG="1" */;
wire [10: 0]                       wfifo0_rd_water_level/* synthesis PAP_MARK_DEBUG="1" */;
wire                               wfifo0_rd_req    /* synthesis PAP_MARK_DEBUG="1" */;
wire                               wfifo0_pre_rd_req/* synthesis PAP_MARK_DEBUG="1" */;
wire [3 : 0]                       wfifo0_state/* synthesis PAP_MARK_DEBUG="1" */;  
wire [3 : 0]                       rfifo0_state/* synthesis PAP_MARK_DEBUG="1" */;  




//********************************assign**********************************//
//固定输出的接口，各主机不需要单独再输出,这里只有一个设备进行写入，所以不考虑仲裁状态的改变
assign M_AXI_AWID       =   4'b1;
assign M_AXI_AWUSER     =   1'b0;
assign M_AXI_WSTRB	    =   {(DQ_WIDTH){1'b1}};//掩码信号，数据位宽/4 4位都为1 意味着全部的数据位有效
assign M_AXI_ARID       =   4'b1;//与写地址类似
assign M_AXI_ARUSER     =   1'b0;



wire [31:0] data_in;
wire [31:0] data_out;
assign data_in = audio_data_in;
assign audio_data_out = data_out;



//********************************例化**********************************//
//inst  axi_m
axi_m
#(
    .AUDIO_WIDTH       (AUDIO_WIDTH      )      ,
    .AUDIO_1slength    (AUDIO_1slength   )      ,
    .CTRL_ADDR_WIDTH   (CTRL_ADDR_WIDTH  )      ,
    .DQ_WIDTH	       (DQ_WIDTH	     )      ,
    .M_AXI_BRUST_LEN   (M_AXI_BRUST_LEN  )      ,
    .AUDIO_BASE_ADDR   (AUDIO_BASE_ADDR  )      

)
axi_m_inst
(

    .DDR_INIT_DONE       (DDR_INIT_DONE       )    ,
    .M_AXI_ACLK          (M_AXI_ACLK          )    ,
    .M_AXI_ARESETN       (M_AXI_ARESETN       )    ,
  
    .M_AXI_AWADDR        (M_AXI_AWADDR        )    ,
    .M_AXI_AWVALID       (M_AXI_AWVALID       )    ,
    .M_AXI_AWREADY       (M_AXI_AWREADY       )    ,
    .M_AXI_AWLEN         (M_AXI_AWLEN         )    ,
  
    .M_AXI_WLAST         (M_AXI_WLAST         )    ,
    .M_AXI_WREADY        (M_AXI_WREADY        )    ,
   
    .M_AXI_ARADDR        (M_AXI_ARADDR        )    ,
    .M_AXI_ARVALID       (M_AXI_ARVALID       )    ,
    .M_AXI_ARREADY       (M_AXI_ARREADY       )    ,
    .M_AXI_ARLEN         (M_AXI_ARLEN         )    ,
   
    .M_AXI_RLAST         (M_AXI_RLAST         )    ,
    .M_AXI_RVALID        (M_AXI_RVALID        )    ,
    
    .wfifo_rd_water_level(wfifo0_rd_water_level)    ,
    .wfifo_rd_req        (wfifo0_rd_req        )    /* synthesis PAP_MARK_DEBUG="1" */,
    .wfifo_pre_rd_req    (wfifo0_pre_rd_req    )    /* synthesis PAP_MARK_DEBUG="1" */,
    .rfifo_wr_water_level(rfifo0_wr_water_level)    ,
    .rfifo_wr_req        (rfifo0_wr_req        )    ,
    .r_fram_done         (fram0_done           )    ,
   
    .wr_addr_min         (wr_addr_min          )    ,//写数据ddr最小地址0地址从采集1s开始算，采集时长为1s:48000 *16 = 768000bits
    .wr_addr_max         (wr_addr_max          )    ,//写数据ddr最大地址，一个地址存32位 768000/32 = 24000
    .w_fifo_state        (wfifo0_state         )       /* synthesis PAP_MARK_DEBUG="1" */,
    .r_fifo_state        (rfifo0_state         )       /* synthesis PAP_MARK_DEBUG="1" */,
    .wr_addr_cnt         (wr_addr_cnt0         )       /* synthesis PAP_MARK_DEBUG="1" */
); 





//inst FIFO
rw_fifo_ctrl user_rw_fifo_ctrl0(
        .rstn                   (M_AXI_ARESETN                     ),//系统复位,DDR未初始化完成时保持复位状态
        .ddr_clk                (M_AXI_ACLK                        ),//写入内存的时钟（内存axi4接口时钟）
         //audio_wfifo_ddr                                         
        .wfifo_wr_clk           (audio_clk_in                      ),//wfifo写时钟
        .wfifo_wr_en            (audio_de_in                       ),//wfifo输入使能
        .wfifo_wr_data32_in     (data_in                           ),//wfifo输入数据,32bits
        .wfifo_rd_req           (wfifo0_rd_req                     ),//wfifo读请求，当数量大于突发长度时拉高
        .wfifo_rd_water_level   (wfifo0_rd_water_level             ),//wfifo读水位，当数量大于突发长度时开始传输
        .wfifo_rd_data256_out   (M_AXI_WDATA                       ),//wfifo读数据，256bits      
        //ddr_rfifo_audio
        .rfifo_rd_clk           (audio_clk_out                     ),//rfifo读时钟
        .rfifo_rd_en            (audio_rd_en                       ),//rfifo读出使能
        .rfifo_rd_data32_out    (data_out                          ),//rfifo输入数据,32bits
        .rfifo_wr_req           (rfifo0_wr_req                     ),//rfifo写请求，当数量大于突发长度时拉高
        .rfifo_wr_water_level   (rfifo0_wr_water_level             ),//rfifo写水位，当数量小于一行数据时开始传输
        .rfifo_wr_data256_in    (M_AXI_RDATA                       )//rfifo写数据，256bits    
   );






endmodule