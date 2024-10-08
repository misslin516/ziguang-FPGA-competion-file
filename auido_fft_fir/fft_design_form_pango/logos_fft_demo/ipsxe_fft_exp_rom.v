//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2022 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
// Functional description: generates twiddle value
// note: There is no need to use this module in the last stage because w(0) is 1

module ipsxe_fft_exp_rom (
    i_clk       ,
    i_clken     ,
    i_rstn      ,
    i_addr      ,
    o_rdata     , // delay 1
    o_blk_exp
);

parameter   FFT_MODE          = 1       ; // 1: FFT; 0: IFFT
parameter   LOG2_FFT_LEN      = 8       ;   
parameter   INPUT_WIDTH       = 16      ;
parameter   SCALE_MODE        = 0       ; // 1: block floating point; 0: unscaled

localparam  UNSCALED_WIDTH    = INPUT_WIDTH + LOG2_FFT_LEN + 1;
localparam  OUTPUT_WIDTH      = SCALE_MODE ? INPUT_WIDTH : UNSCALED_WIDTH;
                               
input                            i_clk        ;
input                            i_clken      ;
input                            i_rstn       ;
input      [LOG2_FFT_LEN-1:0]    i_addr       ;
output reg [OUTPUT_WIDTH*2-1:0]  o_rdata      ;
output     [4:0]                 o_blk_exp    ; 

// ------------------------------------------------------              
reg        [OUTPUT_WIDTH-1:0]    exp_re_rom [2**LOG2_FFT_LEN-1:0];
reg        [OUTPUT_WIDTH-1:0]    exp_im_rom [2**LOG2_FFT_LEN-1:0];
reg        [4:0]    fft_blk_exp[0:0] ;
reg        [4:0]    ifft_blk_exp [0:0];

