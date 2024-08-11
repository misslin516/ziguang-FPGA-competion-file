//revised date:2024/05/16
//version: v1.0
//from ����˼/ARM�ĵ�
module axi_m_revised
#(
    parameter integer AUDIO_WIDTH       = 16                              ,
    parameter integer AUDIO_1slength    = 375                             ,
    parameter integer CTRL_ADDR_WIDTH	= 28                              ,
    parameter integer DQ_WIDTH	        = 32                              ,
    parameter integer M_AXI_BRUST_LEN   = 8                               ,
    parameter integer AUDIO_BASE_ADDR   = 2'd0                            ,
    parameter integer WR_BURST_LENGTH   = 4'd8                            , // дͻ������                64��128bit������
    parameter integer Rr_BURST_LENGTH   = 4'd8                          
)
(

    input wire                                    DDR_INIT_DONE           ,
    input wire                                    M_AXI_ACLK              ,
    input wire                                    M_AXI_ARESETN           ,
    //д��ַͨ����                                                              
    output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_AWADDR            /* synthesis PAP_MARK_DEBUG="1" */ ,
    output wire                                   M_AXI_AWVALID           ,
    input wire                                    M_AXI_AWREADY           ,
    output  wire     [3:0]                        M_AXI_AWLEN             ,                            
    //д����ͨ����                                                              
    input wire                                    M_AXI_WLAST             ,
    input wire                                    M_AXI_WREADY            ,
    //д��Ӧͨ����                                                              
    //����ַͨ����                                                              
    output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_ARADDR             /* synthesis PAP_MARK_DEBUG="1" */,
    output wire                                   M_AXI_ARVALID           ,
    input wire                                    M_AXI_ARREADY           ,
    output  wire     [3:0]                        M_AXI_ARLEN             ,
    //������ͨ����                                                              
    input wire                                    M_AXI_RLAST             ,
    input wire                                    M_AXI_RVALID            ,

    //fifo�ź�
    input wire  [8 : 0]                           wfifo_rd_water_level    ,
    output                                        wfifo_rd_req            /* synthesis PAP_MARK_DEBUG="1" */,
    output                                        wfifo_pre_rd_req        /* synthesis PAP_MARK_DEBUG="1" */,
    input wire  [8 : 0]                           rfifo_wr_water_level    ,
    output                                        rfifo_wr_req            ,
    output reg                                    r_fram_done             ,
    //����
    input       [23 : 0]                          wr_addr_min             ,//д����ddr��С��ַ0��ַ�Ӳɼ�1s��ʼ�㣬�ɼ�ʱ��Ϊ1s:48000 *16 = 768000bits
    input       [23 : 0]                          wr_addr_max             ,//д����ddr����ַ��һ����ַ��32λ 768000/32 = 24000
    output reg [3 : 0]                            w_fifo_state/* synthesis PAP_MARK_DEBUG="1" */,
    output reg [3 : 0]                            r_fifo_state/* synthesis PAP_MARK_DEBUG="1" */,
    output wire [23 : 0]                          wr_addr_cnt/* synthesis PAP_MARK_DEBUG="1" */
);
/************************************************************************/

/*******************************����***************************************/
parameter    IDLE          =   'b0001,
             WRITE_START   =   'b0010,
             WRITE_ADDR    =   'b0100,
             WRITE_DATA    =   'b1000,
             READ_START    =   'b001,
             READ_ADDR     =   'b010,
             READ_DATA     =   'b100;




/*******************************�Ĵ���***************************************/



reg                              r_m_axi_awvalid;
reg                              r_m_axi_arvalid/* synthesis PAP_MARK_DEBUG="1" */;



reg [23 : 0]                     r_wr_addr_cnt/* synthesis PAP_MARK_DEBUG="1" */;
reg [23 : 0]                     r_rd_addr_cnt/* synthesis PAP_MARK_DEBUG="1" */;
reg [3  : 0]                     axi_awlen  /* synthesis PAP_MARK_DEBUG="1" */  ;
reg [3  : 0]                     axi_arlen  /* synthesis PAP_MARK_DEBUG="1" */  ;
reg                              r_wr_done;//��Ƶ��������ź�
reg                              r_rd_done;
    
