//created date:2024/05/21
//verision: v1.0
//note:采用fifo进行数据缓存时，因为要保持输出数据连续，但由于写快和读慢，UDP的数据会写满，从而导致数据的丢失
//y_lms delay 570 clk
//1.采用fifo形式最多支持4s的音频信号 ----- 1.use DDR to attain bigger storage;2.user multi-fifo with ambition（该方法存储小）

//2.采用DDR进行存储
// `define  multi_fifo
module lms_top
#(
    parameter Step_size = 16'h000f      ,   //0.0073 *(2**11)  = 15
    parameter filter_class = 8
)
(
    input                       sys_clk      ,
    input                       rst_n        ,

    input                       audio_clk    ,
    input                       data_valid   ,
    input           [15:0]      adc_data     ,
 
    input                       rgmii_clk    ,
    input                       rec_en       ,
    input           [31:0]      rec_data     , 

    output          [15:0]      y_lms        ,

    output     reg              flag_audio   ,
    output     reg              flag_udp
);

reg en_flag;


//para fifo1
// reg         flag_audio  ;
wire         rd_en_audio;
wire  [15:0] rd_data_aduio;
wire empty_audio;
wire full_audio;
//para fifo2
// reg          flag_udp   ;
wire        rd_en_udp   ;
wire  [15:0] rd_data_udp ;
wire empty_udp;
wire full_udp;
//para lms

wire signed [15:0] Error_out,Delay_out_x,Y_out;
wire signed [15:0] rd_data_udp_trans;
wire signed [15:0] rd_data_aduio_trans;




always@(posedge audio_clk or negedge rst_n)
begin
    if(~rst_n)
        flag_audio <= 1'b0; 
    else if(~empty_audio)
        flag_audio <= 1'b1;
    else
        flag_audio <= flag_audio;
end

always@(posedge rgmii_clk or negedge rst_n)
begin
    if(~rst_n)
        flag_udp <= 1'b0;
    else if(~empty_udp)
        flag_udp <= 1'b1;
    else
        flag_udp  <= flag_udp;
end


always@(posedge audio_clk or negedge rst_n)
begin
    if(~rst_n)
        en_flag <= 1'b0;
    else if (flag_udp == 1'b1 && flag_audio == 1'b1)
        en_flag <= 1'b1;
    else
        en_flag <= 1'b0;
end

assign rd_en_audio = en_flag;
assign rd_en_udp = en_flag;

LMS 
#( 
    .filter_class(filter_class)
)
LMS_inst
(
    .Clk            (audio_clk          ),
    .Reset          (rst_n              ),
    .Enable         (en_flag            ),
    .Data_in        (rd_data_udp_trans  ),
    .Desired_in     (rd_data_aduio_trans),
    .Step_size      (Step_size          ),
    .Error_out      (Error_out          ),
    .Delay_out_x    (Delay_out_x        ),
    .Y_out          (Y_out              )
);

assign rd_data_udp_trans = UNSIGNED_TO_SIGNED(rd_data_udp);
assign rd_data_aduio_trans =  UNSIGNED_TO_SIGNED(rd_data_aduio);
assign y_lms =  SIGNED_TO_UNSIGNED(Y_out);


//inst audio data fifo
lms_fifos lms_fifo1 
(
  .wr_clk        (audio_clk     ),                    // input
  .wr_rst        (~rst_n        ),                    // input
  .wr_en         (data_valid    ),                      // input
  .wr_data       (adc_data      ),                  // input [15:0]
  .wr_full       (full_audio    ),                  // output
  .wr_water_level(              ),    // output [10:0]
  .almost_full   (              ),          // output
  .rd_clk        (audio_clk     ),                    // input
  .rd_rst        (~rst_n        ),                    // input
  .rd_en         (rd_en_audio   ),                      // input
  .rd_data       (rd_data_aduio ),                  // output [15:0]
  .rd_empty      (empty_audio   ),                // output
  .rd_water_level(              ),    // output [10:0]
  .almost_empty  (              )         // output
);




`ifdef multi_fifo
//inst udp data multi-fifo    这里支持5s的数据接收，可以继续增加，但是DRM不够了
    fifo_ambition_top fifo_ambition_top_inst
    (
        .sys_clk   (sys_clk         ) ,
        .sys_rst_n (rst_n           ) ,
        
        .wr_clk    (rgmii_clk       ) ,
        .wr_data   (rec_data[15:0]  ) ,
        .wr_en     (rec_en          ) ,
      
        .rd_clk    (audio_clk       ) ,
        .rd_en     (rd_en_udp       ) ,
        .rd_data   (rd_data_udp     ) ,
       
        .empty     (~empty_udp      )
    );

`elsif sigle_fifo    //单FIFO容量很小
//inst udp data fifo
    lms_fifos lms_fifo2 
    (
      .wr_clk       (rgmii_clk      ),                // input
      .wr_rst       (~rst_n         ),                // input
      .wr_en        (rec_en         ),                  // input
      .wr_data      (rec_data[15:0] ),              // input [15:0]
      .wr_full      (full_udp       ),              // output
      .almost_full  (               ),      // output
      .rd_clk       (audio_clk      ),                // input
      .rd_rst       (~rst_n         ),                // input
      .rd_en        (rd_en_udp      ),                  // input
      .rd_data      (rd_data_udp    ),              // output [15:0]
      .rd_empty     (empty_udp      ),            // output
      .almost_empty (               )     // output
    );
`else 
//这里采用DDR读取数据后的FIFO进行操作
    lms_fifos lms_fifo2
    (
      .wr_clk        (rgmii_clk     ),                    // input
      .wr_rst        (~rst_n        ),                    // input
      .wr_en         (rec_en        ),                      // input
      .wr_data       (rec_data[15:0]),                  // input [15:0]
      .wr_full       (full_udp      ),                  // output
      .wr_water_level(              ),    // output [10:0]
      .almost_full   (              ),          // output
      .rd_clk        (audio_clk     ),                    // input
      .rd_rst        (~rst_n        ),                    // input
      .rd_en         (rd_en_udp     ),                      // input
      .rd_data       (rd_data_udp   ),                  // output [15:0]
      .rd_empty      (empty_udp     ),                // output
      .rd_water_level(              ),    // output [10:0]
      .almost_empty  (              )         // output
    );
    

`endif




// the following function can be used to compute the transform(16 width) of unsigned and signed
function signed [15:0] UNSIGNED_TO_SIGNED;
    input  [15:0]  num1;
    begin
        UNSIGNED_TO_SIGNED = 'd0;
        if(num1 < 32768)
            UNSIGNED_TO_SIGNED = num1;
        else
            UNSIGNED_TO_SIGNED = num1 - 65536;
    end
endfunction    


function [15:0] SIGNED_TO_UNSIGNED;
    input   signed[15:0] num2;
    begin
       SIGNED_TO_UNSIGNED = 'd0;
        if (num2 >= 0)
            SIGNED_TO_UNSIGNED = num2;
        else
            SIGNED_TO_UNSIGNED = num2 + 65536;
    end
endfunction




endmodule
