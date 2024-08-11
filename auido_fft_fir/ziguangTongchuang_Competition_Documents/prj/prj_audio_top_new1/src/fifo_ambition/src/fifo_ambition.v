//created date:2024/06/06
//this code is for multi-fifo write,because the write clk is 125, and the read clk is 12,so ,we need multi-fifo to get it

module fifo_ambition_top
(
    input           sys_clk      ,
    input           sys_rst_n    ,
                           
    input           wr_clk       ,
    input  [15:0]   wr_data      ,
    input           wr_en        ,
                           
    input           rd_clk       ,
    input           rd_en        ,
    output [15:0]   rd_data      ,
    
    output          empty       
);

//compute 读一个多写2个 （时钟关系），地址位宽 = 18  
//单个FIFO支持 = 2^18/2 + 2^18 = 393216/48000 = 8s,加上其他剩余的3个FIFO ，（2^18 /48000）*4 = 21s,一共支持29s的音频存储
//对于官方给定的音频源，完全够用(可惜资源不够，要么采用给DDR要么双板)
parameter  FIFO1 = 3'd0, FIFO2 = 3'd1, FIFO3 = 3'd2,FIFO4 = 3'd3,FIFO5 = 3'd4;

/*************************wire*******************************/
wire        wr_en0      ;
wire [15:0] wr_data0    ;
wire        full_udp0   ;

wire        wr_en1      ;
wire [15:0] wr_data1    ;
wire        full_udp1   ;

wire        wr_en2      ;
wire [15:0] wr_data2    ;
wire        full_udp2   ;

wire        wr_en3      ;
wire [15:0] wr_data3    ;
wire        full_udp3   ;

wire        wr_en4      ;
wire [15:0] wr_data4    ;
wire        full_udp4   ;

wire        rd_en0      ;
wire [15:0] rd_data0    ;
wire        empty_udp0  ;

wire        rd_en1      ;
wire [15:0] rd_data1    ;
wire        empty_udp1  ;

wire        rd_en2      ;
wire [15:0] rd_data2    ;
wire        empty_udp2  ;

wire        rd_en3      ;
wire [15:0] rd_data3    ;
wire        empty_udp3  ;

wire        rd_en4      ;
wire [15:0] rd_data4    ;
wire        empty_udp4  ;

wire [14:0] rd_water_level0;
wire [14:0] rd_water_level1;
wire [14:0] rd_water_level2;
wire [14:0] rd_water_level3;
wire [14:0] rd_water_level4;

/*************************reg*******************************/
reg [2:0]   wr_state    ;
reg [2:0]   rd_state    ;
reg         cnt_wr_flag ;
reg             we_en   ;
/*************************assign*******************************/
assign wr_en0 = ~we_en?(wr_state == FIFO1)? wr_en:1'b0 : 1'b0;
assign wr_en1 = ~we_en?(wr_state == FIFO2)? wr_en:1'b0 : 1'b0;
assign wr_en2 = ~we_en?(wr_state == FIFO3)? wr_en:1'b0 : 1'b0;
assign wr_en3 = ~we_en?(wr_state == FIFO4)? wr_en:1'b0 : 1'b0;
assign wr_en4 = ~we_en?(wr_state == FIFO5)? wr_en:1'b0 : 1'b0;

assign wr_data0 = (wr_state == FIFO1)?wr_data:16'd0;
assign wr_data1 = (wr_state == FIFO2)?wr_data:16'd0;
assign wr_data2 = (wr_state == FIFO3)?wr_data:16'd0;
assign wr_data3 = (wr_state == FIFO4)?wr_data:16'd0;
assign wr_data4 = (wr_state == FIFO5)?wr_data:16'd0;

assign rd_en0 = (rd_state == FIFO1)?rd_en:1'b0;
assign rd_en1 = (rd_state == FIFO2)?rd_en:1'b0;
assign rd_en2 = (rd_state == FIFO3)?rd_en:1'b0;
assign rd_en3 = (rd_state == FIFO4)?rd_en:1'b0;
assign rd_en4 = (rd_state == FIFO5)?rd_en:1'b0;


