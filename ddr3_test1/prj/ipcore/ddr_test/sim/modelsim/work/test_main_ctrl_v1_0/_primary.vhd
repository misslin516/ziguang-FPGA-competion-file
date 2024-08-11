library verilog;
use verilog.vl_types.all;
entity test_main_ctrl_v1_0 is
    generic(
        CTRL_ADDR_WIDTH : integer := 28;
        MEM_DQ_WIDTH    : integer := 16;
        MEM_SPACE_AW    : integer := 18
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        wr_mode         : in     vl_logic_vector(1 downto 0);
        data_mode       : in     vl_logic_vector(1 downto 0);
        len_random_en   : in     vl_logic;
        fix_axi_len     : in     vl_logic_vector(3 downto 0);
        bist_stop       : in     vl_logic;
        pattern_en      : out    vl_logic;
        random_data_en  : out    vl_logic;
        read_repeat_en  : out    vl_logic;
        stress_test     : out    vl_logic;
        write_to_read   : out    vl_logic;
        random_rw_addr  : out    vl_logic_vector;
        random_axi_id   : out    vl_logic_vector(3 downto 0);
        random_axi_len  : out    vl_logic_vector(3 downto 0);
        random_axi_ap   : out    vl_logic;
        ddrc_init_done  : in     vl_logic;
        init_start      : out    vl_logic;
        init_done       : in     vl_logic;
        write_en        : out    vl_logic;
        write_done_p    : in     vl_logic;
        read_en         : out    vl_logic;
        read_done_p     : in     vl_logic;
        bist_run_led    : out    vl_logic;
        test_main_state : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CTRL_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_DQ_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_SPACE_AW : constant is 1;
end test_main_ctrl_v1_0;
