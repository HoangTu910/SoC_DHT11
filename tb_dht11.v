module testbench;
    reg clk;
    reg reset;
    wire data;
    wire [7:0] humidity;
    wire [7:0] temperature;
    wire valid;

    // Instantiate the DHT11 module
    DHT11 dht11_inst (
        .clk(clk),
        .reset(reset),
        .data(data),
        .humidity(humidity),
        .temperature(temperature),
        .valid(valid)
    );

    // Clock generation for 50 MHz clock (period = 20 ns)
    always begin
        #10 clk = ~clk;  // 50 MHz clock, period = 20ns
    end

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;

        // Apply reset
        reset = 1;
        #20 reset = 0;
        
        #50
        // Step 1: Test if FPGA pulls the signal low for 18ms (start condition)
        $display("Step 1: Testing FPGA pulling line low for 18ms...");
        $display("Current state: %d", dht11_inst.current_state);
        $display("Data pin: %d", data);
        $display("Waiting for 18ms...");
        for (int i = 0; i < 900000; i = i + 1) begin
            @(posedge clk); 
        end
        $display("Counter value after 18ms: %d", dht11_inst.counter);
        for (int i = 0; i < 15; i = i + 1) begin
            @(posedge clk); 
        end
        $display("Data pin: %d", data);
        $display("Counter value after 18ms: %d", dht11_inst.counter);
        $display("Current state: %d", dht11_inst.current_state);
        $display("Next state: %d", dht11_inst.next_state);
        $display("Step 1 complete: 18ms passed.");
        
    
        $display("Step 2: Waiting for DHT11 response signal for 80us...");
        for (int i = 0; i < 4000; i = i + 1) begin
            @(posedge clk); 
        end
        $display("Counter value after 80us: %d", dht11_inst.counter);
        $display("Step 2 complete: 80us passed.");
        #20
        $display("Current state: %d", dht11_inst.current_state);
        // End the simulation
        $stop;  // End the simulation
    end
endmodule
