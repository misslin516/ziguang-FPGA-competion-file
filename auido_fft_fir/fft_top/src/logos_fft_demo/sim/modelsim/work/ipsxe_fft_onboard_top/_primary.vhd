library verilog;
use verilog.vl_types.all;
entity ipsxe_fft_onboard_top is
    port(
        i_clk           : in     vl_logic;
        i_rstn          : in     vl_logic;
        i_start_test    : in     vl_logic;
        o_err           : out    vl_logic;
        o_chk_finished  : out    vl_logic
    );
end ipsxe_fft_onboard_top;
