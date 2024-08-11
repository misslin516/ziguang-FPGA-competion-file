//////////////////////////////////////////////////////////////////////////////////
// Module Name:    udp
//////////////////////////////////////////////////////////////////////////////////

module udp(
			input wire           reset_n,
			
			input	 wire           e_rxc,
			input  wire	[7:0]	    e_rxd, 
			input	 wire           e_rxdv,	
			output wire 	       data_o_valid,                        //接收数据有效信号// 
			output wire [31:0]    ram_wr_data,                         //接收到的32bit IP包数据//  
			output wire [15:0]    rx_total_length,                     //接收IP包的总长度
			output wire [15:0]    mydata_num,                          //for chipscope test
			output wire [3:0]     rx_state,                            //for chipscope test
			output wire [15:0]    rx_data_length,		                 //接收IP包的数据长度/
		   output wire [11:0]     ram_wr_addr,
		
			output wire	          e_txen,
			output wire	[7:0]     e_txd,                              
			output wire		       e_txer,
			input  wire [31:0]    ram_rd_data,
		   output      [3:0]     tx_state,
			output      [31:0]    datain_reg,                          //for chipscope test
			input  wire [15:0]    tx_data_length,                      //发送IP包的数据长度/
			input  wire [15:0]    tx_total_length,                     //发送IP包的总长度/
		   output wire [11:0]     ram_rd_addr,
			output wire           data_receive,
			output wire sendstart,//udp发送数据 开始/结束
			output reg sendcmd,
			input senden
			//output reg[3:0] led
);


wire	[31:0] crcnext;
wire	[31:0] crc32;
wire	crcreset;
wire	crcen;

reg[3:0] cmd_in;//转化pc发送来的数据为控制代码
//reg sendcmd;
wire sendend;

always @(negedge e_rxc)
if(!reset_n)
begin
	cmd_in <= 0;
	sendcmd <= 0;
	//led<=0;
end
else
begin
	if(data_o_valid )
	begin
		//led=ram__data
		if(ram_wr_data[31:24]==49)
		begin
			cmd_in <= 1;//发送采集数据命令
			sendcmd <= 1;
			//led<=4'b1100;
		end
		else if(ram_wr_data == 2)
		begin
			cmd_in <= 2;
		end	
	end
	else if(sendend==1)
	begin
		cmd_in <= 0;
		sendcmd <=0;
	end
end

//IP frame发送
ipsend ipsend_inst(
	.clk(e_rxc),
	.clr(1'b1),
	.txen(e_txen),
	.txer(e_txer),
	.dataout(e_txd),
	.crc(crc32),
	.datain(ram_rd_data),
	.crcen(crcen),
	.crcre(crcreset),
	.crc_valid(crc_valid),
	.tx_state(tx_state),
//	.datain_reg(datain_reg),
	.tx_data_length(tx_data_length),
	.tx_total_length(tx_total_length),
	.ram_rd_addr(ram_rd_addr),
	.cmd_in(cmd_in),
	.sendstart(sendstart),
	//.led(led)
	.senden(senden),
	.sendend(sendend)
	);
	
//crc32校验
crc	crc_inst(
	.Clk(e_rxc),
	.Reset(crcreset),
	.Enable(crcen),
	.Data_in(e_txd),
	.Crc(crc32),
	.CrcNext(crcnext));

//IP frame接收程序
iprecieve iprecieve_inst(
	.clk(e_rxc),
	.datain(e_rxd),
	.e_rxdv(e_rxdv),	
	.clr(reset_n),
	.board_mac(),	
	.pc_mac(),
	.IP_Prtcl(),
	.IP_layer(),
	.pc_IP(),	
	.board_IP(),
	.UDP_layer(),
	.mydata_num(mydata_num),
	.data_o(ram_wr_data),	
	.valid_ip_P(),
	.rx_total_length(rx_total_length),
	.data_o_valid(data_o_valid),                                       
	.rx_state(rx_state),
	.rx_data_length(rx_data_length),
	.ram_wr_addr(ram_wr_addr),
	.data_receive(data_receive)
	//.led(led)
	);
	
endmodule
