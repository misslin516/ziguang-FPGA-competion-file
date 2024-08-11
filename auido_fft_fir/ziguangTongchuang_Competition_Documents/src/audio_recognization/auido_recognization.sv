//created date:2024/7/19
//Note:由于牛顿迭代算法本身带来的误差，除了比较商还要考虑余数,这里暂时没有考虑，采用扩大分子来消除这一影响
//Only 40clk can be done
//This code is function test for auido_recognization
module auido_recognization
#(
    parameter   Dlength = 'd192
)
(
    input          sys_clk                 ,
    input          sys_rst_n               ,
                                       
    input  signed [15:0] feature_in        ,
    input          feature_in_en           ,
                                    
    output  reg[3:0] compare_result        ,
    output  reg      compare_result_v1
);

/***********************para*********************************/
//This parameters come from python included every speaker's feature
parameter signed [15:0] feature_user1 [0:3] = {-16'sd1,16'sd2,16'sd2,-16'sd3};
parameter signed [15:0] feature_user2 [0:3] = {-16'sd2,16'sd2,16'sd2,-16'sd4};
parameter signed [15:0] feature_user3 [0:3] = {-16'sd1,-16'sd2,16'sd1,-16'sd5};
parameter signed [15:0] feature_user4 [0:3] = {-16'sd1,16'sd2,16'sd1,-16'sd6};

/***********************wire*********************************/
wire sumofsquare_origin_v;
wire [19:0] sumofsquare_origin_out;
 
wire sumofsquare_norm1_v;
wire [19:0] sumofsquare_norm1_out;

wire sumofsquare_norm2_v;
wire [19:0] sumofsquare_norm2_out;


wire sumofsquare_norm3_v;
wire [19:0] sumofsquare_norm3_out;

wire sumofsquare_norm4_v;
wire [19:0] sumofsquare_norm4_out;

wire simularity_v1;    
wire simularity_v2;    
wire simularity_v3;    
wire simularity_v4;    
   
wire [11:0] simularity_out1;
wire [11:0] simularity_out2;
wire [11:0] simularity_out3;
wire [11:0] simularity_out4;


wire signed [11:0] simularity_out11;
wire signed [11:0] simularity_out22;
wire signed [11:0] simularity_out33;
wire signed [11:0] simularity_out44;


wire  [39:0]  sumofsquare1_unsigned;
wire  [39:0]  sumofsquare2_unsigned;
wire  [39:0]  sumofsquare3_unsigned;
wire  [39:0]  sumofsquare4_unsigned;

/***********************reg*********************************/
reg signed [40:0]  sumofsquare1 [0:3];
reg signed [40:0]  sumofsquare2 [0:3];
reg signed [40:0]  sumofsquare3 [0:3];
reg signed [40:0]  sumofsquare4 [0:3];

reg signed [40:0] sumofsquare_origin[0:3];
reg signed [40:0] sumofsquare_norm1 [0:3];
reg signed [40:0] sumofsquare_norm2 [0:3];
reg signed [40:0] sumofsquare_norm3 [0:3];
reg signed [40:0] sumofsquare_norm4 [0:3];

reg   [7:0] cnt_en;
reg         sqrt_v;


reg [37:0] sqrt_end1;
reg [37:0] sqrt_end2;
reg [37:0] sqrt_end3;
reg [37:0] sqrt_end4;

reg   sumofsquare_norm1_v_reg0;
reg   sumofsquare_norm2_v_reg0;
reg   sumofsquare_norm3_v_reg0;
reg   sumofsquare_norm4_v_reg0;


reg [2:0] compare_result_reg;

reg compare_result_v;

/***********************assign******************************/
assign simularity_out11 = sumofsquare1[3][40]? ~simularity_out1+1'b1 : simularity_out1;
assign simularity_out22 = sumofsquare2[3][40]? ~simularity_out2+1'b1 : simularity_out2;
assign simularity_out33 = sumofsquare3[3][40]? ~simularity_out3+1'b1 : simularity_out3;
assign simularity_out44 = sumofsquare4[3][40]? ~simularity_out4+1'b1 : simularity_out4;

assign sumofsquare1_unsigned = (sumofsquare1[3][40])?~sumofsquare1[3][39:0]:sumofsquare1[3][39:0];
assign sumofsquare2_unsigned = (sumofsquare2[3][40])?~sumofsquare2[3][39:0]:sumofsquare2[3][39:0];
assign sumofsquare3_unsigned = (sumofsquare3[3][40])?~sumofsquare3[3][39:0]:sumofsquare3[3][39:0];
assign sumofsquare4_unsigned = (sumofsquare4[3][40])?~sumofsquare4[3][39:0]:sumofsquare4[3][39:0];


