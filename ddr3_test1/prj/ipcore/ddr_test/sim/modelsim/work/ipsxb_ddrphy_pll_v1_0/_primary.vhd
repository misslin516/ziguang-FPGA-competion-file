library verilog;
use verilog.vl_types.all;
entity ipsxb_ddrphy_pll_v1_0 is
    generic(
        CLKIN_FREQ      : real    := 5.000000e+001;
        STATIC_RATIOI   : integer := 2;
        STATIC_RATIOF   : integer := 32;
        STATIC_RATIO0   : integer := 2;
        STATIC_RATIO1   : integer := 8;
        STATIC_DUTY0    : integer := 2;
        STATIC_DUTY1    : integer := 8
    );
    port(
        clkin1          : in     vl_logic;
        clkout0_gate    : in     vl_logic;
        pll_rst         : in     vl_logic;
        clkout0         : out    vl_logic;
        clkout1         : out    vl_logic;
        pll_lock        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLKIN_FREQ : constant is 2;
    attribute mti_svvh_generic_type of STATIC_RATIOI : constant is 2;
    attribute mti_svvh_generic_type of STATIC_RATIOF : constant is 2;
    attribute mti_svvh_generic_type of STATIC_RATIO0 : constant is 2;
    attribute mti_svvh_generic_type of STATIC_RATIO1 : constant is 2;
    attribute mti_svvh_generic_type of STATIC_DUTY0 : constant is 2;
    attribute mti_svvh_generic_type of STATIC_DUTY1 : constant is 2;
end ipsxb_ddrphy_pll_v1_0;
