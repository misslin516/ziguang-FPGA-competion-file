// Created date:        2024/03/30
//****************************************************************************************//
`define cordic_jpl
// `define cordic_newton

//****************************************************************************************//
  //    note :   cordic_jpl has more error, cordic_newton has more complexity ,but we just wanna diff aptitude,so cordic_jpl be choosed
//****************************************************************************************//

//this code can replace * for multstreamline ,it's faster
module  data_module_fft
(
    input             clk_50m       ,
    input             rst_n         ,
    
    input   [31:0]    source_real   ,
    input   [31:0]    source_imag   ,
    input             source_sop    ,
    input             source_eop    ,
    input             source_valid  ,

    output  [31:0]    data_modulus  ,  
    output  wire      data_sop      ,
    output  wire      data_eop      ,
    output  wire      data_valid
);


// because cordic_jpl conclude the negative and positive decision
`ifdef cordic_jpl   
    cordic_jpl
    #(
       .N(32)
    )
    cordic_jpl_inst
    (
        .clk      (clk_50m      ) ,
        .syn_rst  (~rst_n       ) ,      //active high
        .valid_in (source_valid ) ,
        .dataa    (source_real  ) ,
        .datab    (source_imag  ) ,

        .valid_out(data_valid   ) ,
        .ampout   (data_modulus )
    );  // need 3 clock

reg [2:0] data_sop_reg;
reg [2:0] data_eop_reg;

always@(posedge clk_50m )begin
    if(~rst_n) begin
        data_sop_reg <= 3'b0;
        data_eop_reg <= 3'b0;
    end else begin
        data_sop_reg <= {data_sop_reg[1:0],source_sop};
        data_eop_reg <= {data_eop_reg[1:0],source_eop};
    end
end

assign  data_sop = data_sop_reg[2];
assign  data_eop = data_eop_reg[2];


`else
//reg define
reg  [47:0] source_data;
reg  [31:0] data_real  ;
reg  [31:0] data_imag  ;
reg         data_sop1  ;
reg         data_sop2  ;
reg         data_eop1  ;
reg         data_eop2  ;
reg         data_valid1;
reg         data_valid2;
wire        m_axis_dout_tvalid ;
    always @ (posedge clk_50m or negedge rst_n) begin
        if(!rst_n) begin
            source_data <= 48'd0;
            data_real   <= 32'd0;
            data_imag   <= 32'd0;
        end
        else begin
            if(source_real[31]==1'b0)               //由补码计算原码
                data_real <= source_real;
            else
                data_real <= ~source_real + 1'b1;
                
            if(source_imag[31]==1'b0)               //由补码计算原码
                data_imag <= source_imag;
            else
                data_imag <= ~source_imag + 1'b1;            
            source_data <= (data_real*data_real) + (data_imag*data_imag);//计算原码平方和
            //if the mult is not enough,maybe can use more register for  streamline_mult
        end
    end
wire     [23:0] data_modulus_reg;
wire     data_valid_wire;
cordic_newton
#(     
     .d_width(48            )   , // this para just for test
     .q_width(48/2 - 1      )   ,
     .r_width(23 + 1        ) 
)
cordic_newton_inst
(
        .clk        (clk_50m     )    ,
        .rst        (~rst_n      )    ,   //active high
        .i_vaild    (source_valid)    ,
        .data_i     (source_data)    ,//data_21,data_12,data_22, //输入
     
        .o_vaild    (data_valid_wire  )    ,
        .data_o     (data_modulus_reg)    , //输出
        .data_r     (            )            //余数
);     //need 27 clock
//delay 27 clock

assign data_modulus = {8'b0,data_modulus_reg};

reg [26:0] data_sop_reg;
reg [26:0] data_eop_reg;

always@(posedge clk_50m) begin
    if(~rst_n) begin
        data_sop_reg <= 27'b0;
        data_eop_reg <= 27'b0;
    end else begin
        data_sop_reg <= {data_sop_reg[25:0],source_sop};
        data_eop_reg <= {data_eop_reg[25:0],source_eop};
    end
end

reg [1:0] data_valid_reg;
//delay one clock
always@(posedge clk_50m) begin
    if(~rst_n) begin
        data_valid_reg <= 2'b0;
    end else begin
        data_valid_reg <= {data_valid_reg[0],data_valid_wire};
    end
end


assign data_sop = data_sop_reg[26];
assign data_eop = data_eop_reg[26];
assign data_valid =  data_valid_reg[1];
    
    
    
`endif


endmodule


