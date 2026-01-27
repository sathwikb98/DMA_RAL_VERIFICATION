class dma_monitor extends uvm_monitor;
  `uvm_component_utils(dma_monitor)
  virtual dma_interface vif;
  transaction req;
  uvm_analysis_port#(transaction) mon_port;
  
  function new(string name="dma_monitor",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_port=new("mon_port",this);
    if(!uvm_config_db#(virtual dma_interface)::get(this,"","vif",vif))
      `uvm_fatal(get_full_name(),"Monitor didnt get interface")
  endfunction
      
   virtual task run_phase(uvm_phase phase);
     repeat(2) @(posedge vif.clk);
     forever begin
       repeat(5) @(posedge vif.clk);
       req=transaction::type_id::create("req");
       req.wr_en=vif.wr_en;
       req.rd_en=vif.rd_en;
       req.wdata=vif.wdata;
       req.addr=vif.addr;
       req.rdata=vif.rdata;
       //@(posedge vif.clk);
       `uvm_info("MON", req.print_trx(), UVM_MEDIUM)
       $display();
       if(req.rd_en)
        mon_port.write(req);
     end
   endtask
 endclass 
