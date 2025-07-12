module Uart_Transmitter (uart_if uart);

  parameter int clk_freq = 50_000_000;
  parameter int baud_rate = 115200;
  parameter int div_counter = clk_freq / baud_rate;

  logic [8:0] cycle_counter;
  logic [3:0] bit_index;
  logic [9:0] tx_shift;
  logic sending;

  always_ff @(posedge uart.clk or posedge uart.reset) begin
    if (uart.reset) begin
      uart.TxD <= 1;
      sending <= 0;
      cycle_counter <= 0;
      bit_index <= 0;
      uart.busy <= 0;
    end else begin
      if (uart.transmit && !sending) begin
        tx_shift <= {1'b1, uart.TxData, 1'b0};
        sending <= 1;
        bit_index <= 0;
        cycle_counter <= 0;
        uart.busy <= 1;
      end else if (sending) begin
        if (cycle_counter == div_counter - 1) begin
          cycle_counter <= 0;
          uart.TxD <= tx_shift[bit_index];
          bit_index <= bit_index + 1;
          if (bit_index == 9) begin
            sending <= 0;
            uart.TxD <= 1;
            uart.busy <= 0;
          end
        end else begin
          cycle_counter <= cycle_counter + 1;
        end
      end
    end
  end

endmodule

