library verilog;
use verilog.vl_types.all;
entity ipsxe_fft_drm_sdpram_36k is
    generic(
        WR_ADDR_WIDTH   : integer := 9;
        RD_ADDR_WIDTH   : integer := 9;
        WR_DATA_WIDTH   : integer := 36;
        RD_DATA_WIDTH   : integer := 36;
        POWER_OPT       : integer := 1
    );
    port(
        wr_data         : in     vl_logic_vector;
        wr_addr         : in     vl_logic_vector;
        wr_en           : in     vl_logic;
        wr_clk          : in     vl_logic;
        wr_clk_en       : in     vl_logic;
        wr_rst          : in     vl_logic;
        rd_data         : out    vl_logic_vector;
        rd_addr         : in     vl_logic_vector;
        rd_clk          : in     vl_logic;
        rd_clk_en       : in     vl_logic;
        rd_oce          : in     vl_logic;
        rd_rst          : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WR_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of RD_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of WR_DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of RD_DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of POWER_OPT : constant is 1;
end ipsxe_fft_drm_sdpram_36k;
