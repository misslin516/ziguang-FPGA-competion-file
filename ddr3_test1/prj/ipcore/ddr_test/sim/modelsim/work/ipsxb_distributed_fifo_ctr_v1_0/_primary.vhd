library verilog;
use verilog.vl_types.all;
entity ipsxb_distributed_fifo_ctr_v1_0 is
    generic(
        DEPTH           : integer := 9;
        FIFO_TYPE       : string  := "ASYNC_FIFO";
        ALMOST_FULL_NUM : integer := 4;
        ALMOST_EMPTY_NUM: integer := 4
    );
    port(
        wr_clk          : in     vl_logic;
        w_en            : in     vl_logic;
        wr_addr         : out    vl_logic_vector;
        wrst            : in     vl_logic;
        wfull           : out    vl_logic;
        almost_full     : out    vl_logic;
        wr_water_level  : out    vl_logic_vector;
        rd_clk          : in     vl_logic;
        r_en            : in     vl_logic;
        rd_addr         : out    vl_logic_vector;
        rrst            : in     vl_logic;
        rempty          : out    vl_logic;
        almost_empty    : out    vl_logic;
        rd_water_level  : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DEPTH : constant is 1;
    attribute mti_svvh_generic_type of FIFO_TYPE : constant is 1;
    attribute mti_svvh_generic_type of ALMOST_FULL_NUM : constant is 1;
    attribute mti_svvh_generic_type of ALMOST_EMPTY_NUM : constant is 1;
end ipsxb_distributed_fifo_ctr_v1_0;
