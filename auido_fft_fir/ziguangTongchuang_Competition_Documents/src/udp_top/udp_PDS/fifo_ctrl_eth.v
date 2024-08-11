//created date:2024/6

module fifo_ctrl_eth
(
    input			clk				 ,//sck
    input			clk_eth		     ,
    input			rst_n			 ,
    input	[15:0]	rx_data	 		 ,	
    input			rx_l_vld		 ,
    input			rx_r_vld		 ,
    input			start_rd		/*synthesis PAP_MARK_DEBUG="1"*/,

    output	[7:0]	data_out		 ,
    output	reg		vld				 ,
    output			ram_w_end
   );
/*******************************para***************************************/
//one-hot code
localparam	IDLE 	= 'b000;
localparam	RAM_W 	= 'b001;
localparam	RAM_W0 	= 'b010;
localparam	RAM_W1 	= 'b100;
/*******************************wire***************************************/
wire		    rx_vld      ;
wire    [7:0]	data_in     ;
wire	[7:0]   rd_data_0   ;
wire    [7:0]   rd_data_1   ;
wire            ram_end_neg ;
wire            ram0_end_neg;
wire            ram1_end_neg;
wire		    rx_vld_pos  ;
wire	    	rx_vld_8b   ;
/*******************************reg***************************************/
reg [15:0]	rx_data_d0      ;	
reg	        ram_end_d0      ;
reg	        ram_end_d1      ;
reg	        ram0_end_d0     ;
reg	        ram0_end_d1     ;
reg	        ram1_end_d0     ;
reg	        ram1_end_d1     ;
reg			rx_vld_d0       ;
reg	[11:0]	ram_write_cnt   ;
reg	[2:0]	state,next_state;
reg			ram_end         ;
reg			ram0_end        ;
reg			ram1_end        ;

reg	[9:0]	ram0_write_addr ;
reg	[9:0]	ram1_write_addr ;
reg	[9:0]	ram0_read_addr  ;
reg	[9:0]	ram1_read_addr  ;
reg			rx_vld_pos_d0   ;
reg			ram0_write_en   ;
reg			ram1_write_en   ;
reg	[7:0]	data_in_d0      ;
/*******************************assign***************************************/
assign	rx_vld = rx_l_vld;// | rx_r_vld;
assign	ram_w_end = ram_end_neg | ram0_end_neg | ram1_end_neg;
assign	rx_vld_pos = !rx_vld_d0 & rx_vld;
assign	rx_vld_8b  = rx_vld_pos | rx_vld_pos_d0; 

assign	ram_end_neg  = ram_end_d1 & !ram_end_d0;
assign	ram0_end_neg = ram0_end_d1 & !ram0_end_d0;
assign	ram1_end_neg = ram1_end_d1 & !ram1_end_d0;
assign	data_in = rx_vld? rx_data[15:8] : (rx_vld_d0 ? rx_data_d0[7:0] : 0);
assign data_out = (state == RAM_W0)?rd_data_1:((state == RAM_W1)? rd_data_0 : 0 );

/*******************************always***************************************/
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		rx_vld_d0 <= 0;
	else
		rx_vld_d0 <= rx_vld;
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin		
			rx_data_d0 		<= 0;
			rx_vld_pos_d0 	<= 0;
		end
	else	
		begin
			rx_data_d0 		<= rx_data;
			rx_vld_pos_d0 	<= rx_vld_pos;
		end		
end 

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin		
			ram_end_d0 	<= 0;
			ram_end_d1 	<= 0;
			ram0_end_d0 	<= 0;
			ram0_end_d1 	<= 0;
			ram1_end_d0 	<= 0;
			ram1_end_d1 	<= 0;
		end
	else	
		begin		
			ram_end_d0 	<= ram_end;
			ram_end_d1 	<= ram_end_d0;
			ram0_end_d0 <= ram0_end;
			ram0_end_d1 <= ram0_end_d0;
			ram1_end_d0 <= ram1_end;
			ram1_end_d1 <= ram1_end_d0;
		end		
end 

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		state <= IDLE;
	else
		state <= next_state;
end

