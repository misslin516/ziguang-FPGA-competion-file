library verilog;
use verilog.vl_types.all;
entity test_ddr is
    generic(
        MEM_ROW_ADDR_WIDTH: integer := 15;
        MEM_COL_ADDR_WIDTH: integer := 10;
        MEM_BADDR_WIDTH : integer := 3;
        MEM_DQ_WIDTH    : integer := 32;
        MEM_DM_WIDTH    : vl_notype;
        MEM_DQS_WIDTH   : vl_notype;
        CTRL_ADDR_WIDTH : vl_notype
    );
    port(
        ref_clk         : in     vl_logic;
        free_clk        : in     vl_logic;
        rst_board       : in     vl_logic;
        pll_lock        : out    vl_logic;
        ddr_init_done   : out    vl_logic;
        uart_rxd        : in     vl_logic;
        uart_txd        : out    vl_logic;
        mem_rst_n       : out    vl_logic;
        mem_ck          : out    vl_logic;
        mem_ck_n        : out    vl_logic;
        mem_cke         : out    vl_logic;
        mem_cs_n        : out    vl_logic;
        mem_ras_n       : out    vl_logic;
        mem_cas_n       : out    vl_logic;
        mem_we_n        : out    vl_logic;
        mem_odt         : out    vl_logic;
        mem_a           : out    vl_logic_vector;
        mem_ba          : out    vl_logic_vector;
        mem_dqs         : inout  vl_logic_vector;
        mem_dqs_n       : inout  vl_logic_vector;
        mem_dq          : inout  vl_logic_vector;
        mem_dm          : out    vl_logic_vector;
        heart_beat_led  : out    vl_logic;
        err_flag_led    : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MEM_ROW_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_COL_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_BADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_DQ_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_DM_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of MEM_DQS_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of CTRL_ADDR_WIDTH : constant is 3;
end test_ddr;
