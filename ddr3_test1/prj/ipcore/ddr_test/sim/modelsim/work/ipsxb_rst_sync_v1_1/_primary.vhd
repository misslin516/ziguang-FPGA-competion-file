library verilog;
use verilog.vl_types.all;
entity ipsxb_rst_sync_v1_1 is
    generic(
        DATA_WIDTH      : vl_logic := Hi1;
        DFT_VALUE       : vl_notype
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        sig_async       : in     vl_logic_vector;
        sig_synced      : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DFT_VALUE : constant is 3;
end ipsxb_rst_sync_v1_1;
