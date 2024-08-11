library verilog;
use verilog.vl_types.all;
entity ipsxe_fft_distram_sdpram is
    generic(
        ADDR_WIDTH      : integer := 4;
        DATA_WIDTH      : integer := 4
    );
    port(
        wr_data         : in     vl_logic_vector;
        wr_addr         : in     vl_logic_vector;
        rd_addr         : in     vl_logic_vector;
        wr_clk          : in     vl_logic;
        wr_clken        : in     vl_logic;
        rd_clk          : in     vl_logic;
        rd_clken        : in     vl_logic;
        wr_en           : in     vl_logic;
        rst             : in     vl_logic;
        rd_data         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end ipsxe_fft_distram_sdpram;
