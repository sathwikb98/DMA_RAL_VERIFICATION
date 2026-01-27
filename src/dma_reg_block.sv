class regmodel extends uvm_reg_block;
  `uvm_object_utils(regmodel)
  rand INTR intr_reg_h;
  rand CNTRL cntrl_reg_h;
  rand IO_ADDR io_addr_reg_h;
  rand EXTRA_INFO extra_info_reg_h;
  rand MEM_ADDR mem_addr_reg_h;
       STATUS status_reg_h;
  rand TRANSFER_COUNT transfer_count_reg_h;
  rand DESCRIPTOR_ADDR descriptor_addr_reg_h;
  rand ERROR_STATUS error_status_reg_h;
  rand CONFIG config_reg_h;

  function new(string name="regmodel");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  function void build;
    add_hdl_path("top.dut","RTL"); // for backdoor access...
    uvm_reg::include_coverage("*", UVM_CVR_ALL);

    //1.
    intr_reg_h = INTR::type_id::create("intr_reg_h");
    intr_reg_h.build();
    intr_reg_h.configure(this);
    //intr_reg_h.set_coverage(UVM_CVR_FIELD_VALS); // specific instance coverage !
    intr_reg_h.add_hdl_path_slice("intr_status", 0, 16);
    intr_reg_h.add_hdl_path_slice("intr_mask", 16, 16);
    
    //2.
    cntrl_reg_h = CNTRL::type_id::create("cntrl_reg_h");
    cntrl_reg_h.build();
    cntrl_reg_h.configure(this);
    //cntrl_reg_h.set_coverage(UVM_CVR_FIELD_VALS); // specific instance coverage !
    cntrl_reg_h.add_hdl_path_slice("start_dma", 0, 1);
    cntrl_reg_h.add_hdl_path_slice("w_count", 1, 15);
    cntrl_reg_h.add_hdl_path_slice("io_mem", 16, 1);
    // [17-32] RESERVED .....

    //3.
    io_addr_reg_h = IO_ADDR::type_id::create("io_addr_reg_h");
    io_addr_reg_h.build();
    io_addr_reg_h.configure(this);
    //io_addr_reg_h.set_coverage(UVM_CVR_FIELD_VALS);   // specific instance coverage !VALS);
    io_addr_reg_h.add_hdl_path_slice("io_addr", 0, 32);


    //4.
    mem_addr_reg_h = MEM_ADDR::type_id::create("mem_addr_reg_h");
    mem_addr_reg_h.build();
    mem_addr_reg_h.configure(this);
    //mem_addr_reg_h.set_coverage(UVM_CVR_FIELD_VALS);
    mem_addr_reg_h.add_hdl_path_slice("mem_addr", 0, 32);

    //5.
    extra_info_reg_h = EXTRA_INFO::type_id::create("extra_info_reg_h");
    extra_info_reg_h.build();
    extra_info_reg_h.configure(this);
    //extra_info_reg_h.set_coverage(UVM_CVR_FIELD_VALS);   // specific instance coverage !VALS);
    extra_info_reg_h.add_hdl_path_slice("extra_info", 0, 32);


    //6.
    status_reg_h = STATUS::type_id::create("status_reg_h");
    status_reg_h.build();
    status_reg_h.configure(this);
    //status_reg_h.set_coverage(UVM_CVR_FIELD_VALS);    // specific instance coverage !VALS); 
    status_reg_h.add_hdl_path_slice("status_busy", 0, 1);
    status_reg_h.add_hdl_path_slice("status_done", 1, 1);
    status_reg_h.add_hdl_path_slice("status_error", 2, 1);
    status_reg_h.add_hdl_path_slice("status_paused", 3, 1);
    status_reg_h.add_hdl_path_slice("status_current_state", 4, 4);
    status_reg_h.add_hdl_path_slice("status_fifo_level", 8, 8);
    // [31:16] ...RESERVED....

    //7.
    transfer_count_reg_h = TRANSFER_COUNT::type_id::create("transfer_count_reg_h");
    transfer_count_reg_h.build();
    transfer_count_reg_h.configure(this);
    //transfer_count_reg_h.set_coverage(UVM_CVR_FIELD_VALS); // specific instance coverage !VALS);
    transfer_count_reg_h.add_hdl_path_slice("transfer_count", 0, 32);
    

    //8.
    descriptor_addr_reg_h = DESCRIPTOR_ADDR::type_id::create("descriptor_addr_reg_h");
    descriptor_addr_reg_h.build();
    descriptor_addr_reg_h.configure(this);
    //descriptor_addr_reg_h.set_coverage(UVM_CVR_FIELD_VALS);   // specific instance coverage !VALS);
    descriptor_addr_reg_h.add_hdl_path_slice("descriptor_addr", 0, 32);
    
    //9. 
    error_status_reg_h = ERROR_STATUS::type_id::create("error_status");
    error_status_reg_h.build();
    error_status_reg_h.configure(this);
    //error_status_reg_h.set_coverage(UVM_CVR_FIELD_VALS); // specific instance coverage !VALS);
    error_status_reg_h.add_hdl_path_slice("error_bus", 0, 1);
    error_status_reg_h.add_hdl_path_slice("error_timeout", 1, 1);
    error_status_reg_h.add_hdl_path_slice("error_alignment", 2, 1);
    error_status_reg_h.add_hdl_path_slice("error_overflow", 3, 1);
    error_status_reg_h.add_hdl_path_slice("error_underflow", 4, 1);
    // [7:5] ...RESERVED...
    error_status_reg_h.add_hdl_path_slice("error_code", 8, 8);
    error_status_reg_h.add_hdl_path_slice("error_bus", 16, 16);

    //10.
    config_reg_h = CONFIG::type_id::create("config_reg_h");
    config_reg_h.build();
    config_reg_h.configure(this);
    //config_reg_h.set_coverage(UVM_CVR_FIELD_vals); // specific instance coverage !VALS);
    config_reg_h.add_hdl_path_slice("config_priority", 0, 2);
    config_reg_h.add_hdl_path_slice("config_auto_restart", 2, 1);
    config_reg_h.add_hdl_path_slice("config_interrupt_enable", 3, 1);
    config_reg_h.add_hdl_path_slice("config_burst_size", 4, 2);
    config_reg_h.add_hdl_path_slice("config_data_width", 6, 2);
    config_reg_h.add_hdl_path_slice("config_descriptor_mode", 8, 1);
    //[31:9] ...RESERVED...

    // --------------------------
    //     DEFAULT MAP
    // --------------------------
    default_map = create_map("default_map",'h400,'h4, UVM_LITTLE_ENDIAN);
    default_map.add_reg(intr_reg_h,             'h0,  "RW");
    default_map.add_reg(cntrl_reg_h,            'h4,  "RW");
    default_map.add_reg(io_addr_reg_h,          'h8,  "RW");
    default_map.add_reg(mem_addr_reg_h,         'hc,  "RW");
    default_map.add_reg(extra_info_reg_h,       'h10, "RW");
    default_map.add_reg(status_reg_h,           'h14, "RO");
    default_map.add_reg(transfer_count_reg_h,   'h18, "RO");
    default_map.add_reg(descriptor_addr_reg_h,  'h1c, "RW");
    default_map.add_reg(error_status_reg_h,     'h20, "RW");
    default_map.add_reg(config_reg_h,           'h24, "RW");

    lock_model();

  endfunction

endclass
