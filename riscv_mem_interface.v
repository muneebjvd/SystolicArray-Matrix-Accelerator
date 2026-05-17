//==============================================================================
// Module: riscv_mem_interface
// Description: Memory-mapped interface for RISC-V core
// Base address: 0x80000000 (configurable)
// Register map:
//   0x00: DATA_IN - Write data here
//   0x04: CONTROL - Control/status register
//   0x08: DATA_OUT - Read result data
//==============================================================================

module riscv_mem_interface (
    input wire clk,
    input wire rst_n,
    
    // Memory interface (simplified)
    input wire [31:0] mem_addr,
    input wire [31:0] mem_wdata,
    input wire mem_write,
    input wire mem_read,
    output reg [31:0] mem_rdata,
    output reg mem_ready,
    
    // Internal interface
    output reg [15:0] data_to_accelerator,
    output reg data_valid,
    input wire [15:0] data_from_accelerator,
    input wire result_ready
);

    // Base address for this peripheral
    localparam BASE_ADDR = 32'h80000000;
    
    // Register offsets
    localparam DATA_IN_OFFSET  = 32'h00000000;
    localparam CONTROL_OFFSET  = 32'h00000004;
    localparam DATA_OUT_OFFSET = 32'h00000008;
    
    // Internal registers
    reg [31:0] control_reg;
    
    // Address decoding
    wire addr_match;
    wire data_in_select;
    wire control_select;
    wire data_out_select;
    
    assign addr_match = (mem_addr[31:4] == BASE_ADDR[31:4]);
    assign data_in_select = addr_match && (mem_addr[3:0] == DATA_IN_OFFSET[3:0]);
    assign control_select = addr_match && (mem_addr[3:0] == CONTROL_OFFSET[3:0]);
    assign data_out_select = addr_match && (mem_addr[3:0] == DATA_OUT_OFFSET[3:0]);
    
    // Write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_to_accelerator <= 16'd0;
            data_valid <= 1'b0;
            control_reg <= 32'd0;
        end else begin
            data_valid <= 1'b0; // Pulse
            
            if (mem_write && addr_match) begin
                if (data_in_select) begin
                    data_to_accelerator <= mem_wdata[15:0];
                    data_valid <= 1'b1;
                end else if (control_select) begin
                    control_reg <= mem_wdata;
                end
            end
        end
    end
    
    // Read logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_rdata <= 32'd0;
            mem_ready <= 1'b0;
        end else begin
            mem_ready <= 1'b0;
            
            if (mem_read && addr_match) begin
                mem_ready <= 1'b1;
                
                if (data_out_select) begin
                    mem_rdata <= {16'd0, data_from_accelerator};
                end else if (control_select) begin
                    mem_rdata <= control_reg;
                end else begin
                    mem_rdata <= 32'd0;
                end
            end
        end
    end

endmodule