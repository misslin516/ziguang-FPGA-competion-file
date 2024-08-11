
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    ethernet_test
//////////////////////////////////////////////////////////////////////////////////
module Ethernet(
					input reset_n,                           
					input  fpga_gclk,                   
					output e_reset,

               output e_mdc,
					inout  e_mdio,
		
            
					input	 e_rxc,                       //125Mhz ethernet gmii rx clock
					input	 e_rxdv,	
					input	 e_rxer,						
					input  [7:0] e_rxd,        

					input	 e_txc,                     //25Mhz ethernet mii tx clock         
					output e_gtxc,                    //25Mhz ethernet gmii tx clock  
					output e_txen, 
					output e_txer, 					
					output [7:0] e_txd,
			
					output ad_0_clk,
					input [11:0] ad_0_data,
					output ad_1_clk,
					input  [11:0] ad_1_data	,
					output reg[3:0] led
  
    );
                

wire [31:0] ram_wr_data;
wire [31:0] ram_rd_data;
wire [11:0] ram_wr_addr;
wire [11:0] ram_rd_addr;

assign e_gtxc=e_rxc;	 
assign e_reset = 1'b1; 

reg	[7:0] ad_0_data_reg[2:0];
reg	[7:0] ad_1_data_reg[2:0];

wire [31:0] datain_reg;
         
wire [3:0] tx_state;
wire [3:0] rx_state;
wire [15:0] rx_total_length;          //rx 的IP包的长度
wire [15:0] tx_total_length;          //tx 的IP包的长度
wire [15:0] rx_data_length;           //rx 的UDP的数据包长度
wire [15:0] tx_data_length;           //rx 的UDP的数据包长度

wire data_receive;
reg ram_wr_finish;

reg [31:0] udp_data [6:0];                        //存储发送字符
reg [31:0] ad_data_ram;
reg ram_wren_i;
reg [11:0] ram_addr_i;
reg [31:0] ram_data_i;
reg [11:0] i=0;

reg		initial_0 = 0;
reg senden;
wire data_o_valid;
wire wea;
wire [11:0] addra;
wire [31:0] dina;

wire[11:0] AD_ram_rd_addr;
wire[11:0] AD_ram_data;
wire[11:0] AD_ram_wr_addr;
wire AD_wren;
wire sendstart;
wire sendcmd;

assign wea=ram_wr_finish?data_o_valid:ram_wren_i;
assign addra=ram_wr_finish?ram_wr_addr:ram_addr_i;
assign dina=ram_wr_finish?ram_wr_data:ram_data_i;


assign tx_data_length=36;//data_receive?rx_data_length:36;
assign tx_total_length=56;//data_receive?rx_total_length:56;

////////udp发送和接收程序/////////////////// 
udp u1(
	.reset_n(reset_n),
	.e_rxc(e_rxc),
	.e_rxd(e_rxd),
   .e_rxdv(e_rxdv),
	.data_o_valid(data_o_valid),                    //数据接收有效信号,写入RAM/
	.ram_wr_data(ram_wr_data),                      //接收到的32bit数据写入RAM/	
	.rx_total_length(rx_total_length),              //接收IP包的总长度/
	.mydata_num(mydata_num),                        //for chipscope test
	.rx_state(rx_state),                            //for chipscope test
	.rx_data_length(rx_data_length),                //接收IP包的数据长度/	
	.ram_wr_addr(ram_wr_addr),
	.data_receive(data_receive),
	
	.e_txen(e_txen),
	.e_txd(e_txd),
	.e_txer(e_txer),	
	.ram_rd_data(ram_rd_data),                      //RAM读出的32bit数据/
	.tx_state(tx_state),                            //for chipscope test
	.datain_reg(datain_reg),                        //for chipscope test
	.tx_data_length(tx_data_length),                //发送IP包的数据长度/	
	.tx_total_length(tx_total_length),              //接发送IP包的总长度/
	.ram_rd_addr(ram_rd_addr),
	.sendstart(sendstart),
	.sendcmd(sendcmd),
	.senden(senden)
	//.led(led)
	);


//////////ram用于存储以太网接收到的数据或测试数据///////////////////
/*
ram ram_inst
(
	.data			(dina),
	.inclock		(e_rxc),
	.outclock	(e_rxc),
	.rdaddress	(ram_rd_addr),
	.wraddress	(addra),
	.wren			(wea),
	.q				(ram_rd_data)
);
*/
ram1	ram1_inst (
	.clock ( e_rxc ),
	.data ( dina ),
	.rdaddress ( ram_rd_addr ),
	.wraddress ( addra ),
	.wren ( wea ),
	.q ( ram_rd_data )
	);

	
