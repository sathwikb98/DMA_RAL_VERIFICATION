class dma_sequence extends uvm_sequence#(transaction);
  `uvm_object_utils(dma_sequence)
  function new(string name="seq");
    super.new(name);
  endfunction
  
  task body;
    repeat(10) begin
      `uvm_do(req);
    end
  endtask
endclass
