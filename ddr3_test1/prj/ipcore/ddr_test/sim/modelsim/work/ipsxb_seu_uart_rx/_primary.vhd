library verilog;
use verilog.vl_types.all;
entity ipsxb_seu_uart_rx is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        clk_en          : in     vl_logic;
        rx_fifo_wr_data : out    vl_logic_vector(7 downto 0);
        rx_fifo_wr_data_valid: in     vl_logic;
        rx_fifo_wr_data_req: out    vl_logic;
        rxd_in          : in     vl_logic
    );
end ipsxb_seu_uart_rx;
