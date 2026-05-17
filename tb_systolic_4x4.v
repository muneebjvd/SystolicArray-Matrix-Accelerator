//==============================================================================
// Testbench: tb_systolic_4x4
// Description: Comprehensive test for 4x4 systolic array
// Tests: Identity matrix, Simple multiplication, Zero matrix
//==============================================================================

module tb_systolic_4x4;

    reg clk;
    reg rst_n;
    reg start;
    
    // Matrix A (stored)
    reg [15:0] a00, a01, a02, a03;
    reg [15:0] a10, a11, a12, a13;
    reg [15:0] a20, a21, a22, a23;
    reg [15:0] a30, a31, a32, a33;
    
    // Matrix B (stored)
    reg [15:0] b00, b01, b02, b03;
    reg [15:0] b10, b11, b12, b13;
    reg [15:0] b20, b21, b22, b23;
    reg [15:0] b30, b31, b32, b33;
    
    // Controller outputs
    wire [15:0] a_row0, a_row1, a_row2, a_row3;
    wire [15:0] b_col0, b_col1, b_col2, b_col3;
    wire array_enable;
    wire acc_clear;
    wire done;
    
    // Results
    wire [31:0] c00, c01, c02, c03;
    wire [31:0] c10, c11, c12, c13;
    wire [31:0] c20, c21, c22, c23;
    wire [31:0] c30, c31, c32, c33;
    
    // Instantiate controller
    systolic_array_controller controller (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        
        .a00(a00), .a01(a01), .a02(a02), .a03(a03),
        .a10(a10), .a11(a11), .a12(a12), .a13(a13),
        .a20(a20), .a21(a21), .a22(a22), .a23(a23),
        .a30(a30), .a31(a31), .a32(a32), .a33(a33),
        
        .b00(b00), .b01(b01), .b02(b02), .b03(b03),
        .b10(b10), .b11(b11), .b12(b12), .b13(b13),
        .b20(b20), .b21(b21), .b22(b22), .b23(b23),
        .b30(b30), .b31(b31), .b32(b32), .b33(b33),
        
        .a_row0(a_row0), .a_row1(a_row1), .a_row2(a_row2), .a_row3(a_row3),
        .b_col0(b_col0), .b_col1(b_col1), .b_col2(b_col2), .b_col3(b_col3),
        
        .array_enable(array_enable),
        .acc_clear(acc_clear),
        .done(done)
    );
    
    // Instantiate array
    systolic_array_4x4 array (
        .clk(clk),
        .rst_n(rst_n),
        .enable(array_enable),
        .acc_clear(acc_clear),
        
        .a_row0(a_row0), .a_row1(a_row1), .a_row2(a_row2), .a_row3(a_row3),
        .b_col0(b_col0), .b_col1(b_col1), .b_col2(b_col2), .b_col3(b_col3),
        
        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test task
    task run_test;
        input [255:0] test_name;
        begin
            @(posedge clk);
            start = 1;
            
            @(posedge clk);
            start = 0;
            
            // Wait for completion
            wait(done);
            @(posedge clk);
            
            // Display nothing - check waveforms
        end
    endtask
    
    // Main test sequence
    initial begin
        // Initialize
        rst_n = 0;
        start = 0;
        
        #20 rst_n = 1;
        #20;
        
        // ====================================================================
        // TEST 1: Identity Matrix Multiplication
        // A × I = A
        // ====================================================================
        // Matrix A
        a00 = 16'd1;  a01 = 16'd2;  a02 = 16'd3;  a03 = 16'd4;
        a10 = 16'd5;  a11 = 16'd6;  a12 = 16'd7;  a13 = 16'd8;
        a20 = 16'd9;  a21 = 16'd10; a22 = 16'd11; a23 = 16'd12;
        a30 = 16'd13; a31 = 16'd14; a32 = 16'd15; a33 = 16'd16;
        
        // Identity matrix
        b00 = 16'd1; b01 = 16'd0; b02 = 16'd0; b03 = 16'd0;
        b10 = 16'd0; b11 = 16'd1; b12 = 16'd0; b13 = 16'd0;
        b20 = 16'd0; b21 = 16'd0; b22 = 16'd1; b23 = 16'd0;
        b30 = 16'd0; b31 = 16'd0; b32 = 16'd0; b33 = 16'd1;
        
        run_test("Identity Matrix Test");
        
        // Expected: C = A (same as input)
        #100;
        
        // ====================================================================
        // TEST 2: Simple 2x2 Multiplication
        // ====================================================================
        a00 = 16'd1; a01 = 16'd2; a02 = 16'd0; a03 = 16'd0;
        a10 = 16'd3; a11 = 16'd4; a12 = 16'd0; a13 = 16'd0;
        a20 = 16'd0; a21 = 16'd0; a22 = 16'd0; a23 = 16'd0;
        a30 = 16'd0; a31 = 16'd0; a32 = 16'd0; a33 = 16'd0;
        
        b00 = 16'd5; b01 = 16'd6; b02 = 16'd0; b03 = 16'd0;
        b10 = 16'd7; b11 = 16'd8; b12 = 16'd0; b13 = 16'd0;
        b20 = 16'd0; b21 = 16'd0; b22 = 16'd0; b23 = 16'd0;
        b30 = 16'd0; b31 = 16'd0; b32 = 16'd0; b33 = 16'd0;
        
        run_test("2x2 Multiplication");
        
        // Expected:
        // c00 = 1*5 + 2*7 = 19
        // c01 = 1*6 + 2*8 = 22
        // c10 = 3*5 + 4*7 = 43
        // c11 = 3*6 + 4*8 = 50
        #100;
        
        // ====================================================================
        // TEST 3: Zero Matrix
        // ====================================================================
        a00 = 16'd1; a01 = 16'd2; a02 = 16'd3; a03 = 16'd4;
        a10 = 16'd5; a11 = 16'd6; a12 = 16'd7; a13 = 16'd8;
        a20 = 16'd9; a21 = 16'd10; a22 = 16'd11; a23 = 16'd12;
        a30 = 16'd13; a31 = 16'd14; a32 = 16'd15; a33 = 16'd16;
        
        b00 = 16'd0; b01 = 16'd0; b02 = 16'd0; b03 = 16'd0;
        b10 = 16'd0; b11 = 16'd0; b12 = 16'd0; b13 = 16'd0;
        b20 = 16'd0; b21 = 16'd0; b22 = 16'd0; b23 = 16'd0;
        b30 = 16'd0; b31 = 16'd0; b32 = 16'd0; b33 = 16'd0;
        
        run_test("Zero Matrix Test");
        
        // Expected: All outputs = 0
        #100;
        
        #500;
        
    end

endmodule