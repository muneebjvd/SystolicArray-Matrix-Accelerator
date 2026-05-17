//==============================================================================
// Module: systolic_array_4x4
// Description: 4x4 systolic array for matrix multiplication
// C = A × B where A, B, C are 4x4 matrices
//==============================================================================

module systolic_array_4x4 (
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire acc_clear,
    
    // Input matrix A (horizontal input - 4 rows)
    input wire [15:0] a_row0,
    input wire [15:0] a_row1,
    input wire [15:0] a_row2,
    input wire [15:0] a_row3,
    
    // Input matrix B (vertical input - 4 columns)
    input wire [15:0] b_col0,
    input wire [15:0] b_col1,
    input wire [15:0] b_col2,
    input wire [15:0] b_col3,
    
    // Output accumulated results (16 elements)
    output wire [31:0] c00, c01, c02, c03,
    output wire [31:0] c10, c11, c12, c13,
    output wire [31:0] c20, c21, c22, c23,
    output wire [31:0] c30, c31, c32, c33
);

    // Internal wiring between PEs
    // Horizontal connections (a flows right)
    wire [15:0] a_h00, a_h01, a_h02, a_h03;
    wire [15:0] a_h10, a_h11, a_h12, a_h13;
    wire [15:0] a_h20, a_h21, a_h22, a_h23;
    wire [15:0] a_h30, a_h31, a_h32, a_h33;
    
    // Vertical connections (b flows down)
    wire [15:0] b_v00, b_v10, b_v20, b_v30;
    wire [15:0] b_v01, b_v11, b_v21, b_v31;
    wire [15:0] b_v02, b_v12, b_v22, b_v32;
    wire [15:0] b_v03, b_v13, b_v23, b_v33;
    
    // Row 0 PEs
    processing_element pe00 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_row0), .b_in(b_col0),
        .a_out(a_h00), .b_out(b_v00), .acc_out(c00)
    );
    
    processing_element pe01 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_h00), .b_in(b_col1),
        .a_out(a_h01), .b_out(b_v01), .acc_out(c01)
    );
    
    processing_element pe02 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_h01), .b_in(b_col2),
        .a_out(a_h02), .b_out(b_v02), .acc_out(c02)
    );
    
    processing_element pe03 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_h02), .b_in(b_col3),
        .a_out(a_h03), .b_out(b_v03), .acc_out(c03)
    );
    
    // Row 1 PEs
    processing_element pe10 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_row1), .b_in(b_v00),
        .a_out(a_h10), .b_out(b_v10), .acc_out(c10)
    );
    
    processing_element pe11 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_h10), .b_in(b_v01),
        .a_out(a_h11), .b_out(b_v11), .acc_out(c11)
    );
    
    processing_element pe12 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_h11), .b_in(b_v02),
        .a_out(a_h12), .b_out(b_v12), .acc_out(c12)
    );
    
    processing_element pe13 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_h12), .b_in(b_v03),
        .a_out(a_h13), .b_out(b_v13), .acc_out(c13)
    );
    
    // Row 2 PEs
    processing_element pe20 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_row2), .b_in(b_v10),
        .a_out(a_h20), .b_out(b_v20), .acc_out(c20)
    );
    
    processing_element pe21 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_h20), .b_in(b_v11),
        .a_out(a_h21), .b_out(b_v21), .acc_out(c21)
    );
    
    processing_element pe22 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_h21), .b_in(b_v12),
        .a_out(a_h22), .b_out(b_v22), .acc_out(c22)
    );
    
    processing_element pe23 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_h22), .b_in(b_v13),
        .a_out(a_h23), .b_out(b_v23), .acc_out(c23)
    );
    
    // Row 3 PEs
    processing_element pe30 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_row3), .b_in(b_v20),
        .a_out(a_h30), .b_out(b_v30), .acc_out(c30)
    );
    
    processing_element pe31 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_h30), .b_in(b_v21),
        .a_out(a_h31), .b_out(b_v31), .acc_out(c31)
    );
    
    processing_element pe32 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_h31), .b_in(b_v22),
        .a_out(a_h32), .b_out(b_v32), .acc_out(c32)
    );
    
    processing_element pe33 (
        .clk(clk), .rst_n(rst_n), .enable(enable), .acc_clear(acc_clear),
        .a_in(a_h32), .b_in(b_v23),
        .a_out(a_h33), .b_out(b_v33), .acc_out(c33)
    );

endmodule