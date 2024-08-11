
module led_disp(
    input      clk_50m          , //ϵͳʱ��
    input      rst_n            , //ϵͳ��λ
                                  
    input      ddr3_init_done   , //ddr3��ʼ������ź�
    input      error_flag       , //�����־�ź�
    output reg led_error        , //��д����led��
    output reg led_ddr_init_done  //ddr3��ʼ�����led��             
    );

//reg define
reg [24:0] led_cnt     ;   //����LED��˸���ڵļ�����
reg        init_done_d0;                
reg        init_done_d1;

//*****************************************************
//**                    main code
//***************************************************** 

//ͬ��ddr3��ʼ������ź�
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        init_done_d0 <= 1'b0 ;
        init_done_d1 <= 1'b0 ;
    end
    else if (ddr3_init_done) begin
        init_done_d0 <= ddr3_init_done;
        init_done_d1 <= init_done_d0;	
    end
	else begin
        init_done_d0 <= init_done_d0;
        init_done_d1 <= init_done_d1;	
    end
end    

//����LED�Ʋ�ͬ����ʾ״ָ̬ʾDDR3��ʼ���Ƿ����
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n)
        led_ddr_init_done <= 1'd0;
    else if(init_done_d1) 
        led_ddr_init_done <= 1'd1;
    else
        led_ddr_init_done <= led_ddr_init_done;
end

//��������50MHzʱ�Ӽ�������������Ϊ0.5s
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n)
        led_cnt <= 25'd0;
    else if(led_cnt < 25'd25000000) 
        led_cnt <= led_cnt + 25'd1;
    else
        led_cnt <= 25'd0;
end

//����LED�Ʋ�ͬ����ʾ״ָ̬ʾ�����־�ĸߵ�
always @(posedge clk_50m or negedge rst_n) begin
    if(rst_n == 1'b0)
        led_error <= 1'b0;
    else if(error_flag) begin
        if(led_cnt == 25'd25000000) 
            led_error <= ~led_error;    //�����־Ϊ��ʱ��LED��ÿ��0.5s��˸һ��
        else
            led_error <= led_error;
    end    
    else
        led_error <= 1'b1;        //�����־Ϊ��ʱ��LED�Ƴ���
end

endmodule 