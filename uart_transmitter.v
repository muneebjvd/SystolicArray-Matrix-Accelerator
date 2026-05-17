//==============================================================================
// Module: uart_transmitter
// Description: Simple UART transmitter (8N1 format)
//==============================================================================

module uart_transmitter (
    input wire clk,
    input wire rst_n,
    input wire [7:0] tx_data,
    input wire tx_start,
    output reg tx_serial,
    output reg tx_busy
);

    localparam CLKS_PER_BIT = 434;
    
    localparam IDLE      = 3'd0;
    localparam START_BIT = 3'd1;
    localparam DATA_BITS = 3'd2;
    localparam STOP_BIT  = 3'd3;
    localparam CLEANUP   = 3'd4;
    
    reg [2:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] tx_byte;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
            tx_byte <= 8'd0;
            tx_serial <= 1'b1;
            tx_busy <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx_serial <= 1'b1; // Idle high
                    tx_busy <= 1'b0;
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    
                    if (tx_start) begin
                        tx_byte <= tx_data;
                        tx_busy <= 1'b1;
                        state <= START_BIT;
                    end
                end
                
                START_BIT: begin
                    tx_serial <= 1'b0; // Start bit = 0
                    
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 16'd0;
                        state <= DATA_BITS;
                    end
                end
                
                DATA_BITS: begin
                    tx_serial <= tx_byte[bit_index];
                    
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 16'd0;
                        
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 3'd0;
                            state <= STOP_BIT;
                        end
                    end
                end
                
                STOP_BIT: begin
                    tx_serial <= 1'b1; // Stop bit = 1
                    
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 16'd0;
                        state <= CLEANUP;
                    end
                end
                
                CLEANUP: begin
                    tx_busy <= 1'b0;
                    state <= IDLE;
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule