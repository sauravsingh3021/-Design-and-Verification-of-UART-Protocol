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
