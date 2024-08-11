module start_transfer_ctrl(
    input                 clk                ,   //时钟信号
    input                 rst_n              ,   //复位信号，低电平有效
    input                 udp_rec_pkt_done   ,   //UDP单包数据接收完成信号 
    input                 udp_rec_en         ,   //UDP接收的数据使能信号
    input        [7 :0]   udp_rec_data       ,   //UDP接收的数据 
    input        [15:0]   udp_rec_byte_num   ,   //UDP接收到的字节数
                                  
    output  reg           transfer_flag          //图像开始传输标志,1:开始传输 0:停止传输
    );    
    
//parameter define
parameter  START = "1";  //开始命令
parameter  STOP  = "0";  //停止命令

//*****************************************************
//**                    main code
//*****************************************************

//解析接收到的数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        transfer_flag <= 1'b0;
    else if(udp_rec_pkt_done && udp_rec_byte_num == 1'b1) begin
        if(udp_rec_data == START)         //开始传输
            transfer_flag <= 1'b1;
        else if(udp_rec_data == STOP)     //停止传输
            transfer_flag <= 1'b0;
		else ;
    end
end 

endmodule