class dma_adapter extends uvm_reg_adapter;
  `uvm_object_utils(dma_adapter)

  function new(string name = "dma_adapter");
    super.new(name);
  endfunction

  //--------------------------------------
  // reg2bus
  //--------------------------------------
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    transaction tr;
    tr = transaction::type_id::create("tr");

    tr.addr = rw.addr;

    if (rw.kind == UVM_WRITE) begin
      tr.wr_en = 1'b1;
      tr.rd_en = 1'b0;
      tr.wdata = rw.data;
    end
    else begin // UVM_READ
      tr.wr_en = 1'b0;
      tr.rd_en = 1'b1;
    end

    return tr;
  endfunction

  //--------------------------------------
  // bus2reg
  //--------------------------------------
  function void bus2reg(uvm_sequence_item bus_item,
                        ref uvm_reg_bus_op rw);
    transaction tr;
    assert($cast(tr, bus_item));

    rw.data   = tr.rdata;   // data from DUT
    rw.addr   = tr.addr;
    rw.status = UVM_IS_OK;
  endfunction

endclass

