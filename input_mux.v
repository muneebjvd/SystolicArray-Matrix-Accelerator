//==============================================================================
// Module: input_mux
// Description: Multiplexes between different input sources
// input_select: 00=ROM, 01=UART, 10=RISC-V, 11=Reserved
//==============================================================================

module input_mux (
    input wire [1:0] input_select,
    
    // ROM input
    input wire [15:0] rom_data,
    input wire rom_valid,
    
    // UART input
    input wire [15:0] uart_data,
    input wire uart_valid,
    
    // RISC-V input
    input wire [15:0] riscv_data,
    input wire riscv_valid,
    
    // Output to processing
    output reg [15:0] data_out,
    output reg data_valid
);

    always @(*) begin
        case (input_select)
            2'b00: begin  // ROM
                data_out = rom_data;
                data_valid = rom_valid;
            end
            
            2'b01: begin  // UART
                data_out = uart_data;
                data_valid = uart_valid;
            end
            
            2'b10: begin  // RISC-V
                data_out = riscv_data;
                data_valid = riscv_valid;
            end
            
            default: begin
                data_out = 16'd0;
                data_valid = 1'b0;
            end
        endcase
    end

endmodule