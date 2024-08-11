library verilog;
use verilog.vl_types.all;
entity ipsxe_fft_exp_rom is
    generic(
        FFT_MODE        : integer := 1;
        LOG2_FFT_LEN    : integer := 8;
        INPUT_WIDTH     : integer := 16;
        SCALE_MODE      : integer := 0
    );
    port(
        i_clk           : in     vl_logic;
        i_clken         : in     vl_logic;
        i_rstn          : in     vl_logic;
        i_addr          : in     vl_logic_vector;
        o_rdata         : out    vl_logic_vector;
        o_blk_exp       : out    vl_logic_vector(4 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FFT_MODE : constant is 1;
    attribute mti_svvh_generic_type of LOG2_FFT_LEN : constant is 1;
    attribute mti_svvh_generic_type of INPUT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of SCALE_MODE : constant is 1;
end ipsxe_fft_exp_rom;
