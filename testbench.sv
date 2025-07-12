`timescale 1ns/1ps

`include "uart_if.sv"
`include "uart_transaction.sv"
`include "uart_generator.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"
`include "uart_scoreboard.sv"
`include "uart_environment.sv"
`include "uart_transmitter.sv"
`include "uart_receiver.sv"
`include "uart_top.sv"

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
