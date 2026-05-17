//==============================================================================
// Testbench: tb_processing_element
// Description: Test basic PE functionality
//==============================================================================

module tb_processing_element;

    reg clk;
    reg rst_n;
    reg enable;
    reg [15:0] a_in, b_in;
    reg acc_clear;
    wire [15:0] a_out, b_out;
    wire [31:0] acc_out;
    
    // Instantiate PE
    processing_element pe (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .a_in(a_in),
        .b_in(b_in),
        .a_out(a_out),
        .b_out(b_out),
        .acc_clear(acc_clear),
        .acc_out(acc_out)
    );
    
    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test
    initial begin
        rst_n = 0;
        enable = 0;
        a_in = 0;
        b_in = 0;
        acc_clear = 0;
        
        #20 rst_n = 1;
        #10;
        
        // Test 1: Single MAC operation
        @(posedge clk);
        enable = 1;
        acc_clear = 1;
        a_in = 16'd5;
        b_in = 16'd3;
        
        @(posedge clk);
        acc_clear = 0;
        // Expected acc_out = 5*3 = 15
        
        #20;
        
        // Test 2: Accumulate another value
        @(posedge clk);
        a_in = 16'd4;
        b_in = 16'd2;
        // Expected acc_out = 15 + 4*2 = 23
        
        #20;
        
        // Test 3: Clear and restart
        @(posedge clk);
        acc_clear = 1;
        a_in = 16'd10;
        b_in = 16'd10;
        
        @(posedge clk);
        acc_clear = 0;
        // Expected acc_out = 100
        
        #50;
        
    end

endmodule