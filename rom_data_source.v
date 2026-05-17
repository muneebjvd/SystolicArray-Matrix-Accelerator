//==============================================================================
// Module: rom_data_source
// Description: ROM-based data source for test vectors
// Simple, portable Verilog - no system tasks in synthesizable code
//==============================================================================

module rom_data_source (
    input wire clk,
    input wire rst_n,
    input wire read_enable,
    input wire [7:0] address,
    output reg [15:0] data_out,
    output reg data_valid
);

    // ROM storage - 256 entries of 16-bit data
    // Initialize with test patterns
    reg [15:0] rom_memory [0:255];
    
    // Initialize ROM with test data
    integer i;
    initial begin
        // Matrix A: 4x4 matrix (indices 0-15)
        rom_memory[0]  = 16'd1;    rom_memory[1]  = 16'd2;
        rom_memory[2]  = 16'd3;    rom_memory[3]  = 16'd4;
        rom_memory[4]  = 16'd5;    rom_memory[5]  = 16'd6;
        rom_memory[6]  = 16'd7;    rom_memory[7]  = 16'd8;
        rom_memory[8]  = 16'd9;    rom_memory[9]  = 16'd10;
        rom_memory[10] = 16'd11;   rom_memory[11] = 16'd12;
        rom_memory[12] = 16'd13;   rom_memory[13] = 16'd14;
        rom_memory[14] = 16'd15;   rom_memory[15] = 16'd16;
        
        // Matrix B: 4x4 matrix (indices 16-31)
        rom_memory[16] = 16'd1;    rom_memory[17] = 16'd0;
        rom_memory[18] = 16'd0;    rom_memory[19] = 16'd0;
        rom_memory[20] = 16'd0;    rom_memory[21] = 16'd1;
        rom_memory[22] = 16'd0;    rom_memory[23] = 16'd0;
        rom_memory[24] = 16'd0;    rom_memory[25] = 16'd0;
        rom_memory[26] = 16'd1;    rom_memory[27] = 16'd0;
        rom_memory[28] = 16'd0;    rom_memory[29] = 16'd0;
        rom_memory[30] = 16'd0;    rom_memory[31] = 16'd1;
        
        // Initialize rest to zero
        for (i = 32; i < 256; i = i + 1) begin
            rom_memory[i] = 16'd0;
        end
    end
    
    // Read logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 16'd0;
            data_valid <= 1'b0;
        end else begin
            if (read_enable) begin
                data_out <= rom_memory[address];
                data_valid <= 1'b1;
            end else begin
                data_valid <= 1'b0;
            end
        end
    end

endmodule