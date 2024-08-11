library verilog;
use verilog.vl_types.all;
entity ipsxe_fft_onboard_top_tb is
    generic(
        CLK_P           : integer := 10
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_P : constant is 1;
end ipsxe_fft_onboard_top_tb;
