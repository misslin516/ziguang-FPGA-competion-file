`timescale 1ns / 1ps
module ipsend(
				  input              clk,
				  output reg         txen,
				  output reg         txer,
				  output reg [7:0]   dataout,
				  input              clr,  				  
				  input      [31:0]  crc,
				  input      [31:0]  datain,
				  output reg         crcen,
				  output reg         crcre,
				  output reg         crc_valid,
				  output reg [3:0]   tx_state,
				  output reg [31:0]  datain_reg,
				  input      [15:0]  tx_data_length,
				  input      [15:0]  tx_total_length,
				  output reg [11:0]   ram_rd_addr,
				  input[3:0] cmd_in,
				  output reg sendstart,
				  input senden,
				  output reg sendend
				  //output reg[3:0] led
	  );


	  
reg [31:0] ip_header [6:0];                  //数据段为1K

reg [7:0] preamble [7:0];                    //preamble
reg [7:0] mac_addr [13:0];                   //mac address
reg [4:0] i,j;
reg [9:0] k;

reg [31:0] check_buffer;
reg [31:0] time_counter=32'h04000000;

reg [15:0] tx_data_counter;

parameter idle=4'b0000,start=4'b0001,make=4'b0010,send55=4'b0011,sendmac=4'b0100,sendheader=4'b0101,
          senddata=4'b0110,sendcrc=4'b0111;



initial
  begin
	 // tx_state<=idle;
	 //定义IP 包头
	 preamble[0]<=8'h55;                 //7个前导码55,一个帧开始符d5
	 preamble[1]<=8'h55;
	 preamble[2]<=8'h55;
	 preamble[3]<=8'h55;
	 preamble[4]<=8'h55;
	 preamble[5]<=8'h55;
	 preamble[6]<=8'h55;
	 preamble[7]<=8'hD5;
	 mac_addr[0]<=8'h30;                 //目的MAC地址 D8-D3-85-77-C6-71
	 mac_addr[1]<=8'h65;
	 mac_addr[2]<=8'hEC;
	 mac_addr[3]<=8'h40;
	 mac_addr[4]<=8'h0B;
	 mac_addr[5]<=8'hF3;
	 mac_addr[6]<=8'h00;                 //源MAC地址 00-0A-35-01-FE-C0
	 mac_addr[7]<=8'h0A;
	 mac_addr[8]<=8'h35;
	 mac_addr[9]<=8'h01;
	 mac_addr[10]<=8'hFE;
	 mac_addr[11]<=8'hC0;
	 mac_addr[12]<=8'h08;                //0800: IP包类型
	 mac_addr[13]<=8'h00;
	 i<=0;
	 k<=0;
	 sendstart<=0;
	 ram_rd_addr <= 1;
	 //led<=0;
 end


	 
always@(negedge clk)
begin		
		case(tx_state)
		  idle:begin
			    crc_valid<=1'b0;
				 txer<=1'b0;
				 txen<=1'b0;
				 crcen<=1'b0;
				 crcre<=1;
				 j<=0;
				 dataout<=0;
				 tx_data_counter<=0;
				 sendend <= 0;
				 if(cmd_in==1 & senden==1)
				 begin
						sendstart <= 1;
						sendend <= 0;
				 end
             if (time_counter>=32'h040000 & sendstart) begin          //等待延迟
						
						if(k<512)
						begin
							tx_state<=start; 
							k<=k+1;
						end
						else
						begin
							sendstart <= 0;
							sendend<=1;
							k <=0;
							ram_rd_addr <= 1;
						end	
							time_counter<= 0;
             end
             else
                 time_counter<=time_counter+1'b1;				
			end
		   start:begin
					ip_header[0]<={16'h4500,tx_total_length};        //版本号：4； 包头长度：20；IP包总长
				   ip_header[1][31:16]<=ip_header[1][31:16]+1'b1;   //包序列号
					ip_header[1][15:0]<=16'h4000;                    //Fragment offset
				   ip_header[2]<=32'h80110000;                      //mema[2][15:0] 协议：17(UDP)
				   ip_header[3]<=32'hc0a80002;                      //192.168.0.2源地址
				   ip_header[4]<=32'hc0a80003;                      //192.168.0.3目的地址广播地址
					ip_header[5]<=32'h1f901f90;                      //2个字节的源端口号和2个字节的目的端口号
				   ip_header[6]<={tx_data_length,16'h0000};         //2个字节的数据长度和2个字节的校验和（无）
	   			tx_state<=make;
         end	
         make:begin            //生成包头的校验和
			    if(i==0) begin
					  check_buffer<=ip_header[0][15:0]+ip_header[0][31:16]+ip_header[1][15:0]+ip_header[1][31:16]+ip_header[2][15:0]+
					               ip_header[2][31:16]+ip_header[3][15:0]+ip_header[3][31:16]+ip_header[4][15:0]+ip_header[4][31:16];
                 i<=i+1'b1;
				   end
             else if(i==1) begin
					   check_buffer[15:0]<=check_buffer[31:16]+check_buffer[15:0];
					   i<=i+1'b1;
				 end
			    else	begin
				      ip_header[2][15:0]<=~check_buffer[15:0];                 //header checksum
					   i<=0;
					   tx_state<=send55;
					end
		   end
			send55: begin                    //发送8个IP前导码:7个55, 1个d5                    
 				 txen<=1'b1;
				 crcre<=1'b1;                            //reset crc  
				 if(i==7) begin
               dataout[7:0]<=preamble[i][7:0];
					i<=0;
				   tx_state<=sendmac;
				 end
				 else begin                        
				    dataout[7:0]<=preamble[i][7:0];
				    i<=i+1;
				 end
			end	
			sendmac: begin                           //发送目标MAC address和源MAC address  
			 	 crcen<=1'b1;                            //crc校验使能		
				 crcre<=1'b0;                            			
             if(i==13) begin
               dataout[7:0]<=mac_addr[i][7:0];
					i<=0;
				   tx_state<=sendheader;
				 end
				 else begin                        
				    dataout[7:0]<=mac_addr[i][7:0];
				    i<=i+1'b1;
				 end
			end
			sendheader: begin                        //发送7个32bit的IP 包头
			   if(j==6) begin                             
					  if(i==0) begin
						 dataout[7:0]<=ip_header[j][31:24];
						 i<=i+1'b1;
					  end
					  else if(i==1) begin
						 dataout[7:0]<=ip_header[j][23:16];
						 i<=i+1'b1;
					  end
					  else if(i==2) begin
						 dataout[7:0]<=ip_header[j][15:8];
						 i<=i+1'b1;
					  end
					  else if(i==3) begin
						 dataout[7:0]<=ip_header[j][7:0];
						 i<=0;
						 j<=0;
						 tx_state<=senddata;			 
					  end
					  else
						 txer<=1'b1;
				end		 
				else begin
					  if(i==0) begin
						 dataout[7:0]<=ip_header[j][31:24];
						 i<=i+1'b1;
					  end
					  else if(i==1) begin
						 dataout[7:0]<=ip_header[j][23:16];
						 i<=i+1'b1;
					  end
					  else if(i==2) begin
						 dataout[7:0]<=ip_header[j][15:8];
						 i<=i+1'b1;
					  end
					  else if(i==3) begin
						 dataout[7:0]<=ip_header[j][7:0];
						 i<=0;
						 j<=j+1'b1;
					  end					
					  else
						 txer<=1'b1;
				end
			 end
			 senddata:begin                                      //发送UDP数据包
			   if(tx_data_counter==tx_data_length-9) begin       //发送最后的数据
				   tx_state<=sendcrc;	
					if(i==0) begin    
					  dataout[7:0]<=datain[31:24];
					  i<=0;
					end
					else if(i==1) begin
					  dataout[7:0]<=datain[23:16];
					  i<=0;
					end
					else if(i==2) begin
					  dataout[7:0]<=datain[15:8];
					  i<=0;
					end
					else if(i==3) begin
			        dataout[7:0]<=datain[7:0];
					  i<=0;
					end
            end
            else begin                                     //发送其它的数据包
               tx_data_counter<=tx_data_counter+1'b1;			
					if(i==0) begin    
					  dataout[7:0]<=datain[31:24];
					  i<=i+1'b1;
					end
					else if(i==1) begin
					  dataout[7:0]<=datain[23:16];
					  i<=i+1'b1;
					end
					else if(i==2) begin
					  dataout[7:0]<=datain[15:8];
					  i<=i+1'b1;
						ram_rd_addr<=ram_rd_addr+1'b1;
					end
					else if(i==3) begin
			        dataout[7:0]<=datain[7:0];
					  i<=0; 						  
					end
				end
			end	
			sendcrc: begin                              //发送32位的crc校验
				crcen<=1'b0;
				crc_valid<=1'b1;
				if(i==0)	begin
					  dataout[7:0] <= {~crc[24], ~crc[25], ~crc[26], ~crc[27], ~crc[28], ~crc[29], ~crc[30], ~crc[31]};
					  i<=i+1'b1;
					end
				else begin
				  if(i==1) begin
					   dataout[7:0]<={~crc[16], ~crc[17], ~crc[18], ~crc[19], ~crc[20], ~crc[21], ~crc[22], ~crc[23]};
						i<=i+1'b1;
				  end
				  else if(i==2) begin
					   dataout[7:0]<={~crc[8], ~crc[9], ~crc[10], ~crc[11], ~crc[12], ~crc[13], ~crc[14], ~crc[15]};
						i<=i+1'b1;
				  end
				  else if(i==3) begin
					   dataout[7:0]<={~crc[0], ~crc[1], ~crc[2], ~crc[3], ~crc[4], ~crc[5], ~crc[6], ~crc[7]};
						i<=0;
						tx_state<=idle;
						crc_valid<=1'b0;
				  end
				  else begin
                  txer<=1'b1;
				  end
				end
			end					
			default:tx_state<=idle;		
       endcase	  
 end
endmodule


