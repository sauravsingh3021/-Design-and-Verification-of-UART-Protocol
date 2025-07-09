`timescale 1ns/1ps

//===================== Transaction =====================
class uart_transaction;
  rand bit [7:0] data;
  bit [7:0] received_data;

  function void display(string tag);
    $display("[%s] Data: %s (%0h)", tag, data, data);
  endfunction
endclass

//===================== Generator =====================
class generator;
  mailbox gen2drv;
  function new(mailbox gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task run();
    uart_transaction tr;
    byte message[6] = {"S", "A", "U", "R", "A", "V"};
for (int i = 0; i < $size(message); i++) begin
      tr = new();
      tr.data = message[i];
      tr.display("GEN");
      gen2drv.put(tr);
      #1000;
    end
  endtask
endclass

//===================== Driver =====================
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

//===================== Monitor =====================
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

//===================== Scoreboard =====================
class scoreboard;
  mailbox mon2scb;

  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  task run();
    uart_transaction tr;
   byte expected[6] = {"S", "A", "U", "R", "A", "V"};
for (int i = 0; i < $size(expected); i++) begin
      mon2scb.get(tr);
      if (tr.received_data !== expected[i])
        $display("[SCB][FAIL] Expected %s, Got %s", expected[i], tr.received_data);
      else
        $display("[SCB][PASS] Received %s", tr.received_data);
    end
  endtask
endclass

//===================== Environment =====================
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

//===================== Testbench =====================
module tb_uart_interface;

  uart_if uart(); 
  Uart_Interface dut (.uart(uart)); 

  // Clock generation
  initial uart.clk = 0;
  always #10 uart.clk = ~uart.clk; // 50 MHz

  environment env;
  initial begin
     $dumpfile("uart.vcd");
  $dumpvars(0, tb_uart_interface); 

    uart.reset = 1;
    uart.transmit = 0;
    uart.TxData = 0;
    #100;
    uart.reset = 0;
    #100;

    env = new(uart);
  env.run();
$display("[TB] Simulation completed.");
$finish;
  end

endmodule
