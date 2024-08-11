library verilog;
use verilog.vl_types.all;
entity ipsxe_fft_frame_chk is
    generic(
        FRAME_CHK_PRINT_EN: integer := 0;
        FRAME_CHK_DATA_EN: integer := 0;
        TEST_FRAME_NUM  : integer := 10;
        MAX_TIME_OF_FFT : integer := 21;
        LOG2_FFT_LEN    : integer := 4;
        OUTPUT_ORDER    : integer := 1;
        INPUT_WIDTH     : integer := 16;
        SCALE_MODE      : integer := 0
    );
    port(
        i_aclk          : in     vl_logic;
        i_aclken        : in     vl_logic;
        i_aresetn       : in     vl_logic;
        i_axi4s_data_tvalid: in     vl_logic;
        i_axi4s_data_tdata: in     vl_logic_vector;
        i_axi4s_data_tlast: in     vl_logic;
        i_axi4s_data_tuser: in     vl_logic_vector;
        i_start_test    : in     vl_logic;
        o_chk_finished  : out    vl_logic;
        o_err           : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FRAME_CHK_PRINT_EN : constant is 1;
    attribute mti_svvh_generic_type of FRAME_CHK_DATA_EN : constant is 1;
    attribute mti_svvh_generic_type of TEST_FRAME_NUM : constant is 1;
    attribute mti_svvh_generic_type of MAX_TIME_OF_FFT : constant is 1;
    attribute mti_svvh_generic_type of LOG2_FFT_LEN : constant is 1;
    attribute mti_svvh_generic_type of OUTPUT_ORDER : constant is 1;
    attribute mti_svvh_generic_type of INPUT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of SCALE_MODE : constant is 1;
end ipsxe_fft_frame_chk;
