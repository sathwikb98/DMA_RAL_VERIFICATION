///////////INTERFACE...
interface dma_interface(input clk, rst_n);
  logic       wr_en;
  logic       rd_en;
  logic [31:0] wdata;
  logic [31:0] addr;
  logic [31:0] rdata;

endinterface
