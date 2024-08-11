library verilog;
use verilog.vl_types.all;
entity fft_demo_00 is
    port(
        i_aclk          : in     vl_logic;
        i_axi4s_data_tvalid: in     vl_logic;
        i_axi4s_data_tdata: in     vl_logic_vector(31 downto 0);
        i_axi4s_data_tlast: in     vl_logic;
        o_axi4s_data_tready: out    vl_logic;
        i_axi4s_cfg_tvalid: in     vl_logic;
        i_axi4s_cfg_tdata: in     vl_logic;
        o_axi4s_data_tvalid: out    vl_logic;
        o_axi4s_data_tdata: out    vl_logic_vector(63 downto 0);
        o_axi4s_data_tlast: out    vl_logic;
        o_axi4s_data_tuser: out    vl_logic_vector(15 downto 0);
        o_alm           : out    vl_logic_vector(2 downto 0);
        o_stat          : out    vl_logic
    );
end fft_demo_00;
