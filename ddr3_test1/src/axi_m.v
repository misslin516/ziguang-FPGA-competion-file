//revised date:2024/05/16
//version: v1.0
//from ����˼/ARM�ĵ�
module axi_m
#(
    parameter integer AUDIO_WIDTH       = 16                              ,
    parameter integer AUDIO_1slength    = 375                             ,
    parameter integer CTRL_ADDR_WIDTH	= 28                              ,
    parameter integer DQ_WIDTH	        = 32                              ,
    parameter integer M_AXI_BRUST_LEN   = 8                               ,
    parameter integer AUDIO_BASE_ADDR   = 28'h0100000                           
    
)
(

    input wire                                    DDR_INIT_DONE           ,
    input wire                                    M_AXI_ACLK              ,
    input wire                                    M_AXI_ARESETN           ,
    //д��ַͨ����                                                              
    output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_AWADDR            ,
    output wire                                   M_AXI_AWVALID           ,
    input wire                                    M_AXI_AWREADY           ,
    output  wire     [3:0]                        M_AXI_AWLEN             ,                            
    //д����ͨ����                                                              
    input wire                                    M_AXI_WLAST      /* synthesis PAP_MARK_DEBUG="1" */        ,
    input wire                                    M_AXI_WREADY            ,
    //д��Ӧͨ����                                                              
    //����ַͨ����                                                              
    output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_ARADDR            ,
    output wire                                   M_AXI_ARVALID           ,
    input wire                                    M_AXI_ARREADY           ,
    output  wire     [3:0]                        M_AXI_ARLEN             ,
    //������ͨ����                                                              
    input wire                                    M_AXI_RLAST      /* synthesis PAP_MARK_DEBUG="1" */        ,
    input wire                                    M_AXI_RVALID       /* synthesis PAP_MARK_DEBUG="1" */      ,

    //fifo�ź�
    input wire  [8 : 0]                           wfifo_rd_water_level    ,
    output                                        wfifo_rd_req            /* synthesis PAP_MARK_DEBUG="1" */,
    output                                        wfifo_pre_rd_req        /* synthesis PAP_MARK_DEBUG="1" */,
    input wire  [8 : 0]                           rfifo_wr_water_level    ,
    output                                        rfifo_wr_req            ,
    output reg                                    r_fram_done             ,
    //����
    input       [19 : 0]                          wr_addr_min             ,//д����ddr��С��ַ0��ַ�Ӳɼ�1s��ʼ�㣬�ɼ�ʱ��Ϊ1s:48000 *16 = 768000bits
    input       [19 : 0]                          wr_addr_max             ,//д����ddr����ַ��һ����ַ��32λ 768000/32 = 24000
    output reg [3 : 0]                            w_fifo_state/* synthesis PAP_MARK_DEBUG="1" */,
    output reg [3 : 0]                            r_fifo_state/* synthesis PAP_MARK_DEBUG="1" */,
    output wire [19 : 0]                          wr_addr_cnt/* synthesis PAP_MARK_DEBUG="1" */
);
/************************************************************************/

/*******************************����***************************************/
parameter    IDLE          =   'd0,
             WRITE_START   =   'd1,
             WRITE_ADDR    =   'd2,
             WRITE_DATA    =   'd3,
             READ_START    =   'd1,
             READ_ADDR     =   'd2,
             READ_DATA     =   'd3;




/*******************************�Ĵ���***************************************/


reg [CTRL_ADDR_WIDTH - 1 : 0]    r_m_axi_awaddr;//��ַ�Ĵ���
reg                              r_m_axi_awvalid;
reg                              r_m_axi_wlast;
reg                              r_m_axi_wvalid;
reg [CTRL_ADDR_WIDTH*8 - 1 : 0]  r_m_axi_araddr;
reg                              r_m_axi_arvalid/* synthesis PAP_MARK_DEBUG="1" */;
reg [7 : 0]                      r_wburst_cnt;
reg [7 : 0]                      r_rburst_cnt;
reg [DQ_WIDTH*8 - 1 : 0]         r_m_axi_rdata;

reg [19 : 0]                     r_wr_addr_cnt/* synthesis PAP_MARK_DEBUG="1" */;
reg [19 : 0]                     r_rd_addr_cnt/* synthesis PAP_MARK_DEBUG="1" */;
reg [3 : 0]                      r_wr_addr_page/* synthesis PAP_MARK_DEBUG="1" */;
reg [3 : 0]                      r_rd_addr_page/* synthesis PAP_MARK_DEBUG="1" */;
reg [1 : 0]                      r_wr_last_page/* synthesis PAP_MARK_DEBUG="1" */;
reg [1 : 0]                      r_rd_last_page/* synthesis PAP_MARK_DEBUG="1" */;

reg                              r_wr_done;//��Ƶ��������ź�
reg                              r_rd_done;
reg                              r_wfifo_rd_req;
reg                              r_wfifo_pre_rd_req;
reg                              r_wfifo_pre_rd_flag;
reg                              r_rfifo_wr_req;
                     
/*******************************������***************************************/

