//==============================================================================
// Module: systolic_array_controller
// Description: Controls data feeding into systolic array with proper skewing
// For 4x4 array, needs staggered input timing
//==============================================================================

module systolic_array_controller (
    input wire clk,
    input wire rst_n,
    input wire start,
    
    // Matrix A stored locally (row-major)
    input wire [15:0] a00, a01, a02, a03,
    input wire [15:0] a10, a11, a12, a13,
    input wire [15:0] a20, a21, a22, a23,
    input wire [15:0] a30, a31, a32, a33,
    
    // Matrix B stored locally (column-major)
    input wire [15:0] b00, b01, b02, b03,
    input wire [15:0] b10, b11, b12, b13,
    input wire [15:0] b20, b21, b22, b23,
    input wire [15:0] b30, b31, b32, b33,
    
    // Outputs to systolic array
    output reg [15:0] a_row0,
    output reg [15:0] a_row1,
    output reg [15:0] a_row2,
    output reg [15:0] a_row3,
    
    output reg [15:0] b_col0,
    output reg [15:0] b_col1,
    output reg [15:0] b_col2,
    output reg [15:0] b_col3,
    
    output reg array_enable,
    output reg acc_clear,
    output reg done
);

    reg [3:0] cycle_count;
    reg running;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_count <= 4'd0;
            running <= 1'b0;
            array_enable <= 1'b0;
            acc_clear <= 1'b0;
            done <= 1'b0;
            
            a_row0 <= 16'd0;
            a_row1 <= 16'd0;
            a_row2 <= 16'd0;
            a_row3 <= 16'd0;
            
            b_col0 <= 16'd0;
            b_col1 <= 16'd0;
            b_col2 <= 16'd0;
            b_col3 <= 16'd0;
        end else begin
            if (start && !running) begin
                running <= 1'b1;
                cycle_count <= 4'd0;
                done <= 1'b0;
                acc_clear <= 1'b1; // Clear on first cycle
                array_enable <= 1'b1;
            end else if (running) begin
                acc_clear <= 1'b0; // Only clear on first cycle
                
                cycle_count <= cycle_count + 1;
                
                // Feed data with proper skewing
                // For systolic array, data must be skewed properly
                case (cycle_count)
                    4'd0: begin
                        a_row0 <= a00; b_col0 <= b00;
                        a_row1 <= 16'd0; b_col1 <= 16'd0;
                        a_row2 <= 16'd0; b_col2 <= 16'd0;
                        a_row3 <= 16'd0; b_col3 <= 16'd0;
                    end
                    4'd1: begin
                        a_row0 <= a01; b_col0 <= b10;
                        a_row1 <= a10; b_col1 <= b01;
                        a_row2 <= 16'd0; b_col2 <= 16'd0;
                        a_row3 <= 16'd0; b_col3 <= 16'd0;
                    end
                    4'd2: begin
                        a_row0 <= a02; b_col0 <= b20;
                        a_row1 <= a11; b_col1 <= b11;
                        a_row2 <= a20; b_col2 <= b02;
                        a_row3 <= 16'd0; b_col3 <= 16'd0;
                    end
                    4'd3: begin
                        a_row0 <= a03; b_col0 <= b30;
                        a_row1 <= a12; b_col1 <= b21;
                        a_row2 <= a21; b_col2 <= b12;
                        a_row3 <= a30; b_col3 <= b03;
                    end
                    4'd4: begin
                        a_row0 <= 16'd0; b_col0 <= 16'd0;
                        a_row1 <= a13; b_col1 <= b31;
                        a_row2 <= a22; b_col2 <= b22;
                        a_row3 <= a31; b_col3 <= b13;
                    end
                    4'd5: begin
                        a_row0 <= 16'd0; b_col0 <= 16'd0;
                        a_row1 <= 16'd0; b_col1 <= 16'd0;
                        a_row2 <= a23; b_col2 <= b32;
                        a_row3 <= a32; b_col3 <= b23;
                    end
                    4'd6: begin
                        a_row0 <= 16'd0; b_col0 <= 16'd0;
                        a_row1 <= 16'd0; b_col1 <= 16'd0;
                        a_row2 <= 16'd0; b_col2 <= 16'd0;
                        a_row3 <= a33; b_col3 <= b33;
                    end
                    4'd7: begin
                        // Extra cycles for pipeline to complete
                        a_row0 <= 16'd0; b_col0 <= 16'd0;
                        a_row1 <= 16'd0; b_col1 <= 16'd0;
                        a_row2 <= 16'd0; b_col2 <= 16'd0;
                        a_row3 <= 16'd0; b_col3 <= 16'd0;
                    end
                    4'd8: begin
                        array_enable <= 1'b0;
                        running <= 1'b0;
                        done <= 1'b1;
                    end
                    default: begin
                        a_row0 <= 16'd0; b_col0 <= 16'd0;
                        a_row1 <= 16'd0; b_col1 <= 16'd0;
                        a_row2 <= 16'd0; b_col2 <= 16'd0;
                        a_row3 <= 16'd0; b_col3 <= 16'd0;
                    end
                endcase
            end
        end
    end

endmodule