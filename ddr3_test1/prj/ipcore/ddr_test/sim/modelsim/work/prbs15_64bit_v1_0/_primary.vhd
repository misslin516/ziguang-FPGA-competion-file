library verilog;
use verilog.vl_types.all;
entity prbs15_64bit_v1_0 is
    generic(
        PRBS_INIT       : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        prbs_en         : in     vl_logic;
        din_en          : in     vl_logic;
        din             : in     vl_logic_vector(15 downto 0);
        dout            : out    vl_logic_vector(63 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PRBS_INIT : constant is 1;
end prbs15_64bit_v1_0;
