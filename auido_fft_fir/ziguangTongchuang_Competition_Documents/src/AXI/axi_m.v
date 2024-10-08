//revised date:2024/05/16
//version: v1.0
//from 赛灵思/ARM文档
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
    //写地址通道↓                                                              
    output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_AWADDR            ,
    output wire                                   M_AXI_AWVALID           ,
    input wire                                    M_AXI_AWREADY           ,
    output  wire     [3:0]                        M_AXI_AWLEN             ,                            
    //写数据通道↓                                                              
    input wire                                    M_AXI_WLAST      /* synthesis PAP_MARK_DEBUG="1" */        ,
    input wire                                    M_AXI_WREADY            ,
    //写响应通道↓                                                              
    //读地址通道↓                                                              
    output wire [CTRL_ADDR_WIDTH-1 : 0]           M_AXI_ARADDR            ,
    output wire                                   M_AXI_ARVALID           ,
    input wire                                    M_AXI_ARREADY           ,
    output  wire     [3:0]                        M_AXI_ARLEN             ,
    //读数据通道↓                                                              
    input wire                                    M_AXI_RLAST      /* synthesis PAP_MARK_DEBUG="1" */        ,
    input wire                                    M_AXI_RVALID       /* synthesis PAP_MARK_DEBUG="1" */      ,

    //fifo信号
    input wire  [8 : 0]                           wfifo_rd_water_level    ,
    output                                        wfifo_rd_req            /* synthesis PAP_MARK_DEBUG="1" */,
    output                                        wfifo_pre_rd_req        /* synthesis PAP_MARK_DEBUG="1" */,
    input wire  [8 : 0]                           rfifo_wr_water_level    ,
    output                                        rfifo_wr_req            ,
    output reg                                    r_fram_done             ,
    //其他
    input       [19 : 0]                          wr_addr_min             ,//写数据ddr最小地址0地址从采集1s开始算，采集时长为1s:48000 *16 = 768000bits
    input       [19 : 0]                          wr_addr_max             ,//写数据ddr最大地址，一个地址存32位 768000/32 = 24000
    output reg [3 : 0]                            w_fifo_state/* synthesis PAP_MARK_DEBUG="1" */,
    output reg [3 : 0]                            r_fifo_state/* synthesis PAP_MARK_DEBUG="1" */,
    output wire [19 : 0]                          wr_addr_cnt/* synthesis PAP_MARK_DEBUG="1" */
);
/************************************************************************/

/*******************************参数***************************************/
parameter    IDLE          =   'd0,
             WRITE_START   =   'd1,
             WRITE_ADDR    =   'd2,
             WRITE_DATA    =   'd3,
             READ_START    =   'd1,
             READ_ADDR     =   'd2,
             READ_DATA     =   'd3;




/*******************************寄存器***************************************/


reg [CTRL_ADDR_WIDTH - 1 : 0]    r_m_axi_awaddr;//地址寄存器
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

reg                              r_wr_done;//音频传输完成信号
reg                              r_rd_done;
reg                              r_wfifo_rd_req;
reg                              r_wfifo_pre_rd_req;
reg                              r_wfifo_pre_rd_flag;
reg                              r_rfifo_wr_req;
                     
/*******************************网表型***************************************/

/*******************************组合逻辑***************************************/
//一些常用接口是常量，根据顶层模块直接赋值就好
//写地址
assign M_AXI_AWADDR     =   AUDIO_BASE_ADDR + {4'b0 , r_wr_addr_page , r_wr_addr_cnt};//27-22高位0，21-20 帧缓存页数， 15-0 写地址计数
assign M_AXI_AWVALID    =   r_m_axi_awvalid;
assign M_AXI_AWLEN      =   8;
//写数据
assign wfifo_rd_req     =   M_AXI_WLAST ? 1'b0 : M_AXI_WREADY;//r_wfifo_rd_req;
assign wfifo_pre_rd_req =   1'b0;//当地址有效后进行预读出一次数据
//读地址
assign M_AXI_ARADDR     =  AUDIO_BASE_ADDR +  {4'b0 , r_rd_addr_page , r_rd_addr_cnt};//27-22高位0，21-20 帧缓存页数， 15-0 读地址计数
                                                                                            //地址偏移8位
assign M_AXI_ARVALID    =   r_m_axi_arvalid;
assign M_AXI_ARLEN      =  8;
assign rfifo_wr_req     =   M_AXI_RLAST ? 1'b0 : M_AXI_RVALID;//r_rfifo_wr_req;

assign wr_addr_cnt = r_wr_addr_cnt;
//读数据
/*******************************main***************************************/
//rank > chip > bank > row/column
/*******************************main***************************************/

//地址页改变   DDR页，一个rank里每个chip的行地址
always @(posedge M_AXI_ACLK ) begin
    if(!M_AXI_ARESETN ) begin//复位后为0时
        r_wr_addr_page <= 4'b0;
        r_wr_last_page <= 4'b0;
    end 
    else if(r_wr_done) begin
        r_wr_last_page <= r_wr_addr_page ;
        r_wr_addr_page <= r_wr_addr_page + 1;                                 //最后一次突发传输完成，音频传输完成
        if(r_wr_addr_page == r_rd_addr_page) begin
            r_wr_addr_page <= r_wr_addr_page + 1;
        end
    end
end

always @(posedge M_AXI_ACLK ) begin
    if(!M_AXI_ARESETN ) begin//复位后为0时
        r_rd_addr_page <= 4'b0;
        r_rd_last_page <= 4'b0;
    end 
    else if(r_rd_done) begin//帧缓存读完后，对地址页进行切换，对上一次写的帧缓存进行读，如果当前写入的帧缓存和上一次的帧缓存未变（帧缓存没有写完），则重复读上一次的读帧缓存
        r_rd_last_page <= r_rd_addr_page;
        r_rd_addr_page <= r_wr_last_page;
        if(r_rd_addr_page == r_wr_addr_page) begin
            r_rd_addr_page <= r_rd_last_page ;
        end
    end
end


//写地址通道
always @(posedge M_AXI_ACLK ) begin
   if(!M_AXI_ARESETN ) begin//有效信号和准备信号都为1时，有效信号归0
        r_m_axi_awvalid <= 1'b0;
        r_wr_addr_cnt <= 20'b0;
        r_wr_done <= 1'b0;
        r_fram_done <= 1'b0;
    end 
    else if (DDR_INIT_DONE) begin
        if(r_wr_addr_cnt < wr_addr_max - {M_AXI_BRUST_LEN,3'b0}) begin //写入的地址小于最大地址减去一次突发传输的总量（len*axi_data_width(256)/32）
            r_wr_done<= 1'b0; 
            if(M_AXI_AWVALID && M_AXI_AWREADY) begin         
                r_m_axi_awvalid <= 1'b0;
                r_wr_addr_cnt <= r_wr_addr_cnt + {M_AXI_BRUST_LEN,3'b0};
            end
            else if(w_fifo_state == WRITE_ADDR) begin
                r_m_axi_awvalid <= 1'b1;
            end
        end
        else if(r_wr_addr_cnt >= wr_addr_max - {M_AXI_BRUST_LEN,3'b0}) begin//最后一次突发传输时，地址计数归零            
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
        r_m_axi_awvalid <= r_m_axi_awvalid;//其他状态保持不动
        r_wr_done <= r_wr_done;
        r_wr_addr_cnt <= 20'b0;
    end
end

//写数据通道
always @(posedge M_AXI_ACLK )begin//写突发计数
    if(!M_AXI_ARESETN || M_AXI_WLAST)begin
        r_wburst_cnt <= 'd0;
        r_wfifo_rd_req <= 1'b0;
    end
    else if (M_AXI_WREADY) begin
        r_wburst_cnt <= r_wburst_cnt + 1 ;
        r_wfifo_rd_req <= 1'b1;
        if (r_wburst_cnt == M_AXI_BRUST_LEN - 1'b1) begin//当计数到7时，不再使能读出wfifo
            r_wfifo_rd_req <= 1'b0;
        end
    end
    else begin
        r_wburst_cnt <= r_wburst_cnt;
        r_wfifo_rd_req <= 'd0;
    end
end

//预读WFIFO，清除fifo输出接口上一次数据
always @(posedge M_AXI_ACLK )begin//写突发计数
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

//读地址
always @(posedge M_AXI_ACLK ) begin//读地址有效
    if(!M_AXI_ARESETN)begin
        r_m_axi_arvalid <= 'd0;//复位、拉高后归零
        r_rd_addr_cnt <= 20'b0;
        r_rd_done <= 'd0;
    end
    else if (DDR_INIT_DONE) begin//DDR初始化结束
        if(r_rd_addr_cnt < wr_addr_max - {M_AXI_BRUST_LEN,3'b0}) begin
            r_rd_done <= 'd0;
            if(M_AXI_ARVALID && M_AXI_ARREADY) begin//从机相应后拉低，写地址有效拉低，同时地址自增            
                r_m_axi_arvalid <= 1'b0;
                r_rd_addr_cnt <= r_rd_addr_cnt + {M_AXI_BRUST_LEN,3'b0};
            end
            else if(r_fifo_state == READ_ADDR) begin
                r_m_axi_arvalid <= 1'b1;
            end
        end
        else if(r_rd_addr_cnt == wr_addr_max - {M_AXI_BRUST_LEN,3'b0}) begin
            if(M_AXI_ARVALID && M_AXI_ARREADY) begin//最后传输完成后归零            
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
//读数据
always @(posedge M_AXI_ACLK )begin//收到valid后使能fifo传输数据
    if(!M_AXI_ARESETN || M_AXI_RLAST)begin
        r_rfifo_wr_req <= 'd0;
        r_rburst_cnt <= 'd0;
    end
    else if (M_AXI_RVALID) begin
        r_rfifo_wr_req <= 1'b1;
        r_rburst_cnt <= r_rburst_cnt + 1'b1;
        if (r_rburst_cnt == M_AXI_BRUST_LEN - 1'b1) begin//当计数到7时，不再使能读出wfifo
            r_rfifo_wr_req <= 1'b0;
        end
    end
    else begin
        r_rfifo_wr_req <= 'd0;
        r_rburst_cnt <= r_rburst_cnt;
    end
end

/*******************************状态机***************************************/
//为了实现双向同时传输互不影响，所以读写状态单独做状态机使用
//DDR3写状态机
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
                if(wfifo_rd_water_level > M_AXI_BRUST_LEN) begin//当wfifo中读水位高于突发长度，开始突发传输
                    w_fifo_state <= WRITE_ADDR;   //跳到写操作
                end
                else if((r_wr_addr_cnt >= wr_addr_max - M_AXI_BRUST_LEN * 8) && (wfifo_rd_water_level >= M_AXI_BRUST_LEN)) begin//由于之前预读了一次，所以这里需要-1
                    w_fifo_state <= WRITE_ADDR;
                end                
                else begin
                    w_fifo_state <= w_fifo_state;
                end            
            end
            WRITE_ADDR:
            begin
                if(M_AXI_AWVALID && M_AXI_AWREADY)
                    w_fifo_state <= WRITE_DATA;  //跳到写数据操作
                else
                    w_fifo_state <= w_fifo_state;   //条件不满足，保持当前值
            end
            WRITE_DATA: 
            begin
                //写到设定的长度跳到等待状态
                if(M_AXI_WLAST)//M_AXI_WREADY && (r_wburst_cnt == M_AXI_BRUST_LEN - 1)
                    w_fifo_state <= WRITE_START;  //写到设定的长度跳到等待状态
                else
                    w_fifo_state <= w_fifo_state;  //写条件不满足，保持当前值
            end
            default:
            begin
                w_fifo_state     <= IDLE;
            end
        endcase
    end
end
//DDR读状态机
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
                    r_fifo_state <= READ_ADDR;   //跳到写操作
                else
                    r_fifo_state <= r_fifo_state;
            end
            READ_ADDR:
            begin
                if(M_AXI_ARVALID && M_AXI_ARREADY)
                    r_fifo_state <= READ_DATA;  //跳到写数据操作
                else
                    r_fifo_state <= r_fifo_state;   //条件不满足，保持当前值
            end
            READ_DATA: 
            begin
                //写到设定的长度跳到等待状态
                if(M_AXI_RLAST ) //&& (r_rburst_cnt == M_AXI_BRUST_LEN - 1)
                    r_fifo_state <= READ_START;  //写到设定的长度跳到等待状态
                else
                    r_fifo_state <= r_fifo_state;  //写条件不满足，保持当前值
            end
            default:
            begin
                r_fifo_state     <= IDLE;
            end
        endcase
    end
end

endmodule
