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
        $display("-----------------------");
        $display("Step 1: IDLE Wait...");
        $display("Current state: %d", dht11_inst.current_state);
        $display("Data pin: %d", data);
        $display("Waiting IDLE...");
        for (int i = 0; i < 1000; i = i + 1) begin
            @(posedge clk); 
        end
        $display("Counter value: %d", dht11_inst.counter);
        $display("-----------------------");
    
        $display("-----------------------");
        $display("Step 2: Pull Data Low");
        $display("Current state: %d", dht11_inst.current_state);
        $display("Next state: %d", dht11_inst.next_state);
        $display("Data pin: %d", data);
        $display("Waiting 18ms...");
        for (int i = 0; i < 900000; i = i + 1) begin
            @(posedge clk); 
        end
        $display("Data pin: %d", data);
        $display("Counter value: %d", dht11_inst.counter);
        $display("Current state: %d", dht11_inst.current_state);
        $display("Next state: %d", dht11_inst.next_state);
        $display("-----------------------");
        
        $display("-----------------------");
        $display("Step 3: Wait for response");
        $display("Current state: %d", dht11_inst.current_state);
        $display("Next state: %d", dht11_inst.next_state);
        $display("Data pin: %d", data);
        $display("Waiting 80us...");
        for (int i = 0; i < 4000; i = i + 1) begin
            @(posedge clk); 
        end
        #10
        $display("Data pin: %d", data);
        $display("Counter value: %d", dht11_inst.counter);
        $display("Current state: %d", dht11_inst.current_state);
        $display("Next state: %d", dht11_inst.next_state);
        $display("-----------------------");
        
        $display("-----------------------");
        #100
        $display("Step 4: Read data");
        $display("Current state: %d", dht11_inst.current_state);
        $display("Next state: %d", dht11_inst.next_state);
        $display("Data pin: %d", data);
        $display("-----------------------");
        $stop;  // End the simulation
    end
endmodule
