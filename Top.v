module Top (
    input wire clk,             // Clock (50 MHz)
    input wire reset,           // Reset signal
    inout wire dht11_data,      // DHT11 DATA pin
    output wire [6:0] hex0,     // 7-segment display for humidity
    output wire [6:0] hex1,     // 7-segment display for humidity
    output wire [6:0] hex2,     // 7-segment display for temperature
    output wire [6:0] hex3      // 7-segment display for temperature
);

    // Internal signals to store humidity and temperature
    wire [7:0] humidity;
    wire [7:0] temperature;

    // DHT11 sensor interface
    DHT11 dht11_inst (
        .clk(clk),
        .reset(reset),
        .data(dht11_data),
        .humidity(humidity),
        .temperature(temperature)
    );

    HEX hex0_inst (
        .value(humidity[7:4]), // Display the upper nibble of humidity
        .hex(hex0)
    );

    HEX hex1_inst (
        .value(humidity[3:0]), // Display the lower nibble of humidity
        .hex(hex1)
    );

    HEX hex2_inst (
        .value(temperature[7:4]), // Display the upper nibble of temperature
        .hex(hex2)
    );

    HEX hex3_inst (
        .value(temperature[3:0]), // Display the lower nibble of temperature
        .hex(hex3)
    );

endmodule
