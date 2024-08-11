library verilog;
use verilog.vl_types.all;
entity ipsxb_seu_uart_tx is
    port(
        clk             : in     vl_logic;
        clk_en          : in     vl_logic;
        rst_n           : in     vl_logic;
        tx_fifo_rd_data : in     vl_logic_vector(31 downto 0);
        tx_fifo_rd_data_valid: in     vl_logic;
        tx_fifo_rd_data_req: out    vl_logic;
        txd             : out    vl_logic
    );
end ipsxb_seu_uart_tx;
