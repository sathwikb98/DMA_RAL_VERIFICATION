/////transaction
class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)
  rand bit wr_en, rd_en;
  rand bit[31:0] wdata, addr;
  bit [31:0] rdata;

  function new(string name="trx");
    super.new(name);
  endfunction

  function string print_trx();
   return $sformatf("wr_en = %0b | rd_en = %0b | wdata = 0x%0h | addr = 0x%0h | rdata = 0x%0h",wr_en,rd_en,wdata,addr,rdata);
  endfunction

  //constraint c1 { wr_en != rd_en; }
endclass
