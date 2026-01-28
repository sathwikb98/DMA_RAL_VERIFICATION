// ----------------------------------------------------------------------------------------------------------------
// 1.INTERRUPT REGISTER...
// Purpose: Provides interrupt status and interrupt masking capability.
// ----------------------------------------------------------------------------------------------------------------

class INTR extends uvm_reg;
  `uvm_object_utils(INTR)
  uvm_reg_field intr_status;
  rand uvm_reg_field intr_mask;

  // Add covergroup further to implement verification......
  covergroup intr_cov;
    option.per_instance=1;
  /*  intr_done_cp : coverpoint intr_status.value[0]{
      bins not_done = {0};
      bins done = {1};
    } 
  */
    intr_mask_cp :coverpoint intr_mask.value{
      bins masked = {0};
      bins enabled = {[1:$]};
    }
  //  intr_done_x_intr_mask : cross intr_done_cp, intr_mask_cp;
  endgroup

  function new(string name="INTR");
    super.new(name,32,UVM_CVR_FIELD_VALS);
    if(has_coverage(UVM_CVR_FIELD_VALS))
      intr_cov = new();
  endfunction

  virtual function void sample(uvm_reg_data_t data,
                               uvm_reg_data_t byte_en,
                               bit is_read,
                               uvm_reg_map map);
    intr_cov.sample();
  endfunction
  
  virtual function void sample_values();
    super.sample_values();
    intr_cov.sample();
  endfunction

  function void build();
    // 1. intr_status..
    intr_status = uvm_reg_field::type_id::create("intr_status");
    intr_status.configure( 
      .parent(this), 
      .size(16), 
      .lsb_pos(0), 
      .access("RO"), 
      .volatile(0), 
      .reset(16'h0), 
      .has_reset(0), 
      .is_rand(0), 
      .individually_accessible(1)
    );
    // 2. intr_mask..
    intr_mask = uvm_reg_field::type_id::create("intr_mask");
    intr_mask.configure(
      .parent(this), 
      .size(16), 
      .lsb_pos(16), 
      .access("RW"), 
      .volatile(0), 
      .reset(16'h0), 
      .has_reset(1), 
      .is_rand(1), 
      .individually_accessible(1)
    );
  endfunction

endclass


// ----------------------------------------------------------------------------------------------------------------
// 2.CONTROL REGISTER...
// Purpose: controls DMA start and basic transfer behavior.
// ----------------------------------------------------------------------------------------------------------------

class CNTRL extends uvm_reg;
  `uvm_object_utils(CNTRL)
  rand uvm_reg_field start_dma;
  rand uvm_reg_field w_count;
  rand uvm_reg_field io_mem;
  uvm_reg_field reserved;

  covergroup cntrl_cov;
    option.per_instance = 1;
  
    start_dma_cp : coverpoint start_dma.value {
      bins bin  = {0,1};
      //bins start = {1};
    }
    
    w_count_cp : coverpoint w_count.value{
      bins bin = {[0:$]};
    }
    
    io_mem_cp : coverpoint io_mem.value{
      bins io_and_mem = {0,1};
      // bins mem_to_io = {1};
    }
    
   // start_dir_cross  : cross start_dma_cp, io_mem_cp;
   // start_size_cross : cross start_dma_cp, w_count_cp;
    
  endgroup

  function new(string name="CNTRL");
    super.new(name,32,UVM_CVR_FIELD_VALS);
    if(has_coverage(UVM_CVR_FIELD_VALS))
      cntrl_cov=new();
  endfunction
  
  virtual function void sample(uvm_reg_data_t data,
                               uvm_reg_data_t byte_en,
                               bit is_read,
                               uvm_reg_map map);
    cntrl_cov.sample();
  endfunction
  
  virtual function void sample_values();
    super.sample_values();
    cntrl_cov.sample();
  endfunction

  function void build();
    // 1. start_dma..
    start_dma = uvm_reg_field::type_id::create("start_dma");
    start_dma.configure(
      .parent(this),
      .size(1),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(1'h0),
      .has_reset(1),
      .is_rand(1),
      .individually_accessible(1)
    );
    // 2. w_count..
    w_count = uvm_reg_field::type_id::create("w_count");
    w_count.configure(
      .parent(this),
      .size(15),
      .lsb_pos(1),
      .access("RW"),
      .volatile(0),
      .reset(15'h0),
      .has_reset(1),
      .is_rand(1),
      .individually_accessible(1)
   );
   // 3. io_mem..
   io_mem = uvm_reg_field::type_id::create("io_mem");
   io_mem.configure(
      .parent(this),
      .size(1),
      .lsb_pos(16),
      .access("RW"),
      .volatile(0),
      .reset(1'h0),
      .has_reset(1),
      .is_rand(1),
      .individually_accessible(1)
   );
   // 4. reserved..
   reserved = uvm_reg_field::type_id::create("reserved");
   reserved.configure(
      .parent(this),
      .size(15),
      .lsb_pos(17),
      .access("RO"),
      .volatile(0),
      .reset(16'h0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(1)
   );
  endfunction
endclass


// ----------------------------------------------------------------------------------------------------------------
// 3. INPUT/OUTPUT ADDR REGISTER...
// Purpose: Holds the IO/source address for DMA transfer.
// ----------------------------------------------------------------------------------------------------------------

class IO_ADDR extends uvm_reg;
  `uvm_object_utils(IO_ADDR)
  rand uvm_reg_field io_addr;

  covergroup io_addr_cov;
   option.per_instance = 1;

  io_cp : coverpoint io_addr.value {
    /*
    bins aligned    = {2'b00};
    bins misaligned = {[2'b01:2'b11]};
    */
    bins a = {[0:$]};
  }

 /* io_region_cp : coverpoint io_addr.value[31:28] {
    bins low_addr  = {[4'h0:4'h3]};
    bins mid_addr  = {[4'h4:4'hB]};
    bins high_addr = {[4'hC:4'hF]};
  }
 */
  endgroup

  function new(string name="IO_ADDR");
    super.new(name,32,UVM_CVR_FIELD_VALS);
    if (has_coverage(UVM_CVR_FIELD_VALS))
      io_addr_cov = new();
  endfunction

  virtual function void sample(uvm_reg_data_t data,
                               uvm_reg_data_t byte_en,
                               bit is_read,
                               uvm_reg_map map);
     io_addr_cov.sample();
  endfunction

  virtual function void sample_values();
    super.sample_values();
    io_addr_cov.sample();
  endfunction

  function void build();
    // 1. io_addr..
    io_addr = uvm_reg_field::type_id::create("io_addr");
    io_addr.configure(
      .parent(this),
      .size(32),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(32'h0),
      .has_reset(1),
      .is_rand(1),
      .individually_accessible(1)
    );
  endfunction

endclass


// ----------------------------------------------------------------------------------------------------------------
// 4. MEMORY ADDR REGISTER...
// Purpose: Holds the memory destination/source address.
// ----------------------------------------------------------------------------------------------------------------

class MEM_ADDR extends uvm_reg;
  `uvm_object_utils(MEM_ADDR)
  rand uvm_reg_field mem_addr;

  covergroup mem_addr_cov;
    option.per_instance = 1;

/*
    mem_align_cp : coverpoint mem_addr.value[1:0] {
      bins aligned    = {2'b00};
      bins misaligned = {[2'b01:2'b11]};
    }

    mem_region_cp : coverpoint mem_addr.value[31:28] {
      bins low_mem  = {[4'h0:4'h3]};
      bins mid_mem  = {[4'h4:4'hB]};
      bins high_mem = {[4'hC:4'hF]};
    }
*/
    mem_cp : coverpoint mem_addr.value{
      bins a = {[0:$]};
    }
  endgroup

  function new(string name="MEM_ADDR");
    super.new(name,32,UVM_CVR_FIELD_VALS);
    if(has_coverage(UVM_CVR_FIELD_VALS))
      mem_addr_cov=new();
  endfunction

  virtual function void sample(uvm_reg_data_t data,
                               uvm_reg_data_t byte_en,
                               bit is_read,
                               uvm_reg_map map);
    mem_addr_cov.sample();
  endfunction

  virtual function void sample_values();
    super.sample_values();
    mem_addr_cov.sample();
  endfunction
  
  function void build();
    // 1. mem_addr..
    mem_addr = uvm_reg_field::type_id::create("mem_addr");
    mem_addr.configure(
      .parent(this),
      .size(32),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(32'h0),
      .has_reset(1),
      .is_rand(1),
      .individually_accessible(1)
    );
  endfunction

endclass


// -----------------------------------------------------------------------------------------------------------------
// 5. EXTRA INFO REGISTER...
// Purpose: Software-defined register for passing auxiliary information.
// -----------------------------------------------------------------------------------------------------------------

class EXTRA_INFO extends uvm_reg;
  `uvm_object_utils(EXTRA_INFO)
  rand uvm_reg_field extra_info;

  covergroup extra_info_cov;
    option.per_instance = 1;

    extra_info_cp : coverpoint extra_info.value {
    /* 
      bins zero      = {32'h0000_0000};
      bins all_ones  = {32'hFFFF_FFFF};
      bins walking1[] = {
        32'h0000_0001, 32'h0000_0002, 32'h0000_0004,
        32'h0000_0008, 32'h0000_0010
      };
      bins random    = default;
    */
      bins a = {[0:$]};
    }

  endgroup

  function new(string name="EXTRA_INFO");
    super.new(name,32,UVM_CVR_FIELD_VALS);
    if(has_coverage(UVM_CVR_FIELD_VALS))
      extra_info_cov=new();
  endfunction

  virtual function void sample(uvm_reg_data_t data,
                               uvm_reg_data_t byte_en,
                               bit is_read,
                               uvm_reg_map map);
    extra_info_cov.sample();
  endfunction

  virtual function void sample_values();
    super.sample_values();
    extra_info_cov.sample();
  endfunction

  function void build();
    // 1. extra_info..
    extra_info = uvm_reg_field::type_id::create("extra_info");
    extra_info.configure(
      .parent(this),
      .size(32),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(32'h0),
      .has_reset(1),
      .is_rand(1),
      .individually_accessible(1)
    );
  endfunction
endclass


// -----------------------------------------------------------------------------------------------------------------
// 6. STATUS REGISTER...
// Purpose: Provides real-time DMA engine status.
// -----------------------------------------------------------------------------------------------------------------

class STATUS extends uvm_reg;
  `uvm_object_utils(STATUS)
  uvm_reg_field busy;
  uvm_reg_field done;
  uvm_reg_field error;
  uvm_reg_field paused;
  uvm_reg_field current_state;
  uvm_reg_field fifo_level;
  uvm_reg_field reserved;

/*
  covergroup status_cov;
    option.per_instance = 1;

    busy_cp : coverpoint busy.value {
      bins idle   = {0};
      bins active = {1};
    }

    done_cp : coverpoint done.value {
      bins not_done = {0};
      bins done     = {1};
    }

    error_cp : coverpoint error.value {
      bins no_error = {0};
      bins error    = {1};
    }

    paused_cp : coverpoint paused.value {
      bins running = {0};
      bins paused  = {1};
    }

    fsm_cp : coverpoint current_state.value {
      bins idle     = {0};
      bins setup    = {1};
      bins transfer = {[2:7]};
      bins terminal = {[8:15]};
    }

    fifo_level_cp : coverpoint fifo_level.value {
      bins empty  = {0};
      bins low    = {[1:3]};
      bins mid    = {[4:15]};
      bins high   = {[16:255]};
    }

    busy_done_cross  : cross busy_cp, done_cp;
    error_state_cross: cross error_cp, fsm_cp;
  endgroup  
*/
  function new(string name="STATUS");
    super.new(name,32,UVM_CVR_FIELD_VALS);
    //if(has_coverage(UVM_CVR_FIELD_VALS))
      //status_cov=new();
  endfunction
/*
  virtual function void sample(uvm_reg_data_t data,
                               uvm_reg_data_t byte_en,
                               bit is_read,
                               uvm_reg_map map);
    status_cov.sample();
  endfunction

  virtual function void sample_values();
    super.sample_values();
    status_cov.sample();
  endfunction
*/
  function void build();
     // 1. busy..
     busy = uvm_reg_field::type_id::create("busy");
     busy.configure(
       .parent(this),
       .size(1),
       .lsb_pos(0),
       .access("RO"),
       .volatile(0),
       .reset(1'h0),
       .has_reset(0),
       .is_rand(0),
       .individually_accessible(1)
     );
    // 2. done..
     done = uvm_reg_field::type_id::create("done");
     done.configure(
       .parent(this),
       .size(1),
       .lsb_pos(1),
       .access("RO"),
       .volatile(0),
       .reset(1'h0),
       .has_reset(0),
       .is_rand(0),
       .individually_accessible(1)
     );
     // 3. error..
     error = uvm_reg_field::type_id::create("error");
     error.configure(
       .parent(this),
       .size(1),
       .lsb_pos(2),
       .access("RO"),
       .volatile(0),
       .reset(1'h0),
       .has_reset(0),
       .is_rand(0),
       .individually_accessible(1)
     );
     // 4. paused..
     paused = uvm_reg_field::type_id::create("paused");
     paused.configure(
       .parent(this),
       .size(1),
       .lsb_pos(3),
       .access("RO"),
       .volatile(0),
       .reset(1'h0),
       .has_reset(0),
       .is_rand(0),
       .individually_accessible(1)
     );
     // 5. current_state..
     current_state = uvm_reg_field::type_id::create("current_state");
     current_state.configure(
       .parent(this),
       .size(4),
       .lsb_pos(4),
       .access("RO"),
       .volatile(0),
       .reset(4'h0),
       .has_reset(0),
       .is_rand(0),
       .individually_accessible(1)
     );
     // 6. fifo_level..
     fifo_level = uvm_reg_field::type_id::create("fifo_level");
     fifo_level.configure(
       .parent(this),
       .size(8),
       .lsb_pos(8),
       .access("RO"),
       .volatile(0),
       .reset(8'h0),
       .has_reset(0),
       .is_rand(0),
       .individually_accessible(1)
     );
     // 7. reserved..
     reserved = uvm_reg_field::type_id::create("reserved");
     reserved.configure(
       .parent(this),
       .size(16),
       .lsb_pos(16),
       .access("RW"),
       .volatile(0),
       .reset(16'h0),
       .has_reset(0),
       .is_rand(0),
       .individually_accessible(1)
     );
  endfunction

endclass

// -----------------------------------------------------------------------------------------------------------------
// 7. TRANSFER COUNT REGISTER...
// Purpose: Indicates number of completed transfer beats.
// -----------------------------------------------------------------------------------------------------------------

class TRANSFER_COUNT extends uvm_reg;
  `uvm_object_utils(TRANSFER_COUNT)
  uvm_reg_field transfer_count;
/*
  covergroup transfer_count_cov;
    option.per_instance = 1;
    count_progress_cp : coverpoint transfer_count.value {
      bins zero       = {0};
      bins Small      = {[1:15]};
      bins Medium     = {[16:255]};
      bins Large      = {[256:4095]};
      bins very_large = {[4096:$]};
    }
  
  endgroup
*/
  function new(string name="TRANSAFER_COUNT");
    super.new(name,32,UVM_CVR_FIELD_VALS);
    //if(has_coverage(UVM_CVR_FIELD_VALS))
      //transfer_count_cov=new();
  endfunction
/*
  virtual function void sample(uvm_reg_data_t data,
                               uvm_reg_data_t byte_en,
                               bit is_read,
                               uvm_reg_map map);
    transfer_count_cov.sample();
  endfunction

  virtual function void sample_values();
    super.sample_values();
    transfer_count_cov.sample();
  endfunction
*/

  function void build();
     transfer_count = uvm_reg_field::type_id::create("transfer_count");
     transfer_count.configure(
       .parent(this),
       .size(32),
       .lsb_pos(0),
       .access("RO"),
       .volatile(0),
       .reset(32'h0),
       .has_reset(0),
       .is_rand(0),
       .individually_accessible(1)
     );
  endfunction
 
endclass


//------------------------------------------------------------------------------------------------------------------
// 8. DESCRIPTOR ADDR REGISTER...
// Purpose: Base address of DMA descriptor list.
// -----------------------------------------------------------------------------------------------------------------

class DESCRIPTOR_ADDR extends uvm_reg;
  `uvm_object_utils(DESCRIPTOR_ADDR)
  uvm_reg_field descriptor_addr;

  covergroup descriptor_addr_cov;
    option.per_instance = 1;
/*
    desc_align_cp : coverpoint descriptor_addr.value[1:0] {
      bins aligned    = {2'b00};
      bins misaligned = {[2'b01:2'b11]};
    }
    
    desc_region_cp : coverpoint descriptor_addr.value[31:28] {
      bins low_addr  = {[4'h0:4'h3]};
      bins mid_addr  = {[4'h4:4'hB]};
      bins high_addr = {[4'hC:4'hF]};
    }

    desc_value_cp : coverpoint descriptor_addr.value {
      bins zero     = {32'h0};
      bins non_zero = {[1:$]};
    }
*/
    cp : coverpoint descriptor_addr.value{
      bins a = {[0:$]};
    }
  endgroup

  function new(string name="DESCRIPTOR_ADDR");
    super.new(name,32,UVM_CVR_FIELD_VALS);
    if(has_coverage(UVM_CVR_FIELD_VALS))
      descriptor_addr_cov=new();
  endfunction

  virtual function void sample(uvm_reg_data_t data,
                               uvm_reg_data_t byte_en,
                               bit is_read,
                               uvm_reg_map map);
    descriptor_addr_cov.sample();
  endfunction

  virtual function void sample_values();
    super.sample_values();
    descriptor_addr_cov.sample();
  endfunction

  function void build();
     descriptor_addr = uvm_reg_field::type_id::create("descriptor_addr");
     descriptor_addr.configure(
       .parent(this),
       .size(32),
       .lsb_pos(0),
       .access("RW"),
       .volatile(0),
       .reset(32'h0),
       .has_reset(1),
       .is_rand(1),
       .individually_accessible(1)
     );
  endfunction

endclass


// -----------------------------------------------------------------------------------------------------------------
// 9. ERROR STATUS REGISTER...
// Purpose: Reports DMA error conditions. Error bits are Write-1-to-Clear (W1C).
// -----------------------------------------------------------------------------------------------------------------

class ERROR_STATUS extends uvm_reg;
 `uvm_object_utils(ERROR_STATUS)
  rand uvm_reg_field bus_error;
  rand uvm_reg_field timeout_error;
  rand uvm_reg_field alignment_error;
  rand uvm_reg_field overflow_error;
  rand uvm_reg_field underflow_error;
  uvm_reg_field reserved;
  uvm_reg_field error_code;
  uvm_reg_field error_addr_offset;

  covergroup error_status_cov;
    option.per_instance = 1;

    bus_error_cp : coverpoint bus_error.value {
      bins err = {0,1};
    }

    timeout_error_cp : coverpoint timeout_error.value {
      bins err = {0,1};
    }

    alignment_error_cp : coverpoint alignment_error.value {
      bins err = {0,1};
    }

    overflow_error_cp : coverpoint overflow_error.value {
      bins err = {0,1};
    }

    underflow_error_cp : coverpoint underflow_error.value {
      bins err = {0,1};
    }
/*  // RO-FIELD...
    error_code_cp : coverpoint error_code.value {
      bins zero     = {0};
      bins non_zero = {[1:$]};
    }

    error_addr_cp : coverpoint error_addr_offset.value {
      bins zero     = {0};
      bins non_zero = {[1:$]};
    }
*/
  endgroup

  function new(string name="ERROR_STATUS");
    super.new(name,32,UVM_CVR_FIELD_VALS);
    if(has_coverage(UVM_CVR_FIELD_VALS))
      error_status_cov=new();
  endfunction

  virtual function void sample(uvm_reg_data_t data,
                               uvm_reg_data_t byte_en,
                               bit is_read,
                               uvm_reg_map map);
    error_status_cov.sample();
  endfunction

  virtual function void sample_values();
    super.sample_values();
    error_status_cov.sample();
  endfunction

  function void build();
     // 1. bus_error..
     bus_error = uvm_reg_field::type_id::create("bus_error");
     bus_error.configure(
       .parent(this),
       .size(1),
       .lsb_pos(0),
       .access("W1C"), 
       .volatile(0),
       .reset(1'h0),
       .has_reset(1),
       .is_rand(1),
       .individually_accessible(1)
     );
    // 2. timeout_error..
     timeout_error = uvm_reg_field::type_id::create("timeout_error");
     timeout_error.configure(
       .parent(this),
       .size(1),
       .lsb_pos(1),
       .access("W1C"), //"RW1C" 
       .volatile(0),
       .reset(1'h0),
       .has_reset(1),
       .is_rand(1),
       .individually_accessible(1)
     );
     // 3. alignment_error..
     alignment_error = uvm_reg_field::type_id::create("alignment_error");
     alignment_error.configure(
       .parent(this),
       .size(1),
       .lsb_pos(2),
       .access("W1C"), //"RW1C"
       .volatile(0),
       .reset(1'h0),
       .has_reset(1),
       .is_rand(1),
       .individually_accessible(1)
     );
     // 4. overflow_error..
     overflow_error = uvm_reg_field::type_id::create("overflow_error");
     overflow_error.configure(
       .parent(this),
       .size(1),
       .lsb_pos(3),
       .access("W1C"),//"RW1C"
       .volatile(0),
       .reset(1'h0),
       .has_reset(1),
       .is_rand(1),
       .individually_accessible(1)
     );
     // 5. underflow_error..
     underflow_error = uvm_reg_field::type_id::create("underflow_error");
     underflow_error.configure(
       .parent(this),
       .size(1),
       .lsb_pos(4),
       .access("W1C"), //"RW1C"
       .volatile(0),
       .reset(1'h0),
       .has_reset(1),
       .is_rand(1),
       .individually_accessible(1)
     );
     // 6. reserved..
     reserved = uvm_reg_field::type_id::create("reserved");
     reserved.configure(
       .parent(this),
       .size(3),
       .lsb_pos(5),
       .access("RO"),
       .volatile(0),
       .reset(8'h0),
       .has_reset(0),
       .is_rand(0),
       .individually_accessible(1)
     );
     // 7. error_code..
     error_code = uvm_reg_field::type_id::create("error_code");
     error_code.configure(
       .parent(this),
       .size(8),
       .lsb_pos(8),
       .access("RO"),
       .volatile(0),
       .reset(16'h0),
       .has_reset(0),
       .is_rand(0),
       .individually_accessible(1)
     );
     // 8. error_addr_offset..
     error_addr_offset = uvm_reg_field::type_id::create("error_addr_offset");
     error_addr_offset.configure(
      .parent(this),
      .size(16),
      .lsb_pos(16),
      .access("RO"),
      .volatile(0),
      .reset(16'h0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(1)
    );
  endfunction
 
endclass

// ----------------------------------------------------------------------------------------------------------------
// 10. CONFIG REGISTER...
// Purpose: Configures DMA behavior and performance.
// ----------------------------------------------------------------------------------------------------------------

class CONFIG extends uvm_reg;
 `uvm_object_utils(CONFIG)
  rand uvm_reg_field Priority;
  rand uvm_reg_field auto_restart;
  rand uvm_reg_field interrupt_enable;
  rand uvm_reg_field burst_size;
  rand uvm_reg_field data_width;
  rand uvm_reg_field descriptor_mode;
  uvm_reg_field reserved;

  covergroup config_cov;
    option.per_instance = 1;

    priority_cp : coverpoint Priority.value {
     /* bins p0 = {0};
      bins p1 = {1};
      bins p2 = {2};
      bins p3 = {3};
      */
      bins prio = {[0:3]};
    }

    auto_restart_cp : coverpoint auto_restart.value {
     /* bins disabled = {0};
      bins enabled  = {1};
      */
      bins auto_res = {0,1};
    }

    interrupt_enable_cp : coverpoint interrupt_enable.value {
     /* bins disabled = {0};
      bins enabled  = {1};
      */
      bins intr_enb = {0,1};
    }

    burst_size_cp : coverpoint burst_size.value {
     /* bins burst_1 = {0};
      bins burst_2 = {1};
      bins burst_4 = {2};
      bins burst_8 = {3};
      */
      bins burst_x = {[0:3]};
    }

    data_width_cp : coverpoint data_width.value {
     /* bins width_8  = {0};
      bins width_16 = {1};
      bins width_32 = {2};
      bins width_64 = {3};
      */
      bins width_x = {[0:3]};
    }

    descriptor_mode_cp : coverpoint descriptor_mode.value {
      /*bins disabled = {0};
      bins enabled  = {1};
      */
      bins des_mode = {0,1};
    }

  endgroup

  function new(string name="CONFIG");
    super.new(name,32,UVM_CVR_FIELD_VALS);
    if(has_coverage(UVM_CVR_FIELD_VALS))
      config_cov=new();
  endfunction

  virtual function void sample(uvm_reg_data_t data,
                               uvm_reg_data_t byte_en,
                               bit is_read,
                               uvm_reg_map map);
    config_cov.sample();
  endfunction

  virtual function void sample_values();
    super.sample_values();
    config_cov.sample();
  endfunction

  function void build();
     // 1. Priority..
     Priority = uvm_reg_field::type_id::create("Priority");
     Priority.configure(
       .parent(this),
       .size(2),
       .lsb_pos(0),
       .access("RW"),
       .volatile(0),
       .reset(2'h0),
       .has_reset(1),
       .is_rand(1),
       .individually_accessible(1)
     );
    // 2. auto_restart..
     auto_restart = uvm_reg_field::type_id::create("auto_restart");
     auto_restart.configure(
       .parent(this),
       .size(1),
       .lsb_pos(2),
       .access("RW"),
       .volatile(0),
       .reset(1'h0),
       .has_reset(1),
       .is_rand(1),
       .individually_accessible(1)
     );
     // 3. interrupt_enable..
     interrupt_enable = uvm_reg_field::type_id::create("interrupt_enable");
     interrupt_enable.configure(
       .parent(this),
       .size(1),
       .lsb_pos(3),
       .access("RW"),
       .volatile(0),
       .reset(1'h0),
       .has_reset(1),
       .is_rand(1),
       .individually_accessible(1)
     );
     // 4. burst_size..
     burst_size = uvm_reg_field::type_id::create("burst_size");
     burst_size.configure(
       .parent(this),
       .size(2),
       .lsb_pos(4),
       .access("RW"),
       .volatile(0),
       .reset(2'h0),
       .has_reset(1),
       .is_rand(1),
       .individually_accessible(1)
     );
     // 5. data_width..
     data_width = uvm_reg_field::type_id::create("data_width");
     data_width.configure(
       .parent(this),
       .size(2),
       .lsb_pos(6),
       .access("RW"),
       .volatile(0),
       .reset(2'h0),
       .has_reset(1),
       .is_rand(1),
       .individually_accessible(1)
     );
     // 6. descriptor_mode..
     descriptor_mode = uvm_reg_field::type_id::create("descriptor_mode");
     descriptor_mode.configure(
       .parent(this),
       .size(1),
       .lsb_pos(8),
       .access("RW"),
       .volatile(0),
       .reset(1'h0),
       .has_reset(1),
       .is_rand(1),
       .individually_accessible(1)
     );
     // 7. reserved..
     reserved = uvm_reg_field::type_id::create("reserved");
     reserved.configure(
       .parent(this),
       .size(23),
       .lsb_pos(9),
       .access("RO"),
       .volatile(0),
       .reset(23'h0),
       .has_reset(0),
       .is_rand(0),
       .individually_accessible(1)
     );
  endfunction
 
endclass