initial begin
    if (FFT_MODE) begin
        exp_re_rom[0] = 'h1ffffb1;
        exp_re_rom[1] = 'h359c;
        exp_re_rom[2] = 'h5573;
        exp_re_rom[3] = 'h1b4c;
        exp_re_rom[4] = 'h1ffe893;
        exp_re_rom[5] = 'h1ff96c9;
        exp_re_rom[6] = 'h1ff10a8;
        exp_re_rom[7] = 'h1feca02;
        exp_re_rom[8] = 'h1fb6167;
        exp_re_rom[9] = 'h1ffbc2e;
        exp_re_rom[10] = 'h1fdd664;
        exp_re_rom[11] = 'h1ffa94a;
        exp_re_rom[12] = 'h1fbeae3;
        exp_re_rom[13] = 'h28f1b;
        exp_re_rom[14] = 'h1fdb055;
        exp_re_rom[15] = 'h2f861;
        exp_re_rom[16] = 'h1f7d8a6;
        exp_re_rom[17] = 'h1ff1710;
        exp_re_rom[18] = 'h1d42d;
        exp_re_rom[19] = 'h1fff6c6;
        exp_re_rom[20] = 'h5b0;
        exp_re_rom[21] = 'h6b04;
        exp_re_rom[22] = 'h1fe80ee;
        exp_re_rom[23] = 'h1ffe75c;
        exp_re_rom[24] = 'h4c63;
        exp_re_rom[25] = 'h1ffb570;
        exp_re_rom[26] = 'h1fae443;
        exp_re_rom[27] = 'hc2cb;
        exp_re_rom[28] = 'h1fc607a;
        exp_re_rom[29] = 'h1febf34;
        exp_re_rom[30] = 'h1fb2e82;
        exp_re_rom[31] = 'h3c803;
        exp_re_rom[32] = 'h1f869b3;
        exp_re_rom[33] = 'h1ffe364;
        exp_re_rom[34] = 'h68efa;
        exp_re_rom[35] = 'h1ff5188;
        exp_re_rom[36] = 'h7f83;
        exp_re_rom[37] = 'h58b8;
        exp_re_rom[38] = 'h1ff96f3;
        exp_re_rom[39] = 'h1ddf7;
        exp_re_rom[40] = 'h32bec;
        exp_re_rom[41] = 'h1ff1ab8;
        exp_re_rom[42] = 'h2585f;
        exp_re_rom[43] = 'h1fcd8d9;
        exp_re_rom[44] = 'h1fd8ad4;
        exp_re_rom[45] = 'h1ffc3a7;
        exp_re_rom[46] = 'h1ff5c44;
        exp_re_rom[47] = 'h1fbc289;
        exp_re_rom[48] = 'h46511;
        exp_re_rom[49] = 'h22052;
        exp_re_rom[50] = 'h12c48;
        exp_re_rom[51] = 'h25339;
        exp_re_rom[52] = 'h83f2;
        exp_re_rom[53] = 'hf8f2;
        exp_re_rom[54] = 'h1ffd062;
        exp_re_rom[55] = 'h1fea099;
        exp_re_rom[56] = 'h5a885;
        exp_re_rom[57] = 'h1a956;
        exp_re_rom[58] = 'h20886;
        exp_re_rom[59] = 'h20fca;
        exp_re_rom[60] = 'h1984;
        exp_re_rom[61] = 'h1fc6eed;
        exp_re_rom[62] = 'h1fb18f6;
        exp_re_rom[63] = 'h1fe8d3c;
        exp_re_rom[64] = 'h116670;
        exp_re_rom[65] = 'h1fed618;
        exp_re_rom[66] = 'h1fd2c7c;
        exp_re_rom[67] = 'h1fee6e2;
        exp_re_rom[68] = 'hfd5;
        exp_re_rom[69] = 'h1ff89b6;
        exp_re_rom[70] = 'h1ffab25;
        exp_re_rom[71] = 'h24084;
        exp_re_rom[72] = 'h6c51b;
        exp_re_rom[73] = 'h1ffa585;
        exp_re_rom[74] = 'h6804;
        exp_re_rom[75] = 'h596;
        exp_re_rom[76] = 'h1fd35b4;
        exp_re_rom[77] = 'h46919;
        exp_re_rom[78] = 'hfb48;
        exp_re_rom[79] = 'h1d79a;
        exp_re_rom[80] = 'h3185f;
        exp_re_rom[81] = 'h1fd189d;
        exp_re_rom[82] = 'h1ff3b16;
        exp_re_rom[83] = 'h1ff796d;
        exp_re_rom[84] = 'h1ff89c4;
        exp_re_rom[85] = 'h1ffebf0;
        exp_re_rom[86] = 'h1ffe1e4;
        exp_re_rom[87] = 'h37fd;
        exp_re_rom[88] = 'h1ffbb20;
        exp_re_rom[89] = 'h18c28;
        exp_re_rom[90] = 'h5426;
        exp_re_rom[91] = 'ha631;
        exp_re_rom[92] = 'h12d01;
        exp_re_rom[93] = 'h1fe74ca;
        exp_re_rom[94] = 'h6013e;
        exp_re_rom[95] = 'h1fff404;
        exp_re_rom[96] = 'h1fa9c39;
        exp_re_rom[97] = 'h188fe;
        exp_re_rom[98] = 'h1fd4fc7;
        exp_re_rom[99] = 'h1ff3dd9;
        exp_re_rom[100] = 'h1ff570c;
        exp_re_rom[101] = 'h1ff3d1f;
        exp_re_rom[102] = 'h31288;
        exp_re_rom[103] = 'h1fbe213;
        exp_re_rom[104] = 'h1fc01a0;
        exp_re_rom[105] = 'h6483;
        exp_re_rom[106] = 'h1ff5ed8;
        exp_re_rom[107] = 'hf133;
        exp_re_rom[108] = 'h27a23;
        exp_re_rom[109] = 'h1ffa79a;
        exp_re_rom[110] = 'h35f25;
        exp_re_rom[111] = 'h1fe18f1;
        exp_re_rom[112] = 'h1fa09fb;
        exp_re_rom[113] = 'h16f00;
        exp_re_rom[114] = 'h1feb26c;
        exp_re_rom[115] = 'h1ffecfc;
        exp_re_rom[116] = 'h1ff9a69;
        exp_re_rom[117] = 'h380c;
        exp_re_rom[118] = 'he4da;
        exp_re_rom[119] = 'h3d2ca;
        exp_re_rom[120] = 'h1ee3ef3;
        exp_re_rom[121] = 'h1fb4050;
        exp_re_rom[122] = 'h1ffa8e5;
        exp_re_rom[123] = 'h1ff944c;
        exp_re_rom[124] = 'h96986;
        exp_re_rom[125] = 'h44285;
        exp_re_rom[126] = 'h791ab;
        exp_re_rom[127] = 'h52795;
        exp_re_rom[128] = 'h1eeaaa1;
        exp_re_rom[129] = 'h1fd08a8;
        exp_re_rom[130] = 'h1fef47b;
        exp_re_rom[131] = 'h62e6;
        exp_re_rom[132] = 'h2407;
        exp_re_rom[133] = 'h1ff2ddb;
        exp_re_rom[134] = 'h1fd466c;
        exp_re_rom[135] = 'h1fdc4b6;
        exp_re_rom[136] = 'h1fc8861;
        exp_re_rom[137] = 'h418ba;
        exp_re_rom[138] = 'h48daa;
        exp_re_rom[139] = 'h1fe6b2c;
        exp_re_rom[140] = 'h3daf3;
        exp_re_rom[141] = 'h1fb6cc1;
        exp_re_rom[142] = 'h1ff4cfd;
        exp_re_rom[143] = 'h1fd0513;
        exp_re_rom[144] = 'h1fe6122;
        exp_re_rom[145] = 'h4d11a;
        exp_re_rom[146] = 'h4347;
        exp_re_rom[147] = 'hbfe2;
        exp_re_rom[148] = 'h94c6;
        exp_re_rom[149] = 'h9f78;
        exp_re_rom[150] = 'h1ff800e;
        exp_re_rom[151] = 'h81b0;
        exp_re_rom[152] = 'h1f8e2c5;
        exp_re_rom[153] = 'h1fe0db8;
        exp_re_rom[154] = 'h4d643;
        exp_re_rom[155] = 'h1fd8a99;
        exp_re_rom[156] = 'h6484c;
        exp_re_rom[157] = 'ha9ee;
        exp_re_rom[158] = 'h1fb860a;
        exp_re_rom[159] = 'h1fefe87;
        exp_re_rom[160] = 'h7783b;
        exp_re_rom[161] = 'h1fe1ed2;
        exp_re_rom[162] = 'h2c474;
        exp_re_rom[163] = 'h6588;
        exp_re_rom[164] = 'h9e31;
        exp_re_rom[165] = 'ha736;
        exp_re_rom[166] = 'he301;
        exp_re_rom[167] = 'h1ffa5d5;
        exp_re_rom[168] = 'h1fab0f2;
        exp_re_rom[169] = 'h1692e;
        exp_re_rom[170] = 'h1f8f739;
        exp_re_rom[171] = 'h6c65d;
        exp_re_rom[172] = 'h68a90;
        exp_re_rom[173] = 'h1fee98d;
        exp_re_rom[174] = 'h1fe2b12;
        exp_re_rom[175] = 'h2e8c9;
        exp_re_rom[176] = 'h3c411;
        exp_re_rom[177] = 'h1fdf86c;
        exp_re_rom[178] = 'hfe9c;
        exp_re_rom[179] = 'h24bb;
        exp_re_rom[180] = 'h3848;
        exp_re_rom[181] = 'h6c74;
        exp_re_rom[182] = 'hab64;
        exp_re_rom[183] = 'h13ced;
        exp_re_rom[184] = 'h1fe7ce7;
        exp_re_rom[185] = 'h1fe3ca8;
        exp_re_rom[186] = 'h1fa112e;
        exp_re_rom[187] = 'h1fa67e4;
        exp_re_rom[188] = 'h166082;
        exp_re_rom[189] = 'h267a1;
        exp_re_rom[190] = 'h1fb4154;
        exp_re_rom[191] = 'h1fa22e2;
        exp_re_rom[192] = 'h1ff666e;
        exp_re_rom[193] = 'h279d0;
        exp_re_rom[194] = 'hd3b6;
        exp_re_rom[195] = 'h1ff422c;
        exp_re_rom[196] = 'h1ffac71;
        exp_re_rom[197] = 'h1ff9da6;
        exp_re_rom[198] = 'h1fff3bb;
        exp_re_rom[199] = 'h1ffc750;
        exp_re_rom[200] = 'h1fd03fd;
        exp_re_rom[201] = 'hfad7;
        exp_re_rom[202] = 'h135ae;
        exp_re_rom[203] = 'h1b5d8;
        exp_re_rom[204] = 'h608ba;
        exp_re_rom[205] = 'h1ff463f;
        exp_re_rom[206] = 'h1fb3706;
        exp_re_rom[207] = 'h3af6e;
        exp_re_rom[208] = 'h1fa6219;
        exp_re_rom[209] = 'h1fd2db9;
        exp_re_rom[210] = 'h1fffaae;
        exp_re_rom[211] = 'h1ff7fef;
        exp_re_rom[212] = 'h1ff6b5a;
        exp_re_rom[213] = 'hb20;
        exp_re_rom[214] = 'h1feef38;
        exp_re_rom[215] = 'h1ffa037;
        exp_re_rom[216] = 'h39318;
        exp_re_rom[217] = 'h14f8c;
        exp_re_rom[218] = 'h1fd6d98;
        exp_re_rom[219] = 'h3edb;
        exp_re_rom[220] = 'h8b301;
        exp_re_rom[221] = 'h2d60;
        exp_re_rom[222] = 'h1f67bde;
        exp_re_rom[223] = 'h5b566;
        exp_re_rom[224] = 'h1f50959;
        exp_re_rom[225] = 'h8998;
        exp_re_rom[226] = 'h2541b;
        exp_re_rom[227] = 'h1ffad77;
        exp_re_rom[228] = 'h1ffb700;
        exp_re_rom[229] = 'h1ff7ec3;
        exp_re_rom[230] = 'h1fe2ce8;
        exp_re_rom[231] = 'h18f3d;
        exp_re_rom[232] = 'h4df52;
        exp_re_rom[233] = 'h1feddb3;
        exp_re_rom[234] = 'h1bd50;
        exp_re_rom[235] = 'h4abb;
        exp_re_rom[236] = 'h5452d;
        exp_re_rom[237] = 'h1fdca86;
        exp_re_rom[238] = 'h406d5;
        exp_re_rom[239] = 'h1f5c881;
        exp_re_rom[240] = 'h30f93;
        exp_re_rom[241] = 'h2766a;
        exp_re_rom[242] = 'h10548;
        exp_re_rom[243] = 'hc05c;
        exp_re_rom[244] = 'h2509;
        exp_re_rom[245] = 'h1ffa772;
        exp_re_rom[246] = 'h1ff6910;
        exp_re_rom[247] = 'h1fe3838;
        exp_re_rom[248] = 'h1e3b1;
        exp_re_rom[249] = 'h1fff716;
        exp_re_rom[250] = 'he423;
        exp_re_rom[251] = 'h1ffc7de;
        exp_re_rom[252] = 'h29994;
        exp_re_rom[253] = 'hcb19;
        exp_re_rom[254] = 'h17013;
        exp_re_rom[255] = 'hb0e9;
    end
    else begin
        exp_re_rom[0] = 'h1ffffb1;
        exp_re_rom[1] = 'hb0e9;
        exp_re_rom[2] = 'h17013;
        exp_re_rom[3] = 'hcb19;
        exp_re_rom[4] = 'h29994;
        exp_re_rom[5] = 'h1ffc7de;
        exp_re_rom[6] = 'he423;
        exp_re_rom[7] = 'h1fff716;
        exp_re_rom[8] = 'h1e3b1;
        exp_re_rom[9] = 'h1fe3838;
        exp_re_rom[10] = 'h1ff6910;
        exp_re_rom[11] = 'h1ffa772;
        exp_re_rom[12] = 'h2509;
        exp_re_rom[13] = 'hc05c;
        exp_re_rom[14] = 'h10548;
        exp_re_rom[15] = 'h2766a;
        exp_re_rom[16] = 'h30f93;
        exp_re_rom[17] = 'h1f5c881;
        exp_re_rom[18] = 'h406d5;
        exp_re_rom[19] = 'h1fdca86;
        exp_re_rom[20] = 'h5452d;
        exp_re_rom[21] = 'h4abb;
        exp_re_rom[22] = 'h1bd50;
        exp_re_rom[23] = 'h1feddb3;
        exp_re_rom[24] = 'h4df52;
        exp_re_rom[25] = 'h18f3d;
        exp_re_rom[26] = 'h1fe2ce8;
        exp_re_rom[27] = 'h1ff7ec3;
        exp_re_rom[28] = 'h1ffb700;
        exp_re_rom[29] = 'h1ffad77;
        exp_re_rom[30] = 'h2541b;
        exp_re_rom[31] = 'h8998;
        exp_re_rom[32] = 'h1f50959;
        exp_re_rom[33] = 'h5b566;
        exp_re_rom[34] = 'h1f67bde;
        exp_re_rom[35] = 'h2d60;
        exp_re_rom[36] = 'h8b301;
        exp_re_rom[37] = 'h3edb;
        exp_re_rom[38] = 'h1fd6d98;
        exp_re_rom[39] = 'h14f8c;
        exp_re_rom[40] = 'h39318;
        exp_re_rom[41] = 'h1ffa037;
        exp_re_rom[42] = 'h1feef38;
        exp_re_rom[43] = 'hb20;
        exp_re_rom[44] = 'h1ff6b5a;
        exp_re_rom[45] = 'h1ff7fef;
        exp_re_rom[46] = 'h1fffaae;
        exp_re_rom[47] = 'h1fd2db9;
        exp_re_rom[48] = 'h1fa6219;
        exp_re_rom[49] = 'h3af6e;
        exp_re_rom[50] = 'h1fb3706;
        exp_re_rom[51] = 'h1ff463f;
        exp_re_rom[52] = 'h608ba;
        exp_re_rom[53] = 'h1b5d8;
        exp_re_rom[54] = 'h135ae;
        exp_re_rom[55] = 'hfad7;
        exp_re_rom[56] = 'h1fd03fd;
        exp_re_rom[57] = 'h1ffc750;
        exp_re_rom[58] = 'h1fff3bb;
        exp_re_rom[59] = 'h1ff9da6;
        exp_re_rom[60] = 'h1ffac71;
        exp_re_rom[61] = 'h1ff422c;
        exp_re_rom[62] = 'hd3b6;
        exp_re_rom[63] = 'h279d0;
        exp_re_rom[64] = 'h1ff666e;
        exp_re_rom[65] = 'h1fa22e2;
        exp_re_rom[66] = 'h1fb4154;
        exp_re_rom[67] = 'h267a1;
        exp_re_rom[68] = 'h166082;
        exp_re_rom[69] = 'h1fa67e4;
        exp_re_rom[70] = 'h1fa112e;
        exp_re_rom[71] = 'h1fe3ca8;
        exp_re_rom[72] = 'h1fe7ce7;
        exp_re_rom[73] = 'h13ced;
        exp_re_rom[74] = 'hab64;
        exp_re_rom[75] = 'h6c74;
        exp_re_rom[76] = 'h3848;
        exp_re_rom[77] = 'h24bb;
        exp_re_rom[78] = 'hfe9c;
        exp_re_rom[79] = 'h1fdf86c;
        exp_re_rom[80] = 'h3c411;
        exp_re_rom[81] = 'h2e8c9;
        exp_re_rom[82] = 'h1fe2b12;
        exp_re_rom[83] = 'h1fee98d;
        exp_re_rom[84] = 'h68a90;
        exp_re_rom[85] = 'h6c65d;
        exp_re_rom[86] = 'h1f8f739;
        exp_re_rom[87] = 'h1692e;
        exp_re_rom[88] = 'h1fab0f2;
        exp_re_rom[89] = 'h1ffa5d5;
        exp_re_rom[90] = 'he301;
        exp_re_rom[91] = 'ha736;
        exp_re_rom[92] = 'h9e31;
        exp_re_rom[93] = 'h6588;
        exp_re_rom[94] = 'h2c474;
        exp_re_rom[95] = 'h1fe1ed2;
        exp_re_rom[96] = 'h7783b;
        exp_re_rom[97] = 'h1fefe87;
        exp_re_rom[98] = 'h1fb860a;
        exp_re_rom[99] = 'ha9ee;
        exp_re_rom[100] = 'h6484c;
        exp_re_rom[101] = 'h1fd8a99;
        exp_re_rom[102] = 'h4d643;
        exp_re_rom[103] = 'h1fe0db8;
        exp_re_rom[104] = 'h1f8e2c5;
        exp_re_rom[105] = 'h81b0;
        exp_re_rom[106] = 'h1ff800e;
        exp_re_rom[107] = 'h9f78;
        exp_re_rom[108] = 'h94c6;
        exp_re_rom[109] = 'hbfe2;
        exp_re_rom[110] = 'h4347;
        exp_re_rom[111] = 'h4d11a;
        exp_re_rom[112] = 'h1fe6122;
        exp_re_rom[113] = 'h1fd0513;
        exp_re_rom[114] = 'h1ff4cfd;
        exp_re_rom[115] = 'h1fb6cc1;
        exp_re_rom[116] = 'h3daf3;
        exp_re_rom[117] = 'h1fe6b2c;
        exp_re_rom[118] = 'h48daa;
        exp_re_rom[119] = 'h418ba;
        exp_re_rom[120] = 'h1fc8861;
        exp_re_rom[121] = 'h1fdc4b6;
        exp_re_rom[122] = 'h1fd466c;
        exp_re_rom[123] = 'h1ff2ddb;
        exp_re_rom[124] = 'h2407;
        exp_re_rom[125] = 'h62e6;
        exp_re_rom[126] = 'h1fef47b;
        exp_re_rom[127] = 'h1fd08a8;
        exp_re_rom[128] = 'h1eeaaa1;
        exp_re_rom[129] = 'h52795;
        exp_re_rom[130] = 'h791ab;
        exp_re_rom[131] = 'h44285;
        exp_re_rom[132] = 'h96986;
        exp_re_rom[133] = 'h1ff944c;
        exp_re_rom[134] = 'h1ffa8e5;
        exp_re_rom[135] = 'h1fb4050;
        exp_re_rom[136] = 'h1ee3ef3;
        exp_re_rom[137] = 'h3d2ca;
        exp_re_rom[138] = 'he4da;
        exp_re_rom[139] = 'h380c;
        exp_re_rom[140] = 'h1ff9a69;
        exp_re_rom[141] = 'h1ffecfc;
        exp_re_rom[142] = 'h1feb26c;
        exp_re_rom[143] = 'h16f00;
        exp_re_rom[144] = 'h1fa09fb;
        exp_re_rom[145] = 'h1fe18f1;
        exp_re_rom[146] = 'h35f25;
        exp_re_rom[147] = 'h1ffa79a;
        exp_re_rom[148] = 'h27a23;
        exp_re_rom[149] = 'hf133;
        exp_re_rom[150] = 'h1ff5ed8;
        exp_re_rom[151] = 'h6483;
        exp_re_rom[152] = 'h1fc01a0;
        exp_re_rom[153] = 'h1fbe213;
        exp_re_rom[154] = 'h31288;
        exp_re_rom[155] = 'h1ff3d1f;
        exp_re_rom[156] = 'h1ff570c;
        exp_re_rom[157] = 'h1ff3dd9;
        exp_re_rom[158] = 'h1fd4fc7;
        exp_re_rom[159] = 'h188fe;
        exp_re_rom[160] = 'h1fa9c39;
        exp_re_rom[161] = 'h1fff404;
        exp_re_rom[162] = 'h6013e;
        exp_re_rom[163] = 'h1fe74ca;
        exp_re_rom[164] = 'h12d01;
        exp_re_rom[165] = 'ha631;
        exp_re_rom[166] = 'h5426;
        exp_re_rom[167] = 'h18c28;
        exp_re_rom[168] = 'h1ffbb20;
        exp_re_rom[169] = 'h37fd;
        exp_re_rom[170] = 'h1ffe1e4;
        exp_re_rom[171] = 'h1ffebf0;
        exp_re_rom[172] = 'h1ff89c4;
        exp_re_rom[173] = 'h1ff796d;
        exp_re_rom[174] = 'h1ff3b16;
        exp_re_rom[175] = 'h1fd189d;
        exp_re_rom[176] = 'h3185f;
        exp_re_rom[177] = 'h1d79a;
        exp_re_rom[178] = 'hfb48;
        exp_re_rom[179] = 'h46919;
        exp_re_rom[180] = 'h1fd35b4;
        exp_re_rom[181] = 'h596;
        exp_re_rom[182] = 'h6804;
        exp_re_rom[183] = 'h1ffa585;
        exp_re_rom[184] = 'h6c51b;
        exp_re_rom[185] = 'h24084;
        exp_re_rom[186] = 'h1ffab25;
        exp_re_rom[187] = 'h1ff89b6;
        exp_re_rom[188] = 'hfd5;
        exp_re_rom[189] = 'h1fee6e2;
        exp_re_rom[190] = 'h1fd2c7c;
        exp_re_rom[191] = 'h1fed618;
        exp_re_rom[192] = 'h116670;
        exp_re_rom[193] = 'h1fe8d3c;
        exp_re_rom[194] = 'h1fb18f6;
        exp_re_rom[195] = 'h1fc6eed;
        exp_re_rom[196] = 'h1984;
        exp_re_rom[197] = 'h20fca;
        exp_re_rom[198] = 'h20886;
        exp_re_rom[199] = 'h1a956;
        exp_re_rom[200] = 'h5a885;
        exp_re_rom[201] = 'h1fea099;
        exp_re_rom[202] = 'h1ffd062;
        exp_re_rom[203] = 'hf8f2;
        exp_re_rom[204] = 'h83f2;
        exp_re_rom[205] = 'h25339;
        exp_re_rom[206] = 'h12c48;
        exp_re_rom[207] = 'h22052;
        exp_re_rom[208] = 'h46511;
        exp_re_rom[209] = 'h1fbc289;
        exp_re_rom[210] = 'h1ff5c44;
        exp_re_rom[211] = 'h1ffc3a7;
        exp_re_rom[212] = 'h1fd8ad4;
        exp_re_rom[213] = 'h1fcd8d9;
        exp_re_rom[214] = 'h2585f;
        exp_re_rom[215] = 'h1ff1ab8;
        exp_re_rom[216] = 'h32bec;
        exp_re_rom[217] = 'h1ddf7;
        exp_re_rom[218] = 'h1ff96f3;
        exp_re_rom[219] = 'h58b8;
        exp_re_rom[220] = 'h7f83;
        exp_re_rom[221] = 'h1ff5188;
        exp_re_rom[222] = 'h68efa;
        exp_re_rom[223] = 'h1ffe364;
        exp_re_rom[224] = 'h1f869b3;
        exp_re_rom[225] = 'h3c803;
        exp_re_rom[226] = 'h1fb2e82;
        exp_re_rom[227] = 'h1febf34;
        exp_re_rom[228] = 'h1fc607a;
        exp_re_rom[229] = 'hc2cb;
        exp_re_rom[230] = 'h1fae443;
        exp_re_rom[231] = 'h1ffb570;
        exp_re_rom[232] = 'h4c63;
        exp_re_rom[233] = 'h1ffe75c;
        exp_re_rom[234] = 'h1fe80ee;
        exp_re_rom[235] = 'h6b04;
        exp_re_rom[236] = 'h5b0;
        exp_re_rom[237] = 'h1fff6c6;
        exp_re_rom[238] = 'h1d42d;
        exp_re_rom[239] = 'h1ff1710;
        exp_re_rom[240] = 'h1f7d8a6;
        exp_re_rom[241] = 'h2f861;
        exp_re_rom[242] = 'h1fdb055;
        exp_re_rom[243] = 'h28f1b;
        exp_re_rom[244] = 'h1fbeae3;
        exp_re_rom[245] = 'h1ffa94a;
        exp_re_rom[246] = 'h1fdd664;
        exp_re_rom[247] = 'h1ffbc2e;
        exp_re_rom[248] = 'h1fb6167;
        exp_re_rom[249] = 'h1feca02;
        exp_re_rom[250] = 'h1ff10a8;
        exp_re_rom[251] = 'h1ff96c9;
        exp_re_rom[252] = 'h1ffe893;
        exp_re_rom[253] = 'h1b4c;
        exp_re_rom[254] = 'h5573;
        exp_re_rom[255] = 'h359c;
    end
