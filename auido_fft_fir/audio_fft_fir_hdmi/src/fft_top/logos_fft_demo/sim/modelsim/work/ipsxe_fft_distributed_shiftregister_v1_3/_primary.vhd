library verilog;
use verilog.vl_types.all;
entity ipsxe_fft_distributed_shiftregister_v1_3 is
    generic(
        OUT_REG         : vl_logic := Hi0;
        FIXED_DEPTH     : integer := 16;
        VARIABLE_MAX_DEPTH: integer := 16;
        DATA_WIDTH      : integer := 16;
        SHIFT_REG_TYPE  : string  := "fixed_latency";
        RST_TYPE        : string  := "ASYNC"
    );
    port(
        din             : in     vl_logic_vector;
        addr            : in     vl_logic_vector;
        clk             : in     vl_logic;
        clken           : in     vl_logic;
        rst             : in     vl_logic;
        dout            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of OUT_REG : constant is 1;
    attribute mti_svvh_generic_type of FIXED_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of VARIABLE_MAX_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of SHIFT_REG_TYPE : constant is 1;
    attribute mti_svvh_generic_type of RST_TYPE : constant is 1;
end ipsxe_fft_distributed_shiftregister_v1_3;
