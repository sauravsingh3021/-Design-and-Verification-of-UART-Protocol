module Uart_Interface (uart_if uart);
  Uart_Transmitter tx_inst (uart);
  Uart_Receiver    rx_inst (uart);
endmodule



