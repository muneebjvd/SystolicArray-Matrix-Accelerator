//==============================================================================
// Module: convolution_2d (CORRECTED)
// Description: 2D Convolution using systolic array
// Maps convolution to matrix multiplication via im2col
// For 4x4 input and 2x2 kernel -> 3x3 output
//==============================================================================

module convolution_2d (
    input wire clk,
    input wire rst_n,
    input wire start,
    
    // Input feature map (4x4)
    input wire [15:0] in00, in01, in02, in03,
    input wire [15:0] in10, in11, in12, in13,
    input wire [15:0] in20, in21, in22, in23,
    input wire [15:0] in30, in31, in32, in33,
    
    // Convolution kernel (2x2)
    input wire [15:0] k00, k01,
    input wire [15:0] k10, k11,
    
    // Output feature map (3x3)
    output reg [31:0] out00, out01, out02,
    output reg [31:0] out10, out11, out12,
    output reg [31:0] out20, out21, out22,
    
    output reg done
);

    // State machine
    localparam IDLE = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam FINISH = 2'd2;
    
    reg [1:0] state;
    
    // CHANGED: Increased width to 5 bits to handle count up to 17
    reg [4:0] conv_count;
    
    // Temporary accumulation
    reg [31:0] temp_acc;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            conv_count <= 5'd0;
            done <= 1'b0;
            
            out00 <= 32'd0; out01 <= 32'd0; out02 <= 32'd0;
            out10 <= 32'd0; out11 <= 32'd0; out12 <= 32'd0;
            out20 <= 32'd0; out21 <= 32'd0; out22 <= 32'd0;
            
            temp_acc <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state <= COMPUTE;
                        conv_count <= 5'd0;
                    end
                end
                
                COMPUTE: begin
                    // Compute each output element
                    case (conv_count)
                        // Output (0,0)
                        5'd0: begin
                            temp_acc <= (in00 * k00) + (in01 * k01) + 
                                       (in10 * k10) + (in11 * k11);
                            conv_count <= conv_count + 1;
                        end
                        5'd1: begin
                            out00 <= temp_acc;
                            conv_count <= conv_count + 1;
                        end
                        
                        // Output (0,1)
                        5'd2: begin
                            temp_acc <= (in01 * k00) + (in02 * k01) + 
                                       (in11 * k10) + (in12 * k11);
                            conv_count <= conv_count + 1;
                        end
                        5'd3: begin
                            out01 <= temp_acc;
                            conv_count <= conv_count + 1;
                        end
                        
                        // Output (0,2)
                        5'd4: begin
                            temp_acc <= (in02 * k00) + (in03 * k01) + 
                                       (in12 * k10) + (in13 * k11);
                            conv_count <= conv_count + 1;
                        end
                        5'd5: begin
                            out02 <= temp_acc;
                            conv_count <= conv_count + 1;
                        end
                        
                        // Output (1,0)
                        5'd6: begin
                            temp_acc <= (in10 * k00) + (in11 * k01) + 
                                       (in20 * k10) + (in21 * k11);
                            conv_count <= conv_count + 1;
                        end
                        5'd7: begin
                            out10 <= temp_acc;
                            conv_count <= conv_count + 1;
                        end
                        
                        // Output (1,1)
                        5'd8: begin
                            temp_acc <= (in11 * k00) + (in12 * k01) + 
                                       (in21 * k10) + (in22 * k11);
                            conv_count <= conv_count + 1;
                        end
                        5'd9: begin
                            out11 <= temp_acc;
                            conv_count <= conv_count + 1;
                        end
                        
                        // Output (1,2)
                        5'd10: begin
                            temp_acc <= (in12 * k00) + (in13 * k01) + 
                                       (in22 * k10) + (in23 * k11);
                            conv_count <= conv_count + 1;
                        end
                        5'd11: begin
                            out12 <= temp_acc;
                            conv_count <= conv_count + 1;
                        end
                        
                        // Output (2,0)
                        5'd12: begin
                            temp_acc <= (in20 * k00) + (in21 * k01) + 
                                       (in30 * k10) + (in31 * k11);
                            conv_count <= conv_count + 1;
                        end
                        5'd13: begin
                            out20 <= temp_acc;
                            conv_count <= conv_count + 1;
                        end
                        
                        // Output (2,1)
                        5'd14: begin
                            temp_acc <= (in21 * k00) + (in22 * k01) + 
                                       (in31 * k10) + (in32 * k11);
                            conv_count <= conv_count + 1;
                        end
                        5'd15: begin
                            out21 <= temp_acc;
                            conv_count <= conv_count + 1;
                        end

                        // Output (2,2) - MOVED HERE TO FIX RACE CONDITION
                        5'd16: begin
                             temp_acc <= (in22 * k00) + (in23 * k01) + 
                                        (in32 * k10) + (in33 * k11);
                             conv_count <= conv_count + 1;
                        end
                        5'd17: begin
                            out22 <= temp_acc;
                            state <= FINISH;
                        end
                        
                        default: begin
                            state <= FINISH;
                        end
                    endcase
                end
                
                FINISH: begin
                    done <= 1'b1;
                    state <= IDLE;
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule