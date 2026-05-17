//==============================================================================
// Module: output_controller
// Description: Controls output routing and sequencing
// output_select: 00=RAM only, 01=UART, 10=RISC-V, 11=All
//==============================================================================

module output_controller (
    input wire clk,
    input wire rst_n,
    
    input wire [1:0] output_select,
    
    // Input from systolic array (16 results)
    input wire [31:0] c00, c01, c02, c03,
    input wire [31:0] c10, c11, c12, c13,
    input wire [31:0] c20, c21, c22, c23,
    input wire [31:0] c30, c31, c32, c33,
    input wire results_ready,
    
    // To RAM
    output reg [7:0] ram_addr,
    output reg [31:0] ram_data,
    output reg ram_write,
    
    // To UART output buffer
    output reg [31:0] uart_result,
    output reg uart_result_valid,
    
    // To RISC-V interface
    output reg [31:0] riscv_result,
    output reg riscv_result_valid,
    
    output reg done
);

    // State machine
    localparam IDLE = 2'd0;
    localparam STORE = 2'd1;
    localparam TRANSMIT = 2'd2;
    localparam FINISH = 2'd3;
    
    reg [1:0] state;
    reg [4:0] element_count;
    
    // Array of results for easy indexing
    reg [31:0] results [0:15];
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            element_count <= 5'd0;
            ram_addr <= 8'd0;
            ram_data <= 32'd0;
            ram_write <= 1'b0;
            uart_result <= 32'd0;
            uart_result_valid <= 1'b0;
            riscv_result <= 32'd0;
            riscv_result_valid <= 1'b0;
            done <= 1'b0;
        end else begin
            // Load results into array
            results[0] <= c00; results[1] <= c01;
            results[2] <= c02; results[3] <= c03;
            results[4] <= c10; results[5] <= c11;
            results[6] <= c12; results[7] <= c13;
            results[8] <= c20; results[9] <= c21;
            results[10] <= c22; results[11] <= c23;
            results[12] <= c30; results[13] <= c31;
            results[14] <= c32; results[15] <= c33;
            
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    uart_result_valid <= 1'b0;
                    riscv_result_valid <= 1'b0;
                    ram_write <= 1'b0;
                    
                    if (results_ready) begin
                        element_count <= 5'd0;
                        state <= STORE;
                    end
                end
                
                STORE: begin
                    if (element_count < 16) begin
                        // Write to RAM
                        ram_addr <= element_count[7:0];
                        ram_data <= results[element_count];
                        ram_write <= 1'b1;
                        
                        // Also send to UART if selected
                        if (output_select[0]) begin
                            uart_result <= results[element_count];
                            uart_result_valid <= 1'b1;
                        end
                        
                        // Or to RISC-V if selected
                        if (output_select[1]) begin
                            riscv_result <= results[element_count];
                            riscv_result_valid <= 1'b1;
                        end
                        
                        element_count <= element_count + 1;
                    end else begin
                        ram_write <= 1'b0;
                        uart_result_valid <= 1'b0;
                        riscv_result_valid <= 1'b0;
                        state <= FINISH;
                    end
                end
                
                FINISH: begin
                    done <= 1'b1;
                    state <= IDLE;
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule