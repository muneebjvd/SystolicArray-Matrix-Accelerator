//==============================================================================
// Testbench: tb_uart_complete
// Description: Test UART TX -> RX loopback with buffer
//==============================================================================

module tb_uart_complete;

    reg clk;
    reg rst_n;
    
    // TX signals
    reg [7:0] tx_data;
    reg tx_start;
    wire tx_serial;
    wire tx_busy;
    
    // RX signals
    wire [7:0] rx_data;
    wire rx_valid;
    
    // Buffer signals
    wire [15:0] buffered_data;
    wire data_ready;
    wire [7:0] element_count;
    
    // Instantiate modules
    uart_transmitter tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy)
    );
    
    uart_receiver rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(tx_serial), // Loopback
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );
    
    uart_input_buffer buffer (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx_data(rx_data),
        .uart_rx_valid(rx_valid),
        .data_out(buffered_data),
        .data_ready(data_ready),
        .element_count(element_count)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Test sequence
    integer i;
    reg [7:0] test_bytes [0:7];
    
    initial begin
        // Test data: send 4 elements (8 bytes)
        // Element 0: 0x0001
        test_bytes[0] = 8'h00;
        test_bytes[1] = 8'h01;
        // Element 1: 0x0002
        test_bytes[2] = 8'h00;
        test_bytes[3] = 8'h02;
        // Element 2: 0x0003
        test_bytes[4] = 8'h00;
        test_bytes[5] = 8'h03;
        // Element 3: 0x0004
        test_bytes[6] = 8'h00;
        test_bytes[7] = 8'h04;
        
        // Initialize
        rst_n = 0;
        tx_start = 0;
        tx_data = 0;
        
        #100 rst_n = 1;
        #100;
        
        // Send test bytes
        for (i = 0; i < 8; i = i + 1) begin
            // Wait for TX not busy
            while (tx_busy) @(posedge clk);
            
            @(posedge clk);
            tx_data = test_bytes[i];
            tx_start = 1;
            
            @(posedge clk);
            tx_start = 0;
            
            // Wait for transmission to complete
            while (tx_busy) @(posedge clk);
            
            // Small delay between bytes
            repeat(100) @(posedge clk);
        end
        
        // Wait for all data to be received
        repeat(10000) @(posedge clk);
        
    end

endmodule