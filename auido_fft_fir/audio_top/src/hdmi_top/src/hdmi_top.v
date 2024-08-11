`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
//created by :NJUPT
//created data:2024/04/09
//////////////////////////////////////////////////////////////////////////////////

module hdmi_top
(
    input wire        sys_clk         ,// input system clock 50MHz    
    input             rst_n           ,
    output            rstn_out        ,
    output            iic_tx_scl      ,
    inout             iic_tx_sda      ,
 
    //fft 
    input       [31:0]fft_data         , 
    input             fft_eop          , 
    input             fft_valid        , 
    
    
    output            led_int          ,
//hdmi_out 
    output            pix_clk          ,//pixclk                           
    output            vs_out        , 
    output            hs_out        , 
    output            de_out        ,
    output     [7:0]  r_out         , 
    output     [7:0]  g_out         , 
    output     [7:0]  b_out         

);

wire data_req;
wire fft_point_done;
wire [7:0] fft_point_cnt;
wire [11:0] ram_data_out;
wire cfg_clk;


pll pll_inst 
(
  .clkin1(sys_clk),        // input  50
  .pll_lock(locked),    // output
  .clkout0(pix_clk),      // output   148.5
  .clkout1(cfg_clk)       // output    10
);
 

//delay 20 clk for rstn_out
reg [639:0] data_reg;
reg [19:0] fft_eop_reg;
reg [19:0] fft_valid_reg;

always@(posedge sys_clk or negedge rst_n)    
begin
    if(~rst_n) begin
        data_reg <= 640'd0;
        fft_eop_reg <= 20'd0;
        fft_valid_reg <= 20'd0;
    end else begin
        data_reg <= {data_reg[607:0],fft_data};
        fft_eop_reg <= {fft_eop_reg[18:0],fft_eop};
        fft_valid_reg <={fft_valid_reg[18:0],fft_valid};
    end
end    

wire  [31:0] data_reg1;
wire  fft_eop_reg1;
wire  fft_valid_reg1;

assign  data_reg1 =  data_reg[639:608];
assign  fft_eop_reg1 =  fft_eop_reg[19];
assign  fft_valid_reg1 =  fft_valid_reg[19];


 
 
rw_ram_ctrl rw_ram_ctrl_inst
(
    .clk                (sys_clk       )  ,
    .lcd_clk            (pix_clk       )  ,
    .rst_n              (locked & rst_n)  ,
    //FFT输入数据       
    .fft_data           (data_reg1[11:0])  ,        //FFT频谱数据
    .fft_eop            (fft_eop_reg1       )  ,         //EOP包结束信号
    .fft_valid          (fft_valid_reg1     )  ,       //FFT频谱数据有效信号
   
    .data_req           (data_req      )  ,        //数据请求信号
    .fft_point_done     (fft_point_done)  ,     //FFT当前频谱绘制完成
    .fft_point_cnt      (fft_point_cnt )  ,   //FFT频谱位置
    //ram端口        
    .ram_data_out       (ram_data_out  )   //ram输出有效数据
);


hdmi_test_revised hdmi_test_revised_inst
(
   .sys_clk       (sys_clk       ) ,// input system clock 50MHz    
   .rst_n         (locked & rst_n ) ,
   .cfg_clk       (cfg_clk       ),
   .rstn_out      (rstn_out      ) ,
   .iic_tx_scl    (iic_tx_scl    ) ,
   .iic_tx_sda    (iic_tx_sda    ) ,
   
   .fft_point_cnt (fft_point_cnt ) , 
   .fft_data      (ram_data_out  ) , 
   .fft_point_done(fft_point_done) , 
   .data_req      (data_req      ) ,
  
   .led_int       (led_int       ) ,
 
   .pix_clk       (pix_clk       ) ,//pixclk                           
   .vs_out        (vs_out        ) , 
   .hs_out        (hs_out        ) , 
   .de_out        (de_out        ) ,
   .r_out         (r_out         ) ,  
   .g_out         (g_out         ) , 
   .b_out         (b_out         )

);


endmodule


