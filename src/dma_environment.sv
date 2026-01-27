class dma_environment extends uvm_env;
  `uvm_component_utils(dma_environment)
  //---------
  //reg-model
  //---------
  regmodel reg_blk;
  
  //-------------
  //reg-predictor
  //-------------
  uvm_reg_predictor#(transaction) predict_inst;
  
  //-------
  //adapter
  //-------
  dma_adapter adp_inst;

  dma_agent agt1;

  function new(string name="dma_environment",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    agt1=dma_agent::type_id::create("agt1",this);
    predict_inst=uvm_reg_predictor#(transaction)::type_id::create("predict_inst",this);
    adp_inst=dma_adapter::type_id::create("adp_inst",,get_full_name());
    reg_blk=regmodel::type_id::create("reg_blk",this);
    reg_blk.build(); // call the build !!
  endfunction
  
  function void connect_phase(uvm_phase phase);
    predict_inst.adapter = adp_inst;
    predict_inst.map=reg_blk.default_map;
    reg_blk.default_map.set_sequencer(.sequencer(agt1.seqr),.adapter(adp_inst));
    reg_blk.default_map.set_base_addr('h400);
    agt1.mon.mon_port.connect(predict_inst.bus_in);
    reg_blk.default_map.set_auto_predict(0);
  endfunction
  
endclass
