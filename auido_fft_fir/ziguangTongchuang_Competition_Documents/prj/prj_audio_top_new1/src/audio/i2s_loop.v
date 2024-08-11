//******************************************************************

//******************************************************************
//created date:2024/7/10
//use reg to change the frequency of audio signal
//self_define_module

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
parameter  normal         = 'b0000 
           male_to_famale = 'b0001,
           female_to_male = 'b0010,
           remove_music   = 'b0100,
           remove_vocals  = 'b1000;
parameter fir_class = 'd100;
parameter signed [15:0] music_matrix [0:fir_class] = 
{
   16'sd72,   
    16'sd56,  
    16'sd25,  
    -16'sd16, 
    -16'sd58, 
    -16'sd94, 
    -16'sd112,
    -16'sd104,
    -16'sd64, 
    16'sd4,   
    16'sd88,  
    16'sd168, 
    16'sd219, 
    16'sd219, 
    16'sd158, 
    16'sd39,  
    -16'sd117,
    -16'sd270,
    -16'sd379,
    -16'sd403, 
    -16'sd321, 
    -16'sd139, 
    16'sd109,  
    16'sd365,  
    16'sd560,  
    16'sd632,  
    16'sd546,  
    16'sd307,  
    -16'sd39,  
    -16'sd412, 
    -16'sd716, 
    -16'sd863, 
    -16'sd801, 
    -16'sd529, 
    -16'sd101, 
    16'sd383,  
    16'sd803,  
    16'sd1046, 
    16'sd1039, 
    16'sd770,  
    16'sd296,  
    -16'sd272, 
    -16'sd795, 
    -16'sd1137,
    -16'sd1208,
    -16'sd981, 
    -16'sd508, 
    16'sd99,   
    16'sd688,  
    16'sd1114, 
    16'sd1269, 
    16'sd1114, 
    16'sd688,  
    16'sd99,   
    -16'sd508, 
    -16'sd981, 
    -16'sd1208,
    -16'sd1137,
    -16'sd795, 
    -16'sd272, 
    16'sd296,  
    16'sd770,  
    16'sd1039, 
    16'sd1046, 
    16'sd803,  
    16'sd383,  
    -16'sd101, 
    -16'sd529, 
    -16'sd801, 
    -16'sd863, 
    -16'sd716, 
    -16'sd412, 
    -16'sd39,  
    16'sd307,  
    16'sd546, 
    16'sd632, 
    16'sd560, 
    16'sd365, 
    16'sd109, 
    -16'sd139,
    -16'sd321,
    -16'sd403,
    -16'sd379,
    -16'sd270,
    -16'sd117,
    16'sd39,  
    16'sd158, 
    16'sd219, 
    16'sd219, 
    16'sd168, 
    16'sd88,  
    16'sd4,   
    -16'sd64, 
    -16'sd104,
    -16'sd112,
    -16'sd94, 
    -16'sd58, 
    -16'sd16, 
    16'sd25,  
    16'sd56,  
    16'sd72   
};

parameter  signed [15:0] vocals_matrix [0:fir_class] = 
{
    16'sd24,  
    16'sd22,  
    16'sd19,  
    16'sd15,  
    16'sd11,  
    16'sd7,   
    16'sd4,   
    16'sd0,   
    -16'sd2,  
    -16'sd2,  
    16'sd0,   
    16'sd5,   
    16'sd15,  
    16'sd28,  
    16'sd45,  
    16'sd65,  
    16'sd87,  
    16'sd109, 
    16'sd129, 
    16'sd143, 
    16'sd148, 
    16'sd141, 
    16'sd119, 
    16'sd79,  
    16'sd20,  
    -16'sd58, 
    -16'sd156,
    -16'sd269,
    -16'sd395,
    -16'sd528, 
    -16'sd660, 
    -16'sd783, 
    -16'sd891, 
    -16'sd972, 
    -16'sd1021,
    -16'sd1030,
    -16'sd993, 
    -16'sd908, 
    -16'sd775, 
    -16'sd594, 
    -16'sd373, 
    -16'sd117, 
    16'sd162,  
    16'sd453,  
    16'sd742,  
    16'sd1017, 
    16'sd1264, 
    16'sd1470, 
    16'sd1625, 
    16'sd1721, 
    16'sd1754, 
    16'sd1721, 
    16'sd1625, 
    16'sd1470, 
    16'sd1264, 
    16'sd1017, 
    16'sd742,  
    16'sd453,  
    16'sd162,  
    -16'sd117, 
    -16'sd373, 
    -16'sd594, 
    -16'sd775, 
    -16'sd908, 
    -16'sd993, 
    -16'sd1030,
    -16'sd1021,
    -16'sd972, 
    -16'sd891, 
    -16'sd783, 
    -16'sd660, 
    -16'sd528,
    -16'sd395,
    -16'sd269,
    -16'sd156,
    -16'sd58, 
    16'sd20,  
    16'sd79,  
    16'sd119, 
    16'sd141, 
    16'sd148, 
    16'sd143, 
    16'sd129, 
    16'sd109, 
    16'sd87,  
    16'sd65,  
    16'sd45,  
    16'sd28,  
    16'sd15,  
    16'sd5,   
    16'sd0,   
    -16'sd2,  
    -16'sd2,  
    16'sd0,   
    16'sd4,   
    16'sd7,   
    16'sd11,  
    16'sd15,  
    16'sd19,  
    16'sd22,  
    16'sd24   
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
    end else if(key == male_to_famale) begin
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
        end else if(key == female_to_male)begin
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
                        l_acceleration = l_acceleration + l_x[i] * music_matrix[i];

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
                        r_acceleration = r_acceleration + r_x[i] * music_matrix[i];

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
                        l_acceleration = l_acceleration + l_x[i] * vocals_matrix[i];

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
                        r_acceleration = r_acceleration + r_x[i] * vocals_matrix[i];

                    rdata <= {l_acceleration[31:16],1'b0} + l_acceleration[31:16]; 
                end
                else
                    rdata <=  rdata;
            end
        end else 
        begin
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
