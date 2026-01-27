class dma_driver extends uvm_driver#(transaction);
  `uvm_component_utils(dma_driver)
  virtual dma_interface vif;

  function new(string name="dma_driver", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual dma_interface)::get(this,"","vif",vif))
      `uvm_fatal("DRV", "VIF NOT FOUND")
    
  endfunction

  task run_phase(uvm_phase phase);
    repeat(2) @(posedge vif.clk);
    forever begin
      seq_item_port.get_next_item(req);
      drive_inf();
      seq_item_port.item_done();
    end
  endtask

  task drive_inf();
      // Drive request
      vif.addr  <= req.addr;
      vif.wdata <= req.wdata;
      vif.wr_en <= req.wr_en;
      vif.rd_en <= req.rd_en;

      `uvm_info("DRV", req.print_trx(), UVM_MEDIUM)

      repeat(5) @(posedge vif.clk);
      if(req.rd_en) begin
        `uvm_info("DRV", $sformatf("REQ in drv is updated to send rdata[0x%08h] to read @(reg_model)",vif.rdata), UVM_MEDIUM)
        req.rdata = vif.rdata;
      end

  endtask

endclass
