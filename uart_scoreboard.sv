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
