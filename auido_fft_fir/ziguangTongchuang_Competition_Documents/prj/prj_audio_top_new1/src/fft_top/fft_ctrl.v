

module fft_ctrl
(
    input      clk_50m      ,
    input      rst_n        ,
  
    input      fifo_rd_empty,
    input      re_flag      ,
    output     fifo_rdreq   ,
      
    input      fft_ready    ,
    output reg fft_rst_n    ,
    output reg fft_valid    ,
    output     fft_sop      ,
    output reg fft_eop      ,
    output     fft_stop    
    
);

//reg define
reg         state;
reg  [4:0]  delay_cnt;
reg  [9:0]  fft_cnt;   
reg         rd_en;

parameter FFT_point = 10'd256; 

//*****************************************************
//**                    main code
//***************************************************** 

assign fifo_rdreq = rd_en && re_flag;             //fifo读请求信号
assign fft_sop    = (fft_cnt==10'd1) ? 1'b1 : 1'b0; //生成sop信号
assign fft_stop    = (fft_cnt==FFT_point-1'b1) ? fft_valid : 1'b0; //生成停止信号


always@(posedge clk_50m or negedge rst_n)
begin
    if(~rst_n)
        fft_eop <= 1'b0;
    else if(fft_cnt==FFT_point-1'b1)
        fft_eop <= 1'b1;
    else
        fft_eop <= 1'b0;

end


//产生驱动FFT ip核的控制信号 先将数据进行10个时钟周期的延时，在进行FFT变换
always @ (posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        state     <= 1'b0;
        rd_en     <= 1'b0;
        fft_valid <= 1'b0;
        fft_rst_n <= 1'b0;
        fft_cnt   <= 10'd0;
        delay_cnt <= 5'd0;
    end
    else begin
        case(state)
            1'b0: begin
                fft_valid <= 1'b0;
                fft_cnt   <= 10'd0;
                
                if(delay_cnt < 5'd10) begin 
                    delay_cnt <= delay_cnt + 1'b1;
                    fft_rst_n <= 1'b0;
                end
                else begin
                    delay_cnt <= delay_cnt;
                    fft_rst_n <= 1'b1;
                end
                
                if((delay_cnt==5'd10)&&(fft_ready))
                    state <= 1'b1;
                else
                    state <= 1'b0;
            end
            1'b1: begin
                if(!fifo_rd_empty)
                    rd_en <= 1'b1;
                else
                    rd_en <= 1'b0;
                        
                if(fifo_rdreq) begin
                    fft_valid <= 1'b1;
                    if(fft_cnt < FFT_point)
                        fft_cnt <= fft_cnt + 1'b1;
                    else
                        fft_cnt <= 10'd1;
                end
                else begin
                    fft_valid <= 1'b0;
                    fft_cnt <= fft_cnt;
                end
            end
            default: state <= 1'b0;
        endcase
    end
end

endmodule 