/***********************always******************************/
genvar i;
generate for(i=0;i<4;i=i+1)begin
    always@(posedge sys_clk or negedge sys_rst_n)
    begin
        if(~sys_rst_n)begin
            sumofsquare1[i] <= 'd0;
            sumofsquare2[i] <= 'd0;
            sumofsquare3[i] <= 'd0;
            sumofsquare4[i] <= 'd0;
        end else if(feature_in_en) begin
                if(i == 0) begin
                    sumofsquare1[i] <= feature_in * feature_user1[i];
                    sumofsquare2[i] <= feature_in * feature_user2[i];
                    sumofsquare3[i] <= feature_in * feature_user3[i];
                    sumofsquare4[i] <= feature_in * feature_user4[i];
                end else begin
                    sumofsquare1[i] <= sumofsquare1[i-1] +  feature_in * feature_user1[i];
                    sumofsquare2[i] <= sumofsquare2[i-1] +  feature_in * feature_user2[i];
                    sumofsquare3[i] <= sumofsquare3[i-1] +  feature_in * feature_user3[i];
                    sumofsquare4[i] <= sumofsquare4[i-1] +  feature_in * feature_user4[i];
                end
        end
    end
    
    always@(posedge sys_clk or negedge sys_rst_n)
    begin
        if(~sys_rst_n)begin
            sumofsquare_origin[i] <= 'd0;
             sumofsquare_norm1[i]<= 'd0;
             sumofsquare_norm2[i]<= 'd0;
             sumofsquare_norm3[i]<= 'd0;
             sumofsquare_norm4[i]<= 'd0;
        end else if(feature_in_en)begin
            if(i==0) begin
                sumofsquare_origin[i]  <= feature_in*feature_in;
                sumofsquare_norm1[i]   <= feature_user1[i] * feature_user1[i];
                sumofsquare_norm2[i]   <= feature_user2[i] * feature_user2[i];
                sumofsquare_norm3[i]   <= feature_user3[i] * feature_user3[i];
                sumofsquare_norm4[i]   <= feature_user4[i] * feature_user4[i];
            end else begin
                sumofsquare_origin[i]  <= sumofsquare_origin[i-1] + feature_in*feature_in;
                sumofsquare_norm1[i]   <= sumofsquare_norm1[i-1] + feature_user1[i] * feature_user1[i];
                sumofsquare_norm2[i]   <= sumofsquare_norm2[i-1] + feature_user2[i] * feature_user2[i];
                sumofsquare_norm3[i]   <= sumofsquare_norm3[i-1] + feature_user3[i] * feature_user3[i];
                sumofsquare_norm4[i]   <= sumofsquare_norm4[i-1] + feature_user4[i] * feature_user4[i];
            end
        end

    end
    
end
endgenerate


always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        cnt_en <= 'd0;
        sqrt_v <= 'd0;
    end else if (cnt_en == 'd4-1'b1)begin
        cnt_en <= cnt_en;
        sqrt_v <= 'd1;
    end else if(feature_in_en) begin
        cnt_en <= cnt_en + 1'b1;
    end else begin
        cnt_en <= cnt_en;
    end
end






always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end1 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm1_v)begin
        sqrt_end1 <= sumofsquare_origin_out * sumofsquare_norm1_out;
    end else begin
        sqrt_end1 <= sqrt_end1;
    end
end




always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end2 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm2_v)begin
        sqrt_end2 <= sumofsquare_origin_out * sumofsquare_norm2_out;
    end else begin
        sqrt_end2 <= sqrt_end2;
    end
end


always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end3 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm3_v)begin
        sqrt_end3 <= sumofsquare_origin_out * sumofsquare_norm3_out;
    end else begin
        sqrt_end3 <= sqrt_end3;
    end
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end4 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm4_v)begin
        sqrt_end4 <= sumofsquare_origin_out * sumofsquare_norm4_out;
    end else begin
        sqrt_end4 <= sqrt_end4;
    end
end




always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sumofsquare_norm1_v_reg0 <= 'd0;
        sumofsquare_norm2_v_reg0 <= 'd0;
        sumofsquare_norm3_v_reg0 <= 'd0;
        sumofsquare_norm4_v_reg0 <= 'd0;
    end else begin
        sumofsquare_norm1_v_reg0 <= sumofsquare_norm1_v;
        sumofsquare_norm2_v_reg0 <= sumofsquare_norm2_v;
        sumofsquare_norm3_v_reg0 <= sumofsquare_norm3_v;
        sumofsquare_norm4_v_reg0 <= sumofsquare_norm4_v;
    end
end

