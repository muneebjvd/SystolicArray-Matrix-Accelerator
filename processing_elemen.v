//==============================================================================
// Module: processing_element
// Description: Basic PE for systolic array
// Operation: acc = acc + (a_in * b_in)
// Dataflow: a flows right, b flows down, result accumulates
//==============================================================================

module processing_element (
    input wire clk,
    input wire rst_n,
    input wire enable,
    
    // Data inputs
    input wire [15:0] a_in,
    input wire [15:0] b_in,
    
    // Data outputs (pass-through with delay)
    output reg [15:0] a_out,
    output reg [15:0] b_out,
    
    // Accumulation
    input wire acc_clear,
    output reg [31:0] acc_out
);

    // Internal multiply result
    wire [31:0] mult_result;
    
    // Multiplier
    assign mult_result = a_in * b_in;
    
    // Pipeline and accumulate
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out <= 16'd0;
            b_out <= 16'd0;
            acc_out <= 32'd0;
        end else if (enable) begin
            // Pass data through (with 1-cycle delay)
            a_out <= a_in;
            b_out <= b_in;
            
            // Accumulate
            if (acc_clear) begin
                acc_out <= mult_result;
            end else begin
                acc_out <= acc_out + mult_result;
            end
        end
    end

endmodule