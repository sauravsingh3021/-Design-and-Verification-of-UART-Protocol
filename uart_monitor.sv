class monitor;
  virtual uart_if uart;
  mailbox mon2scb;

  function new(virtual uart_if uart, mailbox mon2scb);
    this.uart = uart;
    this.mon2scb = mon2scb;
  endfunction

  task run();
    int count = 0;
    while (count < 6) begin
      @(posedge uart.clk);
      if (uart.valid_rx) begin
        uart_transaction tr = new();
        tr.received_data = uart.RxData;
        $display("[MON] Received: %s (%0h)", tr.received_data, tr.received_data);
        mon2scb.put(tr);
        count++;
      end
    end
  endtask
endclass
