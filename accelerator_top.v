//==============================================================================
// Module: accelerator_top
// Description: Top-level systolic array accelerator integration
// Complete system with all input/output methods
//==============================================================================

module accelerator_top (
    input wire clk,
    input wire rst_n,
    
    // Configuration
    input wire [1:0] input_select,   // 00=ROM, 01=UART, 10=RISC-V
    input wire [1:0] output_select,  // 00=RAM, 01=UART, 10=RISC-V
    input wire config_4x4,           // 1=4x4 array, 0=2x2 array
    input wire operation_mode,       // 0=MatMul, 1=Conv2D
    
    // Control
    input wire start,
    output wire done,
    
    // UART interface
    input wire uart_rx,
    output wire uart_tx,
    
    // RISC-V memory interface
    input wire [31:0] riscv_addr,
    input wire [31:0] riscv_wdata,
    input wire riscv_write,
    input wire riscv_read,
    output wire [31:0] riscv_rdata,
    output wire riscv_ready,
    
    // ROM address control (for external testing)
    input wire [7:0] rom_addr_external,
    input wire rom_read_enable,
    
    // Status outputs
    output wire [7:0] status_leds
);

    // Internal signals
    wire [15:0] input_data;
    wire input_data_valid;
    
    // ROM signals
    wire [15:0] rom_data;
    wire rom_data_valid;
    
    // UART signals
    wire [7:0] uart_rx_data;
    wire uart_rx_valid;
    wire [15:0] uart_input_data;
    wire uart_input_ready;
    
    wire [7:0] uart_tx_data;
    wire uart_tx_start;
    wire uart_tx_busy;
    
    // RISC-V interface signals
    wire [15:0] riscv_input_data;
    wire riscv_input_valid;
    wire [15:0] riscv_output_data;
    wire riscv_output_ready;
    
    // Matrix storage (16 elements each)
    reg [15:0] matrix_a [0:15];
    reg [15:0] matrix_b [0:15];
    reg [3:0] matrix_load_count;
    reg matrices_loaded;
    
    // Systolic array signals
    wire [15:0] a_row0, a_row1, a_row2, a_row3;
    wire [15:0] b_col0, b_col1, b_col2, b_col3;
    wire array_enable;
    wire acc_clear;
    wire array_done;
    
    // Results
    wire [31:0] c00, c01, c02, c03;
    wire [31:0] c10, c11, c12, c13;
    wire [31:0] c20, c21, c22, c23;
    wire [31:0] c30, c31, c32, c33;
    
    // Result RAM signals
    wire [7:0] ram_write_addr;
    wire [31:0] ram_write_data;
    wire ram_write_enable;
    wire [7:0] ram_read_addr;
    wire [31:0] ram_read_data;
    
    // Output control signals
    wire [31:0] output_result;
    wire output_result_valid;
    
    //==========================================================================
    // INPUT PATH
    //==========================================================================
    
    // ROM data source
    rom_data_source rom_src (
        .clk(clk),
        .rst_n(rst_n),
        .read_enable(rom_read_enable),
        .address(rom_addr_external),
        .data_out(rom_data),
        .data_valid(rom_data_valid)
    );
    
    // UART receiver
    uart_receiver uart_rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(uart_rx),
        .rx_data(uart_rx_data),
        .rx_valid(uart_rx_valid)
    );
    
    // UART input buffer
    uart_input_buffer uart_in_buf (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx_data(uart_rx_data),
        .uart_rx_valid(uart_rx_valid),
        .data_out(uart_input_data),
        .data_ready(uart_input_ready),
        .element_count()
    );
    
    // RISC-V interface
    riscv_mem_interface riscv_if (
        .clk(clk),
        .rst_n(rst_n),
        .mem_addr(riscv_addr),
        .mem_wdata(riscv_wdata),
        .mem_write(riscv_write),
        .mem_read(riscv_read),
        .mem_rdata(riscv_rdata),
        .mem_ready(riscv_ready),
        .data_to_accelerator(riscv_input_data),
        .data_valid(riscv_input_valid),
        .data_from_accelerator(riscv_output_data),
        .result_ready(output_result_valid)
    );
    
    // Input multiplexer
    input_mux in_mux (
        .input_select(input_select),
        .rom_data(rom_data),
        .rom_valid(rom_data_valid),
        .uart_data(uart_input_data),
        .uart_valid(uart_input_ready),
        .riscv_data(riscv_input_data),
        .riscv_valid(riscv_input_valid),
        .data_out(input_data),
        .data_valid(input_data_valid)
    );
    
    // Matrix loading logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_load_count <= 4'd0;
            matrices_loaded <= 1'b0;
        end else begin
            if (input_data_valid && !matrices_loaded) begin
                if (matrix_load_count < 16) begin
                    // Load matrix A
                    matrix_a[matrix_load_count] <= input_data;
                    matrix_load_count <= matrix_load_count + 1;
                end else if (matrix_load_count < 32) begin
                    // Load matrix B
                    matrix_b[matrix_load_count - 16] <= input_data;
                    matrix_load_count <= matrix_load_count + 1;
                    
                    if (matrix_load_count == 31) begin
                        matrices_loaded <= 1'b1;
                    end
                end
            end
            
            if (start && matrices_loaded) begin
                // Reset for next operation
                matrix_load_count <= 4'd0;
                matrices_loaded <= 1'b0;
            end
        end
    end
    
    //==========================================================================
    // PROCESSING PATH
    //==========================================================================
    
    // Systolic array controller
    systolic_array_controller sys_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .start(start && matrices_loaded),
        
        // Matrix A
        .a00(matrix_a[0]), .a01(matrix_a[1]), .a02(matrix_a[2]), .a03(matrix_a[3]),
        .a10(matrix_a[4]), .a11(matrix_a[5]), .a12(matrix_a[6]), .a13(matrix_a[7]),
        .a20(matrix_a[8]), .a21(matrix_a[9]), .a22(matrix_a[10]), .a23(matrix_a[11]),
        .a30(matrix_a[12]), .a31(matrix_a[13]), .a32(matrix_a[14]), .a33(matrix_a[15]),
        
        // Matrix B
        .b00(matrix_b[0]), .b01(matrix_b[1]), .b02(matrix_b[2]), .b03(matrix_b[3]),
        .b10(matrix_b[4]), .b11(matrix_b[5]), .b12(matrix_b[6]), .b13(matrix_b[7]),
        .b20(matrix_b[8]), .b21(matrix_b[9]), .b22(matrix_b[10]), .b23(matrix_b[11]),
        .b30(matrix_b[12]), .b31(matrix_b[13]), .b32(matrix_b[14]), .b33(matrix_b[15]),
        
        // Outputs to array
        .a_row0(a_row0), .a_row1(a_row1), .a_row2(a_row2), .a_row3(a_row3),
        .b_col0(b_col0), .b_col1(b_col1), .b_col2(b_col2), .b_col3(b_col3),
        
        .array_enable(array_enable),
        .acc_clear(acc_clear),
        .done(array_done)
    );
    
    // Configurable systolic array
    configurable_systolic_array sys_array (
        .clk(clk),
        .rst_n(rst_n),
        .enable(array_enable),
        .acc_clear(acc_clear),
        .config_4x4(config_4x4),
        
        .a_row0(a_row0), .a_row1(a_row1), .a_row2(a_row2), .a_row3(a_row3),
        .b_col0(b_col0), .b_col1(b_col1), .b_col2(b_col2), .b_col3(b_col3),
        
        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33)
    );
    
    //==========================================================================
    // OUTPUT PATH
    //==========================================================================
    
    // Result RAM
    result_ram res_ram (
        .clk(clk),
        .rst_n(rst_n),
        .write_addr(ram_write_addr),
        .write_data(ram_write_data),
        .write_enable(ram_write_enable),
        .read_addr(ram_read_addr),
        .read_data(ram_read_data)
    );
    
    // Output controller
    output_controller out_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .output_select(output_select),
        
        .c00(c00), .c01(c01), .c02(c02), .c03(c03),
        .c10(c10), .c11(c11), .c12(c12), .c13(c13),
        .c20(c20), .c21(c21), .c22(c22), .c23(c23),
        .c30(c30), .c31(c31), .c32(c32), .c33(c33),
        .results_ready(array_done),
        
        .ram_addr(ram_write_addr),
        .ram_data(ram_write_data),
        .ram_write(ram_write_enable),
        
        .uart_result(output_result),
        .uart_result_valid(output_result_valid),
        
        .riscv_result(riscv_output_data),
        .riscv_result_valid(),
        
        .done(done)
    );
    
    // UART output buffer
    uart_output_buffer uart_out_buf (
        .clk(clk),
        .rst_n(rst_n),
        .result_data(output_result),
        .result_valid(output_result_valid),
        .tx_byte(uart_tx_data),
        .tx_valid(uart_tx_start),
        .tx_busy(uart_tx_busy)
    );
    
    // UART transmitter
    uart_transmitter uart_tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(uart_tx_data),
        .tx_start(uart_tx_start),
        .tx_serial(uart_tx),
        .tx_busy(uart_tx_busy)
    );
    
    // Status LEDs
    assign status_leds = {
        matrices_loaded,
        array_enable,
        array_done,
        done,
        config_4x4,
        output_select,
        input_select
    };

endmodule