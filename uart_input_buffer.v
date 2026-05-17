//==============================================================================
// Module: uart_input_buffer
// Description: Buffers UART input bytes into 16-bit matrix elements
// Protocol: Receive 2 bytes per element (high byte first)
//==============================================================================

module uart_input_buffer (
    input wire clk,
    input wire rst_n,
    input wire [7:0] uart_rx_data,
    input wire uart_rx_valid,
    output reg [15:0] data_out,
    output reg data_ready,
    output reg [7:0] element_count
);

    reg byte_toggle; // 0 = expecting high byte, 1 = expecting low byte
    reg [7:0] high_byte;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_toggle <= 1'b0;
            high_byte <= 8'd0;
            data_out <= 16'd0;
            data_ready <= 1'b0;
            element_count <= 8'd0;
        end else begin
            data_ready <= 1'b0; // Pulse
            
            if (uart_rx_valid) begin
                if (byte_toggle == 1'b0) begin
                    // Receiving high byte
                    high_byte <= uart_rx_data;
                    byte_toggle <= 1'b1;
                end else begin
                    // Receiving low byte - complete element
                    data_out <= {high_byte, uart_rx_data};
                    data_ready <= 1'b1;
                    byte_toggle <= 1'b0;
                    element_count <= element_count + 1;
                end
            end
        end
    end

endmodule