reg                              r_wfifo_pre_rd_req ;
reg                              r_wfifo_pre_rd_flag;
/*******************************������***************************************/


/*******************************����߼�***************************************/
//һЩ���ýӿ��ǳ��������ݶ���ģ��ֱ�Ӹ�ֵ�ͺ�  �����������д��Ϊ ����ַ ��base_addr��+ r_wr_addr_cnt 
//д��ַ
assign M_AXI_AWADDR     =  AUDIO_BASE_ADDR + {2'b0,r_wr_addr_cnt,2'b0} ;
assign M_AXI_AWLEN      =   WR_BURST_LENGTH;
assign M_AXI_AWVALID    =   r_m_axi_awvalid;
//д����
assign wfifo_rd_req     =   M_AXI_WLAST ? 1'b0 : M_AXI_WREADY;//r_wfifo_rd_req;
assign wfifo_pre_rd_req = 1'b0; //no use
//����ַ
assign M_AXI_ARADDR     =  AUDIO_BASE_ADDR + {2'b0,r_rd_addr_cnt,2'b0} ;
assign M_AXI_ARLEN      =  Rr_BURST_LENGTH;
assign M_AXI_ARVALID    =  r_m_axi_arvalid;
assign rfifo_wr_req     =  M_AXI_RLAST ? 1'b0 : M_AXI_RVALID;//r_rfifo_wr_req;

assign wr_addr_cnt = r_wr_addr_cnt;

//������
/*******************************main***************************************/
//rank > chip > bank > row/column  sigle rank
/*******************************main***************************************/


//д��ַͨ��
always @(posedge M_AXI_ACLK ) begin
   if(!M_AXI_ARESETN ) begin//��Ч�źź�׼���źŶ�Ϊ1ʱ����Ч�źŹ�0
        r_m_axi_awvalid <= 1'b0;
        r_wr_addr_cnt <= wr_addr_min;
        r_wr_done <= 1'b0;
        r_fram_done <= 1'b0;
        axi_awlen <= 4'd0;
    end 
    else if (DDR_INIT_DONE) begin
        axi_awlen <= WR_BURST_LENGTH;
        if(r_wr_addr_cnt < wr_addr_max - WR_BURST_LENGTH) begin
            r_wr_done<= 1'b0; 
            if(M_AXI_AWVALID && M_AXI_AWREADY) begin         
                r_m_axi_awvalid <= 1'b0;
                r_wr_addr_cnt <= r_wr_addr_cnt + WR_BURST_LENGTH;
            end
            else if(w_fifo_state == WRITE_ADDR) begin
                r_m_axi_awvalid <= 1'b1;
            end
        end
        else if(r_wr_addr_cnt == wr_addr_max - WR_BURST_LENGTH ) begin//���һ��ͻ������ʱ����ַ��������            
            if(M_AXI_AWVALID && M_AXI_AWREADY) begin         
                r_m_axi_awvalid <= 1'b0;
                r_wr_addr_cnt <= wr_addr_min;
                r_wr_done<= 1'b1;  
                r_fram_done <= 1'b1;     
            end
            else if(w_fifo_state == WRITE_ADDR) begin
                r_m_axi_awvalid <= 1'b1;
            end
        else
            r_m_axi_awvalid <= 1'b0;
    end
    else begin
        r_m_axi_awvalid <= 1'b0;//����״̬���ֲ���
        r_wr_done <= r_wr_done;
        r_wr_addr_cnt <=wr_addr_min;
        axi_awlen    <= 4'd0;
    end
end
end





