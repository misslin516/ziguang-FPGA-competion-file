//****************************************Copyright (c)***********************************//                        
//----------------------------------------------------------------------------------------
// original Created by:          ����ԭ��
// Created date:        2018/11/27 13:58:23
// Version:             V1.0
// Descriptions:        The original version
//  
// revised Created by:          NJUPT
// Created date:        2024/03/20 
//****************************************************************************************//

module  video_display
(    
    input             pixel_clk,                 //hdmi����ʱ��
    input             sys_rst_n,                //��λ�ź�
    
    input      [10:0] pixel_xpos,               //���ص������
    input      [10:0] pixel_ypos,               //���ص�������
    
    input      [15:0] fft_point_cnt,                 //Ƶ��
    input      [31:0] fft_data,              //Ƶ������
    output     reg       data_req,            //����Ƶ������
    output     reg      fft_point_done,                  //����Ƶ�����
    output    reg  [23:0] lcd_data                  //hdmi���ص����� RGB888
    
    );    


//parameter define    
parameter  H_DISP  = 11'd1280;                  //�ֱ���--��
parameter  V_DISP  = 11'd720;                   //�ֱ���--��


localparam WHITE   = 24'hffffff;    			// ��ɫ
localparam BLACK   = 24'h000000;    			// ��ɫ
localparam RED     = 24'hFF0000;//��ɫ


localparam GREEN = 24'h00FF00;  //��ɫ
localparam BLUE  = 24'h0000FF;  //��ɫ


//*****************************************************
//**                    main code
//*****************************************************

  
//����һ���������Ƶ�׿�ȣ����ε���ʾ�ĵ���256�������Բ��ø�4λ��Ϊ���  
wire [3:0] fft_step;    
assign fft_step = H_DISP[10:8] - 1;    


//�������������ź�
always @(posedge pixel_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        data_req <= 1'b0;
    else begin
        if((pixel_xpos  == (fft_point_cnt  + 1) * fft_step - 1) 
		    && (pixel_ypos >= 'b0) )
            data_req <= 1'b1;
       else
            data_req <= 1'b0;           
    end
end

//1�н���������done�źţ���ʾ�˴ε�Ƶ����ʾ�����
always @(posedge pixel_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        fft_point_done <= 1'b0;
    else begin
       if (pixel_xpos == H_DISP - 1)
            fft_point_done <= 1'b1;
       else
            fft_point_done <= 1'b0;           
    end
end   


always@(posedge pixel_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
       lcd_data <= 24'b0;
    end else begin
        if(pixel_xpos >= (fft_point_cnt * fft_step ) && (pixel_xpos <= ((fft_point_cnt + 1) * fft_step ))) begin 
            if (fft_data == 0) begin
              lcd_data <= WHITE; 
            end else if ((pixel_ypos >= V_DISP - fft_data) && (pixel_ypos <= V_DISP)) begin
               lcd_data <= RED;
            end else begin
               lcd_data <= WHITE; 
            end
    end
end 
end

endmodule