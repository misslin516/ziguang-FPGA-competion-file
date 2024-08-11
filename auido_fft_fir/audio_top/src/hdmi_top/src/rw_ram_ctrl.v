

module rw_ram_ctrl
(
    input             clk,
    input             lcd_clk,
    input             rst_n,
    //FFT输入数据
    input      [11:0] fft_data,        //FFT频谱数据
    input             fft_eop,         //EOP包结束信号
    input             fft_valid,       //FFT频谱数据有效信号
    
    input             data_req,        //数据请求信号
    input             fft_point_done,  //FFT当前频谱绘制完成
    output reg [7:0]  fft_point_cnt,   //FFT频谱位置
    //ram端口  
    output     [11:0]  ram_data_out     //ram输出有效数据
);

//parameter define
parameter TRANSFORM_LEN = 256;        //FFT采样点数:256

//reg define
reg  [9:0]    ram_raddr;		//ram读地址
reg           data_invalid;   	//数据无效标志，高有效
reg  [9:0]    ram_waddr;		//ram写地址

//wire define
wire          ram_wr_en;     	//ram写使能
wire  [11:0]  ram_wr_data;      //ram写数据
wire  [11:0]  ram_rd_data;      //ram读数据

//*****************************************************
//**                    main code
//***************************************************** 


//产生ram写使能
assign ram_wr_en  = fft_valid;
//产生ram写数据
assign ram_wr_data = fft_data;
//在数据无效标志为低的时候将ram读数据赋值给ram输出有效数据信号
assign ram_data_out = data_invalid ? 12'd0 : ram_rd_data;


//产生ram地址
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) 
        ram_waddr  <= 10'd0;
    // else if(fft_eop)
        // ram_waddr  <= 16'd0;        
    else if(ram_wr_en)
        ram_waddr  <= ram_waddr + 1'b1;
    else
        ram_waddr  <= ram_waddr;          
end

//当前从ram中读到的第几个点，fft_point_cnt（0~127）
always @(posedge lcd_clk or negedge rst_n) begin
    if(!rst_n)
        fft_point_cnt <= 8'd0;
    else begin        
        if(fft_point_done)
            fft_point_cnt <= 8'd0;
        else if(data_req)
            fft_point_cnt <= fft_point_cnt + 1'b1;          
        else 
            fft_point_cnt <= fft_point_cnt;                                            
    end
end

//产生ram读地址
always @(posedge lcd_clk or negedge rst_n) begin
    if(!rst_n) 
        ram_raddr <= 10'd0;
    else begin
        if(fft_point_done)   
            ram_raddr <= 10'd0;               
        else if(data_req)   
            ram_raddr <= ram_raddr + 1'b1;
        else
            ram_raddr <= ram_raddr;          
    end
end


always @(posedge lcd_clk or negedge rst_n) begin
    if(!rst_n) 
        data_invalid <= 1'd0;
    else begin
        if(fft_point_done)   
            data_invalid <= 1'd0;               
        else if(ram_raddr == TRANSFORM_LEN-1'b1)   
            data_invalid <= 1'd1; 
        else
            data_invalid <= data_invalid;           
    end
end

single_ram
#(
   .C_ADDR_WIDTH (10) ,
   .C_DATA_WIDTH (12)
)
single_ram_inst
(
   .clka   (clk         ) ,
   .wea    (ram_wr_en   ) ,
   .addra  (ram_waddr   ) ,
   .dina   (ram_wr_data ) ,
  
   .clkb   (lcd_clk     ) ,
   .web    (1'b1        ) ,
   .addrb  (ram_raddr   ) ,
  
   .doutb  (ram_rd_data ) 
);

endmodule 
