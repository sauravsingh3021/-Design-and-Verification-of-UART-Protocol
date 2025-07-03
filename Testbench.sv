// testbench.sv

`timescale 1ns/1ps

module tb_uart_interface;

  logic clk;
  logic reset;
  logic transmit;
  logic [7:0] TxData;
  logic TxD;
  logic busy;
  logic [7:0] RxData;
  logic valid_rx;

  Uart_Interface dut (
    .clk(clk),
    .reset(reset),
    .transmit(transmit),
    .TxData(TxData),
    .TxD(TxD),
    .busy(busy),
    .RxData(RxData),
    .valid_rx(valid_rx)
  );

  always #10 clk = ~clk; // 50 MHz clock

  task send_byte(input [7:0] data);
    begin
      @(negedge clk);
      while (busy) @(negedge clk);
      TxData = data;
      transmit = 1;
      @(negedge clk);
      transmit = 0;
    end
  endtask
  
  
  always_ff @(posedge clk) begin
    if (valid_rx)
      $display("Time = %0t ns | RxData = %s (%0h)", $time, RxData, RxData);
  end

  initial begin
    $dumpfile("uart_interface.vcd");
    $dumpvars(0, tb_uart_interface);

    clk = 0;
    reset = 1;
    transmit = 0;
    TxData = 8'h00;
    #100;
    reset = 0;
    #1000;

    send_byte("S");
    send_byte("A");
    send_byte("U");
    send_byte("R");
    send_byte("A");
    send_byte("V");

   #1200000; 
$finish;

  end

endmodule
