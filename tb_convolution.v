//==============================================================================
// Testbench: tb_convolution
// Description: Test 2D convolution module
//==============================================================================

module tb_convolution;

    reg clk;
    reg rst_n;
    reg start;
    
    // Input 4x4
    reg [15:0] in00, in01, in02, in03;
    reg [15:0] in10, in11, in12, in13;
    reg [15:0] in20, in21, in22, in23;
    reg [15:0] in30, in31, in32, in33;
    
    // Kernel 2x2
    reg [15:0] k00, k01, k10, k11;
    
    // Output 3x3
    wire [31:0] out00, out01, out02;
    wire [31:0] out10, out11, out12;
    wire [31:0] out20, out21, out22;
    wire done;
    
    // Instantiate convolution module
    convolution_2d conv (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        
        .in00(in00), .in01(in01), .in02(in02), .in03(in03),
        .in10(in10), .in11(in11), .in12(in12), .in13(in13),
        .in20(in20), .in21(in21), .in22(in22), .in23(in23),
        .in30(in30), .in31(in31), .in32(in32), .in33(in33),
        
        .k00(k00), .k01(k01), .k10(k10), .k11(k11),
        
        .out00(out00), .out01(out01), .out02(out02),
        .out10(out10), .out11(out11), .out12(out12),
        .out20(out20), .out21(out21), .out22(out22),
        
        .done(done)
    );
    
    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test
    initial begin
        rst_n = 0;
        start = 0;
        
        // Initialize input
        in00 = 16'd1;  in01 = 16'd2;  in02 = 16'd3;  in03 = 16'd4;
        in10 = 16'd5;  in11 = 16'd6;  in12 = 16'd7;  in13 = 16'd8;
        in20 = 16'd9;  in21 = 16'd10; in22 = 16'd11; in23 = 16'd12;
        in30 = 16'd13; in31 = 16'd14; in32 = 16'd15; in33 = 16'd16;
        
        #20 rst_n = 1;
        #10;
        
        // Test 1: Identity kernel
        k00 = 16'd1; k01 = 16'd0;
        k10 = 16'd0; k11 = 16'd0;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        wait(done);
        #50;
        
        // Test 2: Edge detection kernel
        k00 = 16'd1;  k01 = -16'd1;
        k10 = -16'd1; k11 = 16'd1;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        wait(done);
        #50;
        
        // Test 3: Averaging kernel
        k00 = 16'd1; k01 = 16'd1;
        k10 = 16'd1; k11 = 16'd1;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        wait(done);
        #100;
        
    end

endmodule