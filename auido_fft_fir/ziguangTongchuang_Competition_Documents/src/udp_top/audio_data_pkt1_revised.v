// Created date:        2024/4/18
// Version:             V1.4
// revised date:        2024/4/30
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module audio_data_pkt1_revised
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
    output  wire  [15:0] udp_tx_byte_num    //udp单包发送的有效字节数  
);



parameter udp_bytes = 16'd1024;  //以采样率为最大   1024/4 = 256
/*********************************wire/reg*************************/
wire [10:0] fifo_rdusedw;
wire [10:0] wr_water_level;
reg [15:0] aduio_de_cnt;
reg [15:0] wr_fifo_data;
reg wr_fifo_en;


reg [15:0] audio_data1;
always@(posedge audio_clk or negedge rst_n) begin
    if(~rst_n)
        audio_data1 <= 16'd0;
    else
        audio_data1 <= audio_data;
end


//将音频数据写入FIFO
always@(posedge audio_clk or negedge rst_n) begin
    if(~rst_n) begin
        wr_fifo_en <= 1'b0;
        wr_fifo_data <= 16'd0;
        aduio_de_cnt <= 16'd0;
    // end else if(aduio_de_cnt == udp_bytes[15:2]) begin
        // wr_fifo_en <= 1'b1;
        // wr_fifo_data <= 16'hf55f;
        // aduio_de_cnt <= 16'd0;  
    end else if(audio_en) begin
        wr_fifo_en <= 1'b1;
        aduio_de_cnt <= aduio_de_cnt + 'd1;
        wr_fifo_data <= audio_data;     
    end else begin   
        wr_fifo_en <= 1'b0;
        wr_fifo_data <= 16'd0; 
    end
end


assign  udp_tx_byte_num = udp_bytes;


reg tx_busy_flag;
//控制以太网发送开始信号
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(~rst_n) begin
        udp_tx_start_en <= 1'b0;
        tx_busy_flag <= 1'b0;
    end
    //上位机未发送"开始"命令时,以太网不发送数据
    else if(transfer_flag == 1'b0) begin
        udp_tx_start_en <= 1'b0;
        tx_busy_flag <= 1'b0;        
    end
    else begin
        udp_tx_start_en <= 1'b0;
        //当FIFO中的个数满足需要发送的字节数时 水位/4(32bit->8bit)
        if(tx_busy_flag == 1'b0 && fifo_rdusedw >= udp_tx_byte_num[15:2]) begin
            udp_tx_start_en <= 1'b1;                     //开始控制发送一包数据
            tx_busy_flag <= 1'b1;
        end
        else if(udp_tx_done) 
            tx_busy_flag <= 1'b0;
        else;
    end
end

wire [15:0] tx_data;
assign udp_tx_data = {16'b0,tx_data};


fifo_audo_data_pkt the_instance_name (
  .wr_data(wr_fifo_data),                  // input [15:0]
  .wr_en(wr_fifo_en),                      // input
  .wr_clk(audio_clk),                    // input
  .full(),                        // output
  .wr_rst(~transfer_flag),                    // input
  .almost_full(),          // output
  .wr_water_level(wr_water_level),    // output [10:0]
  .rd_data(tx_data),                  // output [15:0]
  .rd_en(udp_tx_req),                      // input
  .rd_clk(eth_tx_clk),                    // input
  .empty(),                      // output
  .rd_rst(~transfer_flag),                    // input
  .almost_empty(),        // output
  .rd_water_level(fifo_rdusedw)     // output [10:0]
);




endmodule

