//==============================================================================
// Module: uart_output_buffer
// Description: Converts 32-bit results to bytes for UART transmission
// Sends 4 bytes per result (big-endian)
//==============================================================================

module uart_output_buffer (
    input wire clk,
    input wire rst_n,
    
    // Input: 32-bit result
    input wire [31:0] result_data,
    input wire result_valid,
    
    // Output: to UART TX
    output reg [7:0] tx_byte,
    output reg tx_valid,
    input wire tx_busy
);

    // State machine
    localparam IDLE   = 3'd0;
    localparam BYTE0  = 3'd1;  // MSB
    localparam BYTE1  = 3'd2;
    localparam BYTE2  = 3'd3;
    localparam BYTE3  = 3'd4;  // LSB
    localparam WAIT   = 3'd5;
    
    reg [2:0] state;
    reg [31:0] data_buffer;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            data_buffer <= 32'd0;
            tx_byte <= 8'd0;
            tx_valid <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx_valid <= 1'b0;
                    if (result_valid) begin
                        data_buffer <= result_data;
                        state <= BYTE0;
                    end
                end
                
                BYTE0: begin
                    if (!tx_busy) begin
                        tx_byte <= data_buffer[31:24];
                        tx_valid <= 1'b1;
                        state <= WAIT;
                    end
                end
                
                WAIT: begin
                    tx_valid <= 1'b0;
                    if (tx_busy) begin
                        // Wait for transmission to complete
                    end else begin
                        // Move to next byte
                        if (state == WAIT) begin
                            if (tx_byte == data_buffer[31:24])
                                state <= BYTE1;
                            else if (tx_byte == data_buffer[23:16])
                                state <= BYTE2;
                            else if (tx_byte == data_buffer[15:8])
                                state <= BYTE3;
                            else
                                state <= IDLE;
                        end
                    end
                end
                
                BYTE1: begin
                    if (!tx_busy) begin
                        tx_byte <= data_buffer[23:16];
                        tx_valid <= 1'b1;
                        state <= WAIT;
                    end
                end
                
                BYTE2: begin
                    if (!tx_busy) begin
                        tx_byte <= data_buffer[15:8];
                        tx_valid <= 1'b1;
                        state <= WAIT;
                    end
                end
                
                BYTE3: begin
                    if (!tx_busy) begin
                        tx_byte <= data_buffer[7:0];
                        tx_valid <= 1'b1;
                        state <= IDLE;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule