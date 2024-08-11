`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/16 23:40:05
// Design Name: 
// Module Name: eth_udp_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module eth_udp_test#(
    parameter       LOCAL_MAC = 48'h11_11_11_11_11_11,
    parameter       LOCAL_IP  = 32'hC0_A8_01_6E,//192.168.1.110
    parameter       LOCL_PORT = 16'h8080,

    parameter       DEST_IP   = 32'hC0_A8_01_69,//192.168.1.105
    parameter       DEST_PORT = 16'h8080 
)(

	input		data_in_vld /*synthesis PAP_MARK_DEBUG="1"*/,
   // input [7:0]	rd_data_0	/*synthesis PAP_MARK_DEBUG="1"*/,
   // input [7:0]	rd_data_1	/*synthesis PAP_MARK_DEBUG="1"*/,
	input	[7:0]	rx_data	/*synthesis PAP_MARK_DEBUG="1"*/,
	input			ram_w_end,


    input                rgmii_clk,
    input                rstn,
    input                gmii_rx_dv,
    input  [7:0]         gmii_rxd,
    output reg           gmii_tx_en,
    output reg [7:0]     gmii_txd,
                 
    output               udp_rec_data_valid,         
    output [7:0]         udp_rec_rdata ,             
    output [15:0]        udp_rec_data_length,
	output				start_rd
);
    
    localparam UDP_WIDTH = 32 ;
    localparam UDP_DEPTH = 5 ;
    reg   [7:0]          ram_wr_data /*synthesis PAP_MARK_DEBUG="1"*/;
    reg                  ram_wr_en /*synthesis PAP_MARK_DEBUG="1"*/;
    wire                 udp_ram_data_req ;
    reg [15:0]           udp_send_data_length;
      
    wire                 udp_tx_req ;
    wire                 arp_request_req ;
    wire                 mac_send_end ;
    reg                  write_end ;
    
    reg  [31:0]          wait_cnt ;
    
    wire                 mac_not_exist ;
    wire                 arp_found ;
    
	
	//assign	rx_data = rd_data_0 | rd_data_1;
	
	
	
    parameter IDLE          = 9'b000_000_001 ;
    parameter ARP_REQ       = 9'b000_000_010 ;
    parameter ARP_SEND      = 9'b000_000_100 ;
    parameter ARP_WAIT      = 9'b000_001_000 ;
    parameter GEN_REQ       = 9'b000_010_000 ;
    parameter WRITE_RAM     = 9'b000_100_000 ;
    parameter SEND          = 9'b001_000_000 ;
    parameter WAIT          = 9'b010_000_000 ;
    parameter CHECK_ARP     = 9'b100_000_000 ;
    parameter ONE_SECOND_CNT= 32'd125_000_000;//32'd12500;//
    
	parameter ADC_RAM = 9'b111_000_000;
	
    reg [8:0]    state /*synthesis PAP_MARK_DEBUG="1"*/ ;
    reg [8:0]    state_n /*synthesis PAP_MARK_DEBUG="1"*/;

    always @(posedge rgmii_clk)
    begin
        if (~rstn)
            state  <=  IDLE  ;
        else
            state  <= state_n ;
    end
      
    always @(*)
    begin
        case(state)
            IDLE        :
            begin
              if (wait_cnt == ONE_SECOND_CNT)    //1s
                    state_n = ARP_REQ ;
                else
                    state_n = IDLE ;
            end
            ARP_REQ     :
                state_n = ARP_SEND ;
            ARP_SEND    :
            begin
                if (mac_send_end)
                    state_n = ARP_WAIT ;
                else
                    state_n = ARP_SEND ;
            end
            ARP_WAIT    :
            begin
                if (1)
                    state_n = WAIT ;
                else if (wait_cnt == ONE_SECOND_CNT)
                    state_n = ARP_REQ ;
                else
                    state_n = ARP_WAIT ;
            end
            GEN_REQ     :
            begin
                if (udp_ram_data_req)
                    state_n = WRITE_RAM ;
				//	state_n = ADC_RAM ;
                else
                    state_n = GEN_REQ ;
            end
			
		//	ADC_RAM:
		//	begin
		//		if(cnt == 8)
		//			state_n = WRITE_RAM;
		//		else
		//			state_n = ADC_RAM;
		//	end
			
			
			
			
			
			
			
            WRITE_RAM   :
            begin
                if (write_end) 
                    state_n = WAIT     ;
                else
                    state_n = WRITE_RAM ;
            end
            SEND        :
            begin
                if (mac_send_end)
                    state_n = WAIT ;
                else
                    state_n = SEND ;
            end
			
            //WAIT        :
            //begin
    		//    if (wait_cnt == ONE_SECOND_CNT)    //1s
            //        state_n = CHECK_ARP ;
            //    else
            //        state_n = WAIT ;
            //end
            WAIT        :
            begin
    		    //if (wait_cnt == ONE_SECOND_CNT)    //1s
				//if(data_in_vld)
					if(ram_w_end)
                    state_n = CHECK_ARP ;
                else
                    state_n = WAIT ;
            end			
				
            CHECK_ARP   :
            begin
                if (0)
                    state_n = ARP_REQ ;
				else
                    state_n = GEN_REQ ;
            end
            default     : state_n = IDLE ;
        endcase
    end

wire	wr_full		/*synthesis PAP_MARK_DEBUG="1"*/;
wire	almost_full	/*synthesis PAP_MARK_DEBUG="1"*/;
wire	rd_empty	/*synthesis PAP_MARK_DEBUG="1"*/;
wire	almost_empty/*synthesis PAP_MARK_DEBUG="1"*/;
reg	almost_empty_d0;
reg	almost_empty_d1;
reg	almost_empty_d2;


reg		rd_en		/*synthesis PAP_MARK_DEBUG="1"*/;
wire	[7:0]rd_data	/*synthesis PAP_MARK_DEBUG="1"*/;


always@(posedge rgmii_clk )
begin
	almost_empty_d0 <= almost_empty   ;
	almost_empty_d1 <= almost_empty_d0;
	almost_empty_d2 <= almost_empty_d1;	
end


always@(posedge rgmii_clk or negedge rstn)
begin
	if(!rstn)
		rd_en <= 0;
	else if(state_n == WRITE_RAM)
		begin
			//if(test_cnt == 511)
			//	rd_en <= 0;
			//else 
			//	rd_en <= 1;
			if(!almost_empty_d2)
				rd_en <= 1;
			else
				rd_en <= 0;
		end
	else
		rd_en <= 0;
end


//UDP_fifo u_UDP_fifo (
//  .clk(rgmii_clk),                      // input
//  .rst(~rstn),                      // input
//  .wr_en(data_in_vld),                  // input
//  .wr_data(rx_data),              // input [7:0]
//  .wr_full(wr_full),              // output
//  .almost_full(almost_full),      // output
//  .rd_en(rd_en),                  // input
//  .rd_data(rd_data),              // output [7:0]
//  .rd_empty(rd_empty),            // output
//  .almost_empty(almost_empty)     // output
//);
//





    reg          gmii_rx_dv_1d;
    reg  [7:0]   gmii_rxd_1d;
    wire         gmii_tx_en_tmp;
    wire [7:0]   gmii_txd_tmp;
    
    always@(posedge rgmii_clk)
    begin
        if(rstn == 1'b0)
        begin
            gmii_rx_dv_1d <= 1'b0 ;
            gmii_rxd_1d   <= 8'd0 ;
        end
        else
        begin
            gmii_rx_dv_1d <= gmii_rx_dv ;
            gmii_rxd_1d   <= gmii_rxd ;
        end
    end
      
    always@(posedge rgmii_clk)
    begin
        if(rstn == 1'b0)
        begin
            gmii_tx_en <= 1'b0 ;
            gmii_txd   <= 8'd0 ;
        end
        else
        begin
            gmii_tx_en <= gmii_tx_en_tmp ;
            gmii_txd   <= gmii_txd_tmp ;
        end
    end
    
    udp_ip_mac_top#(
        .LOCAL_MAC                (LOCAL_MAC               ),// 48'h11_11_11_11_11_11,
        .LOCAL_IP                 (LOCAL_IP                ),// 32'hC0_A8_01_6E,//192.168.1.110
        .LOCL_PORT                (LOCL_PORT               ),// 16'h8080,
                                                           
        .DEST_IP                  (DEST_IP                 ),// 32'hC0_A8_01_69,//192.168.1.105
        .DEST_PORT                (DEST_PORT               ) // 16'h8080 
)udp_ip_mac_top(
        .rgmii_clk                (  rgmii_clk             ),//input           rgmii_clk,
        .rstn                     (  rstn                  ),//input           rstn,
  
        .app_data_in_valid        (  ram_wr_en             ),//input           app_data_in_valid,
        .app_data_in              (  ram_wr_data           ),//input   [7:0]   app_data_in,      
        .app_data_length          (  udp_send_data_length  ),//input   [15:0]  app_data_length,   
        .app_data_request         (  udp_tx_req            ),//input           app_data_request, 
                                                           
        .udp_send_ack             (  udp_ram_data_req      ),//output          udp_send_ack,   
                                                           
        .arp_req                  (  arp_request_req       ),//input           arp_req,
        .arp_found                (  arp_found             ),//output          arp_found,
        .mac_not_exist            (  mac_not_exist         ),//output          mac_not_exist, 
        .mac_send_end             (  mac_send_end          ),//output          mac_send_end,
        
        .udp_rec_rdata            (  udp_rec_rdata         ),//output  [7:0]   udp_rec_rdata ,      //udp ram read data   
        .udp_rec_data_length      (  udp_rec_data_length   ),//output  [15:0]  udp_rec_data_length,     //udp data length     
        .udp_rec_data_valid       (  udp_rec_data_valid    ),//output          udp_rec_data_valid,       //udp data valid      
        
        .mac_data_valid           (  gmii_tx_en_tmp        ),//output          mac_data_valid,
        .mac_tx_data              (  gmii_txd_tmp          ),//output  [7:0]   mac_tx_data,   
                                      
        .rx_en                    (  gmii_rx_dv_1d         ),//input           rx_en,         
        .mac_rx_datain            (  gmii_rxd_1d           ) //input   [7:0]   mac_rx_datain
    );

     reg [191 : 0] test_data = {8'h77,8'h77,8'h77,8'h2E,   //{"w","w","w","."}; 
                               8'h6A,8'h65,8'h79,8'h65,   //{"m","e","y","e"}; 
                               8'h73,8'h65,8'h6D,8'h69,   //{"s","e","m","i"}; 
                               8'h2E,8'h63,8'h6F,8'h6D,   //{".","c","o","m"}; 
							   
							   8'h2E,8'h63,8'h6F,8'h6D,
							   
                               8'h20,8'h20,8'h20,8'h0A  };//{" "," "," ","\n"};

	//reg [159 : 0] test_data = {8'h6D,8'h65,8'h79,8'h65,  //{"w","w","w","."}; 
    //                          8'h77,8'h77,8'h77,8'h2E,  //{"m","e","y","e"}; 
    //                          8'h20,8'h20,8'h20,8'h0A ,   //{"s","e","m","i"}; 
    //                           8'h73,8'h65,8'h6D,8'h69,    //{".","c","o","m"}; 
    //                          8'h2E,8'h63,8'h6F,8'h6D  };//{" "," "," ","\n"};

reg	ram_wr_en_d0,ram_wr_en_d1;
reg write_end_d0  ;
reg write_end_d1  ;
always@(posedge rgmii_clk)
begin
	ram_wr_en_d0 <= ram_wr_en;
	ram_wr_en_d1 <= ram_wr_en_d0;
	write_end_d0 <= write_end;
	write_end_d1 <= write_end_d0;
end

reg	[9:0]	data_in_vld_dly /*synthesis PAP_MARK_DEBUG="1"*/;
always@(posedge rgmii_clk)
begin
	data_in_vld_dly <= {data_in_vld_dly[9:0],data_in_vld}; 
end





reg	[4:0]cnt;
always@(posedge rgmii_clk)
    begin
		if(!rstn)
			cnt <= 0;
		else if(cnt == 8)
			cnt <= 0;
		else if(state == WRITE_RAM)
			cnt <= 0;
		else if(state == ADC_RAM)
			cnt <= cnt + 1;
	end
	
    always@(posedge rgmii_clk)
    begin
        if(rstn == 1'b0)
    	    udp_send_data_length <= 16'd0 ;
    	else
    	    udp_send_data_length <= 512;//4*UDP_DEPTH ;
          //udp_send_data_length <=16'd20 ;
    end
      
    assign udp_tx_req    = (state == GEN_REQ) ;
    assign arp_request_req  = (state == ARP_REQ) ;
    
    always@(posedge rgmii_clk)
    begin
        if(rstn == 1'b0)
            wait_cnt <= 0 ;
        else if ((state==IDLE||state == WAIT || state == ARP_WAIT) && state != state_n)
            wait_cnt <= 0 ;
        else if (state==IDLE||state == WAIT || state == ARP_WAIT)
            wait_cnt <= wait_cnt + 1'b1 ;
    	else
    	    wait_cnt <= 0 ;
    end
    
	reg	[10:0]	cnt0/*synthesis PAP_MARK_DEBUG="1"*/;
	reg	[10:0]	cnt1/*synthesis PAP_MARK_DEBUG="1"*/;
	always@(posedge rgmii_clk)
	begin
		if(data_in_vld)
			cnt0 <= cnt0 + 1;
		else
			cnt0 <= 0;
	end

	always@(posedge rgmii_clk)	
	begin
		if(ram_wr_en)
			cnt1 <= cnt1 + 1;
		else
			cnt1 <= 0;
	end
	
	
	
	
	
	
	
    reg [12:0] test_cnt;
    always@(posedge rgmii_clk)
    begin
        if(rstn == 1'b0)
        begin
            write_end  <= 1'b0;
            ram_wr_data <= 0;
            ram_wr_en  <= 0 ;
            test_cnt   <= 0;
        end
        else if (state == WRITE_RAM)
        begin
            if(test_cnt == 512)//test_cnt == 8'd20
            begin
                ram_wr_en <=1'b0;
                write_end <= 1'b1;
            end
            else
            begin
                ram_wr_en <= 1'b1 ;
                write_end <= 1'b0 ;
                ram_wr_data <= rx_data ;//test_data[8'd159-{test_cnt[4:0],3'd0} -: 8] ;
                test_cnt <= test_cnt + 8'd1;
            end
        end
        else
        begin
            write_end  <= 1'b0;
            ram_wr_data <= 0;
            ram_wr_en  <= 0 ;
            test_cnt   <= 0;
        end
    end
      
	  
	 assign start_rd = (state_n == WRITE_RAM)?	1:0;
	  
	  
	  
endmodule
