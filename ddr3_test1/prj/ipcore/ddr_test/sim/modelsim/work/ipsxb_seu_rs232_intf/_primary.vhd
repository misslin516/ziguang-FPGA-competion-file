library verilog;
use verilog.vl_types.all;
entity ipsxb_seu_rs232_intf is
    generic(
        CLK_DIV_P       : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi1);
        FIFO_D          : integer := 1024
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        tx_fifo_wr_data : in     vl_logic_vector(31 downto 0);
        tx_fifo_wr_data_valid: out    vl_logic;
        tx_fifo_wr_data_req: in     vl_logic;
        rx_fifo_rd_data : out    vl_logic_vector(7 downto 0);
        rx_fifo_rd_data_valid: out    vl_logic;
        rx_fifo_rd_data_req: in     vl_logic;
        txd             : out    vl_logic;
        rxd             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_DIV_P : constant is 1;
    attribute mti_svvh_generic_type of FIFO_D : constant is 1;
end ipsxb_seu_rs232_intf;
