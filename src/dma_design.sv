//==============================================
// Enhanced DMA Design with Additional Registers
//==============================================

module dma_design (
    input  logic        clk,
    input  logic        rst_n,
    
    // Register Interface
    input  logic        wr_en,
    input  logic        rd_en,
    input  logic [31:0] wdata,
    input  logic [31:0] addr,
    output logic [31:0] rdata
);

    //===========================================
    // Register Addresses
    //===========================================
    parameter INTR_ADDR           = 32'h400;
    parameter CTRL_ADDR           = 32'h404;
    parameter IO_ADDR_ADDR        = 32'h408;
    parameter MEM_ADDR_ADDR       = 32'h40C;
    parameter EXTRA_INFO_ADDR     = 32'h410;
    parameter STATUS_ADDR         = 32'h414;  // NEW
    parameter TRANSFER_COUNT_ADDR = 32'h418;  // NEW
    parameter DESCRIPTOR_ADDR     = 32'h41C;  // NEW
    parameter ERROR_STATUS_ADDR   = 32'h420;  // NEW
    parameter CONFIG_ADDR         = 32'h424;  // NEW

    //===========================================
    // Register Declarations
    //===========================================
    
    // INTR Register [31:0]
    // [15:0]  - status (RO)
    // [31:16] - mask (RW)
    logic [15:0] intr_status;
    logic [15:0] intr_mask;
    
    // CTRL Register [31:0]
    // [0]     - start_dma (RW)
    // [15:1]  - w_count (RW)
    // [16]    - io_mem (RW)
    // [31:17] - reserved (RO)
    logic        ctrl_start_dma;
    logic [14:0] ctrl_w_count;
    logic        ctrl_io_mem;
    
    // IO_ADDR Register [31:0]
    logic [31:0] io_addr;
    
    // MEM_ADDR Register [31:0]
    logic [31:0] mem_addr;
    
    // EXTRA_INFO Register [31:0]
    logic [31:0] extra_info;
    
    // STATUS Register [31:0] - NEW
    // [0]     - busy (RO)
    // [1]     - done (RO)
    // [2]     - error (RO)
    // [3]     - paused (RO)
    // [7:4]   - current_state (RO)
    // [15:8]  - fifo_level (RO)
    // [31:16] - reserved
    logic        status_busy;
    logic        status_done;
    logic        status_error;
    logic        status_paused;
    logic [3:0]  status_current_state;
    logic [7:0]  status_fifo_level;
    
    // TRANSFER_COUNT Register [31:0] - NEW
    // [31:0] - transfer_count (RO)
    logic [31:0] transfer_count;
    
    // DESCRIPTOR_ADDR Register [31:0] - NEW
    // [31:0] - descriptor_addr (RW)
    logic [31:0] descriptor_addr;
    
    // ERROR_STATUS Register [31:0] - NEW
    // [0]     - bus_error (RW1C)
    // [1]     - timeout_error (RW1C)
    // [2]     - alignment_error (RW1C)
    // [3]     - overflow_error (RW1C)
    // [4]     - underflow_error (RW1C)
    // [7:5]   - reserved
    // [15:8]  - error_code (RO)
    // [31:16] - error_addr_offset (RO)
    logic        error_bus;
    logic        error_timeout;
    logic        error_alignment;
    logic        error_overflow;
    logic        error_underflow;
    logic [7:0]  error_code;
    logic [15:0] error_addr_offset;
    
    // CONFIG Register [31:0] - NEW
    // [1:0]   - priority (RW)
    // [2]     - auto_restart (RW)
    // [3]     - interrupt_enable (RW)
    // [5:4]   - burst_size (RW)
    // [7:6]   - data_width (RW)
    // [8]     - descriptor_mode (RW)
    // [31:9]  - reserved
    logic [1:0]  config_priority;
    logic        config_auto_restart;
    logic        config_interrupt_enable;
    logic [1:0]  config_burst_size;
    logic [1:0]  config_data_width;
    logic        config_descriptor_mode;

    //===========================================
    // Write Operation
    //===========================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all RW registers
            intr_mask           <= 16'h0;
            ctrl_start_dma      <= 1'b0;
            ctrl_w_count        <= 15'h0;
            ctrl_io_mem         <= 1'b0;
            io_addr             <= 32'h0;
            mem_addr            <= 32'h0;
            extra_info          <= 32'h0;
            descriptor_addr     <= 32'h0;
            error_bus           <= 1'b0;
            error_timeout       <= 1'b0;
            error_alignment     <= 1'b0;
            error_overflow      <= 1'b0;
            error_underflow     <= 1'b0;
            config_priority     <= 2'b00;
            config_auto_restart <= 1'b0;
            config_interrupt_enable <= 1'b0;
            config_burst_size   <= 2'b00;
            config_data_width   <= 2'b00;
            config_descriptor_mode <= 1'b0;
        end 
        else if (wr_en) begin
            case (addr)
                INTR_ADDR: begin
                    intr_mask <= wdata[31:16];
                end
                
                CTRL_ADDR: begin
                    ctrl_start_dma <= wdata[0];
                    ctrl_w_count   <= wdata[15:1];
                    ctrl_io_mem    <= wdata[16];
                end
                
                IO_ADDR_ADDR: begin
                    io_addr <= wdata;
                end
                
                MEM_ADDR_ADDR: begin
                    mem_addr <= wdata;
                end
                
                EXTRA_INFO_ADDR: begin
                    extra_info <= wdata;
                end
                
                DESCRIPTOR_ADDR: begin
                    descriptor_addr <= wdata;
                end
                
                ERROR_STATUS_ADDR: begin
                    // W1C (Write 1 to Clear) for error bits
                    if (wdata[0]) error_bus       <= 1'b0;
                    if (wdata[1]) error_timeout   <= 1'b0;
                    if (wdata[2]) error_alignment <= 1'b0;
                    if (wdata[3]) error_overflow  <= 1'b0;
                    if (wdata[4]) error_underflow <= 1'b0;
                end
                
                CONFIG_ADDR: begin
                    config_priority         <= wdata[1:0];
                    config_auto_restart     <= wdata[2];
                    config_interrupt_enable <= wdata[3];
                    config_burst_size       <= wdata[5:4];
                    config_data_width       <= wdata[7:6];
                    config_descriptor_mode  <= wdata[8];
                end
            endcase
        end
        else begin
            // Auto-clear start_dma after 1 cycle (pulse)
            if (ctrl_start_dma)
                ctrl_start_dma <= 1'b0;
        end
    end

    //===========================================
    // Read Operation
    //===========================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata <= 32'h0;
        end 
        else if (rd_en) begin
            case (addr)
                INTR_ADDR: begin
                    rdata <= {intr_mask, intr_status};
                end
                
                CTRL_ADDR: begin
                    rdata <= {15'h0, ctrl_io_mem, ctrl_w_count, ctrl_start_dma};
                end
                
                IO_ADDR_ADDR: begin
                    rdata <= io_addr;
                end
                
                MEM_ADDR_ADDR: begin
                    rdata <= mem_addr;
                end
                
                EXTRA_INFO_ADDR: begin
                    rdata <= extra_info;
                end
                
                STATUS_ADDR: begin
                    rdata <= {16'h0, status_fifo_level, status_current_state,
                              3'b0, status_paused, status_error, status_done, status_busy};
                end
                
                TRANSFER_COUNT_ADDR: begin
                    rdata <= transfer_count;
                end
                
                DESCRIPTOR_ADDR: begin
                    rdata <= descriptor_addr;
                end
                
                ERROR_STATUS_ADDR: begin
                    rdata <= {error_addr_offset, error_code, 3'b0,
                              error_underflow, error_overflow, error_alignment,
                              error_timeout, error_bus};
                end
                
                CONFIG_ADDR: begin
                    rdata <= {23'h0, config_descriptor_mode, config_data_width,
                              config_burst_size, config_interrupt_enable,
                              config_auto_restart, config_priority};
                end
                
                default: begin
                    rdata <= 32'h0;
                end
            endcase
        end
    end

    //===========================================
    // DMA Logic (Status Updates)
    //===========================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            intr_status          <= 16'h0;
            status_busy          <= 1'b0;
            status_done          <= 1'b0;
            status_error         <= 1'b0;
            status_paused        <= 1'b0;
            status_current_state <= 4'h0;
            status_fifo_level    <= 8'h0;
            transfer_count       <= 32'h0;
            error_code           <= 8'h0;
            error_addr_offset    <= 16'h0;
        end
        else begin
            // Simplified DMA state machine
            if (ctrl_start_dma) begin
                status_busy          <= 1'b1;
                status_done          <= 1'b0;
                status_current_state <= 4'h1; // ACTIVE
                transfer_count       <= 32'h0;
            end
            else if (status_busy) begin
                // Simulate transfer
                transfer_count <= transfer_count + 1;
                
                // Complete after w_count transfers
                if (transfer_count >= {17'h0, ctrl_w_count}) begin
                    status_busy          <= 1'b0;
                    status_done          <= 1'b1;
                    status_current_state <= 4'h0; // IDLE
                    intr_status[0]       <= 1'b1; // Transfer done interrupt
                end
                
                // Simulate FIFO level
                status_fifo_level <= transfer_count[7:0];
            end
            
            // Clear done flag on next start
            if (ctrl_start_dma && status_done)
                status_done <= 1'b0;
        end
    end

endmodule
