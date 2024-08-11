library verilog;
use verilog.vl_types.all;
entity ipsxe_fft_sync_arstn is
    port(
        i_clk           : in     vl_logic;
        i_arstn_presync : in     vl_logic;
        o_arstn_synced  : out    vl_logic
    );
end ipsxe_fft_sync_arstn;
