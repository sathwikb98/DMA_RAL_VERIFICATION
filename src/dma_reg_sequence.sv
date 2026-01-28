//--------------------------------------------------------------------
// DMA REG SEQUENCE
//--------------------------------------------------------------------
class dma_reg_base_seq extends uvm_sequence;
  `uvm_object_utils(dma_reg_base_seq)

  regmodel rm;
  uvm_status_e status;
  uvm_reg_data_t rdata;
  uvm_reg_data_t mir, dis;

  function new(string name="dma_reg_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    if (rm == null)
      `uvm_fatal("REG_SEQ", "Register model handle is NULL")
  endtask

endclass

class intr_01_reset_write_read_seq extends dma_reg_base_seq;
  `uvm_object_utils(intr_01_reset_write_read_seq)

  task body();
    if (!rm.intr_reg_h.has_hdl_path())
        `uvm_fatal("INTR_HDL_PATH", "INTR_REG backdoor path missing")
    
    rm.reset();  // RAL reset

    rm.intr_reg_h.read(status, rdata);
    dis = rm.intr_reg_h.get();
    mir = rm.intr_reg_h.get_mirrored_value();
    
    `uvm_info("REG_SEQ:[READ AFTER RESET]",
               $sformatf("[INTR_01] Desired=0x%08h, Mirror=0x%08h [status : %0s]",
               dis, mir, status.name()),
               UVM_LOW)
    
    //-----------------------------------------------
    // BACKDOOR WRITE, FRONTDOOR READ [TEST]...
    //-----------------------------------------------
    rm.intr_reg_h.write(status,32'hFFFF_FFFF,UVM_BACKDOOR);
    dis=rm.intr_reg_h.get();
    mir=rm.intr_reg_h.get_mirrored_value();
    rm.intr_reg_h.update(status);
    `uvm_info("REG_SEQ:[WRITE]",
              $sformatf("[INTR_01] [BACKDOOR-WRITE] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)

    rm.intr_reg_h.read(status, rdata/*, UVM_BACKDOOR*/); // UVM_FRONTDOOR
    dis = rm.intr_reg_h.get();
    //rm.intr_reg_h.update(status);
    mir = rm.intr_reg_h.get_mirrored_value();

    `uvm_info("REG_SEQ:[READ]",
              $sformatf("[INTR_01] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)

    if(rdata == 32'hFFFF_0000) // WRITE CHECK.... 
      `uvm_info("REPORT", "[INTR_REG] MATCH's write and read value...", UVM_MEDIUM)
    else
      `uvm_error("REPORT_ERROR", "[INTR_REG] DOES'NT MATCH write and read value!");

  endtask

endclass

class intr_03_mask_seq extends dma_reg_base_seq;
  `uvm_object_utils(intr_03_mask_seq)

  task body();
    if (!rm.intr_reg_h.has_hdl_path())
        `uvm_fatal("INTR_HDL_PATH", "INTR_REG backdoor path missing")

    // --------------------------------------------
    //   FRONTDOOR WRITE, BACKDOOR READ [TEST]
    // --------------------------------------------
    rm.intr_reg_h.write(status, 32'hABCD_0000);
    dis = rm.intr_reg_h.get();
    mir = rm.intr_reg_h.get_mirrored_value();

    `uvm_info("REG_SEQ:[WRITE]",
              $sformatf("[INTR_03] Desired=0x%08h, Mirror=0x%08h [status : %0s]",
              dis, mir, status.name()),
              UVM_LOW)

    rm.intr_reg_h.read(status, rdata, UVM_BACKDOOR);
    dis = rm.intr_reg_h.get();
    mir = rm.intr_reg_h.get_mirrored_value();

    `uvm_info("REG_SEQ:[READ]",
              $sformatf("[INTR_03] [BACKDOOR-READ] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)
  
    if(rdata == 32'hABCD_0000)
       `uvm_info("REPORT", "[INTR_REG] MATCH's write and read value...", UVM_MEDIUM)
    else
       `uvm_error("REPORT_ERROR", "[INTR_REG] DOES'NT MATCH write and read value!");

  endtask

endclass

class ctrl_01_start_dma_seq extends dma_reg_base_seq;
  `uvm_object_utils(ctrl_01_start_dma_seq)

  task body();
    if (!rm.cntrl_reg_h.has_hdl_path())
         `uvm_fatal("CNTRL_HDL_PATH", "CNTRL_REG backdoor path missing")

    rm.cntrl_reg_h.write(status, {15'd0, 1'b0, 15'd4, 1'b1}); ////write::32bit {Reserved, io_mem, w_count, start_dma}      [{15bit}, 1bit, 15bits, 1bit]....
    
    dis = rm.cntrl_reg_h.get();
    mir = rm.cntrl_reg_h.get_mirrored_value();
    
    `uvm_info("REG_SEQ:[WRITE]",
              $sformatf("[CNTRL_01] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)
    
    rm.cntrl_reg_h.read(status, rdata);
    //rm.cntrl_reg_h.update(status);
    dis = rm.cntrl_reg_h.get();
    mir = rm.cntrl_reg_h.get_mirrored_value();
    
    `uvm_info("REG_SEQ:[READ]",
              $sformatf("[CNTRL_01] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)

    if (mir[0] != 0)
       `uvm_error("CTRL_01", "start_dma did not self-clear")
    else
       `uvm_info("CTRL_01", "start_dma self-clear OK", UVM_MEDIUM)

    if(rdata == {15'd0, 1'b0, 15'd4, 1'b0}) // self cleared value !!
      `uvm_info("REPORT", "[CTRL_REG] MATCH's write and read value...", UVM_MEDIUM)
    else
      `uvm_error("REPORT_ERROR", "[CTRL_REG] DOES'NT MATCH write and read value!")

  endtask

endclass

class ioa_01_rw_seq extends dma_reg_base_seq;
  `uvm_object_utils(ioa_01_rw_seq)

  task body();
    if (!rm.io_addr_reg_h.has_hdl_path())
        `uvm_fatal("IO_ADDR_HDL_PATH", "IO_ADDR_REG backdoor path missing")

    // ---------------------------------------------------------------------
    //  UVM_BACKDOOR WRITE & READ......[TEST]
    // ---------------------------------------------------------------------
    assert(rm.io_addr_reg_h.io_addr.randomize()); // random value generated...
    rm.io_addr_reg_h.write(status, rm.io_addr_reg_h.io_addr.value, UVM_BACKDOOR);
    dis = rm.io_addr_reg_h.get();
    mir = rm.io_addr_reg_h.get_mirrored_value();

    `uvm_info("REG_SEQ:[WRITE]",
              $sformatf("[IO_ADDR_01] [BACKDOOR-WRITE] Desired=0x%08h, Mirror=0x%08h [status : %0s]",
              dis, mir, status.name()),
              UVM_LOW)

    rm.io_addr_reg_h.read(status, rdata, UVM_BACKDOOR);
    dis = rm.io_addr_reg_h.get();
    mir = rm.io_addr_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[READ]",
              $sformatf("[IO_ADDR_01] [BACKDOOR-READ] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)

    if(rdata == rm.io_addr_reg_h.io_addr.value)
      `uvm_info("REPORT", "[IO_ADDR_REG] MATCH's write and read value...", UVM_MEDIUM)
    else
      `uvm_error("REPORT_ERROR", "[IO_ADDR_REG] DOES'NT MATCH write and read value!")

    // ---------------------------------------------------------------------
    //  WRITE & READ......[TEST]
    // ---------------------------------------------------------------------
    assert(rm.io_addr_reg_h.io_addr.randomize()); // random value generated...
    rm.io_addr_reg_h.write(status, rm.io_addr_reg_h.io_addr.value, UVM_FRONTDOOR);
    dis = rm.io_addr_reg_h.get();
    mir = rm.io_addr_reg_h.get_mirrored_value();

    `uvm_info("REG_SEQ:[WRITE]",
              $sformatf("[IO_ADDR_01] [BACKDOOR-WRITE] Desired=0x%08h, Mirror=0x%08h [status : %0s]",
              dis, mir, status.name()),
              UVM_LOW)

    rm.io_addr_reg_h.read(status, rdata, UVM_FRONTDOOR);
    dis = rm.io_addr_reg_h.get();
    mir = rm.io_addr_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[READ]",
              $sformatf("[IO_ADDR_01] [BACKDOOR-READ] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)

    if(rdata == rm.io_addr_reg_h.io_addr.value)
      `uvm_info("REPORT", "[IO_ADDR_REG] MATCH's write and read value...", UVM_MEDIUM)
    else
      `uvm_error("REPORT_ERROR", "[IO_ADDR_REG] DOES'NT MATCH write and read value!")
    

  endtask
endclass

class mem_01_rw_seq extends dma_reg_base_seq;
  `uvm_object_utils(mem_01_rw_seq)

  task body();
    if (!rm.mem_addr_reg_h.has_hdl_path())
       `uvm_fatal("MEM_ADDR_HDL_PATH", "MEM_ADDR_REG backdoor path missing")

    // ------------------------------------------------------
    // POKE AND PEEK used rather write/read............[TEST]
    // ------------------------------------------------------
    assert(rm.mem_addr_reg_h.mem_addr.randomize()); // random value generated...
    rm.mem_addr_reg_h.poke(status, rm.mem_addr_reg_h.mem_addr.value);
    dis = rm.mem_addr_reg_h.get();
    mir = rm.mem_addr_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[WRITE]",
              $sformatf("[MEM_ADDR_01]...[POKE]... Desired=0x%08h, Mirror=0x%08h [status : %0s]",
              dis, mir, status.name()),
              UVM_LOW)

    rm.mem_addr_reg_h.peek(status, rdata);
    dis = rm.mem_addr_reg_h.get();
    mir = rm.mem_addr_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[READ]",
              $sformatf("[MEM_ADDR_01]...[PEEK]... Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)

    if(rdata == rm.mem_addr_reg_h.mem_addr.value)
      `uvm_info("REPORT", "[MEM_ADDR_REG] MATCH's write and read value...", UVM_MEDIUM)
    else
      `uvm_error("REPORT_ERROR", "[MEM_ADDR_REG] DOES'NT MATCH write and read value!")

    // ------------------------------------------------------
    // write & read............[TEST]
    // ------------------------------------------------------
    assert(rm.mem_addr_reg_h.mem_addr.randomize()); // random value generated...
    rm.mem_addr_reg_h.write(status, rm.mem_addr_reg_h.mem_addr.value, UVM_FRONTDOOR);
    dis = rm.mem_addr_reg_h.get();
    mir = rm.mem_addr_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[WRITE]",
              $sformatf("[MEM_ADDR_01]...[POKE]... Desired=0x%08h, Mirror=0x%08h [status : %0s]",
              dis, mir, status.name()),
              UVM_LOW)

    rm.mem_addr_reg_h.read(status, rdata, UVM_FRONTDOOR);
    dis = rm.mem_addr_reg_h.get();
    mir = rm.mem_addr_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[READ]",
              $sformatf("[MEM_ADDR_01]...[PEEK]... Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)

    if(rdata == rm.mem_addr_reg_h.mem_addr.value)
      `uvm_info("REPORT", "[MEM_ADDR_REG] MATCH's write and read value...", UVM_MEDIUM)
    else
      `uvm_error("REPORT_ERROR", "[MEM_ADDR_REG] DOES'NT MATCH write and read value!")

  endtask

endclass


class status_01_busy_seq extends dma_reg_base_seq;
  `uvm_object_utils(status_01_busy_seq)

    task body();
      if(!rm.status_reg_h.has_hdl_path())
        `uvm_fatal("STATUS_HDL_PATH", "EXTRA_INFO_REG backdoor path missing")

      `uvm_info("REG_SEQ",
        "STATUS_01 : Starting STATUS register verification",
        UVM_MEDIUM)

      /*....[LSB]
      [0] busy    =|
      [1] done     |=>[4bits]
      [2] error    |
      [3] paused  =|
      [7:4] current_state [4bits]
      [15:8] fifo_level [8bits]
      [31:16] Reserved...[16bits]
      ......[MSB]
      */
      rm.cntrl_reg_h.write(status, 32'd0, UVM_BACKDOOR);
      //rm.status_reg_h.poke(status, 32'd0);
      rm.transfer_count_reg_h.poke(status, 32'd0);
      
      rm.status_reg_h.poke(status, 32'h000_00_0_1);
      dis = rm.status_reg_h.get();
      mir = rm.status_reg_h.get_mirrored_value();

      `uvm_info("REG_SEQ:[POKE]",
                $sformatf("[STATUS_INFO_01] Desired=0x%08h, Mirror=0x%08h [status : %0s]",
                dis, mir, status.name()),
                UVM_LOW)

      rm.status_reg_h.write(status,32'h0000_AB_C_D);
      dis = rm.status_reg_h.get();
      mir = rm.status_reg_h.get_mirrored_value();
      
      `uvm_info("REG_SEQ:[WRITE]",
                $sformatf("[STATUS_INFO_01] Desired=0x%08h, Mirror=0x%08h [status : %0s]",
                dis, mir, status.name()),
                UVM_LOW)

      rm.status_reg_h.read(status,rdata);
      dis = rm.status_reg_h.get();
      mir = rm.status_reg_h.get_mirrored_value();

      `uvm_info("REG_SEQ:[READ]",
                $sformatf("[STATUS_INFO_01] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
                dis, mir, rdata,  status.name()),
                UVM_LOW)

      if(rdata != 32'h0000_AB_C_D)
        `uvm_info("REPORT", "[STATUS_REG] MATCH's write & read value as not same [RO].....", UVM_MEDIUM)
      else
        `uvm_error("REPORT_ERROR", "[STATUS_REG] DOES'NT MATCH write & read value as not same [RO]...!")

    `uvm_info("REG_SEQ",
      "STATUS_01 : verification completed",
      UVM_MEDIUM)

  endtask

endclass

class transfer_01_ro_seq extends dma_reg_base_seq;
  `uvm_object_utils(transfer_01_ro_seq)

  task body;
    if (!rm.transfer_count_reg_h.has_hdl_path())
        `uvm_fatal("TRANSFER_COUNT_HDL_PATH", "TRANSFER_COUNT_REG backdoor path missing")

    // -------------------------------------------------
    //  Trying to POKE/PEEK for RO register !!
    // -------------------------------------------------
    
    rm.transfer_count_reg_h.read(status, rdata);
    dis = rm.transfer_count_reg_h.get();
    mir = rm.transfer_count_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[READ]",
              $sformatf("[TRANSFER_COUNT_01] BEFORE POKE.. Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW
             )
    
    rm.transfer_count_reg_h.poke(status, 32'hFFFFFFFF);
    dis = rm.transfer_count_reg_h.get();
    mir = rm.transfer_count_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[POKE]",
              $sformatf("[TRANSFER_COUNT_01] Desired=0x%08h, Mirror=0x%08h [status : %0s]",
              dis, mir, status.name()),
              UVM_LOW
             )

    // DO THE WRITE TO CHECK IF THE UPDATE HAPPENS...............
    rm.transfer_count_reg_h.write(status, 32'hB0C00FA0);
    dis = rm.transfer_count_reg_h.get();
    mir = rm.transfer_count_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[WRITE]",
              $sformatf("After write.....[TRANSFER_COUNT_01] Desired=0x%08h, Mirror=0x%08h [status : %0s]",
              dis, mir, status.name()),
              UVM_LOW
             )

    rm.transfer_count_reg_h.peek(status, rdata);
    dis = rm.transfer_count_reg_h.get();
    mir = rm.transfer_count_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[PEEK]",
              $sformatf("[TRANSFER_COUNT_01] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW
             )

    if(rdata == 32'hFFFFFFFF)
        `uvm_info("REPORT", "[TRANSFER_REG] MATCH's write and read value.....", UVM_MEDIUM)
      else
        `uvm_error("REPORT_ERROR", "[TRANSFER_REG] DOES'NT MATCH write and read value...!")
    
  endtask

endclass

class ext_01_rw_seq extends dma_reg_base_seq;
  `uvm_object_utils(ext_01_rw_seq)

  task body();
    if (!rm.extra_info_reg_h.has_hdl_path())
       `uvm_fatal("EXTRA_INFO_HDL_PATH", "EXTRA_INFO_REG backdoor path missing")

    assert(rm.extra_info_reg_h.extra_info.randomize()); // random value generated...
    rm.extra_info_reg_h.write(status, rm.extra_info_reg_h.extra_info.value);
    dis = rm.extra_info_reg_h.get();
    mir = rm.extra_info_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[WRITE]",
              $sformatf("[EXTRA_INFO_01] Desired=0x%08h, Mirror=0x%08h [status : %0s]",
              dis, mir, status.name()),
              UVM_LOW)

    rm.extra_info_reg_h.read(status, rdata);
    dis = rm.extra_info_reg_h.get();
    mir = rm.extra_info_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[READ]",
              $sformatf("[EXTRA_INFO_01] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)

    if(rdata == rm.extra_info_reg_h.extra_info.value)
      `uvm_info("REPORT", "[TRANSFER_REG] MATCH's write and read value.....", UVM_MEDIUM)
    else
      `uvm_error("REPORT_ERROR", "[TRANSFER_REG] DOES'NT MATCH write and read value...!")

  endtask
endclass

class desc_01_rw_seq extends dma_reg_base_seq;
  `uvm_object_utils(desc_01_rw_seq)

  task body();
    
    assert(rm.descriptor_addr_reg_h.descriptor_addr.randomize()); // random value generated...
    rm.descriptor_addr_reg_h.write(status, rm.descriptor_addr_reg_h.descriptor_addr.value);
    dis = rm.descriptor_addr_reg_h.get();
    mir = rm.descriptor_addr_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[WRITE]",
              $sformatf("[DESCRIPTOR_ADDR_01] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)

    rm.descriptor_addr_reg_h.read(status, rdata);
    dis = rm.descriptor_addr_reg_h.get();
    mir = rm.descriptor_addr_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[READ]",
              $sformatf("[DESCRIPTOR_ADDR_01] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)

    if(rdata == rm.descriptor_addr_reg_h.descriptor_addr.value)
      `uvm_info("REPORT", "[DESCRIPTOR_ADDR_REG] MATCH's write and read value.....", UVM_MEDIUM)
    else
      `uvm_error("REPORT_ERROR", "[DESCRIPTOR_ADDR_REG] DOES'NT MATCH write and read value...!")
  
  endtask

endclass

class err_01_w1c_seq extends dma_reg_base_seq;
  `uvm_object_utils(err_01_w1c_seq)

  task body();
    // ----------------------------------------------------------------------------------------------------
    // Try doing poke and write 1 to clear and then check for clear with read............
    // ----------------------------------------------------------------------------------------------------
    rm.reset();
    rm.error_status_reg_h.read(status, rdata);
    dis = rm.error_status_reg_h.get();
    mir = rm.error_status_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[READ]",
              $sformatf("[ERROR_STATUS_01]Before POKE... Desired=0x%08h, Mirror=0x%08h, rdata=0x%0h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)

    // poke...
    rm.error_status_reg_h.poke(status, 32'h0000001F);
    dis = rm.error_status_reg_h.get();
    mir = rm.error_status_reg_h.get_mirrored_value();
    //rm.error_status_reg_h.predict(32'h0000001F);
    `uvm_info("REG_SEQ:[POKE]",
              $sformatf("[ERROR_STATUS_01] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)
    
    // peek...
    rm.error_status_reg_h.peek(status, rdata);
    dis = rm.error_status_reg_h.get();
    mir = rm.error_status_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[PEEK]",
              $sformatf("[ERROR_STATUS_01] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)

    // write...
    rm.error_status_reg_h.write(status, {24'd0, 8'h1F}, UVM_BACKDOOR);
    dis = rm.error_status_reg_h.get();
    mir = rm.error_status_reg_h.get_mirrored_value();
     `uvm_info("REG_SEQ:[WRITE]",
               $sformatf("[ERROR_STATUS_01] Desired=0x%08h, Mirror=0x%08h[status : %0s]",
               dis, mir, status.name()),
               UVM_LOW)
    // read...
    rm.error_status_reg_h.read(status, rdata);
    dis = rm.error_status_reg_h.get();
    mir = rm.error_status_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[READ]",
              $sformatf("[ERROR_STATUS_01] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)

    if(rdata == 32'h0)
      `uvm_info("REPORT", "[ERROR_STATUS_REG] MATCH's read value as Zero.....[W1C]", UVM_MEDIUM)
    else
      `uvm_error("REPORT_ERROR", "[ERROR_STATUS_REG] DOES'NT MATCH read value as Zero[W1C]...!")

  endtask

endclass

class cfg_01_priority_seq extends dma_reg_base_seq;
  `uvm_object_utils(cfg_01_priority_seq)

  task body();
    for (int prio = 0; prio <= 3; prio++) begin
      /*
         [1:0]  priority [RW]          -> prio [2bits]
         [2]    auto_restart [RW]         
         [3]    interrupt_enable [RW]
         [5:4]  burst_size [RW]
         [7:6]  data_width [RW] 
         [8]    descriptor_mode [RW] 
         [31:9] Reserved [RO]
      */
      rm.config_reg_h.write(status, {30'd0, prio});
      dis = rm.config_reg_h.get();
      mir = rm.config_reg_h.get_mirrored_value();
      `uvm_info("REG_SEQ:[WRITE]",
              $sformatf("[CONFIGURE_01] Desired=0x%08h, Mirror=0x%08h, Priority=%0d [status : %0s]",
              dis, mir, prio, status.name()),
              UVM_LOW)

      rm.config_reg_h.read(status, rdata);
      dis = rm.config_reg_h.get();
      mir = rm.config_reg_h.get_mirrored_value();
      `uvm_info("REG_SEQ:[READ]",
              $sformatf("[CONFIGURE_01] Desired=0x%08h, Mirror=0x%08h, Priority=%0d, rdata=0x%08h [status : %0s]",
              dis, mir, prio, rdata, status.name()),
              UVM_LOW)
      if(rdata == prio)
        `uvm_info("REPORT", "[CONFIG_REG] MATCH's prio and read value.....", UVM_MEDIUM)
      else
        `uvm_error("REPORT_ERROR", "[CONFIG_REG] DOES'NT MATCH prio and read value...!")
    end
    //-----------------------------------------
    //  Writing random value...
    // ----------------------------------------
    assert(rm.config_reg_h.randomize);
    rm.config_reg_h.write(status, {23'd0, rm.config_reg_h.descriptor_mode.value, rm.config_reg_h.data_width.value, rm.config_reg_h.burst_size.value, rm.config_reg_h.interrupt_enable.value, rm.config_reg_h.auto_restart.value, rm.config_reg_h.Priority.value} );
    dis = rm.config_reg_h.get();
    mir = rm.config_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[WRITE]",
              $sformatf("[CONFIGURE_01] Desired=0x%08h, Mirror=0x%08h [status : %0s]",
              dis, mir, status.name()),
              UVM_LOW)

    rm.config_reg_h.read(status, rdata);
    dis = rm.config_reg_h.get();
    mir = rm.config_reg_h.get_mirrored_value();
    `uvm_info("REG_SEQ:[READ]",
              $sformatf("[CONFIGURE_01] Desired=0x%08h, Mirror=0x%08h, rdata=0x%08h [status : %0s]",
              dis, mir, rdata, status.name()),
              UVM_LOW)
    if(rdata == {23'd0, rm.config_reg_h.descriptor_mode.value, rm.config_reg_h.data_width.value, rm.config_reg_h.burst_size.value, rm.config_reg_h.interrupt_enable.value, rm.config_reg_h.auto_restart.value, rm.config_reg_h.Priority.value} )
      `uvm_info("REPORT", "[CONFIG_REG] MATCH's write and read value.....", UVM_MEDIUM)
    else
      `uvm_error("REPORT_ERROR", "[CONFIG_REG] DOES'NT MATCH write and read value...!")
  
  endtask

endclass