//compare the result
always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        compare_result_reg <= 'd0;
        compare_result_v <= 'd0;
    end else if(simularity_v1 && simularity_v2 && simularity_v3 && simularity_v4) begin
        compare_result_v <= 'd1;
        if(simularity_out11 > simularity_out22)begin
            compare_result_reg[0] <= 'd1;
        end else begin
            compare_result_reg[0] <= 'd0;
        end
        
        if(simularity_out22 > simularity_out33)begin
            compare_result_reg[1] <= 'd1;
        end else begin
            compare_result_reg[1] <= 'd0;
        end
        
        
        if(simularity_out33 > simularity_out44)begin
            compare_result_reg[2] <= 'd1;
        end else begin
            compare_result_reg[2] <= 'd0;
        end
    end
end


always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        compare_result <= 'd0;
    end else if(compare_result_v) begin
        case(compare_result_reg)
            3'b000:
                   compare_result <= 'd4;
            3'b001:
                   compare_result <=  (simularity_out11 > simularity_out44)?'d1:'d4;
            3'b010:
                   compare_result <=  (simularity_out22 > simularity_out44)?'d2:'d4;
            3'b011:
                   compare_result <=  (simularity_out11 > simularity_out44)?'d1:'d4;
            3'b100:
                   compare_result <= 'd3;
            3'b101:
                   compare_result <= (simularity_out11 > simularity_out33)?'d1:'d3;
            3'b110:
                   compare_result <= 'd2;
            3'b111:
                   compare_result <= 'd1;
            default:compare_result <= 'd0;
        endcase
    end
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        compare_result_v1 <= 1'b0;
    end else begin
        compare_result_v1 <= compare_result_v;
    end
end



 
cordic_newton
#(     
     .d_width(40            )   , // this para just for test
     .q_width(19            )   ,
     .r_width(20            ) 
)
cordic_newton_inst0
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_origin[3][39:0]     )    ,//data_21,data_12,data_22, //输入
     
        .o_vaild    (sumofsquare_origin_v   )    ,
        .data_o     (sumofsquare_origin_out )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock



cordic_newton
#(     
    .d_width(40      )   , // this para just for test
    .q_width(19      )   ,
    .r_width(20      ) 
)
cordic_newton_inst1
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm1[3][39:0]      )    ,//data_21,data_12,data_22, //输入
     
        .o_vaild    (sumofsquare_norm1_v    )    ,
        .data_o     (sumofsquare_norm1_out  )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock



cordic_newton
#(     
    .d_width(40     )   , // this para just for test
    .q_width(19     )   ,
    .r_width(20     ) 
)
cordic_newton_inst2
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm2[3][39:0]     )    ,//data_21,data_12,data_22, //输入
     
        .o_vaild    (sumofsquare_norm2_v   )    ,
        .data_o     (sumofsquare_norm2_out )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock



cordic_newton
#(     
    .d_width(40      )   , // this para just for test
    .q_width(19      )   ,
    .r_width(20      ) 
)
cordic_newton_inst3
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm3[3][39:0]      )    ,//data_21,data_12,data_22, //输入
                     
        .o_vaild    (sumofsquare_norm3_v    )    ,
        .data_o     (sumofsquare_norm3_out  )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock


cordic_newton
#(     
     .d_width(40      )   , // this para just for test
     .q_width(19      )   ,
     .r_width(20      ) 
)
cordic_newton_inst4
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm4[3][39:0]      )    ,//data_21,data_12,data_22, //输入
                     
        .o_vaild    (sumofsquare_norm4_v    )    ,
        .data_o     (sumofsquare_norm4_out  )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock

//需要一个除法IP
divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst0
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm1_v_reg0)  ,   //有效信号
    .dividend ( {sumofsquare1_unsigned,10'b0}   )  ,   //被除数
    .divisor  (   sqrt_end1             )  ,   //除数 	 
    .valid_o  (   simularity_v1         )  ,	  
    .quotient (   simularity_out1       )  ,	//商
    .remaind  (                         )   //余数 
    );
    
divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst1
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm2_v_reg0)  ,   //有效信号
    .dividend ({sumofsquare2_unsigned,10'b0}   )  ,   //被除数
    .divisor  (   sqrt_end2             )  ,   //除数 	 
    .valid_o  (   simularity_v2         )  ,	  
    .quotient (    simularity_out2      )  ,	//商
    .remaind  (                         )   //余数 
    );
    
divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst2
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm3_v_reg0)  ,   //有效信号
    .dividend ({sumofsquare3_unsigned,10'b0}    )  ,   //被除数
    .divisor  (   sqrt_end3             )  ,   //除数 	 
    .valid_o  (   simularity_v3         )  ,	  
    .quotient (    simularity_out3      )  ,	//商
    .remaind  (                         )   //余数 
    );
    
divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst3
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm4_v_reg0)  ,   //有效信号
    .dividend ({sumofsquare4_unsigned,10'b0}     )  ,   //被除数
    .divisor  (   sqrt_end4             )  ,   //除数 	 
    .valid_o  (   simularity_v4         )  ,	  
    .quotient (    simularity_out4      )  ,	//商
    .remaind  (                         )   //余数 
);

endmodule


















