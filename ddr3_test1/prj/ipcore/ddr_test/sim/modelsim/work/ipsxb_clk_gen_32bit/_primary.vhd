library verilog;
use verilog.vl_types.all;
entity ipsxb_clk_gen_32bit is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        clk_div         : in     vl_logic_vector(15 downto 0);
        clk_en          : out    vl_logic
    );
end ipsxb_clk_gen_32bit;
