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

`define resolution_720
module video_driver
(
    input           	pixel_clk	,
    input           	sys_rst_n	,
		
    //RGB�ӿ�	
    output          	video_hs	,     //��ͬ���ź�
    output          	video_vs	,     //��ͬ���ź�
    output          	video_de	,     //����ʹ��
    output  	[23:0]  video_rgb	,    //RGB888��ɫ����
   
	
    input   	[23:0]  pixel_data	,   //���ص�����
    output  wire[10:0]  pixel_xpos	,   //���ص������
    output  wire[10:0]  pixel_ypos    //���ص�������
);
//the following parameter is defined differ  resolution
//parameter define
`ifdef resolution_720
//1280*720 �ֱ���ʱ�����
    parameter  H_SYNC   =  11'd40;   //��ͬ��
    parameter  H_BACK   =  11'd220;  //����ʾ����
    parameter  H_DISP   =  11'd1280; //����Ч����
    parameter  H_FRONT  =  11'd110;  //����ʾǰ��
    parameter  H_TOTAL  =  11'd1650; //��ɨ������

    parameter  V_SYNC   =  11'd5;    //��ͬ��
    parameter  V_BACK   =  11'd20;   //����ʾ����
    parameter  V_DISP   =  11'd720;  //����Ч����
    parameter  V_FRONT  =  11'd5;    //����ʾǰ��
    parameter  V_TOTAL  =  11'd750;  //��ɨ������
`else
//1920*1080�ֱ���ʱ�����
    parameter  H_SYNC   =  12'd44;   //��ͬ��
    parameter  H_BACK   =  12'd148;  //����ʾ����
    parameter  H_DISP   =  12'd1920; //����Ч����
    parameter  H_FRONT  =  12'd88;  //����ʾǰ��
    parameter  H_TOTAL  =  12'd2200; //��ɨ������

    parameter  V_SYNC   =  12'd5;    //��ͬ��
    parameter  V_BACK   =  12'd36;   //����ʾ����
    parameter  V_DISP   =  12'd1080;  //����Ч����
    parameter  V_FRONT  =  12'd4;    //����ʾǰ��
    parameter  V_TOTAL  =  12'd1125;  //��ɨ������
`endif


//reg define
reg  [11:0] cnt_h;
reg  [11:0] cnt_v;
wire       	video_en;

//*****************************************************
//**                    main code
//*****************************************************

assign video_de  = video_en;
assign video_hs  = ( cnt_h < H_SYNC ) ? 1'b0 : 1'b1;  //��ͬ���źŸ�ֵ
assign video_vs  = ( cnt_v < V_SYNC ) ? 1'b0 : 1'b1;  //��ͬ���źŸ�ֵ

//ʹ��RGB�������
assign video_en  = (((cnt_h >= H_SYNC+H_BACK) && (cnt_h < H_SYNC+H_BACK+H_DISP))
                 &&((cnt_v >= V_SYNC+V_BACK) && (cnt_v < V_SYNC+V_BACK+V_DISP)))
                 ?  1'b1 : 1'b0;



//RGB888�������
assign video_rgb = video_de ? pixel_data : 24'd0;

wire data_req;
//�������ص���ɫ��������
assign data_req = (((cnt_h >= H_SYNC+H_BACK-1'b1) && (cnt_h < H_SYNC+H_BACK+H_DISP-1'b1))
                  && ((cnt_v >= V_SYNC+V_BACK) && (cnt_v < V_SYNC+V_BACK+V_DISP)))
                  ?  1'b1 : 1'b0;




//���ص�����
assign pixel_xpos = data_req ? (cnt_h - (H_SYNC + H_BACK - 1'b1)) : 11'd0;
assign pixel_ypos = data_req ? (cnt_v - (V_SYNC + V_BACK - 1'b1)) : 11'd0;

//�м�����������ʱ�Ӽ���
always @(posedge pixel_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        cnt_h <= 11'd0;
    else begin
        if(cnt_h < H_TOTAL - 1'b1)
            cnt_h <= cnt_h + 1'b1;
        else 
            cnt_h <= 11'd0;
    end
end

//�����������м���
always @(posedge pixel_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        cnt_v <= 11'd0;
    else if(cnt_h == H_TOTAL - 1'b1) begin
        if(cnt_v < V_TOTAL - 1'b1)
            cnt_v <= cnt_v + 1'b1;
        else 
            cnt_v <= 11'd0;
    end
end

endmodule