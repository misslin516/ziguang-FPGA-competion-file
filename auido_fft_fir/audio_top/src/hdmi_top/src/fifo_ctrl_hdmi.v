
module fifo_ctrl_hdmi(
    input             clk_50m    ,
    input             lcd_clk    ,
    input             rst_n      ,
    
    input      [31:0] fft_data   ,
    input             fft_sop    ,
    input             fft_eop    ,
    input             fft_valid  ,
    
    input             data_req   ,     //外部数据请求信号
    input             wr_over    ,
    output reg [7:0]  rd_cnt     ,
    
    output     [31:0] fifo_wr_data,
    output            fifo_wr_req ,
    output reg        fifo_rd_req
);

//parameter define
parameter Transform_Length =256;

//reg define
reg [1:0]  wr_state;
reg [1:0]  rd_state;
reg [7:0]  wr_cnt;
reg        wr_en;
reg        fft_valid_r;
reg [31:0] fft_data_r;

//*****************************************************
//**                    main code
//***************************************************** 

//产生fifo写请求信号
assign fifo_wr_req  = fft_valid_r && wr_en;
assign fifo_wr_data = fft_data_r;

//将数据与有效信号延时一个时钟周期
always @ (posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        fft_data_r  <= 32'd0;
        fft_valid_r <= 1'b0;
    end
    else begin
        fft_data_r  <= fft_data;
        fft_valid_r <= fft_valid;
    end     
end

//控制FIFO写端口，每次向FIFO中写入前半帧（64个）数据
always @ (posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        wr_state <= 2'd0;
        wr_en    <= 1'b0;
        wr_cnt   <= 8'd0;
    end
    else begin
        case(wr_state)
            2'd0: begin             //等待一帧数据的开始信号
                if(fft_sop) begin
                    wr_state <= 2'd1;
                    wr_en    <= 1'b1;
                end
                else begin          //进入写数据过程，拉高写使能wr_en
                    wr_state <= 2'd0;
                    wr_en    <= 1'b0;
                end
            end
            2'd1: begin             
                if(fifo_wr_req)     //对写入FIFO中的数据计数
                    wr_cnt   <= wr_cnt + 1'b1;
                else
                    wr_cnt   <= wr_cnt;
                                    //由于FFT得到的数据具有对称性，因此只取一帧数据的一半
                if(wr_cnt < Transform_Length/2 - 1'b1) begin
                    wr_en    <= 1'b1;
                    wr_state <= 2'd1;
                end
                else begin
                    wr_en    <= 1'b0;
                    wr_state <= 2'd2;
                end
            end
            2'd2: begin             //当FIFO中的数据被读出一半的时候，进入下一帧数据写过程
                if((rd_cnt == Transform_Length/4)&& wr_over) begin
                    wr_cnt   <= 8'd0;
                    wr_state <= 2'd0;
                end
                else 
                    wr_state <= 2'd2;
            end
            default: 
                    wr_state <= 2'd0;
        endcase
    end     
end
    
//控制FIFO读端口，每次输出一个数据用于绘制频谱
always @ (posedge lcd_clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_state    <= 2'd0;
        rd_cnt      <= 8'd0;
        fifo_rd_req <= 1'b0;
    end
    else begin
        case(rd_state)
            2'd0: begin             //外部请求频谱数据时，拉高读FIFO请求信号
                if(data_req) begin
                    fifo_rd_req <= 1'b1;
                    rd_state    <= 2'd1;
                end
                else begin
                    fifo_rd_req <= 1'b0;
                    rd_state    <= 2'd0;
                end
            end
            2'd1: begin             //读FIFO请求仅拉高一个时钟周期
                    fifo_rd_req <= 1'b0;
                    rd_state    <= 2'd2;
            end
            2'd2: begin             //等待输出的频谱数据绘制结束
                if(wr_over) begin 
                    rd_state    <= 2'd0;
                    if( rd_cnt== Transform_Length/2 -1 ) 
                        rd_cnt <= 8'd0;
                    else 
                        rd_cnt <= rd_cnt + 1'b1;
                end 
                else 
                    rd_state    <= 2'd2;
            end 
            default: 
                    rd_state    <= 2'd0;
        endcase
    end     
end

endmodule 