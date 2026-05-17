//==============================================================================
// Testbench: tb_rom_data_source
// Description: Test ROM data reading
//==============================================================================

module tb_rom_data_source;

    reg clk;
    reg rst_n;
    reg read_enable;
    reg [7:0] address;
    wire [15:0] data_out;
    wire data_valid;
    
    // Instantiate ROM
    rom_data_source uut (
        .clk(clk),
        .rst_n(rst_n),
        .read_enable(read_enable),
        .address(address),
        .data_out(data_out),
        .data_valid(data_valid)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    integer i;
    initial begin
        // Initialize
        rst_n = 0;
        read_enable = 0;
        address = 0;
        
        // Reset
        #20 rst_n = 1;
        #10;
        
        // Read Matrix A (addresses 0-15)
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk);
            read_enable = 1;
            address = i;
            @(posedge clk);
            if (data_valid) begin
                // Print nothing - simulation tool will show waveforms
            end
        end
        
        read_enable = 0;
        #50;
        
        // Read Matrix B (addresses 16-31)
        for (i = 16; i < 32; i = i + 1) begin
            @(posedge clk);
            read_enable = 1;
            address = i;
            @(posedge clk);
        end
        
        read_enable = 0;
        #100;
        
        // Finish
        #50;
    end

endmodule