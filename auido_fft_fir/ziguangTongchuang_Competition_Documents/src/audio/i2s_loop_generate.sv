//******************************************************************

//******************************************************************
//created date:2024/7/10
//use reg to change the frequency of audio signal
//self_define_module
//use the traditional fir to remove music or vocal,though it's not perfect

`timescale 1ns/1ns
module i2s_loop_generate
#(
    parameter DATA_WIDTH = 8,
    parameter key = 'b0000
)
(
    input                       sck,
    input                       rst_n,

    output reg [DATA_WIDTH - 1:0]  ldata,
    output reg [DATA_WIDTH - 1:0]  rdata,

    input   [DATA_WIDTH - 1:0]  data,
    input                       r_vld,
    input                       l_vld
);
/**********************para************************************/
parameter  normal         = 'b0000,
           female_to_male = 'b0001,
           male_to_female = 'b0010,
           remove_music   = 'b0100,
           remove_vocals  = 'b1000;
parameter fir_class = 'd100;
parameter signed [15:0] music_matrix [0:fir_class] = 
 {
   16'sd72,   // 0.00221 * 2^15
    16'sd56,   // 0.00170 * 2^15
    16'sd25,   // 0.00076 * 2^15
    -16'sd16,   // -0.00048 * 2^15
    -16'sd58,   // -0.00178 * 2^15
    -16'sd94,   // -0.00288 * 2^15
    -16'sd112,   // -0.00343 * 2^15
    -16'sd104,   // -0.00317 * 2^15
    -16'sd64,   // -0.00195 * 2^15
    16'sd4,   // 0.00013 * 2^15
    16'sd88,   // 0.00269 * 2^15
    16'sd168,   // 0.00512 * 2^15
    16'sd219,   // 0.00667 * 2^15
    16'sd219,   // 0.00669 * 2^15
    16'sd158,   // 0.00482 * 2^15
    16'sd39,   // 0.00118 * 2^15
    -16'sd117,   // -0.00356 * 2^15
    -16'sd270,   // -0.00825 * 2^15
    -16'sd379,   // -0.01156 * 2^15
    -16'sd403,   // -0.01230 * 2^15
    -16'sd321,   // -0.00981 * 2^15
    -16'sd139,   // -0.00424 * 2^15
    16'sd109,   // 0.00333 * 2^15
    16'sd365,   // 0.01114 * 2^15
    16'sd560,   // 0.01708 * 2^15
    16'sd632,   // 0.01928 * 2^15
    16'sd546,   // 0.01667 * 2^15
    16'sd307,   // 0.00937 * 2^15
    -16'sd39,   // -0.00120 * 2^15
    -16'sd412,   // -0.01258 * 2^15
    -16'sd716,   // -0.02184 * 2^15
    -16'sd863,   // -0.02633 * 2^15
    -16'sd801,   // -0.02445 * 2^15
    -16'sd529,   // -0.01615 * 2^15
    -16'sd101,   // -0.00309 * 2^15
    16'sd383,   // 0.01170 * 2^15
    16'sd803,   // 0.02451 * 2^15
    16'sd1046,   // 0.03192 * 2^15
    16'sd1039,   // 0.03170 * 2^15
    16'sd770,   // 0.02351 * 2^15
    16'sd296,   // 0.00904 * 2^15
    -16'sd272,   // -0.00831 * 2^15
    -16'sd795,   // -0.02425 * 2^15
    -16'sd1137,   // -0.03470 * 2^15
    -16'sd1208,   // -0.03685 * 2^15
    -16'sd981,   // -0.02994 * 2^15
    -16'sd508,   // -0.01549 * 2^15
    16'sd99,   // 0.00301 * 2^15
    16'sd688,   // 0.02100 * 2^15
    16'sd1114,   // 0.03399 * 2^15
    16'sd1269,   // 0.03871 * 2^15
    16'sd1114,   // 0.03399 * 2^15
    16'sd688,   // 0.02100 * 2^15
    16'sd99,   // 0.00301 * 2^15
    -16'sd508,   // -0.01549 * 2^15
    -16'sd981,   // -0.02994 * 2^15
    -16'sd1208,   // -0.03685 * 2^15
    -16'sd1137,   // -0.03470 * 2^15
    -16'sd795,   // -0.02425 * 2^15
    -16'sd272,   // -0.00831 * 2^15
    16'sd296,   // 0.00904 * 2^15
    16'sd770,   // 0.02351 * 2^15
    16'sd1039,   // 0.03170 * 2^15
    16'sd1046,   // 0.03192 * 2^15
    16'sd803,   // 0.02451 * 2^15
    16'sd383,   // 0.01170 * 2^15
    -16'sd101,   // -0.00309 * 2^15
    -16'sd529,   // -0.01615 * 2^15
    -16'sd801,   // -0.02445 * 2^15
    -16'sd863,   // -0.02633 * 2^15
    -16'sd716,   // -0.02184 * 2^15
    -16'sd412,   // -0.01258 * 2^15
    -16'sd39,   // -0.00120 * 2^15
    16'sd307,   // 0.00937 * 2^15
    16'sd546,   // 0.01667 * 2^15
    16'sd632,   // 0.01928 * 2^15
    16'sd560,   // 0.01708 * 2^15
    16'sd365,   // 0.01114 * 2^15
    16'sd109,   // 0.00333 * 2^15
    -16'sd139,   // -0.00424 * 2^15
    -16'sd321,   // -0.00981 * 2^15
    -16'sd403,   // -0.01230 * 2^15
    -16'sd379,   // -0.01156 * 2^15
    -16'sd270,   // -0.00825 * 2^15
    -16'sd117,   // -0.00356 * 2^15
    16'sd39,   // 0.00118 * 2^15
    16'sd158,   // 0.00482 * 2^15
    16'sd219,   // 0.00669 * 2^15
    16'sd219,   // 0.00667 * 2^15
    16'sd168,   // 0.00512 * 2^15
    16'sd88,   // 0.00269 * 2^15
    16'sd4,   // 0.00013 * 2^15
    -16'sd64,   // -0.00195 * 2^15
    -16'sd104,   // -0.00317 * 2^15
    -16'sd112,   // -0.00343 * 2^15
    -16'sd94,   // -0.00288 * 2^15
    -16'sd58,   // -0.00178 * 2^15
    -16'sd16,   // -0.00048 * 2^15
    16'sd25,   // 0.00076 * 2^15
    16'sd56,   // 0.00170 * 2^15
    16'sd72   // 0.00221 * 2^15
};

parameter  signed [15:0] vocals_matrix [0:fir_class] = 
{
    16'sd24,   // 0.00074 * 2^15
    16'sd22,   // 0.00066 * 2^15
    16'sd19,   // 0.00056 * 2^15
    16'sd15,   // 0.00046 * 2^15
    16'sd11,   // 0.00035 * 2^15
    16'sd7,   // 0.00023 * 2^15
    16'sd4,   // 0.00011 * 2^15
    16'sd0,   // 0.00001 * 2^15
    -16'sd2,   // -0.00005 * 2^15
    -16'sd2,   // -0.00007 * 2^15
    16'sd0,   // 0.00000 * 2^15
    16'sd5,   // 0.00017 * 2^15
    16'sd15,   // 0.00045 * 2^15
    16'sd28,   // 0.00085 * 2^15
    16'sd45,   // 0.00137 * 2^15
    16'sd65,   // 0.00199 * 2^15
    16'sd87,   // 0.00267 * 2^15
    16'sd109,   // 0.00334 * 2^15
    16'sd129,   // 0.00394 * 2^15
    16'sd143,   // 0.00436 * 2^15
    16'sd148,   // 0.00452 * 2^15
    16'sd141,   // 0.00431 * 2^15
    16'sd119,   // 0.00363 * 2^15
    16'sd79,   // 0.00242 * 2^15
    16'sd20,   // 0.00062 * 2^15
    -16'sd58,   // -0.00178 * 2^15
    -16'sd156,   // -0.00475 * 2^15
    -16'sd269,   // -0.00822 * 2^15
    -16'sd395,   // -0.01206 * 2^15
    -16'sd528,   // -0.01610 * 2^15
    -16'sd660,   // -0.02013 * 2^15
    -16'sd783,   // -0.02391 * 2^15
    -16'sd891,   // -0.02718 * 2^15
    -16'sd972,   // -0.02968 * 2^15
    -16'sd1021,   // -0.03116 * 2^15
    -16'sd1030,   // -0.03143 * 2^15
    -16'sd993,   // -0.03031 * 2^15
    -16'sd908,   // -0.02772 * 2^15
    -16'sd775,   // -0.02364 * 2^15
    -16'sd594,   // -0.01814 * 2^15
    -16'sd373,   // -0.01138 * 2^15
    -16'sd117,   // -0.00358 * 2^15
    16'sd162,   // 0.00494 * 2^15
    16'sd453,   // 0.01382 * 2^15
    16'sd742,   // 0.02265 * 2^15
    16'sd1017,   // 0.03104 * 2^15
    16'sd1264,   // 0.03856 * 2^15
    16'sd1470,   // 0.04485 * 2^15
    16'sd1625,   // 0.04958 * 2^15
    16'sd1721,   // 0.05253 * 2^15
    16'sd1754,   // 0.05353 * 2^15
    16'sd1721,   // 0.05253 * 2^15
    16'sd1625,   // 0.04958 * 2^15
    16'sd1470,   // 0.04485 * 2^15
    16'sd1264,   // 0.03856 * 2^15
    16'sd1017,   // 0.03104 * 2^15
    16'sd742,   // 0.02265 * 2^15
    16'sd453,   // 0.01382 * 2^15
    16'sd162,   // 0.00494 * 2^15
    -16'sd117,   // -0.00358 * 2^15
    -16'sd373,   // -0.01138 * 2^15
    -16'sd594,   // -0.01814 * 2^15
    -16'sd775,   // -0.02364 * 2^15
    -16'sd908,   // -0.02772 * 2^15
    -16'sd993,   // -0.03031 * 2^15
    -16'sd1030,   // -0.03143 * 2^15
    -16'sd1021,   // -0.03116 * 2^15
    -16'sd972,   // -0.02968 * 2^15
    -16'sd891,   // -0.02718 * 2^15
    -16'sd783,   // -0.02391 * 2^15
    -16'sd660,   // -0.02013 * 2^15
    -16'sd528,   // -0.01610 * 2^15
    -16'sd395,   // -0.01206 * 2^15
    -16'sd269,   // -0.00822 * 2^15
    -16'sd156,   // -0.00475 * 2^15
    -16'sd58,   // -0.00178 * 2^15
    16'sd20,   // 0.00062 * 2^15
    16'sd79,   // 0.00242 * 2^15
    16'sd119,   // 0.00363 * 2^15
    16'sd141,   // 0.00431 * 2^15
    16'sd148,   // 0.00452 * 2^15
    16'sd143,   // 0.00436 * 2^15
    16'sd129,   // 0.00394 * 2^15
    16'sd109,   // 0.00334 * 2^15
    16'sd87,   // 0.00267 * 2^15
    16'sd65,   // 0.00199 * 2^15
    16'sd45,   // 0.00137 * 2^15
    16'sd28,   // 0.00085 * 2^15
    16'sd15,   // 0.00045 * 2^15
    16'sd5,   // 0.00017 * 2^15
    16'sd0,   // 0.00000 * 2^15
    -16'sd2,   // -0.00007 * 2^15
    -16'sd2,   // -0.00005 * 2^15
    16'sd0,   // 0.00001 * 2^15
    16'sd4,   // 0.00011 * 2^15
    16'sd7,   // 0.00023 * 2^15
    16'sd11,   // 0.00035 * 2^15
    16'sd15,   // 0.00046 * 2^15
    16'sd19,   // 0.00056 * 2^15
    16'sd22,   // 0.00066 * 2^15
    16'sd24   // 0.00074 * 2^15
};

/**********************always************************************/

generate 
    if(key == normal) begin
        always @(posedge sck or negedge rst_n)
        begin
            if(~rst_n)
                ldata <= {DATA_WIDTH{1'b0}};
            else if(l_vld)
                ldata <= data;
        end

        always @(posedge sck or negedge rst_n)
        begin
            if(~rst_n)
                rdata <= {DATA_WIDTH{1'b0}};
            else if(r_vld)
                rdata <= data;
        end
    end else if(key == female_to_male) begin
        /******************para and reg******************************/
        parameter  ADDR_WIDTH = 8;
        localparam MAX_ADDR = (1 << ADDR_WIDTH) - 1;
        reg [DATA_WIDTH-1:0] memory_wla [0:(1 << ADDR_WIDTH)-1];
        reg [DATA_WIDTH-1:0] memory_wlb [0:(1 << ADDR_WIDTH)-1];
        reg [DATA_WIDTH-1:0] memory_wra [0:(1 << ADDR_WIDTH)-1];
        reg [DATA_WIDTH-1:0] memory_wrb [0:(1 << ADDR_WIDTH)-1];
        reg [ADDR_WIDTH-1:0] wrl_point;
        reg [ADDR_WIDTH-1:0] wrr_point;
        reg [ADDR_WIDTH-1:0] arl_point;
        reg [ADDR_WIDTH-1:0] arr_point;
        reg curbuffer;
        reg [5:0] frequency_cnt;
        reg wl_full;
        reg wr_full;
        /******************always******************************/
        always@(posedge sck or negedge rst_n)
        begin
            if(~rst_n)begin
                wrl_point  <= 'd0;
                wrr_point  <= 'd0;
                arl_point  <= 'd0;
                arr_point  <= 'd0;
                ldata <= {DATA_WIDTH{1'b0}};
                rdata <= {DATA_WIDTH{1'b0}};
                frequency_cnt <= 'd0;
                curbuffer <= 'd0;
                wl_full <= 'd0;
                wr_full <= 'd0;
            end else begin
                if(l_vld & ~wl_full) begin
                    if(curbuffer == 'd0)
                       memory_wla[wrl_point] <= data;
                    else
                       memory_wlb[wrl_point] <= data;
                       
                    wrl_point <= (wrl_point == MAX_ADDR) ?'d0:wrl_point + 1'b1;
                
                    if(wrl_point == MAX_ADDR)
                        wl_full <= 'd1;
                end
            
            
                if(r_vld &  ~wr_full)begin
                    if(curbuffer == 'd0)
                        memory_wra[wrr_point] <= data;
                    else
                        memory_wrb[wrr_point] <= data;
                 
                    wrr_point <= (wrr_point == MAX_ADDR)?'d0:wrr_point + 1'b1;
                   
                    if(wrr_point == MAX_ADDR)
                        wr_full <= 'd1;
                end
                
                frequency_cnt <= frequency_cnt + 1'b1;
            
                if(frequency_cnt == 'd0)begin
                    if(curbuffer == 'd0)begin
                        ldata <= memory_wlb[arl_point];
                        rdata <= memory_wrb[arr_point];
                    end else begin
                        ldata <= memory_wla[arl_point];
                        rdata <= memory_wra[arr_point];
                    end
                    
                    arl_point <= (arl_point == MAX_ADDR) ? 'd0 : arl_point + 1'b1;
                    arr_point <= (arr_point == MAX_ADDR) ? 'd0 : arr_point + 1'b1;
                    
                    if(arl_point == MAX_ADDR || arr_point == MAX_ADDR )begin
                        wl_full <= 'd0; 
                        wr_full <= 'd0;  
                        curbuffer <= ~curbuffer;
                    end
                end
            end
        end
        end else if(key == male_to_female)begin
            /******************para and reg******************************/
            parameter  ADDR_WIDTH = 10;
            localparam MAX_ADDR = (1 << ADDR_WIDTH) - 1;
            reg [DATA_WIDTH-1:0] memory_wla [0:(1 << ADDR_WIDTH)-1];
            reg [DATA_WIDTH-1:0] memory_wlb [0:(1 << ADDR_WIDTH)-1];
            reg [DATA_WIDTH-1:0] memory_wra [0:(1 << ADDR_WIDTH)-1];
            reg [DATA_WIDTH-1:0] memory_wrb [0:(1 << ADDR_WIDTH)-1];
            reg [ADDR_WIDTH-1:0] wrl_point;
            reg [ADDR_WIDTH-1:0] wrr_point;
            reg [ADDR_WIDTH-1:0] arl_point;
            reg [ADDR_WIDTH-1:0] arr_point;
            reg curbuffer;
            reg [3:0] frequency_cnt;
            reg wl_full;
            reg wr_full;
            /******************always******************************/
            always@(posedge sck or negedge rst_n)
            begin
                if(~rst_n)begin
                    wrl_point  <= 'd0;
                    wrr_point  <= 'd0;
                    arl_point  <= 'd0;
                    arr_point  <= 'd0;
                    ldata <= {DATA_WIDTH{1'b0}};
                    rdata <= {DATA_WIDTH{1'b0}};
                    frequency_cnt <= 'd0;
                    curbuffer <= 'd0;
                    wl_full <= 'd0;
                    wr_full <= 'd0;
            end else begin

                if(l_vld & ~wl_full) begin
                    if(curbuffer == 'd0)
                       memory_wla[wrl_point] <= data;
                    else
                       memory_wlb[wrl_point] <= data;
                       
                    wrl_point <= (wrl_point == MAX_ADDR) ?'d0:wrl_point + 1'b1;
                
                    if(wrl_point == MAX_ADDR)
                        wl_full <= 'd1;
                end
                
                
                if(r_vld &  ~wr_full)begin
                    if(curbuffer == 'd0)
                        memory_wra[wrr_point] <= data;
                    else
                        memory_wrb[wrr_point] <= data;
                 
                    wrr_point <= (wrr_point == MAX_ADDR)?'d0:wrr_point + 1'b1;
                   
                    if(wrr_point == MAX_ADDR)
                        wr_full <= 'd1;
                end
                    
                frequency_cnt <= frequency_cnt + 1'b1;
                
                if(frequency_cnt == 'd0)begin
                    if(curbuffer == 'd0)begin
                        ldata <= memory_wlb[arl_point];
                        rdata <= memory_wrb[arr_point];
                    end else begin
                        ldata <= memory_wla[arl_point];
                        rdata <= memory_wra[arr_point];
                    end
                    
                    arl_point <= (arl_point == MAX_ADDR) ? 'd0 : arl_point + 1'b1;
                    arr_point <= (arr_point == MAX_ADDR) ? 'd0 : arr_point + 1'b1;
                    
                    if(arl_point == MAX_ADDR || arr_point == MAX_ADDR )begin
                        wl_full <= 'd0; 
                        wr_full <= 'd0;  
                        curbuffer <= ~curbuffer;
                    end
                end
            end
        end
        end else if(key == remove_music)begin
           /******************para and reg******************************/
            reg signed [DATA_WIDTH - 1:0] l_x [0:fir_class];  
            reg signed [DATA_WIDTH - 1:0] r_x [0:fir_class]; 
            
            reg signed [31:0] l_acceleration;
            reg signed [31:0] r_acceleration;
            integer i;
            reg  [5:0]                 cnt1;
        
            always@(posedge sck or negedge rst_n)
            begin
                if(~rst_n)
                    cnt1 <= 6'h0;
                else
                begin
                    if(cnt1 == 6'd6)
                        cnt1 <= 6'h0;
                    else
                        cnt1 <= cnt1 + 1'b1;
                end
            end
            
            always@(posedge sck or negedge rst_n)
            begin
                if(~rst_n)
                begin
                    ldata <= {DATA_WIDTH{1'b0}};
                    for (i = 0; i <= fir_class; i = i + 1)
                        l_x[i] <= {DATA_WIDTH{1'b0}};
                end
                else if(l_vld && cnt1 == 6'd6)
                begin
                    for (i = fir_class; i > 0; i = i - 1)
                        l_x[i] <= l_x[i - 1];
                    l_x[0] <= data;


                    l_acceleration <= 'd0;
                    for (i = 0; i <= fir_class; i = i + 1)
                        l_acceleration <= l_acceleration + l_x[i] * music_matrix[i];

                    ldata <= {l_acceleration[31:16],1'b0} + l_acceleration[31:16];  //signed to unsigned  
                    //这里之所以不对ldata部分进行转换，是因为无符号和有符号混合使用时，统一转化为无符号计算，所以不转化也无伤大雅
                end
                else
                    ldata <=  ldata;
            end
            
            always@(posedge sck or negedge rst_n)
            begin
                if(~rst_n)
                begin
                    rdata <= {DATA_WIDTH{1'b0}};
                    for (i = 0; i <= fir_class; i = i + 1)
                        r_x[i] <= {DATA_WIDTH{1'b0}};
                end
                else if(r_vld && cnt1 == 6'd6)
                begin
                    for (i = fir_class; i > 0; i = i - 1)
                        r_x[i] <= r_x[i - 1];
                    r_x[0] <= data;


                    r_acceleration <= 'd0;
                    for (i = 0; i <= fir_class; i = i + 1)
                        r_acceleration <= r_acceleration + r_x[i] * music_matrix[i];

                    rdata <= {l_acceleration[31:16],1'b0} + l_acceleration[31:16]; 
                end
                else
                    rdata <=  rdata;
            end  
        end else if(key == remove_vocals)
        begin
         /******************para and reg******************************/
            reg signed [DATA_WIDTH - 1:0] l_x [0:fir_class];  
            reg signed [DATA_WIDTH - 1:0] r_x [0:fir_class]; 
            
            reg signed [31:0] l_acceleration;
            reg signed [31:0] r_acceleration;
            integer i;
            reg  [5:0]                 cnt1;
        
            always@(posedge sck or negedge rst_n)
            begin
                if(~rst_n)
                    cnt1 <= 6'h0;
                else
                begin
                    if(cnt1 == 6'd6)
                        cnt1 <= 6'h0;
                    else
                        cnt1 <= cnt1 + 1'b1;
                end
            end
            
            always@(posedge sck or negedge rst_n)
            begin
                if(~rst_n)
                begin
                    ldata <= {DATA_WIDTH{1'b0}};
                    for (i = 0; i <= fir_class; i = i + 1)
                        l_x[i] <= {DATA_WIDTH{1'b0}};
                end
                else if(l_vld && cnt1 == 6'd6)
                begin
                    for (i = fir_class; i > 0; i = i - 1)
                        l_x[i] <= l_x[i - 1];
                    l_x[0] <= data;


                    l_acceleration <= 'd0;
                    for (i = 0; i <= fir_class; i = i + 1)
                        l_acceleration <= l_acceleration + l_x[i] * vocals_matrix[i];

                    ldata <= {l_acceleration[31:16],1'b0} + l_acceleration[31:16]; 
                end
                else
                    ldata <=  ldata;
            end
            
            always@(posedge sck or negedge rst_n)
            begin
                if(~rst_n)
                begin
                    rdata <= {DATA_WIDTH{1'b0}};
                    for (i = 0; i <= fir_class; i = i + 1)
                        r_x[i] <= {DATA_WIDTH{1'b0}};
                end
                else if(r_vld && cnt1 == 6'd6)
                begin
                    for (i = fir_class; i > 0; i = i - 1)
                        r_x[i] <= r_x[i - 1];
                    r_x[0] <= data;


                    r_acceleration <= 'd0;
                    for (i = 0; i <= fir_class; i = i + 1)
                        r_acceleration <= r_acceleration + r_x[i] * vocals_matrix[i];

                    rdata <= {l_acceleration[31:16],1'b0} + l_acceleration[31:16]; 
                end
                else
                    rdata <=  rdata;
            end
        end
        else  begin
            always @(posedge sck or negedge rst_n)
            begin
                if(~rst_n)
                    ldata <= {DATA_WIDTH{1'b0}};
                else if(l_vld)
                    ldata <= data;
            end

            always @(posedge sck or negedge rst_n)
            begin
                if(~rst_n)
                    rdata <= {DATA_WIDTH{1'b0}};
                else if(r_vld)
                    rdata <= data;
            end
        end
    
endgenerate   



endmodule //i2s_loop
