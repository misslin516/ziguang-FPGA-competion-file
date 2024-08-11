
module ddr_data_inandout(
    input             clk_50m       ,   //ʱ��
    input             rst_n         ,   //��λ,����Ч
                                        
    output reg        wr_en         ,   //дʹ��
    output reg [15:0] wr_data       ,   //д����
    output reg        rd_en         ,   //��ʹ��
    input      [15:0] rd_data       ,   //������
    input      [27:0] data_max      ,   //д��ddr�����������
    
    input             ddr3_init_done,   //ddr3��ʼ������ź�
    output reg        error_flag        //ddr3��д����
    
    );

//reg define
reg        init_done_d0;
reg        init_done_d1;
reg [27:0] wr_cnt      ;   //д����������
reg [27:0] rd_cnt      ;   //������������
reg        rd_valid    ;   //��������Ч��־
reg [27:0] rd_cnt_d0   ;
  
//*****************************************************
//**                    main code
//***************************************************** 

//ͬ��ddr3��ʼ������ź�
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        init_done_d0 <= 1'b0 ;
        init_done_d1 <= 1'b0 ;
    end
    else begin
        init_done_d0 <= ddr3_init_done;
        init_done_d1 <= init_done_d0;
    end
end

//�Զ���������һ����ʱʹ���ݶ���
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n)
        rd_cnt_d0    <= 28'd0;
    else
        rd_cnt_d0 <= rd_cnt;
end 

//ddr3��ʼ�����֮��,д������������ʼ����
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) 
        wr_cnt <= 28'd0;
    else if(init_done_d1 && (wr_cnt < data_max ))
        wr_cnt <= wr_cnt + 1'b1;
    else 
        wr_cnt <= wr_cnt;
end    

//ddr3д�˿�FIFO��дʹ�ܡ�д����
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        wr_en   <= 1'b0;
        wr_data <= 16'd0;
    end
    else if(wr_cnt >= 11'd0 && (wr_cnt < data_max )&&init_done_d1) begin
            wr_en   <= 1'b1;            //дʹ������
            wr_data <= wr_cnt[15:0];    //д������
    end    
    else begin
            wr_en   <= 1'b0;
            wr_data <= 16'd0;
    end
end

//д��������ɺ�,��ʼ������
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) 
        rd_en <= 1'b0;
    else if(wr_cnt >= data_max )         //д�������
        rd_en <= 1'b1;                   //��ʹ��
    else
        rd_en <= rd_en;
end

//�Զ���������
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) 
        rd_cnt <= 28'd0;
    else if(rd_en) begin
        if(rd_cnt < data_max - 1'd1)
            rd_cnt <= rd_cnt + 1'd1;
        else
            rd_cnt <= 28'd0;
    end
end

//��һ�ζ�ȡ��������Ч,��������������ȡ�����ݲ���Ч
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) 
        rd_valid <= 1'b0;
    else if(rd_cnt >= data_max - 1'd1 )  //�ȴ���һ�ζ���������
        rd_valid <= 1'b1;                //������ȡ��������Ч
    else
        rd_valid <= rd_valid;
end

//��������Чʱ,����ȡ���ݴ���,������־�ź�
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n)
        error_flag <= 1'b0; 
    else if(wr_en)       
        error_flag <= 1'b0;      
    else if(rd_valid && ((rd_data[15:0] != rd_cnt_d0[15:0])) )
        error_flag <= 1'b1;             //����ȡ�����ݴ���,�������־λ����
    else
        error_flag <= error_flag;
end

endmodule