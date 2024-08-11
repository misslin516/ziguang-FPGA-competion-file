library verilog;
use verilog.vl_types.all;
entity ipsxb_distributed_fifo_v1_0_distributed_fifo_v1_0 is
    generic(
        ADDR_WIDTH      : integer := 10;
        DATA_WIDTH      : integer := 32;
        RST_TYPE        : string  := "ASYNC";
        OUT_REG         : integer := 0;
        FIFO_TYPE       : string  := "ASYNC_FIFO";
        ALMOST_FULL_NUM : integer := 4;
        ALMOST_EMPTY_NUM: integer := 4
    );
    port(
        wr_data         : in     vl_logic_vector;
        wr_en           : in     vl_logic;
        wr_clk          : in     vl_logic;
        full            : out    vl_logic;
        wr_rst          : in     vl_logic;
        almost_full     : out    vl_logic;
        wr_water_level  : out    vl_logic_vector;
        rd_data         : out    vl_logic_vector;
        rd_en           : in     vl_logic;
        rd_clk          : in     vl_logic;
        empty           : out    vl_logic;
        rd_rst          : in     vl_logic;
        almost_empty    : out    vl_logic;
        rd_water_level  : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of RST_TYPE : constant is 1;
    attribute mti_svvh_generic_type of OUT_REG : constant is 1;
    attribute mti_svvh_generic_type of FIFO_TYPE : constant is 1;
    attribute mti_svvh_generic_type of ALMOST_FULL_NUM : constant is 1;
    attribute mti_svvh_generic_type of ALMOST_EMPTY_NUM : constant is 1;
end ipsxb_distributed_fifo_v1_0_distributed_fifo_v1_0;