//////////写入默认发送的数据(0 x data data)//////////////////
always@(negedge e_rxc)
begin	
  if(!reset_n) 
  begin
     ram_wr_finish<=1'b0;
	  ram_addr_i<=0;
	  ram_data_i<=0;
	  i<=0;led<=0;
	  initial_0<=1'b0;
	 // sendcmd <= 0;
		senden<=0;
  end
  else begin
  
		if(!sendstart )
		begin
			//led<=4'b1000;
			if(i==4095) 
			begin
				ram_wren_i<=1'b0;	
				initial_0<=1'b1;
				if(!sendcmd) begin
					led<=4'b1000;
					i <= 0;
					ram_addr_i<=0;
					ram_data_i<=0;
				end
				else
				begin
					senden <= 1;
					led <= 4'b1111;
				end
			end
			else 
			begin
				ram_wren_i<=1'b1;
				ram_addr_i<=ram_addr_i+1'b1;
				ram_data_i<=udp_data[(i%7)];
				i<=i+1'b1;
			end			
		end
		else
		begin
			//led<=4'b0001;
			ram_addr_i<=0;
			ram_data_i<=0;
			i<=0;		
			senden <=0;
		end
  end 
end 

PLL	pll(
	.areset	(~reset_n),
	.inclk0	(fpga_gclk),
	.c0		(ad_0_clk),
	.c1		(ad_1_clk)
);

reg	[11:0]	reg_0_0;
reg	[3:0]		reg_0_1;
reg	[11:0]	reg_1_0;
reg	[3:0]		reg_1_1;

reg	[3:0]		Num_0;
reg	[3:0]		Num_1;

always @(posedge e_rxc)
begin
	case(Num_0)
		4'h0	:	begin
					if(!sendstart)
						begin
							reg_0_0 <= ad_0_data[11:0];
							reg_0_1 <= ad_0_data[3:0];
							Num_0   <= 4'h1; 
						end
						else
							Num_0 <= 4'h0;
					end
		4'h1	:	begin
						reg_0_1 	<= reg_0_0[7:4];
						Num_0 	<= 4'h2;
					end
		4'h2	:	begin
						reg_0_1 	<= reg_0_0[11:8];
						Num_0 	<= 4'h3;						
					end
		4'h3	:	begin
						Num_0 	<= 4'h0;						
					end			
		default:	begin
						Num_0 	<= 4'h0;	
					end				
	endcase	
	
	if((Num_0==1)||(Num_0==2)||(Num_0==3))
	begin
		case(reg_0_1)
			4'h0	:	ad_0_data_reg[Num_0-1] <=	8'h30;
			4'h1	:	ad_0_data_reg[Num_0-1] <=	8'h31;
			4'h2	:	ad_0_data_reg[Num_0-1] <=	8'h32;
			4'h3	:	ad_0_data_reg[Num_0-1] <=	8'h33;
			4'h4	:	ad_0_data_reg[Num_0-1] <=	8'h34;
			4'h5	:	ad_0_data_reg[Num_0-1] <=	8'h35;
			4'h6	:	ad_0_data_reg[Num_0-1] <=	8'h36;
			4'h7	:	ad_0_data_reg[Num_0-1] <=	8'h37;
			4'h8	:	ad_0_data_reg[Num_0-1] <=	8'h38;
			4'h9	:	ad_0_data_reg[Num_0-1] <=	8'h39;
			4'hA	:	ad_0_data_reg[Num_0-1] <=	8'h41;
			4'hB	:	ad_0_data_reg[Num_0-1] <=	8'h42;
			4'hC	:	ad_0_data_reg[Num_0-1] <=	8'h43;
			4'hD	:	ad_0_data_reg[Num_0-1] <=	8'h44;
			4'hE	:	ad_0_data_reg[Num_0-1] <=	8'h45;
			4'hF	:	ad_0_data_reg[Num_0-1] <=	8'h46;
			default:	ad_0_data_reg[Num_1-1] <=	8'h30;	
		endcase		
	end
end

always @(posedge e_rxc)
begin
	case(Num_1)
		4'h0	:	begin
						if(!sendstart)
						begin
							reg_1_0 <= ad_1_data[11:0];
							reg_1_1 <= ad_1_data[3:0];
							Num_1   <= 4'h1; 
						end
						else
							Num_1 <= 4'h0;
					end
		4'h1	:	begin
						reg_1_1 	<= reg_1_0[7:4];
						Num_1 	<= 4'h2;
					end
		4'h2	:	begin
						reg_1_1 	<= reg_1_0[11:8];
						Num_1 	<= 4'h3;						
					end
		4'h3	:	begin
						Num_1 	<= 4'h0;						
					end
		default:	begin
						Num_1 	<= 4'h0;	
					end				
	endcase	
	
	if((Num_1==1)||(Num_1==2)||(Num_1==3))
	begin
		case(reg_1_1)
			4'h0	:	ad_1_data_reg[Num_1-1] <=	8'h30;
			4'h1	:	ad_1_data_reg[Num_1-1] <=	8'h31;
			4'h2	:	ad_1_data_reg[Num_1-1] <=	8'h32;
			4'h3	:	ad_1_data_reg[Num_1-1] <=	8'h33;
			4'h4	:	ad_1_data_reg[Num_1-1] <=	8'h34;
			4'h5	:	ad_1_data_reg[Num_1-1] <=	8'h35;
			4'h6	:	ad_1_data_reg[Num_1-1] <=	8'h36;
			4'h7	:	ad_1_data_reg[Num_1-1] <=	8'h37;
			4'h8	:	ad_1_data_reg[Num_1-1] <=	8'h38;
			4'h9	:	ad_1_data_reg[Num_1-1] <=	8'h39;
			4'hA	:	ad_1_data_reg[Num_1-1] <=	8'h41;
			4'hB	:	ad_1_data_reg[Num_1-1] <=	8'h42;
			4'hC	:	ad_1_data_reg[Num_1-1] <=	8'h43;
			4'hD	:	ad_1_data_reg[Num_1-1] <=	8'h44;
			4'hE	:	ad_1_data_reg[Num_1-1] <=	8'h45;
			4'hF	:	ad_1_data_reg[Num_1-1] <=	8'h46;
			default:	ad_1_data_reg[Num_1-1] <=	8'h30;
		endcase		
	end	
end

/********************************************/
//存储待发送的字符
/********************************************/
always @(posedge e_rxc)
begin     //定义发送的字符
	if(!sendstart)
	begin
		if(!initial_0)
		begin
			udp_data[0]<={8'h48,8'h45,8'h4c,8'h4c};	//H		E		L		L 
			udp_data[1]<={8'h4f,8'h20,8'h57,8'h4f};	//O		空格	W		O 
			udp_data[2]<={8'h52,8'h4c,8'h44,8'h0a};	//R		L		D		转行
			udp_data[3]<={8'h77,8'h77,8'h77,8'h2e};	//w		w		w		. 	 
			udp_data[4]<={8'h68,8'h73,8'h65,8'h64};	//h		s		e		d                           
			udp_data[5]<={8'h61,8'h2e,8'h63,8'h6f};	//a		.		c		o	
			udp_data[6]<={8'h6d,8'h20,8'h20,8'h0a};	//m		空格	空格	换行
		end	
		else
		begin
			udp_data[0]<={8'h41,					8'h44,				8'h31,				8'h3a					};	//A		D		1		:		
			udp_data[1]<={8'h30,					8'h78,				ad_0_data_reg[2],	ad_0_data_reg[1]	};	//0		x		数据	数据
			//ad_data_ram<={8'h30,					8'h78,				ad_0_data_reg[2],	ad_0_data_reg[1]	};	//0		x		数据	数据
			udp_data[2]<={ad_0_data_reg[0],	8'h20,				8'h20,				8'h20					}; //数据		空格	空格	空格
			udp_data[3]<={8'h20,					8'h20,				8'h20,				8'h20					};	//空格		空格	空格	空格		
			udp_data[4]<={8'h41,					8'h44,				8'h32,				8'h3a					};	//A		D		2		:		
			udp_data[5]<={8'h30,					8'h78,				ad_1_data_reg[2],	ad_1_data_reg[1]	};	//0		x		数据	数据
			udp_data[6]<={ad_1_data_reg[0],	8'h20,				8'h20,				8'h0a					}; //数据		空格	空格	空格
		end
	end	
end 

endmodule
