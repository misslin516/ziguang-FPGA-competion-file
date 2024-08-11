library verilog;
use verilog.vl_types.all;
entity ipsxb_ver_ctrl_32bit is
    generic(
        DFT_CTRL_BUS_0  : integer := 0;
        DFT_CTRL_BUS_1  : integer := 0;
        DFT_CTRL_BUS_2  : integer := 0;
        DFT_CTRL_BUS_3  : integer := 0;
        DFT_CTRL_BUS_4  : integer := 0;
        DFT_CTRL_BUS_5  : integer := 0;
        DFT_CTRL_BUS_6  : integer := 0;
        DFT_CTRL_BUS_7  : integer := 0;
        DFT_CTRL_BUS_8  : integer := 0;
        DFT_CTRL_BUS_9  : integer := 0;
        DFT_CTRL_BUS_10 : integer := 0;
        DFT_CTRL_BUS_11 : integer := 0;
        DFT_CTRL_BUS_12 : integer := 0;
        DFT_CTRL_BUS_13 : integer := 0;
        DFT_CTRL_BUS_14 : integer := 0;
        DFT_CTRL_BUS_15 : integer := 0
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        addr            : in     vl_logic_vector(8 downto 0);
        data            : in     vl_logic_vector(31 downto 0);
        we              : in     vl_logic;
        cmd_en          : in     vl_logic;
        cmd_done        : out    vl_logic;
        fifo_data       : out    vl_logic_vector(31 downto 0);
        fifo_data_valid : in     vl_logic;
        fifo_data_req   : out    vl_logic;
        read_req        : out    vl_logic;
        read_ack        : in     vl_logic;
        ctrl_bus_0      : out    vl_logic_vector(31 downto 0);
        ctrl_bus_1      : out    vl_logic_vector(31 downto 0);
        ctrl_bus_2      : out    vl_logic_vector(31 downto 0);
        ctrl_bus_3      : out    vl_logic_vector(31 downto 0);
        ctrl_bus_4      : out    vl_logic_vector(31 downto 0);
        ctrl_bus_5      : out    vl_logic_vector(31 downto 0);
        ctrl_bus_6      : out    vl_logic_vector(31 downto 0);
        ctrl_bus_7      : out    vl_logic_vector(31 downto 0);
        ctrl_bus_8      : out    vl_logic_vector(31 downto 0);
        ctrl_bus_9      : out    vl_logic_vector(31 downto 0);
        ctrl_bus_10     : out    vl_logic_vector(31 downto 0);
        ctrl_bus_11     : out    vl_logic_vector(31 downto 0);
        ctrl_bus_12     : out    vl_logic_vector(31 downto 0);
        ctrl_bus_13     : out    vl_logic_vector(31 downto 0);
        ctrl_bus_14     : out    vl_logic_vector(31 downto 0);
        ctrl_bus_15     : out    vl_logic_vector(31 downto 0);
        status_bus      : in     vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_0 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_1 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_2 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_3 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_4 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_5 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_6 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_7 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_8 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_9 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_10 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_11 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_12 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_13 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_14 : constant is 1;
    attribute mti_svvh_generic_type of DFT_CTRL_BUS_15 : constant is 1;
end ipsxb_ver_ctrl_32bit;
