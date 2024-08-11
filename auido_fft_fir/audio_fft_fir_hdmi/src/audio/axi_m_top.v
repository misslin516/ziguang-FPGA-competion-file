module axi_m_top 
#(
    parameter integer AUDIO_LENGTH      = 4000                            ,
    parameter integer AUDIO_WIDTH       = 16                              ,
	parameter integer CTRL_ADDR_WIDTH   = 28                              ,
	parameter integer DQ_WIDTH	       = 32                               ,
    parameter integer M_AXI_BRUST_LEN   = 8
)
(
	input wire                                    DDR_INIT_DONE           /* synthesis PAP_MARK_DEBUG="1" */,
	input wire                                    M_AXI_ACLK              /* synthesis PAP_MARK_DEBUG="1" */,
	input wire                                    M_AXI_ARESETN           /* synthesis PAP_MARK_DEBUG="1" */,
    input wire                                    audio_clk_out           ,
	//д��ַͨ����                                                              
	output wire [3 : 0]                           M_AXI_AWID              ,
	output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_AWADDR            ,
//	output wire [3 : 0]                           M_AXI_AWLEN             ,
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
	output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_ARADDR            ,
//	output wire [3 : 0]                           M_AXI_ARLEN             ,
	output wire                                   M_AXI_ARVALID           ,
	input wire                                    M_AXI_ARREADY           ,
	//������ͨ����                                                              
	input wire  [3 : 0]                           M_AXI_RID               ,
	input wire  [DQ_WIDTH*8-1 : 0]                M_AXI_RDATA             ,
	input wire                                    M_AXI_RLAST             ,
	input wire                                    M_AXI_RVALID            ,
    //audio
    input wire                                    audio_en                ,
    input wire              [15:0]                audio_data              ,
    
    //fifo�ź�
    input wire                                    audio_rd_en             ,
    output wire [15 : 0]                          aduio_data_out         /* synthesis PAP_MARK_DEBUG="1" */,
    output wire                                   fram_done              ,
    
 
    //other signal
    input       [19 : 0]                          wr_addr_min             ,//д����ddr��С��ַ0��ַ��ʼ�㣬1920*1080*16 = 33177600 bits
    input       [19 : 0]                          wr_addr_max             //д����ddr����ַ��һ����ַ��32λ 33177600/32 = 1036800 = 20'b1111_1101_0010_0000_0000
        
   );
//********************************parameter**********************************//
parameter    READ_ARBITRATION = 3'd0;

//********************************wire**********************************//
wire [255 : 0]                     M0_AXI_WDATA      /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_AWVALID    /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_AWREADY    /* synthesis PAP_MARK_DEBUG="1" */;
wire [CTRL_ADDR_WIDTH-1 : 0]       M0_AXI_AWADDR     /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_WLAST      /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_WREADY     /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_ARVALID    /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_ARREADY    /* synthesis PAP_MARK_DEBUG="1" */;
wire [CTRL_ADDR_WIDTH-1 : 0]       M0_AXI_ARADDR     /* synthesis PAP_MARK_DEBUG="1" */;
wire [255 : 0]                     M0_AXI_RDATA      /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_RLAST      /* synthesis PAP_MARK_DEBUG="1" */;
wire                               M0_AXI_RVALID     /* synthesis PAP_MARK_DEBUG="1" */;


     
wire                               rfifo0_wr_req        /* synthesis PAP_MARK_DEBUG="1" */;
wire [8 : 0]                       rfifo0_wr_water_level/* synthesis PAP_MARK_DEBUG="1" */;


wire [8 : 0]                       wfifo0_rd_water_level/* synthesis PAP_MARK_DEBUG="1" */;

wire                               wfifo0_rd_req    /* synthesis PAP_MARK_DEBUG="1" */;
wire                               wfifo0_pre_rd_req/* synthesis PAP_MARK_DEBUG="1" */;


wire [1 : 0]                       wfifo0_state/* synthesis PAP_MARK_DEBUG="1" */;  



wire [1 : 0]                       rfifo0_state/* synthesis PAP_MARK_DEBUG="1" */;  

