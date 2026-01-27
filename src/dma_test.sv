  //-----------------------------------------------
  //....DMA TEST....
  //-----------------------------------------------
  class dma_test_base extends uvm_test;
    `uvm_component_utils(dma_test_base)

    dma_environment env_h;

    function new(string name="dma_test_base", uvm_component parent=null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      uvm_config_db#(uvm_active_passive_enum)::set(
        this, "env_h.agt1", "is_active", UVM_ACTIVE
      );

      env_h = dma_environment::type_id::create("env_h", this);
    endfunction

  endclass

  class intr_01_test extends dma_test_base;
    `uvm_component_utils(intr_01_test)

    intr_01_reset_write_read_seq seq;

    function new(string name="intr_01_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      seq = intr_01_reset_write_read_seq::type_id::create("seq");
      seq.rm = env_h.reg_blk;
      seq.start(env_h.agt1.seqr);

      phase.drop_objection(this);
    endtask
  endclass

  class intr_03_test extends dma_test_base;
    `uvm_component_utils(intr_03_test)

    intr_03_mask_seq seq;

    function new(string name="intr_03_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      seq = intr_03_mask_seq::type_id::create("seq");
      seq.rm = env_h.reg_blk;
      seq.start(env_h.agt1.seqr);

      phase.drop_objection(this);
    endtask
  endclass

  class ctrl_01_test extends dma_test_base;
      `uvm_component_utils(ctrl_01_test)

      ctrl_01_start_dma_seq seq;

      function new(string name="cntrl_01_test", uvm_component parent);
        super.new(name, parent);
      endfunction

      task run_phase(uvm_phase phase);
          phase.raise_objection(this);

          seq = ctrl_01_start_dma_seq::type_id::create("seq");
          seq.rm = env_h.reg_blk;
          seq.start(env_h.agt1.seqr);

          phase.drop_objection(this);
      endtask
  endclass

  class ioa_01_test extends dma_test_base;
      `uvm_component_utils(ioa_01_test)

      ioa_01_rw_seq seq;

      function new(string name="ioa_01_test", uvm_component parent);
         super.new(name, parent);
      endfunction

      task run_phase(uvm_phase phase);
            phase.raise_objection(this);

            seq = ioa_01_rw_seq::type_id::create("seq");
            seq.rm = env_h.reg_blk;
            seq.start(env_h.agt1.seqr);

            phase.drop_objection(this);
      endtask
  endclass


  class mem_01_test extends dma_test_base;
      `uvm_component_utils(mem_01_test)

      mem_01_rw_seq seq;

      function new(string name="mem_01_test", uvm_component parent);
        super.new(name, parent);
      endfunction

      task run_phase(uvm_phase phase);
            phase.raise_objection(this);

            seq = mem_01_rw_seq::type_id::create("seq");
            seq.rm = env_h.reg_blk;
            seq.start(env_h.agt1.seqr);

            phase.drop_objection(this);
      endtask
  endclass


  class sta_01_test extends dma_test_base;
    `uvm_component_utils(sta_01_test)

    status_01_busy_seq seq;

    function new(string name="sta_01_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      seq = status_01_busy_seq::type_id::create("seq");
      seq.rm = env_h.reg_blk;
      seq.start(env_h.agt1.seqr);

      phase.drop_objection(this);
    endtask

  endclass 

  class tran_01_test extends dma_test_base;
    `uvm_component_utils(tran_01_test)

    transfer_01_ro_seq seq;

    function new(string name="tran_01_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      
      seq = transfer_01_ro_seq::type_id::create("seq");
      seq.rm = env_h.reg_blk;
      seq.start(env_h.agt1.seqr);
      
      phase.drop_objection(this);
    endtask

  endclass
  
  class ext_01_test extends dma_test_base;
      `uvm_component_utils(ext_01_test)

      ext_01_rw_seq seq;

      function new(string name="ext_01_test", uvm_component parent);
         super.new(name, parent);
      endfunction

      task run_phase(uvm_phase phase);
            phase.raise_objection(this);

            seq = ext_01_rw_seq::type_id::create("seq");
            seq.rm = env_h.reg_blk;
            seq.start(env_h.agt1.seqr);

            phase.drop_objection(this);
      endtask
  endclass
  
  
  class desc_01_test extends dma_test_base;
      `uvm_component_utils(desc_01_test)

      desc_01_rw_seq seq;

      function new(string name="desc_01_test", uvm_component parent);
        super.new(name, parent);
      endfunction

      task run_phase(uvm_phase phase);
            phase.raise_objection(this);

            seq = desc_01_rw_seq::type_id::create("seq");
            seq.rm = env_h.reg_blk;
            seq.start(env_h.agt1.seqr);

            phase.drop_objection(this);
          endtask
  endclass

  class err_sta_01_test extends dma_test_base;
    `uvm_component_utils(err_sta_01_test)

    err_01_w1c_seq seq;

    function new(string name="err_sta_01_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      seq = err_01_w1c_seq::type_id::create("seq");
      seq.rm = env_h.reg_blk;
      seq.start(env_h.agt1.seqr);

      phase.drop_objection(this);
   endtask

  endclass

  class cfg_01_test extends dma_test_base;
      `uvm_component_utils(cfg_01_test)

      cfg_01_priority_seq seq;

      function new(string name="cfg_01_test", uvm_component parent);
        super.new(name, parent);
      endfunction

      task run_phase(uvm_phase phase);
            phase.raise_objection(this);

            seq = cfg_01_priority_seq::type_id::create("seq");
            seq.rm = env_h.reg_blk;
            seq.start(env_h.agt1.seqr);

            phase.drop_objection(this);
   endtask
  
  endclass


  class regression_test extends dma_test_base;
    `uvm_component_utils(regression_test)
    intr_01_reset_write_read_seq seq1;
    intr_03_mask_seq seq2;
    ctrl_01_start_dma_seq seq3;
    ioa_01_rw_seq seq4;
    mem_01_rw_seq seq5;
    status_01_busy_seq seq6;
    transfer_01_ro_seq seq7;
    ext_01_rw_seq seq8;
    desc_01_rw_seq seq9;
    err_01_w1c_seq seq10;
    cfg_01_priority_seq seq11;

    function new(string name="regression_test", uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      // CREATE
      seq1 = intr_01_reset_write_read_seq::type_id::create("seq1");
      seq2 = intr_03_mask_seq::type_id::create("seq2");
      seq3 = ctrl_01_start_dma_seq::type_id::create("seq3");
      seq4 = ioa_01_rw_seq::type_id::create("seq4");
      seq5 = mem_01_rw_seq::type_id::create("seq5");
      seq6 = status_01_busy_seq::type_id::create("seq6");
      seq7 = transfer_01_ro_seq::type_id::create("seq7");
      seq8 = ext_01_rw_seq::type_id::create("seq8");
      seq9 = desc_01_rw_seq::type_id::create("seq9");
      seq10 = err_01_w1c_seq::type_id::create("seq10");
      seq11 = cfg_01_priority_seq::type_id::create("seq11");

      // CONNECT TO REG_BLOCK
      seq1.rm = env_h.reg_blk;
      seq2.rm = env_h.reg_blk;
      seq3.rm = env_h.reg_blk;
      seq4.rm = env_h.reg_blk;
      seq5.rm = env_h.reg_blk;
      seq6.rm = env_h.reg_blk;
      seq7.rm = env_h.reg_blk;
      seq8.rm = env_h.reg_blk;
      seq9.rm = env_h.reg_blk;
      seq10.rm = env_h.reg_blk;
      seq11.rm = env_h.reg_blk;

      // START ON SEQR
      seq1.start(env_h.agt1.seqr);
      seq2.start(env_h.agt1.seqr);
      seq3.start(env_h.agt1.seqr);
      seq4.start(env_h.agt1.seqr);
      seq5.start(env_h.agt1.seqr);
      seq6.start(env_h.agt1.seqr);
      seq7.start(env_h.agt1.seqr);
      seq8.start(env_h.agt1.seqr);
      seq9.start(env_h.agt1.seqr);
      seq10.start(env_h.agt1.seqr);
      seq11.start(env_h.agt1.seqr);
      
      phase.drop_objection(this);

    endtask

  endclass
