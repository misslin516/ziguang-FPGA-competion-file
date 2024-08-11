library verilog;
use verilog.vl_types.all;
entity ipsxe_fft_frame_gen is
    generic(
        FRAME_GEN_PRINT_EN: integer := 0;
        CLKDIV          : integer := 2;
        TEST_FRAME_NUM  : integer := 10;
        LOG2_FFT_LEN    : integer := 4;
        INPUT_WIDTH     : integer := 16
    );
    port(
        i_aclk          : in     vl_logic;
        i_aresetn       : in     vl_logic;
        o_aclken        : out    vl_logic;
        i_axi4s_data_tready: in     vl_logic;
        o_axi4s_data_tvalid: out    vl_logic;
        o_axi4s_data_tdata: out    vl_logic_vector;
        o_axi4s_data_tlast: out    vl_logic;
        o_axi4s_cfg_tvalid: out    vl_logic;
        o_axi4s_cfg_tdata: out    vl_logic;
        i_start_test    : in     vl_logic;
        i_chk_finished  : in     vl_logic;
        i_stat          : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FRAME_GEN_PRINT_EN : constant is 1;
    attribute mti_svvh_generic_type of CLKDIV : constant is 1;
    attribute mti_svvh_generic_type of TEST_FRAME_NUM : constant is 1;
    attribute mti_svvh_generic_type of LOG2_FFT_LEN : constant is 1;
    attribute mti_svvh_generic_type of INPUT_WIDTH : constant is 1;
end ipsxe_fft_frame_gen;