end
initial begin
    if (FFT_MODE) begin
        exp_im_rom[0] = 'h1ffffae;
        exp_im_rom[1] = 'h717c;
        exp_im_rom[2] = 'h9131;
        exp_im_rom[3] = 'h2003;
        exp_im_rom[4] = 'h1fff7a2;
        exp_im_rom[5] = 'h3ee;
        exp_im_rom[6] = 'h1ff9cbe;
        exp_im_rom[7] = 'h597;
        exp_im_rom[8] = 'h1fe2381;
        exp_im_rom[9] = 'h2bf30;
        exp_im_rom[10] = 'h19f07;
        exp_im_rom[11] = 'h24c27;
        exp_im_rom[12] = 'hab5b;
        exp_im_rom[13] = 'h2d823;
        exp_im_rom[14] = 'h1e39b;
        exp_im_rom[15] = 'h338d1;
        exp_im_rom[16] = 'h2a55d;
        exp_im_rom[17] = 'h1f8c7d8;
        exp_im_rom[18] = 'h14856;
        exp_im_rom[19] = 'h1ff2c22;
        exp_im_rom[20] = 'h1ff99a2;
        exp_im_rom[21] = 'h1ff8578;
        exp_im_rom[22] = 'h1fed3b4;
        exp_im_rom[23] = 'h41df;
        exp_im_rom[24] = 'h1fa8db0;
        exp_im_rom[25] = 'h1fcf7ca;
        exp_im_rom[26] = 'h375ee;
        exp_im_rom[27] = 'hdc7c;
        exp_im_rom[28] = 'h1fbd843;
        exp_im_rom[29] = 'h1ff9734;
        exp_im_rom[30] = 'h61842;
        exp_im_rom[31] = 'h10585;
        exp_im_rom[32] = 'h1f51d94;
        exp_im_rom[33] = 'h3ccc8;
        exp_im_rom[34] = 'h1fbf84f;
        exp_im_rom[35] = 'h1ffe167;
        exp_im_rom[36] = 'h1ffc76f;
        exp_im_rom[37] = 'h1ffa85e;
        exp_im_rom[38] = 'haf88;
        exp_im_rom[39] = 'h1fea1f6;
        exp_im_rom[40] = 'h1fbc64a;
        exp_im_rom[41] = 'h1ffa70e;
        exp_im_rom[42] = 'h129a5;
        exp_im_rom[43] = 'h1fce259;
        exp_im_rom[44] = 'h1fb9ee4;
        exp_im_rom[45] = 'h7c82;
        exp_im_rom[46] = 'h176b8;
        exp_im_rom[47] = 'h1fcca00;
        exp_im_rom[48] = 'h1fb235d;
        exp_im_rom[49] = 'h30ed3;
        exp_im_rom[50] = 'h1fe804a;
        exp_im_rom[51] = 'h4077;
        exp_im_rom[52] = 'h5299;
        exp_im_rom[53] = 'h1ffea20;
        exp_im_rom[54] = 'h1ffaf44;
        exp_im_rom[55] = 'h1ff73d2;
        exp_im_rom[56] = 'h2fd8d;
        exp_im_rom[57] = 'h2f55;
        exp_im_rom[58] = 'h1ffae59;
        exp_im_rom[59] = 'ha880;
        exp_im_rom[60] = 'h1f42336;
        exp_im_rom[61] = 'h1fe50b4;
        exp_im_rom[62] = 'h33517;
        exp_im_rom[63] = 'h4a3f2;
        exp_im_rom[64] = 'h333d;
        exp_im_rom[65] = 'h1fcce10;
        exp_im_rom[66] = 'h1feb5fd;
        exp_im_rom[67] = 'h1208b;
        exp_im_rom[68] = 'ha29a;
        exp_im_rom[69] = 'h1bf15;
        exp_im_rom[70] = 'h31a21;
        exp_im_rom[71] = 'h1d932;
        exp_im_rom[72] = 'h23b0d;
        exp_im_rom[73] = 'h1fef456;
        exp_im_rom[74] = 'h1ff6023;
        exp_im_rom[75] = 'h1ff6c4e;
        exp_im_rom[76] = 'h1fdac5b;
        exp_im_rom[77] = 'hb45;
        exp_im_rom[78] = 'h24b00;
        exp_im_rom[79] = 'h1fd0d9d;
        exp_im_rom[80] = 'h3f74c;
        exp_im_rom[81] = 'h23879;
        exp_im_rom[82] = 'h1ff94d0;
        exp_im_rom[83] = 'h2f02;
        exp_im_rom[84] = 'h7672;
        exp_im_rom[85] = 'h1ff2fc8;
        exp_im_rom[86] = 'h38929;
        exp_im_rom[87] = 'h1ffcbb9;
        exp_im_rom[88] = 'h63720;
        exp_im_rom[89] = 'h1b4ca;
        exp_im_rom[90] = 'h1ff92b5;
        exp_im_rom[91] = 'h3c0;
        exp_im_rom[92] = 'h1fe0ca3;
        exp_im_rom[93] = 'h1ff055a;
        exp_im_rom[94] = 'h54be9;
        exp_im_rom[95] = 'h1fc57bd;
        exp_im_rom[96] = 'h6e7e4;
        exp_im_rom[97] = 'h1fef172;
        exp_im_rom[98] = 'h1fde447;
        exp_im_rom[99] = 'h1fffc09;
        exp_im_rom[100] = 'h1fff2dc;
        exp_im_rom[101] = 'h8875;
        exp_im_rom[102] = 'h1fe24f9;
        exp_im_rom[103] = 'h19310;
        exp_im_rom[104] = 'h78efa;
        exp_im_rom[105] = 'h1fff399;
        exp_im_rom[106] = 'h26ced;
        exp_im_rom[107] = 'h1ff94a6;
        exp_im_rom[108] = 'h1ffc479;
        exp_im_rom[109] = 'h9557;
        exp_im_rom[110] = 'h1fef060;
        exp_im_rom[111] = 'h603f3;
        exp_im_rom[112] = 'h1fd70d8;
        exp_im_rom[113] = 'h1fd39db;
        exp_im_rom[114] = 'h1ff08c3;
        exp_im_rom[115] = 'h1fe7e26;
        exp_im_rom[116] = 'h1ff7720;
        exp_im_rom[117] = 'h1ffd525;
        exp_im_rom[118] = 'h1fdae0a;
        exp_im_rom[119] = 'h1fce05f;
        exp_im_rom[120] = 'h322ad;
        exp_im_rom[121] = 'h314fb;
        exp_im_rom[122] = 'h67359;
        exp_im_rom[123] = 'h45d5d;
        exp_im_rom[124] = 'h42ed3;
        exp_im_rom[125] = 'hc092;
        exp_im_rom[126] = 'h1fca4aa;
        exp_im_rom[127] = 'h1fad79d;
        exp_im_rom[128] = 'h1edfff8;
        exp_im_rom[129] = 'h2cd58;
        exp_im_rom[130] = 'h2806f;
        exp_im_rom[131] = 'h35d3;
        exp_im_rom[132] = 'h1ff5936;
        exp_im_rom[133] = 'h1ff67e6;
        exp_im_rom[134] = 'h1ff6be0;
        exp_im_rom[135] = 'h263eb;
        exp_im_rom[136] = 'h10df47;
        exp_im_rom[137] = 'h1f93a28;
        exp_im_rom[138] = 'h1fc73c5;
        exp_im_rom[139] = 'h1fc7e89;
        exp_im_rom[140] = 'h1fba6ed;
        exp_im_rom[141] = 'h13f8d;
        exp_im_rom[142] = 'h1fd744f;
        exp_im_rom[143] = 'h264e7;
        exp_im_rom[144] = 'h1fa19eb;
        exp_im_rom[145] = 'h1feaae0;
        exp_im_rom[146] = 'h13d60;
        exp_im_rom[147] = 'h1ffb0da;
        exp_im_rom[148] = 'h1ffad9c;
        exp_im_rom[149] = 'h1ff6744;
        exp_im_rom[150] = 'h1ffbfe2;
        exp_im_rom[151] = 'h1ff187f;
        exp_im_rom[152] = 'h32ae4;
        exp_im_rom[153] = 'h50a78;
        exp_im_rom[154] = 'h1f6e370;
        exp_im_rom[155] = 'h7072;
        exp_im_rom[156] = 'h1ff50fb;
        exp_im_rom[157] = 'h1ff7f2e;
        exp_im_rom[158] = 'h1fb2004;
        exp_im_rom[159] = 'h3568b;
        exp_im_rom[160] = 'h1fb5ad2;
        exp_im_rom[161] = 'h86ea;
        exp_im_rom[162] = 'h2e97d;
        exp_im_rom[163] = 'h321;
        exp_im_rom[164] = 'h3a3d;
        exp_im_rom[165] = 'h2cc;
        exp_im_rom[166] = 'h1ffe98a;
        exp_im_rom[167] = 'h1fee84e;
        exp_im_rom[168] = 'h11dc;
        exp_im_rom[169] = 'h1ff4230;
        exp_im_rom[170] = 'h1ff765b;
        exp_im_rom[171] = 'h1fe624f;
        exp_im_rom[172] = 'h1ff2146;
        exp_im_rom[173] = 'h896;
        exp_im_rom[174] = 'h1ffa306;
        exp_im_rom[175] = 'h1fcc04c;
        exp_im_rom[176] = 'h3fe51;
        exp_im_rom[177] = 'h2029f;
        exp_im_rom[178] = 'h11b8c;
        exp_im_rom[179] = 'h1863b;
        exp_im_rom[180] = 'h9bd1;
        exp_im_rom[181] = 'h93de;
        exp_im_rom[182] = 'h6576;
        exp_im_rom[183] = 'hcacc;
        exp_im_rom[184] = 'h1f9c995;
        exp_im_rom[185] = 'h1fd33df;
        exp_im_rom[186] = 'h16b11;
        exp_im_rom[187] = 'h31824;
        exp_im_rom[188] = 'h52b20;
        exp_im_rom[189] = 'h1fa9eee;
        exp_im_rom[190] = 'h1f97add;
        exp_im_rom[191] = 'h1fe9f10;
        exp_im_rom[192] = 'h11ccd5;
        exp_im_rom[193] = 'h1ff7674;
        exp_im_rom[194] = 'h1fe6e1f;
        exp_im_rom[195] = 'h1ffc8e3;
        exp_im_rom[196] = 'h88a6;
        exp_im_rom[197] = 'h2c5f;
        exp_im_rom[198] = 'h1ffce6d;
        exp_im_rom[199] = 'h1ffa0f4;
        exp_im_rom[200] = 'h1fb3717;
        exp_im_rom[201] = 'h32686;
        exp_im_rom[202] = 'h1fcb1;
        exp_im_rom[203] = 'h1fdf7a2;
        exp_im_rom[204] = 'h1f67815;
        exp_im_rom[205] = 'h94f27;
        exp_im_rom[206] = 'h1c622;
        exp_im_rom[207] = 'h292b7;
        exp_im_rom[208] = 'h404a4;
        exp_im_rom[209] = 'h1fcf02f;
        exp_im_rom[210] = 'h1ff9d4a;
        exp_im_rom[211] = 'h1ffebb6;
        exp_im_rom[212] = 'hc24;
        exp_im_rom[213] = 'hc10c;
        exp_im_rom[214] = 'h1ff3e29;
        exp_im_rom[215] = 'heb41;
        exp_im_rom[216] = 'h1fd4b28;
        exp_im_rom[217] = 'h1fde5a4;
        exp_im_rom[218] = 'h21e0d;
        exp_im_rom[219] = 'ha9e2;
        exp_im_rom[220] = 'h1fe69ab;
        exp_im_rom[221] = 'h1f9ec28;
        exp_im_rom[222] = 'he7529;
        exp_im_rom[223] = 'h1fee2bf;
        exp_im_rom[224] = 'h1f7aebe;
        exp_im_rom[225] = 'h1ed94;
        exp_im_rom[226] = 'h1fd7ea1;
        exp_im_rom[227] = 'h1ff4e3b;
        exp_im_rom[228] = 'h1ff9ab0;
        exp_im_rom[229] = 'h1ff7df9;
        exp_im_rom[230] = 'h1cac1;
        exp_im_rom[231] = 'h1ffe614;
        exp_im_rom[232] = 'h1ff6e74;
        exp_im_rom[233] = 'h1ffe66d;
        exp_im_rom[234] = 'h366cb;
        exp_im_rom[235] = 'h1fdc16a;
        exp_im_rom[236] = 'h98fd;
        exp_im_rom[237] = 'h1ff781d;
        exp_im_rom[238] = 'h4210e;
        exp_im_rom[239] = 'h1fe606d;
        exp_im_rom[240] = 'h1f79942;
        exp_im_rom[241] = 'h1bef3;
        exp_im_rom[242] = 'h1fecf47;
        exp_im_rom[243] = 'h4774;
        exp_im_rom[244] = 'h1ffc552;
        exp_im_rom[245] = 'h1ffd60d;
        exp_im_rom[246] = 'ha8bc;
        exp_im_rom[247] = 'h1ffee0b;
        exp_im_rom[248] = 'h45a95;
        exp_im_rom[249] = 'h18319;
        exp_im_rom[250] = 'h1e225;
        exp_im_rom[251] = 'h176a7;
        exp_im_rom[252] = 'h28073;
        exp_im_rom[253] = 'hdf80;
        exp_im_rom[254] = 'he9f2;
        exp_im_rom[255] = 'h590d;
    end
    else begin
        exp_im_rom[0] = 'h1ffffae;
        exp_im_rom[1] = 'h590d;
        exp_im_rom[2] = 'he9f2;
        exp_im_rom[3] = 'hdf80;
        exp_im_rom[4] = 'h28073;
        exp_im_rom[5] = 'h176a7;
        exp_im_rom[6] = 'h1e225;
        exp_im_rom[7] = 'h18319;
        exp_im_rom[8] = 'h45a95;
        exp_im_rom[9] = 'h1ffee0b;
        exp_im_rom[10] = 'ha8bc;
        exp_im_rom[11] = 'h1ffd60d;
        exp_im_rom[12] = 'h1ffc552;
        exp_im_rom[13] = 'h4774;
        exp_im_rom[14] = 'h1fecf47;
        exp_im_rom[15] = 'h1bef3;
        exp_im_rom[16] = 'h1f79942;
        exp_im_rom[17] = 'h1fe606d;
        exp_im_rom[18] = 'h4210e;
        exp_im_rom[19] = 'h1ff781d;
        exp_im_rom[20] = 'h98fd;
        exp_im_rom[21] = 'h1fdc16a;
        exp_im_rom[22] = 'h366cb;
        exp_im_rom[23] = 'h1ffe66d;
        exp_im_rom[24] = 'h1ff6e74;
        exp_im_rom[25] = 'h1ffe614;
        exp_im_rom[26] = 'h1cac1;
        exp_im_rom[27] = 'h1ff7df9;
        exp_im_rom[28] = 'h1ff9ab0;
        exp_im_rom[29] = 'h1ff4e3b;
        exp_im_rom[30] = 'h1fd7ea1;
        exp_im_rom[31] = 'h1ed94;
        exp_im_rom[32] = 'h1f7aebe;
        exp_im_rom[33] = 'h1fee2bf;
        exp_im_rom[34] = 'he7529;
        exp_im_rom[35] = 'h1f9ec28;
        exp_im_rom[36] = 'h1fe69ab;
        exp_im_rom[37] = 'ha9e2;
        exp_im_rom[38] = 'h21e0d;
        exp_im_rom[39] = 'h1fde5a4;
        exp_im_rom[40] = 'h1fd4b28;
        exp_im_rom[41] = 'heb41;
        exp_im_rom[42] = 'h1ff3e29;
        exp_im_rom[43] = 'hc10c;
        exp_im_rom[44] = 'hc24;
        exp_im_rom[45] = 'h1ffebb6;
        exp_im_rom[46] = 'h1ff9d4a;
        exp_im_rom[47] = 'h1fcf02f;
        exp_im_rom[48] = 'h404a4;
        exp_im_rom[49] = 'h292b7;
        exp_im_rom[50] = 'h1c622;
        exp_im_rom[51] = 'h94f27;
        exp_im_rom[52] = 'h1f67815;
        exp_im_rom[53] = 'h1fdf7a2;
        exp_im_rom[54] = 'h1fcb1;
        exp_im_rom[55] = 'h32686;
        exp_im_rom[56] = 'h1fb3717;
        exp_im_rom[57] = 'h1ffa0f4;
        exp_im_rom[58] = 'h1ffce6d;
        exp_im_rom[59] = 'h2c5f;
        exp_im_rom[60] = 'h88a6;
        exp_im_rom[61] = 'h1ffc8e3;
        exp_im_rom[62] = 'h1fe6e1f;
        exp_im_rom[63] = 'h1ff7674;
        exp_im_rom[64] = 'h11ccd5;
        exp_im_rom[65] = 'h1fe9f10;
        exp_im_rom[66] = 'h1f97add;
        exp_im_rom[67] = 'h1fa9eee;
        exp_im_rom[68] = 'h52b20;
        exp_im_rom[69] = 'h31824;
        exp_im_rom[70] = 'h16b11;
        exp_im_rom[71] = 'h1fd33df;
        exp_im_rom[72] = 'h1f9c995;
        exp_im_rom[73] = 'hcacc;
        exp_im_rom[74] = 'h6576;
        exp_im_rom[75] = 'h93de;
        exp_im_rom[76] = 'h9bd1;
        exp_im_rom[77] = 'h1863b;
        exp_im_rom[78] = 'h11b8c;
        exp_im_rom[79] = 'h2029f;
        exp_im_rom[80] = 'h3fe51;
        exp_im_rom[81] = 'h1fcc04c;
        exp_im_rom[82] = 'h1ffa306;
        exp_im_rom[83] = 'h896;
        exp_im_rom[84] = 'h1ff2146;
        exp_im_rom[85] = 'h1fe624f;
        exp_im_rom[86] = 'h1ff765b;
        exp_im_rom[87] = 'h1ff4230;
        exp_im_rom[88] = 'h11dc;
        exp_im_rom[89] = 'h1fee84e;
        exp_im_rom[90] = 'h1ffe98a;
        exp_im_rom[91] = 'h2cc;
        exp_im_rom[92] = 'h3a3d;
        exp_im_rom[93] = 'h321;
        exp_im_rom[94] = 'h2e97d;
        exp_im_rom[95] = 'h86ea;
        exp_im_rom[96] = 'h1fb5ad2;
        exp_im_rom[97] = 'h3568b;
        exp_im_rom[98] = 'h1fb2004;
        exp_im_rom[99] = 'h1ff7f2e;
        exp_im_rom[100] = 'h1ff50fb;
        exp_im_rom[101] = 'h7072;
        exp_im_rom[102] = 'h1f6e370;
        exp_im_rom[103] = 'h50a78;
        exp_im_rom[104] = 'h32ae4;
        exp_im_rom[105] = 'h1ff187f;
        exp_im_rom[106] = 'h1ffbfe2;
        exp_im_rom[107] = 'h1ff6744;
        exp_im_rom[108] = 'h1ffad9c;
        exp_im_rom[109] = 'h1ffb0da;
        exp_im_rom[110] = 'h13d60;
        exp_im_rom[111] = 'h1feaae0;
        exp_im_rom[112] = 'h1fa19eb;
        exp_im_rom[113] = 'h264e7;
        exp_im_rom[114] = 'h1fd744f;
        exp_im_rom[115] = 'h13f8d;
        exp_im_rom[116] = 'h1fba6ed;
        exp_im_rom[117] = 'h1fc7e89;
        exp_im_rom[118] = 'h1fc73c5;
        exp_im_rom[119] = 'h1f93a28;
        exp_im_rom[120] = 'h10df47;
        exp_im_rom[121] = 'h263eb;
        exp_im_rom[122] = 'h1ff6be0;
        exp_im_rom[123] = 'h1ff67e6;
        exp_im_rom[124] = 'h1ff5936;
        exp_im_rom[125] = 'h35d3;
        exp_im_rom[126] = 'h2806f;
        exp_im_rom[127] = 'h2cd58;
        exp_im_rom[128] = 'h1edfff8;
        exp_im_rom[129] = 'h1fad79d;
        exp_im_rom[130] = 'h1fca4aa;
        exp_im_rom[131] = 'hc092;
        exp_im_rom[132] = 'h42ed3;
        exp_im_rom[133] = 'h45d5d;
        exp_im_rom[134] = 'h67359;
        exp_im_rom[135] = 'h314fb;
        exp_im_rom[136] = 'h322ad;
        exp_im_rom[137] = 'h1fce05f;
        exp_im_rom[138] = 'h1fdae0a;
        exp_im_rom[139] = 'h1ffd525;
        exp_im_rom[140] = 'h1ff7720;
        exp_im_rom[141] = 'h1fe7e26;
        exp_im_rom[142] = 'h1ff08c3;
        exp_im_rom[143] = 'h1fd39db;
        exp_im_rom[144] = 'h1fd70d8;
        exp_im_rom[145] = 'h603f3;
        exp_im_rom[146] = 'h1fef060;
        exp_im_rom[147] = 'h9557;
        exp_im_rom[148] = 'h1ffc479;
        exp_im_rom[149] = 'h1ff94a6;
        exp_im_rom[150] = 'h26ced;
        exp_im_rom[151] = 'h1fff399;
        exp_im_rom[152] = 'h78efa;
        exp_im_rom[153] = 'h19310;
        exp_im_rom[154] = 'h1fe24f9;
        exp_im_rom[155] = 'h8875;
        exp_im_rom[156] = 'h1fff2dc;
        exp_im_rom[157] = 'h1fffc09;
        exp_im_rom[158] = 'h1fde447;
        exp_im_rom[159] = 'h1fef172;
        exp_im_rom[160] = 'h6e7e4;
        exp_im_rom[161] = 'h1fc57bd;
        exp_im_rom[162] = 'h54be9;
        exp_im_rom[163] = 'h1ff055a;
        exp_im_rom[164] = 'h1fe0ca3;
        exp_im_rom[165] = 'h3c0;
        exp_im_rom[166] = 'h1ff92b5;
        exp_im_rom[167] = 'h1b4ca;
        exp_im_rom[168] = 'h63720;
        exp_im_rom[169] = 'h1ffcbb9;
        exp_im_rom[170] = 'h38929;
        exp_im_rom[171] = 'h1ff2fc8;
        exp_im_rom[172] = 'h7672;
        exp_im_rom[173] = 'h2f02;
        exp_im_rom[174] = 'h1ff94d0;
        exp_im_rom[175] = 'h23879;
        exp_im_rom[176] = 'h3f74c;
        exp_im_rom[177] = 'h1fd0d9d;
        exp_im_rom[178] = 'h24b00;
        exp_im_rom[179] = 'hb45;
        exp_im_rom[180] = 'h1fdac5b;
        exp_im_rom[181] = 'h1ff6c4e;
        exp_im_rom[182] = 'h1ff6023;
        exp_im_rom[183] = 'h1fef456;
        exp_im_rom[184] = 'h23b0d;
        exp_im_rom[185] = 'h1d932;
        exp_im_rom[186] = 'h31a21;
        exp_im_rom[187] = 'h1bf15;
        exp_im_rom[188] = 'ha29a;
        exp_im_rom[189] = 'h1208b;
        exp_im_rom[190] = 'h1feb5fd;
        exp_im_rom[191] = 'h1fcce10;
        exp_im_rom[192] = 'h333d;
        exp_im_rom[193] = 'h4a3f2;
        exp_im_rom[194] = 'h33517;
        exp_im_rom[195] = 'h1fe50b4;
        exp_im_rom[196] = 'h1f42336;
        exp_im_rom[197] = 'ha880;
        exp_im_rom[198] = 'h1ffae59;
        exp_im_rom[199] = 'h2f55;
        exp_im_rom[200] = 'h2fd8d;
        exp_im_rom[201] = 'h1ff73d2;
        exp_im_rom[202] = 'h1ffaf44;
        exp_im_rom[203] = 'h1ffea20;
        exp_im_rom[204] = 'h5299;
        exp_im_rom[205] = 'h4077;
        exp_im_rom[206] = 'h1fe804a;
        exp_im_rom[207] = 'h30ed3;
        exp_im_rom[208] = 'h1fb235d;
        exp_im_rom[209] = 'h1fcca00;
        exp_im_rom[210] = 'h176b8;
        exp_im_rom[211] = 'h7c82;
        exp_im_rom[212] = 'h1fb9ee4;
        exp_im_rom[213] = 'h1fce259;
        exp_im_rom[214] = 'h129a5;
        exp_im_rom[215] = 'h1ffa70e;
        exp_im_rom[216] = 'h1fbc64a;
        exp_im_rom[217] = 'h1fea1f6;
        exp_im_rom[218] = 'haf88;
        exp_im_rom[219] = 'h1ffa85e;
        exp_im_rom[220] = 'h1ffc76f;
        exp_im_rom[221] = 'h1ffe167;
        exp_im_rom[222] = 'h1fbf84f;
        exp_im_rom[223] = 'h3ccc8;
        exp_im_rom[224] = 'h1f51d94;
        exp_im_rom[225] = 'h10585;
        exp_im_rom[226] = 'h61842;
        exp_im_rom[227] = 'h1ff9734;
        exp_im_rom[228] = 'h1fbd843;
        exp_im_rom[229] = 'hdc7c;
        exp_im_rom[230] = 'h375ee;
        exp_im_rom[231] = 'h1fcf7ca;
        exp_im_rom[232] = 'h1fa8db0;
        exp_im_rom[233] = 'h41df;
        exp_im_rom[234] = 'h1fed3b4;
        exp_im_rom[235] = 'h1ff8578;
        exp_im_rom[236] = 'h1ff99a2;
        exp_im_rom[237] = 'h1ff2c22;
        exp_im_rom[238] = 'h14856;
        exp_im_rom[239] = 'h1f8c7d8;
        exp_im_rom[240] = 'h2a55d;
        exp_im_rom[241] = 'h338d1;
        exp_im_rom[242] = 'h1e39b;
        exp_im_rom[243] = 'h2d823;
        exp_im_rom[244] = 'hab5b;
        exp_im_rom[245] = 'h24c27;
        exp_im_rom[246] = 'h19f07;
        exp_im_rom[247] = 'h2bf30;
        exp_im_rom[248] = 'h1fe2381;
        exp_im_rom[249] = 'h597;
        exp_im_rom[250] = 'h1ff9cbe;
        exp_im_rom[251] = 'h3ee;
        exp_im_rom[252] = 'h1fff7a2;
        exp_im_rom[253] = 'h2003;
        exp_im_rom[254] = 'h9131;
        exp_im_rom[255] = 'h717c;
    end
end
initial begin
    fft_blk_exp[0] = 'h0;
    ifft_blk_exp[0] = 'h0;
end
 

always @(posedge i_clk or negedge i_rstn) begin
    if (~i_rstn) begin
        o_rdata <= {(OUTPUT_WIDTH*2){1'b0}};
    end        
    else if (i_clken) begin
        o_rdata[OUTPUT_WIDTH-1:0] <= exp_re_rom[i_addr];
        o_rdata[OUTPUT_WIDTH*2-1:OUTPUT_WIDTH] <= exp_im_rom[i_addr];
    end
end
      
assign o_blk_exp = FFT_MODE ? fft_blk_exp[0] : ifft_blk_exp[0];

endmodule