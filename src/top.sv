`include "dma_pkg.sv"
`include "uvm_macros.svh"
`include "dma_interface.sv"
`include "dma_design.sv"

import uvm_pkg::*;
import dma_pkg::*;

module top;
  bit clk, rst_n;
  dma_interface vif (.clk(clk), .rst_n(rst_n));

  dma_design dut (.clk(clk), .rst_n(rst_n), .wr_en(vif.wr_en), .rd_en(vif.rd_en), .wdata(vif.wdata), .addr(vif.addr), .rdata(vif.rdata));


  initial begin
      clk = 0;
      forever #5 clk = ~clk;
  end

  initial begin
    uvm_config_db#(virtual dma_interface)::set(null,"","vif",vif);
    run_test(/*"intr_01_test"*/ /*"regression_test"*/);
  end

  initial begin
    rst_n = 0;
    #10;
    rst_n = 1; // de-activate
  end

endmodule