wire                               wr_rst           /* synthesis PAP_MARK_DEBUG="1" */;
wire                               rd_rst           /* synthesis PAP_MARK_DEBUG="1" */;
wire [19 : 0]                      wr_addr_cnt0    /* synthesis PAP_MARK_DEBUG="1" */;

//********************************reg**********************************//
reg [4 : 0]                           arbitration_wr_state/* synthesis PAP_MARK_DEBUG="1" */;
reg [2 : 0]                           arbitration_rd_state/* synthesis PAP_MARK_DEBUG="1" */;
reg                                   rfifo_pre_write_init/* synthesis PAP_MARK_DEBUG="1" */;
reg [11 : 0]                          r_y_act_d0/* synthesis PAP_MARK_DEBUG="1" */;    
reg [11 : 0]                          r_x_act_d0/* synthesis PAP_MARK_DEBUG="1" */;    
reg                                   r_video0_rd_en_d0/* synthesis PAP_MARK_DEBUG="1" */;
reg                                   r_video1_rd_en_d0/* synthesis PAP_MARK_DEBUG="1" */;
reg                                   r_video2_rd_en_d0/* synthesis PAP_MARK_DEBUG="1" */;
reg                                   r_video3_rd_en_d0/* synthesis PAP_MARK_DEBUG="1" */;
//********************************assign**********************************//
//�̶�����Ľӿڣ�����������Ҫ���������
assign M_AXI_AWID       =   4'b0;
assign M_AXI_AWUSER     =   1'b0;
assign M_AXI_WSTRB	     =   {(DQ_WIDTH){1'b1}};//������źţ�����λ��/4 4λ��Ϊ1
assign M_AXI_ARID       =   4'b0;//��д��ַ����
assign M_AXI_ARUSER     =   1'b0;
//�ٲ�����������Ŀ����ź�
assign M_AXI_AWVALID = M0_AXI_AWVALID ;
assign M_AXI_AWADDR  = M0_AXI_AWADDR  ;
assign M_AXI_ARVALID = M0_AXI_ARVALID ;
assign M_AXI_ARADDR  = M0_AXI_ARADDR  ;
//�ٲ������ӻ��������ź�ת��������0
assign M0_AXI_AWREADY = M_AXI_AWREADY ;
assign M0_AXI_WLAST   = M_AXI_WLAST   ;
assign M0_AXI_WREADY  = M_AXI_WREADY  ;
assign M0_AXI_ARREADY = M_AXI_ARREADY ;
assign M0_AXI_RLAST   = M_AXI_RLAST   ;
assign M0_AXI_RVALID  = M_AXI_RVALID  ;

//�������
assign M_AXI_WDATA    = M0_AXI_WDATA;//дFIFO������ݸ�DDR
//��������
assign M0_AXI_RDATA   = M_AXI_RDATA;

//********************************always**********************************//
//��AXI������FIFO���и�λ
always @(posedge M_AXI_ACLK ) begin
    if(!M_AXI_ARESETN) begin
        r_video0_rd_en_d0 <= 'd0;
    end
    else begin
        r_video0_rd_en_d0 <= video0_rd_en;
    end
end

//********************************����**********************************//
//����AXI_FULL_M
AXI_FULL_M #(
        .VIDEO_LENGTH     (ZOOM_VIDEO_LENGTH)    ,
        .VIDEO_HIGTH      (ZOOM_VIDEO_HIGTH )    ,
        .PIXEL_WIDTH      (PIXEL_WIDTH      )    ,
        .CTRL_ADDR_WIDTH  (CTRL_ADDR_WIDTH  )    ,
        .DQ_WIDTH	      (DQ_WIDTH         )    ,
        .M_AXI_BRUST_LEN  (M_AXI_BRUST_LEN  )    ,
        .VIDEO_BASE_ADDR  (VIDEO0_BASE_ADDR )     
)
u_axi_full_m0
    (
		.DDR_INIT_DONE       (DDR_INIT_DONE  )                 ,//input wire  
		.M_AXI_ACLK          (M_AXI_ACLK     )                 ,//input wire  
		.M_AXI_ARESETN       (M_AXI_ARESETN)     ,//input wire  
		//д��ַͨ����                                               
		.M_AXI_AWADDR        (M0_AXI_AWADDR   )     ,           //output wire 
		.M_AXI_AWVALID       (M0_AXI_AWVALID  )     ,           //output wire 
		.M_AXI_AWREADY       (M0_AXI_AWREADY  )     ,           //input wire 
		//д����ͨ����                                            //д����ͨ����           
        .M_AXI_WLAST         (M0_AXI_WLAST    )     ,           //input wire   
        .M_AXI_WREADY        (M0_AXI_WREADY   )     ,           //input wire 
		//д��Ӧͨ����                                             //д��Ӧͨ����  
		//����ַͨ����                                             //����ַͨ����    
		.M_AXI_ARADDR        (M0_AXI_ARADDR   )     ,          //output wire   
		.M_AXI_ARVALID       (M0_AXI_ARVALID  )     ,          //output wire   
		.M_AXI_ARREADY       (M0_AXI_ARREADY  )     ,          //input wire   
		//������ͨ����                                            //������ͨ����     
		.M_AXI_RLAST         (M0_AXI_RLAST    )     ,          //input wire 
		.M_AXI_RVALID        (M0_AXI_RVALID   )     ,          //input wire 
        //video                                                ////video      
        .vs_in               (video0_vs_in        )      ,          //input wire  
        .vs_out              (vs_out         )      ,          //input wire   
        //fifo                                                 ////fifo�ź�     
        .wfifo_rd_water_level(wfifo0_rd_water_level) ,         //input wire   
        .wfifo_rd_req        (wfifo0_rd_req        )      ,    //output       
        .wfifo_pre_rd_req    (wfifo0_pre_rd_req    ) ,         //output       
        .rfifo_wr_water_level(rfifo0_wr_water_level) ,         //input wire   
        .rfifo_wr_req        (rfifo0_wr_req   )      ,         // output       
        .r_fram_done         (fram0_done      )      ,         // output reg   
         //����
        .wr_addr_min         (wr_addr_min     )      ,          // input         
        .wr_addr_max         (wr_addr_max     )      ,          // input  
        .r_wr_rst            (wr_rst          )      ,
        .r_rd_rst            (rd_rst          )      ,
        .w_fifo_state        (wfifo0_state    )      ,
        .r_fifo_state        (rfifo0_state    )      ,
        .wr_addr_cnt         (wr_addr_cnt0    )
	);                                                               

//��0��FIFO
rw_fifo_ctrl user_rw_fifo_ctrl0(
        .rstn                   (M_AXI_ARESETN),//ϵͳ��λ,DDRδ��ʼ�����ʱ���ָ�λ״̬
        .ddr_clk                (M_AXI_ACLK          ),//д���ڴ��ʱ�ӣ��ڴ�axi4�ӿ�ʱ�ӣ�
         //hdmi_wfifo_ddr                             
        .wfifo_wr_clk           (video0_clk_in          ),//wfifoдʱ��
        .wfifo_wr_en            (video0_de_in         ),//wfifo����ʹ��
        .wfifo_wr_data32_in     (video0_data_in       ),//wfifo��������,32bits
        .wfifo_rd_req           (wfifo0_rd_req || wfifo0_pre_rd_req),//wfifo�����󣬵���������ͻ������ʱ����
        .wfifo_rd_water_level   (wfifo0_rd_water_level),//wfifo��ˮλ������������ͻ������ʱ��ʼ����
        .wfifo_rd_data256_out   (M0_AXI_WDATA        ),//wfifo�����ݣ�256bits      
        //ddr_rfifo_hdmi
        .rfifo_rd_clk           (pix_clk_out)          ,//rfifo��ʱ��
        .rfifo_rd_en            (video0_rd_en   )         ,//rfifo����ʹ��
        .rfifo_rd_data32_out    (video0_data_out)      ,//rfifo��������,32bits
        .rfifo_wr_req           (rfifo0_wr_req)        ,//rfifoд���󣬵���������ͻ������ʱ����
        .rfifo_wr_water_level   (rfifo0_wr_water_level),//rfifoдˮλ��������С��һ������ʱ��ʼ����
        .rfifo_wr_data256_in    (M0_AXI_RDATA)         ,//rfifoд���ݣ�256bits    
        .vs_in                  (video0_vs_in          )      ,
        .vs_out                 (vs_out         )                              
   );

endmodule