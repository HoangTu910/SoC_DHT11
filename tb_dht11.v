`timescale 1ns / 1ps

module tb_dht11;
    reg clk50M;

    wire io_dht11;

    reg tb_o_dht11;

    pullup(io_dht11);       // Enable pull-up on io_dht11

    assign io_dht11 = tb_o_dht11;

    wire [31:0] dht11_data;
    wire dht11_data_valid;

    dht11 #(
        .INIT_DELAY_CNT(50_000) // Adjust delay count for 50 MHz clock
    ) u_dht11 (
        .clk50M(clk50M),         // Update port to use clk50M
        .io_dht11(io_dht11),
        .dht11_data(dht11_data),
        .dht11_data_valid(dht11_data_valid)
    );

    // Clock parameters for 50 MHz
    localparam CLK_PERIOD = 20; // Clock period = 1 / 50MHz = 20ns
    always #(CLK_PERIOD / 2) clk50M = ~clk50M;

    task ack;
        begin
            tb_o_dht11 <= 1'b0;               // Pull low for 80us
            repeat(80 * 50) @(posedge clk50M);
            tb_o_dht11 <= 1'b1;               // Pull high for 85us
            repeat(85 * 50) @(posedge clk50M);
        end
    endtask

    task dht11_send_bits(input x);
        begin
            tb_o_dht11 <= 1'b0;               // Pull low for 50us
            repeat(50 * 50) @(posedge clk50M);
            tb_o_dht11 <= 1'b1;
            if (x == 1'b1) begin
                repeat(72 * 50) @(posedge clk50M);    // High for 72us
            end else begin
                repeat(24 * 50) @(posedge clk50M);    // High for 24us
            end
        end
    endtask

    task dht11_send_byte(input [7:0] b);
        begin
            dht11_send_bits(b[7]);
            dht11_send_bits(b[6]);
            dht11_send_bits(b[5]);
            dht11_send_bits(b[4]);
            dht11_send_bits(b[3]);
            dht11_send_bits(b[2]);
            dht11_send_bits(b[1]);
            dht11_send_bits(b[0]);
        end
    endtask

    localparam SHIDU_H = 8'h35;
    localparam SHIDU_L = 8'h00;
    reg [7:0] TEMP_H, TEMP_H1, TEMP_L, TEMP_L1, ADD_END, ADD_END1;

    initial begin
        TEMP_H = 8'h18 + $random % 3; // Range: 18-3 ~ 18+3
        TEMP_H1 = 8'h18 + $random % 3;
        TEMP_L = $random % 100;
        TEMP_L1 = $random % 100;
        ADD_END = SHIDU_H + SHIDU_L + TEMP_H + TEMP_L;
        ADD_END1 = SHIDU_H + SHIDU_L + TEMP_H1 + TEMP_L1;
    end

    initial begin
        clk50M <= 0;
        tb_o_dht11 = 1'bz;
        @(posedge clk50M);
        repeat(2) @(posedge clk50M);

        @(negedge io_dht11); // Wait for io_dht11 to go low

        while (io_dht11 == 1'b0)
            @(posedge clk50M); // Wait for io_dht11 to go high

        tb_o_dht11 <= 1'b1; // Wait for 5us
        repeat(50 * 5) @(posedge clk50M);

        ack(); // Send ACK

        dht11_send_byte(SHIDU_H);
        dht11_send_byte(SHIDU_L);
        dht11_send_byte(TEMP_H);
        dht11_send_byte(TEMP_L);
        dht11_send_byte(ADD_END);

        tb_o_dht11 <= 1'b0; // Wait for 56us
        repeat(56 * 50) @(posedge clk50M);
        tb_o_dht11 = 1'bz; // Release the line

        @(negedge io_dht11); // Wait for io_dht11 to go low

        while (io_dht11 == 1'b0)
            @(posedge clk50M); // Wait for io_dht11 to go high

        tb_o_dht11 <= 1'b1; // Wait for 5us
        repeat(50 * 5) @(posedge clk50M);

        ack(); // Send ACK

        dht11_send_byte(SHIDU_H);
        dht11_send_byte(SHIDU_L);
        dht11_send_byte(TEMP_H1);
        dht11_send_byte(TEMP_L1);
        dht11_send_byte(ADD_END1);

        tb_o_dht11 <= 1'b0; // Wait for 56us
        repeat(56 * 50) @(posedge clk50M);
        tb_o_dht11 = 1'bz; // Release the line

        $display("1:TEMP:%h, %h", TEMP_H, TEMP_L);
        $display("2:TEMP:%h, %h", TEMP_H1, TEMP_L1);
    end
endmodule