//����ַ
always @(posedge M_AXI_ACLK ) begin//����ַ��Ч
    if(!M_AXI_ARESETN)begin
        r_m_axi_arvalid <= 'd0;//��λ�����ߺ����
        r_rd_addr_cnt <= wr_addr_min;
        r_rd_done <= 'd0;
        axi_arlen <= 4'd0;
    end
    else if (DDR_INIT_DONE) begin//DDR��ʼ������
        axi_arlen <= Rr_BURST_LENGTH;
        if(r_rd_addr_cnt < wr_addr_max - Rr_BURST_LENGTH) begin
            r_rd_done <= 'd0;
            if(M_AXI_ARVALID && M_AXI_ARREADY) begin//�ӻ���Ӧ�����ͣ�д��ַ��Ч���ͣ�ͬʱ��ַ����            
                r_m_axi_arvalid <= 1'b0;
                r_rd_addr_cnt <= r_rd_addr_cnt + Rr_BURST_LENGTH;
            end
            else if(r_fifo_state == READ_ADDR) begin
                r_m_axi_arvalid <= 1'b1;
            end
        end
        else if(r_rd_addr_cnt == wr_addr_max - Rr_BURST_LENGTH) begin
            if(M_AXI_ARVALID && M_AXI_ARREADY) begin//�������ɺ����            
                r_m_axi_arvalid <= 1'b0;
                r_rd_addr_cnt <= wr_addr_min;
                r_rd_done <= 'd1;
            end
            else if(r_fifo_state == READ_ADDR) begin
                r_m_axi_arvalid <= 1'b1;
            end            
        end
        else
            r_m_axi_arvalid <= 1'b0;
    end
    else begin
        r_m_axi_arvalid <= 1'b0;
        r_rd_addr_cnt <= wr_addr_min;
        axi_arlen <= 4'd0;
    end
end




/*******************************״̬��***************************************/
//Ϊ��ʵ��˫��ͬʱ���以��Ӱ�죬���Զ�д״̬������״̬��ʹ��
//DDR3д״̬��
always @(posedge M_AXI_ACLK ) begin
    if(~M_AXI_ARESETN)
        w_fifo_state    <= IDLE;
    else begin
        case(w_fifo_state)
            IDLE: 
            begin
                if(DDR_INIT_DONE)
                    w_fifo_state <= WRITE_START ;
                else
                    w_fifo_state <= IDLE;
            end
            WRITE_START:
            begin
                if(wfifo_rd_water_level > WR_BURST_LENGTH) begin//��wfifo�ж�ˮλ����ͻ�����ȣ���ʼͻ������
                    w_fifo_state <= WRITE_ADDR;   //����д����
                end       
                else begin
                    w_fifo_state <= w_fifo_state;
                end            
            end
            WRITE_ADDR:
            begin
                if(M_AXI_AWVALID && M_AXI_AWREADY)
                    w_fifo_state <= WRITE_DATA;  //����д���ݲ���
                else
                    w_fifo_state <= w_fifo_state;   //���������㣬���ֵ�ǰֵ
            end
            WRITE_DATA: 
            begin
                //д���趨�ĳ��������ȴ�״̬
                if(M_AXI_WLAST)//M_AXI_WREADY && (r_wburst_cnt == M_AXI_BRUST_LEN - 1)
                    w_fifo_state <= WRITE_START;  //д���趨�ĳ��������ȴ�״̬
                else
                    w_fifo_state <= w_fifo_state;  //д���������㣬���ֵ�ǰֵ
            end
            default:
            begin
                w_fifo_state     <= IDLE;
            end
        endcase
    end
end

//DDR��״̬��
always @(posedge M_AXI_ACLK ) begin
    if(~M_AXI_ARESETN)
        r_fifo_state    <= IDLE;
    else begin
        case(r_fifo_state)
            IDLE: 
            begin
                if(DDR_INIT_DONE && r_fram_done) begin
                    r_fifo_state <= READ_START ;
                end
                else begin
                    r_fifo_state <= IDLE;
                end
            end
            READ_START:
            begin
                if(rfifo_wr_water_level < Rr_BURST_LENGTH)
                    r_fifo_state <= READ_ADDR;   //����������
                else
                    r_fifo_state <= r_fifo_state;
            end
            READ_ADDR:
            begin
                if(M_AXI_ARVALID && M_AXI_ARREADY)
                    r_fifo_state <= READ_DATA;  //���������ݲ���
                else
                    r_fifo_state <= r_fifo_state;   //���������㣬���ֵ�ǰֵ
            end
            READ_DATA: 
            begin
                //д���趨�ĳ��������ȴ�״̬
                if(M_AXI_RLAST )
                    r_fifo_state <= READ_START;  //д���趨�ĳ��������ȴ�״̬
                else
                    r_fifo_state <= r_fifo_state;  //д���������㣬���ֵ�ǰֵ
            end
            default:
            begin
                r_fifo_state     <= IDLE;
            end
        endcase
    end
end






endmodule
