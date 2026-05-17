//==============================================================================
// Testbench: tb_full_system
// Description: Complete system test with all interfaces
//==============================================================================

module tb_full_system;

    reg clk;
    reg rst_n;
    
    // Configuration
    reg [1:0] input_select;
    reg [1:0] output_select;
    reg config_4x4;
    reg operation_mode;
    
    // Control
    reg start;
    wire done;
    
    // UART
    reg uart_rx;
    wire uart_tx;
    
    // RISC-V
    reg [31:0] riscv_addr;
    reg [31:0] riscv_wdata;
    reg riscv_write;
    reg riscv_read;
    wire [31:0] riscv_rdata;
    wire riscv_ready;
    
    // ROM control
    reg [7:0] rom_addr_external;
    reg rom_read_enable;
    
    // Status
    wire [7:0] status_leds;
    
    // Instantiate top module
    accelerator_top dut (
        .clk(clk),
        .rst_n(rst_n),
        
        .input_select(input_select),
        .output_select(output_select),
        .config_4x4(config_4x4),
        .operation_mode(operation_mode),
        
        .start(start),
        .done(done),
        
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        
        .riscv_addr(riscv_addr),
        .riscv_wdata(riscv_wdata),
        .riscv_write(riscv_write),
        .riscv_read(riscv_read),
        .riscv_rdata(riscv_rdata),
        .riscv_ready(riscv_ready),
        
        .rom_addr_external(rom_addr_external),
        .rom_read_enable(rom_read_enable),
        
        .status_leds(status_leds)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // UART byte transmission task
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit
            uart_rx = 0;
            repeat(434) @(posedge clk);
            
            // Data bits
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                repeat(434) @(posedge clk);
            end
            
            // Stop bit
            uart_rx = 1;
            repeat(434) @(posedge clk);
        end
    endtask
    
    // RISC-V write task
    task riscv_write_data;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            riscv_addr = addr;
            riscv_wdata = data;
            riscv_write = 1;
            
            @(posedge clk);
            riscv_write = 0;
            
            wait(riscv_ready);
            @(posedge clk);
        end
    endtask
    
    // Main test
    integer i;
    initial begin
        // Initialize
        rst_n = 0;
        start = 0;
        uart_rx = 1;  // Idle high
        
        input_select = 2'b00;   // ROM
        output_select = 2'b00;  // RAM
        config_4x4 = 1'b1;      // 4x4 mode
        operation_mode = 1'b0;  // Matrix multiplication
        
        riscv_addr = 32'd0;
        riscv_wdata = 32'd0;
        riscv_write = 0;
        riscv_read = 0;
        
        rom_addr_external = 8'd0;
        rom_read_enable = 0;
        
        #100 rst_n = 1;
        #100;
        
        // ====================================================================
        // TEST 1: ROM Input Mode
        // ====================================================================
        
        input_select = 2'b00;  // ROM input
        output_select = 2'b00; // RAM output
        
        // Load matrices from ROM by reading sequentially
        for (i = 0; i < 32; i = i + 1) begin
            @(posedge clk);
            rom_addr_external = i;
            rom_read_enable = 1;
            @(posedge clk);
            rom_read_enable = 0;
            repeat(5) @(posedge clk);
        end
        
        // Wait for matrices to be loaded
        wait(dut.matrices_loaded);
        #100;
        
        // Start computation
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion
        wait(done);
        #200;
        
        // ====================================================================
        // TEST 2: UART Input Mode
        // ====================================================================
        
        input_select = 2'b01;  // UART input
        #100;
        
        // Send Matrix A (16 elements, 2 bytes each)
        // Example: Send 1, 2, 3, ... 16
        for (i = 1; i <= 16; i = i + 1) begin
            send_uart_byte(8'd0);     // High byte
            send_uart_byte(i[7:0]);   // Low byte
            repeat(100) @(posedge clk);
        end
        
        // Send Matrix B (identity matrix)
        for (i = 0; i < 16; i = i + 1) begin
            if (i == 0 || i == 5 || i == 10 || i == 15) begin
                send_uart_byte(8'd0);
                send_uart_byte(8'd1);
            end else begin
                send_uart_byte(8'd0);
                send_uart_byte(8'd0);
            end
            repeat(100) @(posedge clk);
        end
        
        // Wait for matrices to load
        wait(dut.matrices_loaded);
        #100;
        
        // Start computation
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        wait(done);
        #200;
        
        // ====================================================================
        // TEST 3: RISC-V Input Mode
        // ====================================================================
        
        input_select = 2'b10;  // RISC-V input
        #100;
        
        // Write matrix elements via RISC-V interface
        for (i = 1; i <= 32; i = i + 1) begin
            riscv_write_data(32'h80000000, i);
            repeat(10) @(posedge clk);
        end
        
        // Wait and start
        wait(dut.matrices_loaded);
        #100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        wait(done);
        #200;
        
        // ====================================================================
        // TEST 4: 2x2 Mode
        // ====================================================================
        
        config_4x4 = 1'b0;  // Switch to 2x2 mode
        input_select = 2'b00;
        #100;
        
        // Load small matrices
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge clk);
            rom_addr_external = i;
            rom_read_enable = 1;
            @(posedge clk);
            rom_read_enable = 0;
            repeat(5) @(posedge clk);
        end
        
        wait(dut.matrices_loaded);
        #100;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        wait(done);
        #500;
        
    end

endmodule