//==============================================================================
// Module: configurable_systolic_array
// Description: Systolic array with configurable size (2x2 or 4x4)
// Config: 0 = 2x2 mode, 1 = 4x4 mode
//==============================================================================

module configurable_systolic_array (
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire acc_clear,
    input wire config_4x4, // 1 = 4x4, 0 = 2x2
    
    // Inputs (always provide 4x4, will use subset for 2x2)
    input wire [15:0] a_row0, a_row1, a_row2, a_row3,
    input wire [15:0] b_col0, b_col1, b_col2, b_col3,
    
    // Outputs (16 results, subset used for 2x2)
    output wire [31:0] c00, c01, c02, c03,
    output wire [31:0] c10, c11, c12, c13,
    output wire [31:0] c20, c21, c22, c23,
    output wire [31:0] c30, c31, c32, c33
);

    // Internal enable signals
    wire en_row0, en_row1, en_row2, en_row3;
    wire en_col0, en_col1, en_col2, en_col3;
    
    // In 2x2 mode, only enable first 2 rows and columns
    assign en_row0 = enable;
    assign en_row1 = enable;
    assign en_row2 = enable & config_4x4;
    assign en_row3 = enable & config_4x4;
    
    assign en_col0 = enable;
    assign en_col1 = enable;
    assign en_col2 = enable & config_4x4;
    assign en_col3 = enable & config_4x4;
    
    // Horizontal and vertical wiring (same as 4x4 array)
    wire [15:0] a_h00, a_h01, a_h02, a_h03;
    wire [15:0] a_h10, a_h11, a_h12, a_h13;
    wire [15:0] a_h20, a_h21, a_h22, a_h23;
    wire [15:0] a_h30, a_h31, a_h32, a_h33;
    
    wire [15:0] b_v00, b_v10, b_v20, b_v30;
    wire [15:0] b_v01, b_v11, b_v21, b_v31;
    wire [15:0] b_v02, b_v12, b_v22, b_v32;
    wire [15:0] b_v03, b_v13, b_v23, b_v33;
    
    // Instantiate all 16 PEs with conditional enables
    // Row 0
    processing_element pe00 (
        .clk(clk), .rst_n(rst_n), .enable(en_row0 & en_col0), .acc_clear(acc_clear),
        .a_in(a_row0), .b_in(b_col0), .a_out(a_h00), .b_out(b_v00), .acc_out(c00)
    );
    
    processing_element pe01 (
        .clk(clk), .rst_n(rst_n), .enable(en_row0 & en_col1), .acc_clear(acc_clear),
        .a_in(a_h00), .b_in(b_col1), .a_out(a_h01), .b_out(b_v01), .acc_out(c01)
    );
    
    processing_element pe02 (
        .clk(clk), .rst_n(rst_n), .enable(en_row0 & en_col2), .acc_clear(acc_clear),
        .a_in(a_h01), .b_in(b_col2), .a_out(a_h02), .b_out(b_v02), .acc_out(c02)
    );
    
    processing_element pe03 (
        .clk(clk), .rst_n(rst_n), .enable(en_row0 & en_col3), .acc_clear(acc_clear),
        .a_in(a_h02), .b_in(b_col3), .a_out(a_h03), .b_out(b_v03), .acc_out(c03)
    );
    
    // Row 1
    processing_element pe10 (
        .clk(clk), .rst_n(rst_n), .enable(en_row1 & en_col0), .acc_clear(acc_clear),
        .a_in(a_row1), .b_in(b_v00), .a_out(a_h10), .b_out(b_v10), .acc_out(c10)
    );
    
    processing_element pe11 (
        .clk(clk), .rst_n(rst_n), .enable(en_row1 & en_col1), .acc_clear(acc_clear),
        .a_in(a_h10), .b_in(b_v01), .a_out(a_h11), .b_out(b_v11), .acc_out(c11)
    );
    
    processing_element pe12 (
        .clk(clk), .rst_n(rst_n), .enable(en_row1 & en_col2), .acc_clear(acc_clear),
        .a_in(a_h11), .b_in(b_v02), .a_out(a_h12), .b_out(b_v12), .acc_out(c12)
    );
    
    processing_element pe13 (
        .clk(clk), .rst_n(rst_n), .enable(en_row1 & en_col3), .acc_clear(acc_clear),
        .a_in(a_h12), .b_in(b_v03), .a_out(a_h13), .b_out(b_v13), .acc_out(c13)
    );
    
    // Row 2
    processing_element pe20 (
        .clk(clk), .rst_n(rst_n), .enable(en_row2 & en_col0), .acc_clear(acc_clear),
        .a_in(a_row2), .b_in(b_v10), .a_out(a_h20), .b_out(b_v20), .acc_out(c20)
    );
    
    processing_element pe21 (
        .clk(clk), .rst_n(rst_n), .enable(en_row2 & en_col1), .acc_clear(acc_clear),
        .a_in(a_h20), .b_in(b_v11), .a_out(a_h21), .b_out(b_v21), .acc_out(c21)
    );
    
    processing_element pe22 (
        .clk(clk), .rst_n(rst_n), .enable(en_row2 & en_col2), .acc_clear(acc_clear),
        .a_in(a_h21), .b_in(b_v12), .a_out(a_h22), .b_out(b_v22), .acc_out(c22)
    );
    
    processing_element pe23 (
        .clk(clk), .rst_n(rst_n), .enable(en_row2 & en_col3), .acc_clear(acc_clear),
        .a_in(a_h22), .b_in(b_v13), .a_out(a_h23), .b_out(b_v23), .acc_out(c23)
    );
    
    // Row 3
    processing_element pe30 (
        .clk(clk), .rst_n(rst_n), .enable(en_row3 & en_col0), .acc_clear(acc_clear),
        .a_in(a_row3), .b_in(b_v20), .a_out(a_h30), .b_out(b_v30), .acc_out(c30)
    );
    
    processing_element pe31 (
        .clk(clk), .rst_n(rst_n), .enable(en_row3 & en_col1), .acc_clear(acc_clear),
        .a_in(a_h30), .b_in(b_v21), .a_out(a_h31), .b_out(b_v31), .acc_out(c31)
    );
    
    processing_element pe32 (
        .clk(clk), .rst_n(rst_n), .enable(en_row3 & en_col2), .acc_clear(acc_clear),
        .a_in(a_h31), .b_in(b_v22), .a_out(a_h32), .b_out(b_v32), .acc_out(c32)
    );
    
    processing_element pe33 (
        .clk(clk), .rst_n(rst_n), .enable(en_row3 & en_col3), .acc_clear(acc_clear),
        .a_in(a_h32), .b_in(b_v23), .a_out(a_h33), .b_out(b_v33), .acc_out(c33)
    );

endmodule