/*******************************����߼�***************************************/
//һЩ���ýӿ��ǳ��������ݶ���ģ��ֱ�Ӹ�ֵ�ͺ�
//д��ַ
assign M_AXI_AWADDR     =   AUDIO_BASE_ADDR + {4'b0 , r_wr_addr_page , r_wr_addr_cnt};//27-22��λ0��21-20 ֡����ҳ���� 15-0 д��ַ����
assign M_AXI_AWVALID    =   r_m_axi_awvalid;
assign M_AXI_AWLEN      =   8;
//д����
assign wfifo_rd_req     =   M_AXI_WLAST ? 1'b0 : M_AXI_WREADY;//r_wfifo_rd_req;
assign wfifo_pre_rd_req =   1'b0;//����ַ��Ч�����Ԥ����һ������
//����ַ
assign M_AXI_ARADDR     =  AUDIO_BASE_ADDR +  {4'b0 , r_rd_addr_page , r_rd_addr_cnt};//27-22��λ0��21-20 ֡����ҳ���� 15-0 ����ַ����
                                                                                            //��ַƫ��8λ
assign M_AXI_ARVALID    =   r_m_axi_arvalid;
assign M_AXI_ARLEN      =  8;
assign rfifo_wr_req     =   M_AXI_RLAST ? 1'b0 : M_AXI_RVALID;//r_rfifo_wr_req;

assign wr_addr_cnt = r_wr_addr_cnt;
//������
/*******************************main***************************************/
//rank > chip > bank > row/column
/*******************************main***************************************/

//��ַҳ�ı�   DDRҳ��һ��rank��ÿ��chip���е�ַ
always @(posedge M_AXI_ACLK ) begin
    if(!M_AXI_ARESETN ) begin//��λ��Ϊ0ʱ
        r_wr_addr_page <= 4'b0;
        r_wr_last_page <= 4'b0;
    end 
    else if(r_wr_done) begin
        r_wr_last_page <= r_wr_addr_page ;
        r_wr_addr_page <= r_wr_addr_page + 1;                                 //���һ��ͻ��������ɣ���Ƶ�������
        if(r_wr_addr_page == r_rd_addr_page) begin
            r_wr_addr_page <= r_wr_addr_page + 1;
        end
    end
end

always @(posedge M_AXI_ACLK ) begin
    if(!M_AXI_ARESETN ) begin//��λ��Ϊ0ʱ
        r_rd_addr_page <= 4'b0;
        r_rd_last_page <= 4'b0;
    end 
    else if(r_rd_done) begin//֡�������󣬶Ե�ַҳ�����л�������һ��д��֡������ж��������ǰд���֡�������һ�ε�֡����δ�䣨֡����û��д�꣩�����ظ�����һ�εĶ�֡����
        r_rd_last_page <= r_rd_addr_page;
        r_rd_addr_page <= r_wr_last_page;
        if(r_rd_addr_page == r_wr_addr_page) begin
            r_rd_addr_page <= r_rd_last_page ;
        end
    end
end


//д��ַͨ��
always @(posedge M_AXI_ACLK ) begin
   if(!M_AXI_ARESETN ) begin//��Ч�źź�׼���źŶ�Ϊ1ʱ����Ч�źŹ�0
        r_m_axi_awvalid <= 1'b0;
        r_wr_addr_cnt <= 20'b0;
        r_wr_done <= 1'b0;
        r_fram_done <= 1'b0;
    end 
    else if (DDR_INIT_DONE) begin
        if(r_wr_addr_cnt < wr_addr_max - {M_AXI_BRUST_LEN,3'b0}) begin //д��ĵ�ַС������ַ��ȥһ��ͻ�������������len*axi_data_width(256)/32��
            r_wr_done<= 1'b0; 
            if(M_AXI_AWVALID && M_AXI_AWREADY) begin         
                r_m_axi_awvalid <= 1'b0;
                r_wr_addr_cnt <= r_wr_addr_cnt + {M_AXI_BRUST_LEN,3'b0};
            end
            else if(w_fifo_state == WRITE_ADDR) begin
                r_m_axi_awvalid <= 1'b1;
            end
        end
        else if(r_wr_addr_cnt >= wr_addr_max - {M_AXI_BRUST_LEN,3'b0}) begin//���һ��ͻ������ʱ����ַ��������            
            if(M_AXI_AWVALID && M_AXI_AWREADY) begin         
                r_m_axi_awvalid <= 1'b0;
                r_wr_addr_cnt <= wr_addr_min;
                r_wr_done<= 1'b1;  
                r_fram_done <= 1'b1;     
            end
            else if(w_fifo_state == WRITE_ADDR) begin
                r_m_axi_awvalid <= 1'b1;
            end
        end  
    end
    else begin
        r_m_axi_awvalid <= r_m_axi_awvalid;//����״̬���ֲ���
        r_wr_done <= r_wr_done;
        r_wr_addr_cnt <= 20'b0;
    end
end

//д����ͨ��
always @(posedge M_AXI_ACLK )begin//дͻ������
    if(!M_AXI_ARESETN || M_AXI_WLAST)begin
        r_wburst_cnt <= 'd0;
        r_wfifo_rd_req <= 1'b0;
    end
    else if (M_AXI_WREADY) begin
        r_wburst_cnt <= r_wburst_cnt + 1 ;
        r_wfifo_rd_req <= 1'b1;
        if (r_wburst_cnt == M_AXI_BRUST_LEN - 1'b1) begin//��������7ʱ������ʹ�ܶ���wfifo
            r_wfifo_rd_req <= 1'b0;
        end
    end
    else begin
        r_wburst_cnt <= r_wburst_cnt;
        r_wfifo_rd_req <= 'd0;
    end
end

//Ԥ��WFIFO�����fifo����ӿ���һ������
always @(posedge M_AXI_ACLK )begin//дͻ������
    if(!M_AXI_ARESETN)begin
        r_wfifo_pre_rd_req <= 'd0;
        r_wfifo_pre_rd_flag <= 'd0;
    end
    else if(M_AXI_AWVALID && M_AXI_AWREADY && (r_wfifo_pre_rd_flag == 'd0)) begin
        r_wfifo_pre_rd_req <= 'd1;
        r_wfifo_pre_rd_flag <= 'd1;
    end
    else begin
        r_wfifo_pre_rd_req <= 'd0;
    end
end

//����ַ
always @(posedge M_AXI_ACLK ) begin//����ַ��Ч
    if(!M_AXI_ARESETN)begin
        r_m_axi_arvalid <= 'd0;//��λ�����ߺ����
        r_rd_addr_cnt <= 20'b0;
        r_rd_done <= 'd0;
    end
    else if (DDR_INIT_DONE) begin//DDR��ʼ������
        if(r_rd_addr_cnt < wr_addr_max - {M_AXI_BRUST_LEN,3'b0}) begin
            r_rd_done <= 'd0;
            if(M_AXI_ARVALID && M_AXI_ARREADY) begin//�ӻ���Ӧ�����ͣ�д��ַ��Ч���ͣ�ͬʱ��ַ����            
                r_m_axi_arvalid <= 1'b0;
                r_rd_addr_cnt <= r_rd_addr_cnt + {M_AXI_BRUST_LEN,3'b0};
            end
            else if(r_fifo_state == READ_ADDR) begin
                r_m_axi_arvalid <= 1'b1;
            end
        end
        else if(r_rd_addr_cnt == wr_addr_max - {M_AXI_BRUST_LEN,3'b0}) begin
            if(M_AXI_ARVALID && M_AXI_ARREADY) begin//�������ɺ����            
                r_m_axi_arvalid <= 1'b0;
                r_rd_addr_cnt <= wr_addr_min;
                r_rd_done <= 'd1;
            end
            else if(r_fifo_state == READ_ADDR) begin
                r_m_axi_arvalid <= 1'b1;
            end            
        end

    end
    else begin
        r_m_axi_arvalid <= r_m_axi_arvalid;
        r_rd_addr_cnt <= r_rd_addr_cnt;
    end
end
//������
always @(posedge M_AXI_ACLK )begin//�յ�valid��ʹ��fifo��������
    if(!M_AXI_ARESETN || M_AXI_RLAST)begin
        r_rfifo_wr_req <= 'd0;
        r_rburst_cnt <= 'd0;
    end
    else if (M_AXI_RVALID) begin
        r_rfifo_wr_req <= 1'b1;
        r_rburst_cnt <= r_rburst_cnt + 1'b1;
        if (r_rburst_cnt == M_AXI_BRUST_LEN - 1'b1) begin//��������7ʱ������ʹ�ܶ���wfifo
            r_rfifo_wr_req <= 1'b0;
        end
    end
    else begin
        r_rfifo_wr_req <= 'd0;
        r_rburst_cnt <= r_rburst_cnt;
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
                if(wfifo_rd_water_level > M_AXI_BRUST_LEN) begin//��wfifo�ж�ˮλ����ͻ�����ȣ���ʼͻ������
                    w_fifo_state <= WRITE_ADDR;   //����д����
                end
                else if((r_wr_addr_cnt >= wr_addr_max - M_AXI_BRUST_LEN * 8) && (wfifo_rd_water_level >= M_AXI_BRUST_LEN)) begin//����֮ǰԤ����һ�Σ�����������Ҫ-1
                    w_fifo_state <= WRITE_ADDR;
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
                if(rfifo_wr_water_level < AUDIO_1slength)
                    r_fifo_state <= READ_ADDR;   //����д����
                else
                    r_fifo_state <= r_fifo_state;
            end
            READ_ADDR:
            begin
                if(M_AXI_ARVALID && M_AXI_ARREADY)
                    r_fifo_state <= READ_DATA;  //����д���ݲ���
                else
                    r_fifo_state <= r_fifo_state;   //���������㣬���ֵ�ǰֵ
            end
            READ_DATA: 
            begin
                //д���趨�ĳ��������ȴ�״̬
                if(M_AXI_RLAST ) //&& (r_rburst_cnt == M_AXI_BRUST_LEN - 1)
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
