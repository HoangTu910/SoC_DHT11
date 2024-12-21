module Top (
    input CLOCK_50,             
    input reset,                
    inout wire io_dht11,        
    output wire [6:0] HEX0,     
    output wire [6:0] HEX1,     
    output wire [6:0] HEX2,     
    output wire [6:0] HEX3      
);

    wire [31:0] dht11_data;     
    wire valid;                 

    // Instantiate the DHT11 module
    dht11 dht11_inst (
        .clk50M(CLOCK_50),
        .io_dht11(io_dht11),
        .dht11_data(dht11_data),
        .dht11_data_valid(valid)
    );

    wire [7:0] humidity = dht11_data[31:24];  // High byte of humidity
    wire [7:0] temperature = dht11_data[15:8]; // High byte of temperature

    HEX hex3_inst (
        .value(humidity / 10),  
        .hex(HEX3)
    );

    HEX hex2_inst (
        .value(humidity % 10),  
        .hex(HEX2)
    );

    HEX hex1_inst (
        .value(temperature / 10), 
        .hex(HEX1)
    );

    HEX hex0_inst (
        .value(temperature % 10), 
        .hex(HEX0)
    );

endmodule
