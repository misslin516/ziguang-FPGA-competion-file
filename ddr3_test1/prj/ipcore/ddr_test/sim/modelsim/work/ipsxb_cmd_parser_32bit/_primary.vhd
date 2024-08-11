library verilog;
use verilog.vl_types.all;
entity ipsxb_cmd_parser_32bit is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        fifo_data       : in     vl_logic_vector(7 downto 0);
        fifo_data_valid : in     vl_logic;
        fifo_data_req   : out    vl_logic;
        addr            : out    vl_logic_vector(23 downto 0);
        data            : out    vl_logic_vector(31 downto 0);
        we              : out    vl_logic;
        cmd_en          : out    vl_logic;
        cmd_done        : in     vl_logic
    );
end ipsxb_cmd_parser_32bit;