assign rd_data = (rd_state == FIFO1)?rd_data0:(rd_state == FIFO2)?rd_data1:(rd_state == FIFO3)?rd_data2:(rd_state == FIFO4)?rd_data3:(rd_state == FIFO5)?rd_data4:16'd0;

assign empty = ~empty_udp0 || ~empty_udp1 || ~empty_udp2 || ~empty_udp3 || ~empty_udp4;
/*************************main*******************************/
//write state
always@(posedge wr_clk  or negedge sys_rst_n)
begin
    if(~sys_rst_n) begin
        wr_state <= 3'd0;
        cnt_wr_flag <= 1'b0;
        we_en <= 1'b0;
    end else begin
        case(wr_state)
            FIFO1:
                if(cnt_wr_flag)begin
                    we_en <= 1'b0;
                    if(full_udp0 && rd_state != FIFO1) begin
                        wr_state <= FIFO2;
                    end else  begin    //进入读一个丢三个
                        wr_state <= wr_state;
                        we_en <= 1'b1;
                    end
                end else begin
                    if(full_udp0) 
                        wr_state <= FIFO2;
                    else
                        wr_state <= wr_state;
                end
                    
            FIFO2:
                if(cnt_wr_flag)begin
                    we_en <= 1'b0;
                    if(full_udp1 && rd_state != FIFO2) begin
                        wr_state <= FIFO3;
                    end else begin
                        wr_state <= wr_state;
                        we_en <= 1'b1;
                    end
                end else begin
                    if(full_udp1)
                        wr_state <= FIFO3;
                    else
                        wr_state <= wr_state;
                end
            FIFO3:
                if(cnt_wr_flag)begin
                    we_en <= 1'b0;
                    if(full_udp2 && rd_state != FIFO3) begin
                        wr_state <= FIFO4;
                    end else begin
                        wr_state <= wr_state;
                        we_en <= 1'b1;
                    end
                end else begin
                    if(full_udp2)
                        wr_state <= FIFO4;
                    else
                        wr_state <= wr_state;
                end
            FIFO4:
                if(cnt_wr_flag)begin
                    we_en <= 1'b0;
                    if(full_udp3 && rd_state != FIFO4) begin
                        wr_state <= FIFO5;
                    end else begin
                        wr_state <= wr_state;
                        we_en <= 1'b1;
                    end
                end else begin
                    if(full_udp3)
                        wr_state <= FIFO5;
                    else
                        wr_state <= wr_state;
                end
            FIFO5:           
                if(cnt_wr_flag)begin
                    we_en <= 1'b0;
                    if(full_udp4 && rd_state != FIFO5)begin
                        wr_state <= FIFO1;
                    end else begin
                        wr_state <= wr_state;
                        we_en <= 1'b1;
                    end
                end else begin
                    if(full_udp4) begin
                        wr_state <= FIFO1;
                        cnt_wr_flag <= 1'b1;
                    end else begin
                        wr_state <= wr_state;
                    end
                end
            default:wr_state <= 2'd0;
        endcase
    end
end

//rd state
always@(posedge rd_clk  or negedge sys_rst_n)
begin
    if(~sys_rst_n) begin
        rd_state <= 3'd0;
    end else begin
        case(rd_state)
            FIFO1:
                if(empty_udp0 )
                    rd_state <= FIFO2;
                else
                    rd_state <= rd_state;
            FIFO2:
                if(empty_udp1)
                    rd_state <= FIFO3;
                else
                    rd_state <= rd_state;
            FIFO3:
                if(empty_udp2 )
                    rd_state <= FIFO4;
                else
                    rd_state <= rd_state;
            FIFO4:
                if(empty_udp3)
                    rd_state <= FIFO5;
                else
                    rd_state <= rd_state;
            FIFO5:
                if(empty_udp4)
                    rd_state <= FIFO1;
                else
                    rd_state <= rd_state;
            default:rd_state <= 2'd0;
        endcase
    end
end





