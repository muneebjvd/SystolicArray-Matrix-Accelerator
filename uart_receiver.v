//==============================================================================
// Module: uart_receiver
// Description: Simple UART receiver (8N1 format)
// Baud rate configurable via CLKS_PER_BIT parameter
//==============================================================================

module uart_receiver (
    input wire clk,
    input wire rst_n,
    input wire rx_serial,
    output reg [7:0] rx_data,
    output reg rx_valid
);

    // For 50MHz clock, 9600 baud: 50000000/9600 = 5208 clocks per bit
    // For simulation, use smaller value
    localparam CLKS_PER_BIT = 434; // Adjust based on your clock frequency
    
    // State machine states
    localparam IDLE         = 3'd0;
    localparam START_BIT    = 3'd1;
    localparam DATA_BITS    = 3'd2;
    localparam STOP_BIT     = 3'd3;
    localparam CLEANUP      = 3'd4;
    
    reg [2:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] rx_byte;
    
    // UART receiver state machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
            rx_byte <= 8'd0;
            rx_data <= 8'd0;
            rx_valid <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    rx_valid <= 1'b0;
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    
                    // Wait for start bit (rx_serial goes low)
                    if (rx_serial == 1'b0) begin
                        state <= START_BIT;
                    end
                end
                
                START_BIT: begin
                    // Wait in middle of start bit
                    if (clk_count == (CLKS_PER_BIT - 1) / 2) begin
                        if (rx_serial == 1'b0) begin
                            clk_count <= 16'd0;
                            state <= DATA_BITS;
                        end else begin
                            state <= IDLE; // False start
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                DATA_BITS: begin
                    // Sample in the middle of each bit
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 16'd0;
                        rx_byte[bit_index] <= rx_serial;
                        
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 3'd0;
                            state <= STOP_BIT;
                        end
                    end
                end
                
                STOP_BIT: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 16'd0;
                        rx_data <= rx_byte;
                        rx_valid <= 1'b1;
                        state <= CLEANUP;
                    end
                end
                
                CLEANUP: begin
                    state <= IDLE;
                    rx_valid <= 1'b0;
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule