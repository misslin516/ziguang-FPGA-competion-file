// Created by:          njupt
// Created date:        2024/4/18
// Version:             V1.2
// revised data:        2024/4/23
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//


module audio_data_pkt
(
    input               rst_n          ,
    //音频相关信号                     
    input               audio_clk      ,
    input               audio_en       ,
    input [15:0]        audio_data     ,
                                    
    input               transfer_flag  ,  //音频开始传输标志,1:开始传输 0:停止传输
    
    //udp相关信号
    input               eth_tx_clk     ,   //以太网发送时钟
    input               udp_tx_req     ,   //udp发送数据请求信号
    input               udp_tx_done    ,   //udp发送数据完成信号                               
    output  reg         udp_tx_start_en,   //udp开始发送信号
    output       [31:0] udp_tx_data    ,   //udp发送的数据
    output  reg  [15:0] udp_tx_byte_num    //udp单包发送的有效字节数  --65535 maxbytes
);

parameter udp_bytes = 10'd1000;  //以采样率为最大   
parameter udp_bytes_step = 6'd48;

reg audio_en1;
reg audio_en2;
reg [15:0] audio_data1;
reg [15:0] audio_data2;
wire [10:0] fifo_rdusedw;

wire [10:0] wr_water_level;

always@(posedge audio_clk or negedge rst_n)
begin
    if(~rst_n)begin
        audio_en1 <= 1'b0;
        audio_en2 <= 1'b0;
        audio_data1 <= 16'd0;
        audio_data2 <= 16'd0;
    end else begin
        audio_en1 <= audio_en;
        audio_en2 <= audio_en1;
        audio_data1 <= audio_data;
        audio_data2 <= audio_data1;
    end
end

reg             wr_sw           ;  //用于位拼接的标志
reg    [15:0]   audio_data_d0   ;  //有效音频数据打拍


always @(posedge audio_clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_sw <= 1'b0;
        audio_data_d0 <= 1'b0;
    end
    else if(audio_en) begin
        wr_sw <= ~wr_sw;
        audio_data_d0 <= audio_data;
    end    
end 



reg wr_fifo_en;
reg [31:0] wr_fifo_data;

//put data in fifo
always@(posedge audio_clk or negedge rst_n)
begin
    if(~rst_n)begin
        wr_fifo_en <= 1'b0;
        wr_fifo_data <= 32'd0;
    end else begin
        if(wr_water_level == 11'd0) begin
            wr_fifo_en <= 1'b1;
            wr_fifo_data <= {udp_bytes,udp_bytes_step}; //64048
        end else if(audio_en && wr_sw) begin
            wr_fifo_en <= 1'b1;
            wr_fifo_data <= {audio_data_d0,audio_data};
        end else begin
            wr_fifo_en <= 1'b0;
            wr_fifo_data <= 16'd0; 
        end
    end
end


always@(posedge eth_tx_clk or negedge rst_n)
begin
    if(~rst_n)
        udp_tx_byte_num <= 16'd0;
    else if(udp_tx_done)
        udp_tx_byte_num <= udp_bytes;
    else;
end



reg tx_busy_flag;
//控制以太网发送开始信号
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(~rst_n) begin
        udp_tx_start_en <= 1'b0;
        tx_busy_flag <= 1'b0;
    end
    //上位机未发送"开始"命令时,以太网不发送audio数据
    else if(transfer_flag == 1'b0) begin
        udp_tx_start_en <= 1'b0;
        tx_busy_flag <= 1'b0;        
    end
    else begin
        udp_tx_start_en <= 1'b0;
        //当FIFO中的个数满足需要发送的字节数时
        if(tx_busy_flag == 1'b0 && fifo_rdusedw >= udp_tx_byte_num) begin
            udp_tx_start_en <= 1'b1;                     //开始控制发送一包数据
            tx_busy_flag <= 1'b1;
        end
        else if(udp_tx_done) 
            tx_busy_flag <= 1'b0;
        else;
    end
end


reg    [10:0]   udp_pkt_cnt     /* synthesis PAP_MARK_DEBUG="1" */;  //udp包计数
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(~rst_n) begin
        udp_pkt_cnt <= 'd0;
    end    
    else if(udp_tx_done)begin
        udp_pkt_cnt <= udp_pkt_cnt + 'd1;
    end
    else begin
        udp_pkt_cnt <= udp_pkt_cnt;
    end
end


//注意读写时钟相差太大的问题
fifo_audo_data_pkt fifo_audo_data_pkt_inst 
(
  .wr_data(wr_fifo_data),                  // input [31:0]
  .wr_en  (wr_fifo_en),                      // input
  .wr_clk (audio_clk),                    // input
  .full ()   ,                     // output
  .wr_rst(~transfer_flag),                    // input
  .almost_full(),          // output
  .wr_water_level(wr_water_level),    // output [10:0]
  .rd_data(udp_tx_data),                  // output [31:0]
  .rd_en(udp_tx_req),                      // input
  .rd_clk(eth_tx_clk),                    // input
  .empty(),                      // output
  .rd_rst(~transfer_flag),                    // input
  .almost_empty()   ,      // output
  .rd_water_level(fifo_rdusedw)    //[10:0]
);




   

endmodule
