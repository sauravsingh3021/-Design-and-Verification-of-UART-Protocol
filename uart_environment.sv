class environment;
  generator g;
  driver d;
  monitor m;
  scoreboard s;

  mailbox gen2drv = new();
  mailbox mon2scb = new();
  virtual uart_if uart;

  function new(virtual uart_if uart);
    this.uart = uart;
    g = new(gen2drv);
    d = new(uart, gen2drv);
    m = new(uart, mon2scb);
    s = new(mon2scb);
  endfunction

  task run();
    fork
      g.run();
      d.run();
      m.run();
      s.run();
    join
  endtask
endclass
