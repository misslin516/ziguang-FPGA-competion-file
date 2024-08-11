library verilog;
use verilog.vl_types.all;
entity ipsxe_fft_distram_sreg is
    generic(
        FIXED_DEPTH     : integer := 4;
        DATA_WIDTH      : integer := 10
    );
    port(
        din             : in     vl_logic_vector;
        clk             : in     vl_logic;
        clken           : in     vl_logic;
        rst             : in     vl_logic;
        dout            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FIXED_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end ipsxe_fft_distram_sreg;
