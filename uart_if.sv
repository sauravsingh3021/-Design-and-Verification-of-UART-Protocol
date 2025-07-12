interface uart_if;
  logic clk;
  logic reset;
  logic transmit;
  logic [7:0] TxData;
  logic TxD;
  logic busy;
  logic [7:0] RxData;
  logic valid_rx;
endinterface
