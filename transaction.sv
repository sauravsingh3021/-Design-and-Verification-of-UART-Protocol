class uart_transaction;
  rand bit [7:0] data;
  bit [7:0] received_data;

  function void display(string tag);
    $display("[%s] Data: %s (%0h)", tag, data, data);
  endfunction
endclass
