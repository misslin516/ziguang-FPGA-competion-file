module axi_m_top
#(
    parameter integer AUDIO_WIDTH       = 16                              ,
    parameter integer AUDIO_1slength    = 375                             ,

	parameter integer CTRL_ADDR_WIDTH   = 28                              ,
	parameter integer DQ_WIDTH	        = 32                              ,
    parameter integer M_AXI_BRUST_LEN   = 8                               ,
    parameter integer AUDIO_BASE_ADDR   = 28'h0100000                     ,
    parameter integer WR_BURST_LENGTH   = 8'd8                            , // дͻ������                64��128bit������
    parameter integer Rr_BURST_LENGTH   = 8'd8       
)
(
	input wire                                    DDR_INIT_DONE           /* synthesis PAP_MARK_DEBUG="1" */,
	input wire                                    M_AXI_ACLK              /* synthesis PAP_MARK_DEBUG="1" */,
	input wire                                    M_AXI_ARESETN           /* synthesis PAP_MARK_DEBUG="1" */,
    input wire                                    audio_clk_out           ,
	//д��ַͨ����                                                              
	output wire [3 : 0]                           M_AXI_AWID              ,
	output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_AWADDR          /* synthesis PAP_MARK_DEBUG="1" */   ,
    output wire [3 : 0]                           M_AXI_AWLEN             ,
	output wire                                   M_AXI_AWUSER            ,
	output wire                                   M_AXI_AWVALID           ,
	input wire                                    M_AXI_AWREADY           ,
	//д����ͨ����                                                              
	output wire [DQ_WIDTH*8-1 : 0]                M_AXI_WDATA             ,
	output wire [DQ_WIDTH-1 : 0]                  M_AXI_WSTRB             ,
	input wire                                    M_AXI_WLAST             ,
	input wire  [3 : 0]                           M_AXI_WUSER             ,
	input wire                                    M_AXI_WREADY            ,
                                                             
	//����ַͨ����                                                              
	output wire [3 : 0]                           M_AXI_ARID              ,
    output wire                                   M_AXI_ARUSER            ,
	output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_ARADDR         /* synthesis PAP_MARK_DEBUG="1" */    ,

	output wire                                   M_AXI_ARVALID         /* synthesis PAP_MARK_DEBUG="1" */    ,
	input wire                                    M_AXI_ARREADY           ,
    output  wire [3 : 0]                          M_AXI_ARLEN             ,
        
	//������ͨ����                                                              
	input wire  [3 : 0]                           M_AXI_RID               ,
	input wire  [DQ_WIDTH*8-1 : 0]                M_AXI_RDATA             ,
	input wire                                    M_AXI_RLAST             ,
	input wire                                    M_AXI_RVALID            ,
 
 
 
    //fifo0�ź�
    input wire                                    audio_clk_in             ,
    input wire                                    audio_de_in            /* synthesis PAP_MARK_DEBUG="1" */,
    input wire [31 : 0]                           audio_data_in          /* synthesis PAP_MARK_DEBUG="1" */,
    input wire                                    audio_rd_en            ,
    output wire [31 : 0]                          audio_data_out         /* synthesis PAP_MARK_DEBUG="1" */,

   
    //����
    input       [19 : 0]                          wr_addr_min             ,//д����ddr��С��ַ0��ַ��ʼ��
    input       [19 : 0]                          wr_addr_max             ,//д����ddr����ַ
    
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
//�̶�����Ľӿڣ�����������Ҫ���������,����ֻ��һ���豸����д�룬���Բ������ٲ�״̬�ĸı�
assign M_AXI_AWID       =   4'b1;
assign M_AXI_AWUSER     =   1'b0;
assign M_AXI_WSTRB	    =   {(DQ_WIDTH){1'b1}};//�����źţ�����λ��/4 4λ��Ϊ1 ��ζ��ȫ��������λ��Ч
assign M_AXI_ARID       =   4'b1;//��д��ַ����
assign M_AXI_ARUSER     =   1'b0;



wire [31:0] data_in;
wire [31:0] data_out;
assign data_in = audio_data_in;
assign audio_data_out = data_out;



//********************************����**********************************//
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
   
    .wr_addr_min         (wr_addr_min          )    ,//д����ddr��С��ַ0��ַ�Ӳɼ�1s��ʼ�㣬�ɼ�ʱ��Ϊ1s:48000 *16 = 768000bits
    .wr_addr_max         (wr_addr_max          )    ,//д����ddr����ַ��һ����ַ��32λ 768000/32 = 24000
    .w_fifo_state        (wfifo0_state         )       /* synthesis PAP_MARK_DEBUG="1" */,
    .r_fifo_state        (rfifo0_state         )       /* synthesis PAP_MARK_DEBUG="1" */,
    .wr_addr_cnt         (wr_addr_cnt0         )       /* synthesis PAP_MARK_DEBUG="1" */
); 





//inst FIFO
rw_fifo_ctrl user_rw_fifo_ctrl0(
        .rstn                   (M_AXI_ARESETN                     ),//ϵͳ��λ,DDRδ��ʼ�����ʱ���ָ�λ״̬
        .ddr_clk                (M_AXI_ACLK                        ),//д���ڴ��ʱ�ӣ��ڴ�axi4�ӿ�ʱ�ӣ�
         //audio_wfifo_ddr                                         
        .wfifo_wr_clk           (audio_clk_in                      ),//wfifoдʱ��
        .wfifo_wr_en            (audio_de_in                       ),//wfifo����ʹ��
        .wfifo_wr_data32_in     (data_in                           ),//wfifo��������,32bits
        .wfifo_rd_req           (wfifo0_rd_req                     ),//wfifo�����󣬵���������ͻ������ʱ����
        .wfifo_rd_water_level   (wfifo0_rd_water_level             ),//wfifo��ˮλ������������ͻ������ʱ��ʼ����
        .wfifo_rd_data256_out   (M_AXI_WDATA                       ),//wfifo�����ݣ�256bits      
        //ddr_rfifo_audio
        .rfifo_rd_clk           (audio_clk_out                     ),//rfifo��ʱ��
        .rfifo_rd_en            (audio_rd_en                       ),//rfifo����ʹ��
        .rfifo_rd_data32_out    (data_out                          ),//rfifo��������,32bits
        .rfifo_wr_req           (rfifo0_wr_req                     ),//rfifoд���󣬵���������ͻ������ʱ����
        .rfifo_wr_water_level   (rfifo0_wr_water_level             ),//rfifoдˮλ��������С��һ������ʱ��ʼ����
        .rfifo_wr_data256_in    (M_AXI_RDATA                       )//rfifoд���ݣ�256bits    
   );






endmodule