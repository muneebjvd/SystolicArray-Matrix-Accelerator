//==============================================================================
// Module: multi_operand_adder
// Description: Three implementations of 4-operand addition
// 1. Linear (sequential)
// 2. Tree (balanced)
// 3. Carry-save (parallel)
//==============================================================================

//==============================================================================
// Implementation 1: Linear Adder Tree
//==============================================================================
module adder_linear (
    input wire clk,
    input wire [31:0] a, b, c, d,
    output reg [31:0] sum
);

    reg [31:0] sum_ab;
    reg [31:0] sum_abc;
    
    always @(posedge clk) begin
        // Stage 1
        sum_ab <= a + b;
        
        // Stage 2
        sum_abc <= sum_ab + c;
        
        // Stage 3
        sum <= sum_abc + d;
    end

endmodule

//==============================================================================
// Implementation 2: Tree Adder (Balanced)
//==============================================================================
module adder_tree (
    input wire clk,
    input wire [31:0] a, b, c, d,
    output reg [31:0] sum
);

    reg [31:0] sum_ab, sum_cd;
    reg [31:0] sum_final;
    
    always @(posedge clk) begin
        // Stage 1: Add in parallel
        sum_ab <= a + b;
        sum_cd <= c + d;
        
        // Stage 2: Add results
        sum_final <= sum_ab + sum_cd;
        
        // Stage 3: Output
        sum <= sum_final;
    end

endmodule

//==============================================================================
// Implementation 3: Carry-Save Adder
// Uses carry-save logic for parallel reduction
//==============================================================================
module adder_carry_save (
    input wire clk,
    input wire [31:0] a, b, c, d,
    output reg [31:0] sum
);

    // Carry-save adder for 4 inputs
    wire [31:0] sum1, carry1;
    wire [31:0] sum2, carry2;
    wire [31:0] final_sum, final_carry;
    
    // First CSA: a + b + c
    assign sum1 = a ^ b ^ c;
    assign carry1 = ((a & b) | (b & c) | (a & c)) << 1;
    
    // Second CSA: sum1 + carry1 + d
    assign sum2 = sum1 ^ carry1 ^ d;
    assign carry2 = ((sum1 & carry1) | (carry1 & d) | (sum1 & d)) << 1;
    
    // Final addition: sum2 + carry2
    assign final_sum = sum2 + carry2;
    
    always @(posedge clk) begin
        sum <= final_sum;
    end

endmodule

//==============================================================================
// Top-level wrapper for comparison
//==============================================================================
module multi_operand_adder (
    input wire clk,
    input wire rst_n,
    input wire [1:0] mode,  // 00=linear, 01=tree, 10=carry-save
    input wire [31:0] in_a, in_b, in_c, in_d,
    output reg [31:0] result
);

    wire [31:0] linear_out, tree_out, cs_out;
    
    adder_linear linear (
        .clk(clk),
        .a(in_a), .b(in_b), .c(in_c), .d(in_d),
        .sum(linear_out)
    );
    
    adder_tree tree (
        .clk(clk),
        .a(in_a), .b(in_b), .c(in_c), .d(in_d),
        .sum(tree_out)
    );
    
    adder_carry_save cs (
        .clk(clk),
        .a(in_a), .b(in_b), .c(in_c), .d(in_d),
        .sum(cs_out)
    );
    
    // Multiplexer
    always @(*) begin
        case (mode)
            2'b00: result = linear_out;
            2'b01: result = tree_out;
            2'b10: result = cs_out;
            default: result = linear_out;
        endcase
    end

endmodule