/***********************************************************
This module is for streamline FIR design
************************************************************/
`define SAFE_DESIGN
 
module fir_guide    
( 
    input           rstn    ,
    input           clk     ,
    input           en      ,
    input [15:0]    xin     ,
    output          valid   ,
    output[30:0]    yout
   
);
 
reg [3:0]            en_r;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            en_r[3:0]      <=4'b0 ;
        end
        else begin
            en_r[3:0]      <= {en_r[2:0], en} ;
        end
    end
 
  
    reg        [15:0]   xin_reg[15:0];
    reg [4:0]            i, j ;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i=0; i<16; i=i+1) begin
                xin_reg[i]  <= 16'd0;
            end
        end
        else if (en) begin
            xin_reg[0] <= xin ;
            for (j=0; j<15; j=j+1) begin
                xin_reg[j+1] <= xin_reg[j] ; 
            end
        end
    end
 
 
    reg        [16:0]    add_reg[7:0];
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i=0; i<8; i=i+1) begin
                add_reg[i] <= 16'd0 ;
            end
        end
        else if (en_r[0]) begin
            for (i=0; i<8; i=i+1) begin
                add_reg[i] <= xin_reg[i] + xin_reg[15-i] ;
            end
        end
    end
 
 //  coef = -38	 4	56	113	169	219	255	275	275	255	219	169	113	56	4	-38   
    wire        [11:0]   coe[7:0]  ;
    assign coe[0]        = 12'd37  ;
    assign coe[1]        = 12'd4   ;
    assign coe[2]        = 12'd56  ;
    assign coe[3]        = 12'd113 ;
    assign coe[4]        = 12'd169 ;
    assign coe[5]        = 12'd219 ;
    assign coe[6]        = 12'd255 ;
    assign coe[7]        = 12'd275 ;

    wire        [28:0]   mout[7:0]; 
 
 

 
 
`ifdef SAFE_DESIGN
    //流水线式乘法器
    wire [7:0]          valid_mult;
    genvar              k ;
    generate
        for (k=0; k<8; k=k+1) begin
            mult_man #(17, 12)
            u_mult_paral          (
              .clk        (clk),
              .rstn       (rstn),
              .data_rdy   (en_r[1]),
              .mult1      (add_reg[k]),
              .mult2      (coe[k]),
              .res_rdy    (valid_mult[k]), 
              .res        (mout[k])
            );
        end
    endgenerate
    wire valid_mult7     = valid_mult[7] ;
 
`else
    //如果对时序要求不高，可以直接用乘号
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i=0 ; i<8; i=i+1) begin
                mout[i]     <= 29'b0 ;
            end
        end
        else if (en_r[1]) begin
            for (i=0 ; i<8; i=i+1) begin
                mout[i]     <= coe[i] * add_reg[i] ;
            end
        end
    end
    wire valid_mult7 = en_r[2];
`endif
 
    //(4) 积分累加，8组25bit数据 -> 1组 29bit 数据
    //数据有效延时
    reg [3:0]            valid_mult_r ;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_mult_r[3:0]  <= 'b0 ;
        end
        else begin
            valid_mult_r[3:0]  <= {valid_mult_r[2:0], valid_mult7} ;
        end
    end

`ifdef SAFE_DESIGN
    //加法运算时，分多个周期进行流水，优化时序
    reg        [30:0]    sum1 ;
    reg        [30:0]    sum2 ;
    reg        [30:0]    yout_t ;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sum1   <= 31'd0 ;
            sum2   <= 31'd0 ;
            yout_t <= 31'd0 ;
        end
        else if(valid_mult7) begin
            sum1   <= mout[0] + mout[1] + mout[2];
            sum2   <= mout[3] + mout[4] + mout[5];
            yout_t <= sum1 + sum2 ;
        end
    end
 
`else 
    //一步计算累加结果，但是实际中时序非常危险
    reg  [30:0]    sum ;
    reg  [30:0]    yout_t ;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sum    <= 31'd0 ;
            yout_t <= 31'd0 ;
        end
        else if (valid_mult7) begin
            sum    <= mout[0] + mout[1] + mout[2] + mout[3] + mout[4] + mout[5];
            yout_t <= sum ;
        end
    end 
`endif
    assign yout  = yout_t ;
    assign valid = valid_mult_r[0];

endmodule