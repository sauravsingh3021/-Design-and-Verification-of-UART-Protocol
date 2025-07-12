class driver;
  virtual uart_if uart;
  mailbox gen2drv;

  function new(virtual uart_if uart, mailbox gen2drv);
    this.uart = uart;
    this.gen2drv = gen2drv;
  endfunction

  task run();
    uart_transaction tr;
    repeat (6) begin
      gen2drv.get(tr);
      @(negedge uart.clk);
      while (uart.busy) @(negedge uart.clk);
      uart.TxData = tr.data;
      uart.transmit = 1;
      @(negedge uart.clk);
      uart.transmit = 0;
    end
  endtask
endclass
