library verilog;
use verilog.vl_types.all;
entity ipsxe_fft_distributed_sdpram_v1_2 is
    generic(
        ADDR_WIDTH      : integer := 4;
        DATA_WIDTH      : integer := 4;
        RST_TYPE        : string  := "ASYNC";
        OUT_REG         : integer := 0;
        INIT_FILE       : string  := "NONE";
        FILE_FORMAT     : string  := "BIN"
    );
    port(
        wr_data         : in     vl_logic_vector;
        wr_addr         : in     vl_logic_vector;
        rd_addr         : in     vl_logic_vector;
        wr_clk          : in     vl_logic;
        rd_clk          : in     vl_logic;
        wr_en           : in     vl_logic;
        rd_en           : in     vl_logic;
        rst             : in     vl_logic;
        rd_data         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of RST_TYPE : constant is 1;
    attribute mti_svvh_generic_type of OUT_REG : constant is 1;
    attribute mti_svvh_generic_type of INIT_FILE : constant is 1;
    attribute mti_svvh_generic_type of FILE_FORMAT : constant is 1;
end ipsxe_fft_distributed_sdpram_v1_2;
