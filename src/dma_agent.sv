class dma_agent extends uvm_agent;
  `uvm_component_utils(dma_agent)
  dma_driver drv;
  dma_monitor mon;
  dma_sequencer seqr;
  
  function new(string name="dma_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(uvm_active_passive_enum)::get(this,"","is_active",is_active))
      `uvm_fatal(get_full_name(),"Agent not set");
    
    if(get_is_active()==UVM_ACTIVE)
      begin
       drv=dma_driver::type_id::create("drv",this);
       seqr=dma_sequencer::type_id::create("seqr",this);
      end 
       mon=dma_monitor::type_id::create("mon",this);
  
  endfunction
  
  function void connect_phase(uvm_phase phase);
    if(get_is_active()==UVM_ACTIVE)
      drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
  
endclass
