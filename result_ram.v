//==============================================================================
// Module: result_ram
// Description: Simple RAM to store computation results
// 256 entries of 32-bit data
//==============================================================================

module result_ram (
    input wire clk,
    input wire rst_n,
    
    // Write port
    input wire [7:0] write_addr,
    input wire [31:0] write_data,
    input wire write_enable,
    
    // Read port
    input wire [7:0] read_addr,
    output reg [31:0] read_data
);

    // RAM storage
    reg [31:0] memory [0:255];
    
    // Initialize to zero
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 32'd0;
        end
    end
    
    // Write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset handled by initial block
        end else begin
            if (write_enable) begin
                memory[write_addr] <= write_data;
            end
        end
    end
    
    // Read logic (synchronous read)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_data <= 32'd0;
        end else begin
            read_data <= memory[read_addr];
        end
    end

endmodule