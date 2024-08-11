module start_transfer_ctrl(
    input                 clk                ,   //ʱ���ź�
    input                 rst_n              ,   //��λ�źţ��͵�ƽ��Ч
    input                 udp_rec_pkt_done   ,   //UDP�������ݽ�������ź� 
    input                 udp_rec_en         ,   //UDP���յ�����ʹ���ź�
    input        [7 :0]   udp_rec_data       ,   //UDP���յ����� 
    input        [15:0]   udp_rec_byte_num   ,   //UDP���յ����ֽ���
                                  
    output  reg           transfer_flag          //ͼ��ʼ�����־,1:��ʼ���� 0:ֹͣ����
    );    
    
//parameter define
parameter  START = "1";  //��ʼ����
parameter  STOP  = "0";  //ֹͣ����

//*****************************************************
//**                    main code
//*****************************************************

//�������յ�������
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        transfer_flag <= 1'b0;
    else if(udp_rec_pkt_done && udp_rec_byte_num == 1'b1) begin
        if(udp_rec_data == START)         //��ʼ����
            transfer_flag <= 1'b1;
        else if(udp_rec_data == STOP)     //ֹͣ����
            transfer_flag <= 1'b0;
		else ;
    end
end 

endmodule