always@(*)
begin
	case(state)
		IDLE:
			if(rx_vld_pos_d0)
				next_state = RAM_W;
			else
				next_state = IDLE;
		RAM_W:
			if(ram_end)	
				next_state = RAM_W1;
			else
				next_state = RAM_W;
		RAM_W0:
			if(ram0_end)
				next_state = RAM_W1;
			else
				next_state = RAM_W0;
		RAM_W1:
			if(ram1_end)
				next_state = RAM_W0;
			else
				next_state = RAM_W1;
		default: ;
	endcase
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			ram0_write_en <= 0;
			ram1_write_en <= 0;
		end
	else if(state == RAM_W || state == RAM_W0)
		begin
			ram0_write_en <= rx_vld_8b;
			ram1_write_en <= 0;
		end
	else if(state == RAM_W1)
		begin
		ram0_write_en <= 0;
		ram1_write_en <= rx_vld_8b;
		end
	else
		begin
			ram0_write_en <= 0;
			ram1_write_en <= 0;
		end		
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			ram0_write_addr <= 0;
			ram1_write_addr <= 0;
		end
	else if(state == RAM_W || state == RAM_W0)
		begin
			if(rx_vld_8b)
				begin
					ram0_write_addr <= ram0_write_addr + 1;
					ram1_write_addr <= 0;
				end
		end
	else if(state == RAM_W1)
		begin
			if(rx_vld_8b)
				begin
					ram0_write_addr <= 0;
					ram1_write_addr <= ram1_write_addr + 1;					
				end
		end
	else
		begin
			ram0_write_addr <= 0;
			ram1_write_addr <= 0;
		end
end




always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		ram_write_cnt <= 0;
	else if(state != IDLE && rx_vld_pos)
		begin
			if(ram_write_cnt == 1024/2 )
				ram_write_cnt <= 1;
			else
				ram_write_cnt <= ram_write_cnt + 1;			
		end	
end 

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		ram_end <= 0;
	else if(state == RAM_W && ram_write_cnt==512/2 )
		ram_end <= 1;
	else
		ram_end <= 0;
end 

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		ram0_end <= 0;
	else if(state == RAM_W0 && ram_write_cnt == 512/2 )
		ram0_end <= 1;
	else
		ram0_end <= 0;
end 

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		ram1_end <= 0;
	else if(state == RAM_W1 && ram_write_cnt == 1024/2)
		ram1_end <= 1;
	else
		ram1_end <= 0;
end 

always@(posedge clk_eth or negedge rst_n)
begin
	if(!rst_n)
		begin
			ram0_read_addr <= 1;
			ram1_read_addr <= 1;
		end
	else if(state == RAM_W0 && start_rd)
		begin
			if(ram1_read_addr == 512)
				begin
					ram0_read_addr <= 1;
					ram1_read_addr <= 513;
				end
			else if(ram1_read_addr == 513)
				begin
					ram1_read_addr <= 513;
				end
			else
				begin
					ram1_read_addr <= ram1_read_addr + 1;
					ram0_read_addr <= 1;
				end
		end
	else if(state == RAM_W1 && start_rd)
		begin
			if(ram0_read_addr == 512)
				begin
					ram0_read_addr <= 513;
					ram1_read_addr <= 1;
				end
			else if(ram0_read_addr == 513)
				ram0_read_addr <= 513;
			else
				begin
					ram0_read_addr <= ram0_read_addr + 1;
					ram1_read_addr <= 1;
				end	
		end		
	else 
		begin
			ram0_read_addr <= 1;
			ram1_read_addr <= 1;
		end
end


always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		data_in_d0 <= 0;
	else
		data_in_d0 <= data_in;
end

always@(posedge clk_eth or negedge rst_n)
begin
	if(!rst_n)
		vld <= 0;
	else if((ram0_read_addr >=1 && ram0_read_addr <= 512) || (ram1_read_addr >=1 && ram1_read_addr <= 512))
		vld <= 1;
	else
		vld <= 0;
end



ram0 ram_0 (
  .wr_data(data_in_d0),    // input [7:0]
  .wr_addr(ram0_write_addr),    // input [9:0]
  .wr_en(ram0_write_en),        // input
  .wr_clk(clk),      // input
  .wr_rst(~rst_n),      // input
  .rd_addr(ram0_read_addr),    // input [9:0]
  .rd_data(rd_data_0),    // output [7:0]
  .rd_clk(clk_eth),      // input
  .rd_rst(~rst_n)       // input
);

ram0 ram_1 (
  .wr_data(data_in_d0),    // input [7:0]
  .wr_addr(ram1_write_addr),    // input [9:0]
  .wr_en(ram1_write_en),        // input
  .wr_clk(clk),      // input
  .wr_rst(~rst_n),      // input
  .rd_addr(ram1_read_addr),    // input [9:0]
  .rd_data(rd_data_1),    // output [7:0]
  .rd_clk(clk_eth),      // input
  .rd_rst(~rst_n)       // input
);


endmodule
