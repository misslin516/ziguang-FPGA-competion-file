//****************************************Copyright (c)***********************************//
//----------------------------------------------------------------------------------------
// File name:           rw_ram_ctrl
// Last modified Date:  2023/05/28 20:28:08
// Last Version:        V1.0
// Descriptions:        ram��д����ģ��
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2023/05/28 20:28:08
// Version:             V1.0
// Descriptions:        The original version
// revised   by :      NJUPT
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module rw_ram_ctrl
(
    input             clk,
    input             lcd_clk,
    input             rst_n,
    //FFT��������
    input      [31:0] fft_data,        //FFTƵ������
    input             fft_eop,         //EOP�������ź�
    input             fft_valid,       //FFTƵ��������Ч�ź�
    
    input             data_req,        //���������ź�
    input             fft_point_done,  //FFT��ǰƵ�׻������
    output reg [7:0]  fft_point_cnt,   //FFTƵ��λ��
    //ram�˿�  
    output     [31:0]  ram_data_out     //ram�����Ч����
);

//parameter define
parameter TRANSFORM_LEN = 256;        //FFT��������:256

//reg define
reg  [7:0]    ram_raddr;		//ram����ַ
reg           data_invalid;   	//������Ч��־������Ч
reg  [7:0]    ram_waddr;		//ramд��ַ

//wire define
wire          ram_wr_en;     	//ramдʹ��
wire  [31:0]  ram_wr_data;      //ramд����
wire  [31:0]  ram_rd_data;      //ram������

//*****************************************************
//**                    main code
//***************************************************** 


//����ramдʹ��
assign ram_wr_en  = fft_valid;
//����ramд����
assign ram_wr_data = fft_data;
//��������Ч��־Ϊ�͵�ʱ��ram�����ݸ�ֵ��ram�����Ч�����ź�
assign ram_data_out = data_invalid ? 32'd0 : ram_rd_data;


//����ram��ַ
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) 
        ram_waddr  <= 8'd0;
    else if(fft_eop)
        ram_waddr  <= 8'd0;        
    else if(ram_wr_en)
        ram_waddr  <= ram_waddr + 8'd1;
    else
        ram_waddr  <= ram_waddr;          
end

//��ǰ��ram�ж����ĵڼ����㣬fft_point_cnt��0~127��
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

//����ram����ַ
always @(posedge lcd_clk or negedge rst_n) begin
    if(!rst_n) 
        ram_raddr <= 8'd0;
    else begin
        if(fft_point_done)   
            ram_raddr <= 8'd0;               
        else if(data_req)   
            ram_raddr <= ram_raddr + 1'b1;
        else
            ram_raddr <= ram_raddr;          
    end
end

//����������Ч��־����Ϊfft�������ǶԳƵģ�����ֻҪȡǰһ�����ݾͿ�����
always @(posedge lcd_clk or negedge rst_n) begin
    if(!rst_n) 
        data_invalid <= 1'd0;
    else begin
        if(fft_point_done)   
            data_invalid <= 1'd0;               
        else if(ram_raddr == TRANSFORM_LEN/2)   
            data_invalid <= 1'd1; 
        else
            data_invalid <= data_invalid;           
    end
end

single_ram
#(
   .C_ADDR_WIDTH (8) ,
   .C_DATA_WIDTH (32)
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
