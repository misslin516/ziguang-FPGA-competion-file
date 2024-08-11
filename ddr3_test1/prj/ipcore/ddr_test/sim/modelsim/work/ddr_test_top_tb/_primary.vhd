library verilog;
use verilog.vl_types.all;
entity ddr_test_top_tb is
    generic(
        TCK_MIN         : integer := 2500;
        TJIT_PER        : integer := 100;
        TJIT_CC         : integer := 200;
        TERR_2PER       : integer := 147;
        TERR_3PER       : integer := 175;
        TERR_4PER       : integer := 194;
        TERR_5PER       : integer := 209;
        TERR_6PER       : integer := 222;
        TERR_7PER       : integer := 232;
        TERR_8PER       : integer := 241;
        TERR_9PER       : integer := 249;
        TERR_10PER      : integer := 257;
        TERR_11PER      : integer := 263;
        TERR_12PER      : integer := 269;
        TDS             : integer := 125;
        TDH             : integer := 150;
        TDQSQ           : integer := 200;
        TDQSS           : real    := 0.250000;
        TDSS            : real    := 0.200000;
        TDSH            : real    := 0.200000;
        TDQSCK          : integer := 400;
        TQSH            : real    := 0.380000;
        TQSL            : real    := 0.380000;
        TDIPW           : integer := 600;
        TIPW            : integer := 900;
        TIS             : integer := 350;
        TIH             : integer := 275;
        TRAS_MIN        : integer := 37500;
        TRC             : integer := 50000;
        TRCD            : integer := 12500;
        TRP             : integer := 12500;
        TXP             : integer := 7500;
        TCKE            : integer := 7500;
        TAON            : integer := 400;
        TWLS            : integer := 325;
        TWLH            : integer := 325;
        TWLO            : integer := 9000;
        TAA_MIN         : integer := 12500;
        CL_TIME         : integer := 12500;
        TDQSCK_DLLDIS   : vl_notype;
        TRRD            : integer := 10000;
        TFAW            : integer := 50000;
        CL_MIN          : integer := 5;
        CL_MAX          : integer := 14;
        AL_MIN          : integer := 0;
        AL_MAX          : integer := 2;
        WR_MIN          : integer := 5;
        WR_MAX          : integer := 16;
        BL_MIN          : integer := 4;
        BL_MAX          : integer := 8;
        CWL_MIN         : integer := 5;
        CWL_MAX         : integer := 10;
        TCK_MAX         : integer := 3300;
        TCH_AVG_MIN     : real    := 0.470000;
        TCL_AVG_MIN     : real    := 0.470000;
        TCH_AVG_MAX     : real    := 0.530000;
        TCL_AVG_MAX     : real    := 0.530000;
        TCH_ABS_MIN     : real    := 0.430000;
        TCL_ABS_MIN     : real    := 0.430000;
        TCKE_TCK        : integer := 3;
        TAA_MAX         : integer := 20000;
        TQH             : real    := 0.380000;
        TRPRE           : real    := 0.900000;
        TRPST           : real    := 0.300000;
        TDQSH           : real    := 0.450000;
        TDQSL           : real    := 0.450000;
        TWPRE           : real    := 0.900000;
        TWPST           : real    := 0.300000;
        TCCD            : integer := 4;
        TCCD_DG         : integer := 2;
        TRAS_MAX        : real    := 60000000000.000000;
        TWR             : integer := 15000;
        TMRD            : integer := 4;
        TMOD            : integer := 15000;
        TMOD_TCK        : integer := 12;
        TRRD_TCK        : integer := 4;
        TRRD_DG         : integer := 3000;
        TRRD_DG_TCK     : integer := 2;
        TRTP            : integer := 7500;
        TRTP_TCK        : integer := 4;
        TWTR            : integer := 7500;
        TWTR_DG         : integer := 3750;
        TWTR_TCK        : integer := 4;
        TWTR_DG_TCK     : integer := 2;
        TDLLK           : integer := 512;
        TRFC_MIN        : integer := 260000;
        TRFC_MAX        : integer := 70200000;
        TXP_TCK         : integer := 3;
        TXPDLL          : integer := 24000;
        TXPDLL_TCK      : integer := 10;
        TACTPDEN        : integer := 1;
        TPRPDEN         : integer := 1;
        TREFPDEN        : integer := 1;
        TCPDED          : integer := 1;
        TPD_MAX         : vl_notype;
        TXPR            : vl_notype;
        TXPR_TCK        : integer := 5;
        TXS             : vl_notype;
        TXS_TCK         : integer := 5;
        TXSDLL          : vl_notype;
        TISXR           : vl_notype;
        TCKSRE          : integer := 10000;
        TCKSRE_TCK      : integer := 5;
        TCKSRX          : integer := 10000;
        TCKSRX_TCK      : integer := 5;
        TCKESR_TCK      : integer := 4;
        TAOF            : real    := 0.700000;
        TAONPD          : integer := 8500;
        TAOFPD          : integer := 8500;
        ODTH4           : integer := 4;
        ODTH8           : integer := 6;
        TADC            : real    := 0.700000;
        TWLMRD          : integer := 40;
        TWLDQSEN        : integer := 25;
        TWLOE           : integer := 2000;
        DM_BITS         : integer := 2;
        ADDR_BITS       : integer := 16;
        ROW_BITS        : integer := 15;
        COL_BITS        : integer := 10;
        DQ_BITS         : integer := 16;
        DQS_BITS        : integer := 2;
        BA_BITS         : integer := 3;
        MEM_BITS        : integer := 15;
        AP              : integer := 10;
        BC              : integer := 12;
        BL_BITS         : integer := 3;
        BO_BITS         : integer := 2;
        CS_BITS         : integer := 1;
        RANKS           : integer := 1;
        RZQ             : integer := 240;
        PRE_DEF_PAT     : vl_logic_vector(0 to 7) := (Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0);
        STOP_ON_ERROR   : integer := 1;
        DEBUG           : integer := 1;
        BUS_DELAY       : integer := 0;
        RANDOM_OUT_DELAY: integer := 0;
        RANDOM_SEED     : integer := 31913;
        RDQSEN_PRE      : integer := 2;
        RDQSEN_PST      : integer := 1;
        RDQS_PRE        : integer := 2;
        RDQS_PST        : integer := 1;
        RDQEN_PRE       : integer := 0;
        RDQEN_PST       : integer := 0;
        WDQS_PRE        : integer := 2;
        WDQS_PST        : integer := 1;
        CLKIN_FREQ      : real    := 5.000000e+001;
        PLL_REFCLK_IN_PERIOD: vl_notype;
        MEM_ADDR_WIDTH  : integer := 15;
        MEM_BADDR_WIDTH : integer := 3;
        MEM_DQ_WIDTH    : integer := 32;
        MEM_DM_WIDTH    : vl_notype;
        MEM_DQS_WIDTH   : vl_notype;
        MEM_NUM         : vl_notype
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of TCK_MIN : constant is 1;
    attribute mti_svvh_generic_type of TJIT_PER : constant is 1;
    attribute mti_svvh_generic_type of TJIT_CC : constant is 1;
    attribute mti_svvh_generic_type of TERR_2PER : constant is 1;
    attribute mti_svvh_generic_type of TERR_3PER : constant is 1;
    attribute mti_svvh_generic_type of TERR_4PER : constant is 1;
    attribute mti_svvh_generic_type of TERR_5PER : constant is 1;
    attribute mti_svvh_generic_type of TERR_6PER : constant is 1;
    attribute mti_svvh_generic_type of TERR_7PER : constant is 1;
    attribute mti_svvh_generic_type of TERR_8PER : constant is 1;
    attribute mti_svvh_generic_type of TERR_9PER : constant is 1;
    attribute mti_svvh_generic_type of TERR_10PER : constant is 1;
    attribute mti_svvh_generic_type of TERR_11PER : constant is 1;
    attribute mti_svvh_generic_type of TERR_12PER : constant is 1;
    attribute mti_svvh_generic_type of TDS : constant is 1;
    attribute mti_svvh_generic_type of TDH : constant is 1;
    attribute mti_svvh_generic_type of TDQSQ : constant is 1;
    attribute mti_svvh_generic_type of TDQSS : constant is 1;
    attribute mti_svvh_generic_type of TDSS : constant is 1;
    attribute mti_svvh_generic_type of TDSH : constant is 1;
    attribute mti_svvh_generic_type of TDQSCK : constant is 1;
    attribute mti_svvh_generic_type of TQSH : constant is 1;
    attribute mti_svvh_generic_type of TQSL : constant is 1;
    attribute mti_svvh_generic_type of TDIPW : constant is 1;
    attribute mti_svvh_generic_type of TIPW : constant is 1;
    attribute mti_svvh_generic_type of TIS : constant is 1;
    attribute mti_svvh_generic_type of TIH : constant is 1;
    attribute mti_svvh_generic_type of TRAS_MIN : constant is 1;
    attribute mti_svvh_generic_type of TRC : constant is 1;
    attribute mti_svvh_generic_type of TRCD : constant is 1;
    attribute mti_svvh_generic_type of TRP : constant is 1;
    attribute mti_svvh_generic_type of TXP : constant is 1;
    attribute mti_svvh_generic_type of TCKE : constant is 1;
    attribute mti_svvh_generic_type of TAON : constant is 1;
    attribute mti_svvh_generic_type of TWLS : constant is 1;
    attribute mti_svvh_generic_type of TWLH : constant is 1;
    attribute mti_svvh_generic_type of TWLO : constant is 1;
    attribute mti_svvh_generic_type of TAA_MIN : constant is 1;
    attribute mti_svvh_generic_type of CL_TIME : constant is 1;
    attribute mti_svvh_generic_type of TDQSCK_DLLDIS : constant is 3;
    attribute mti_svvh_generic_type of TRRD : constant is 1;
    attribute mti_svvh_generic_type of TFAW : constant is 1;
    attribute mti_svvh_generic_type of CL_MIN : constant is 1;
    attribute mti_svvh_generic_type of CL_MAX : constant is 1;
    attribute mti_svvh_generic_type of AL_MIN : constant is 1;
    attribute mti_svvh_generic_type of AL_MAX : constant is 1;
    attribute mti_svvh_generic_type of WR_MIN : constant is 1;
    attribute mti_svvh_generic_type of WR_MAX : constant is 1;
    attribute mti_svvh_generic_type of BL_MIN : constant is 1;
    attribute mti_svvh_generic_type of BL_MAX : constant is 1;
    attribute mti_svvh_generic_type of CWL_MIN : constant is 1;
    attribute mti_svvh_generic_type of CWL_MAX : constant is 1;
    attribute mti_svvh_generic_type of TCK_MAX : constant is 1;
    attribute mti_svvh_generic_type of TCH_AVG_MIN : constant is 1;
    attribute mti_svvh_generic_type of TCL_AVG_MIN : constant is 1;
    attribute mti_svvh_generic_type of TCH_AVG_MAX : constant is 1;
    attribute mti_svvh_generic_type of TCL_AVG_MAX : constant is 1;
    attribute mti_svvh_generic_type of TCH_ABS_MIN : constant is 1;
    attribute mti_svvh_generic_type of TCL_ABS_MIN : constant is 1;
    attribute mti_svvh_generic_type of TCKE_TCK : constant is 1;
    attribute mti_svvh_generic_type of TAA_MAX : constant is 1;
    attribute mti_svvh_generic_type of TQH : constant is 1;
    attribute mti_svvh_generic_type of TRPRE : constant is 1;
    attribute mti_svvh_generic_type of TRPST : constant is 1;
    attribute mti_svvh_generic_type of TDQSH : constant is 1;
    attribute mti_svvh_generic_type of TDQSL : constant is 1;
    attribute mti_svvh_generic_type of TWPRE : constant is 1;
    attribute mti_svvh_generic_type of TWPST : constant is 1;
    attribute mti_svvh_generic_type of TCCD : constant is 1;
    attribute mti_svvh_generic_type of TCCD_DG : constant is 1;
    attribute mti_svvh_generic_type of TRAS_MAX : constant is 1;
    attribute mti_svvh_generic_type of TWR : constant is 1;
    attribute mti_svvh_generic_type of TMRD : constant is 1;
    attribute mti_svvh_generic_type of TMOD : constant is 1;
    attribute mti_svvh_generic_type of TMOD_TCK : constant is 1;
    attribute mti_svvh_generic_type of TRRD_TCK : constant is 1;
    attribute mti_svvh_generic_type of TRRD_DG : constant is 1;
    attribute mti_svvh_generic_type of TRRD_DG_TCK : constant is 1;
    attribute mti_svvh_generic_type of TRTP : constant is 1;
    attribute mti_svvh_generic_type of TRTP_TCK : constant is 1;
    attribute mti_svvh_generic_type of TWTR : constant is 1;
    attribute mti_svvh_generic_type of TWTR_DG : constant is 1;
    attribute mti_svvh_generic_type of TWTR_TCK : constant is 1;
    attribute mti_svvh_generic_type of TWTR_DG_TCK : constant is 1;
    attribute mti_svvh_generic_type of TDLLK : constant is 1;
    attribute mti_svvh_generic_type of TRFC_MIN : constant is 1;
    attribute mti_svvh_generic_type of TRFC_MAX : constant is 1;
    attribute mti_svvh_generic_type of TXP_TCK : constant is 1;
    attribute mti_svvh_generic_type of TXPDLL : constant is 1;
    attribute mti_svvh_generic_type of TXPDLL_TCK : constant is 1;
    attribute mti_svvh_generic_type of TACTPDEN : constant is 1;
    attribute mti_svvh_generic_type of TPRPDEN : constant is 1;
    attribute mti_svvh_generic_type of TREFPDEN : constant is 1;
    attribute mti_svvh_generic_type of TCPDED : constant is 1;
    attribute mti_svvh_generic_type of TPD_MAX : constant is 3;
    attribute mti_svvh_generic_type of TXPR : constant is 3;
    attribute mti_svvh_generic_type of TXPR_TCK : constant is 1;
    attribute mti_svvh_generic_type of TXS : constant is 3;
    attribute mti_svvh_generic_type of TXS_TCK : constant is 1;
    attribute mti_svvh_generic_type of TXSDLL : constant is 3;
    attribute mti_svvh_generic_type of TISXR : constant is 3;
    attribute mti_svvh_generic_type of TCKSRE : constant is 1;
    attribute mti_svvh_generic_type of TCKSRE_TCK : constant is 1;
    attribute mti_svvh_generic_type of TCKSRX : constant is 1;
    attribute mti_svvh_generic_type of TCKSRX_TCK : constant is 1;
    attribute mti_svvh_generic_type of TCKESR_TCK : constant is 1;
    attribute mti_svvh_generic_type of TAOF : constant is 1;
    attribute mti_svvh_generic_type of TAONPD : constant is 1;
    attribute mti_svvh_generic_type of TAOFPD : constant is 1;
    attribute mti_svvh_generic_type of ODTH4 : constant is 1;
    attribute mti_svvh_generic_type of ODTH8 : constant is 1;
    attribute mti_svvh_generic_type of TADC : constant is 1;
    attribute mti_svvh_generic_type of TWLMRD : constant is 1;
    attribute mti_svvh_generic_type of TWLDQSEN : constant is 1;
    attribute mti_svvh_generic_type of TWLOE : constant is 1;
    attribute mti_svvh_generic_type of DM_BITS : constant is 1;
    attribute mti_svvh_generic_type of ADDR_BITS : constant is 1;
    attribute mti_svvh_generic_type of ROW_BITS : constant is 1;
    attribute mti_svvh_generic_type of COL_BITS : constant is 1;
    attribute mti_svvh_generic_type of DQ_BITS : constant is 1;
    attribute mti_svvh_generic_type of DQS_BITS : constant is 1;
    attribute mti_svvh_generic_type of BA_BITS : constant is 1;
    attribute mti_svvh_generic_type of MEM_BITS : constant is 1;
    attribute mti_svvh_generic_type of AP : constant is 1;
    attribute mti_svvh_generic_type of BC : constant is 1;
    attribute mti_svvh_generic_type of BL_BITS : constant is 1;
    attribute mti_svvh_generic_type of BO_BITS : constant is 1;
    attribute mti_svvh_generic_type of CS_BITS : constant is 1;
    attribute mti_svvh_generic_type of RANKS : constant is 1;
    attribute mti_svvh_generic_type of RZQ : constant is 1;
    attribute mti_svvh_generic_type of PRE_DEF_PAT : constant is 1;
    attribute mti_svvh_generic_type of STOP_ON_ERROR : constant is 1;
    attribute mti_svvh_generic_type of DEBUG : constant is 1;
    attribute mti_svvh_generic_type of BUS_DELAY : constant is 1;
    attribute mti_svvh_generic_type of RANDOM_OUT_DELAY : constant is 1;
    attribute mti_svvh_generic_type of RANDOM_SEED : constant is 1;
    attribute mti_svvh_generic_type of RDQSEN_PRE : constant is 1;
    attribute mti_svvh_generic_type of RDQSEN_PST : constant is 1;
    attribute mti_svvh_generic_type of RDQS_PRE : constant is 1;
    attribute mti_svvh_generic_type of RDQS_PST : constant is 1;
    attribute mti_svvh_generic_type of RDQEN_PRE : constant is 1;
    attribute mti_svvh_generic_type of RDQEN_PST : constant is 1;
    attribute mti_svvh_generic_type of WDQS_PRE : constant is 1;
    attribute mti_svvh_generic_type of WDQS_PST : constant is 1;
    attribute mti_svvh_generic_type of CLKIN_FREQ : constant is 2;
    attribute mti_svvh_generic_type of PLL_REFCLK_IN_PERIOD : constant is 3;
    attribute mti_svvh_generic_type of MEM_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_BADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_DQ_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_DM_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of MEM_DQS_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of MEM_NUM : constant is 3;
end ddr_test_top_tb;