//inst fifo
fifo_ambition fifo_ambition0 
(
  .wr_clk           (wr_clk         ),                    // input
  .wr_rst           (~sys_rst_n     ),                    // input
  .wr_en            (wr_en0         ),                      // input
  .wr_data          (wr_data0       ),                  // input [15:0]
  .wr_full          (full_udp0      ),                  // output
  .wr_water_level   (               ),    // output [17:0]
  .almost_full      (               ),          // output
  .rd_clk           (rd_clk         ),                    // input
  .rd_rst           (~sys_rst_n     ),                    // input
  .rd_en            (rd_en0         ),                      // input
  .rd_data          (rd_data0       ),                  // output [15:0]
  .rd_empty         (empty_udp0     ),                // output
  .rd_water_level   (rd_water_level0),    // output [17:0]
  .almost_empty     (               )         // output
);

fifo_ambition fifo_ambition1 
(
  .wr_clk           (wr_clk         ),                    // input
  .wr_rst           (~sys_rst_n     ),                    // input
  .wr_en            (wr_en1         ),                      // input
  .wr_data          (wr_data1       ),                  // input [15:0]
  .wr_full          (full_udp1      ),                  // output
  .wr_water_level   (               ),    // output [17:0]
  .almost_full      (               ),          // output
  .rd_clk           (rd_clk         ),                    // input
  .rd_rst           (~sys_rst_n     ),                    // input
  .rd_en            (rd_en1         ),                      // input
  .rd_data          (rd_data1       ),                  // output [15:0]
  .rd_empty         (empty_udp1     ),                // output
  .rd_water_level   (rd_water_level1),    // output [17:0]
  .almost_empty     (               )         // output
);

fifo_ambition fifo_ambition2 
(
  .wr_clk           (wr_clk         ),                    // input
  .wr_rst           (~sys_rst_n     ),                    // input
  .wr_en            (wr_en2         ),                      // input
  .wr_data          (wr_data2       ),                  // input [15:0]
  .wr_full          (full_udp2      ),                  // output
  .wr_water_level   (               ),    // output [17:0]
  .almost_full      (               ),          // output
  .rd_clk           (rd_clk         ),                    // input
  .rd_rst           (~sys_rst_n     ),                    // input
  .rd_en            (rd_en2         ),                      // input
  .rd_data          (rd_data2       ),                  // output [15:0]
  .rd_empty         (empty_udp2     ),                // output
  .rd_water_level   (rd_water_level2),    // output [17:0]
  .almost_empty     (               )         // output
);

fifo_ambition fifo_ambition3 
(
  .wr_clk           (wr_clk         ),                    // input
  .wr_rst           (~sys_rst_n     ),                    // input
  .wr_en            (wr_en3         ),                      // input
  .wr_data          (wr_data3       ),                  // input [15:0]
  .wr_full          (full_udp3      ),                  // output
  .wr_water_level   (               ),    // output [17:0]
  .almost_full      (               ),          // output
  .rd_clk           (rd_clk         ),                    // input
  .rd_rst           (~sys_rst_n     ),                    // input
  .rd_en            (rd_en3         ),                      // input
  .rd_data          (rd_data3       ),                  // output [15:0]
  .rd_empty         (empty_udp3     ),                // output
  .rd_water_level   (rd_water_level3),    // output [17:0]
  .almost_empty     (               )         // output
);

fifo_ambition fifo_ambition4 
(
  .wr_clk           (wr_clk         ),                    // input
  .wr_rst           (~sys_rst_n     ),                    // input
  .wr_en            (wr_en4         ),                      // input
  .wr_data          (wr_data4       ),                  // input [15:0]
  .wr_full          (full_udp4      ),                  // output
  .wr_water_level   (               ),    // output [17:0]
  .almost_full      (               ),          // output
  .rd_clk           (rd_clk         ),                    // input
  .rd_rst           (~sys_rst_n     ),                    // input
  .rd_en            (rd_en4         ),                      // input
  .rd_data          (rd_data4       ),                  // output [15:0]
  .rd_empty         (empty_udp4     ),                // output
  .rd_water_level   (rd_water_level4),    // output [17:0]
  .almost_empty     (               )         // output
);

endmodule




