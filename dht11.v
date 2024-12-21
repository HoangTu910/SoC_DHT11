`timescale 1ns / 1ps

module dht11 (
    input clk50M,
    inout io_dht11,
    output [31:0] dht11_data,
    output reg dht11_data_valid
);
    reg o_dht11;
    reg dht11_o_en; 
    assign io_dht11 = dht11_o_en ? o_dht11 : 1'bz;

    wire clk; // 1us / 1MHz

    clk_1us_gen #(
        .CLK_IN(50)
    ) u_clk_1us_gen (
        .clk(clk50M),
        .clk_out_1us(clk)
    );

    reg rst_n = 0;

    always @(posedge clk) begin
        if (!rst_n) begin
            rst_n <= 1'b1;
        end
    end

    parameter INIT_DELAY_CNT = 3_000_000;

    reg [$clog2(INIT_DELAY_CNT + 1) - 1:0] cnt_3s;
    reg [$clog2(20_000 + 1) - 1:0] cnt;

    reg io_dht11_r;
    reg io_dht11_rr;
    reg io_dht11_rrr;

    always @(posedge clk) begin
        io_dht11_r <= io_dht11;
        io_dht11_rr <= io_dht11_r;
        io_dht11_rrr <= io_dht11_rr;
    end

    wire dht11_pos = (~io_dht11_rrr) && io_dht11_rr; // Rising edge
    wire dht11_neg = io_dht11_rrr && (~io_dht11_rr); // Falling edge

    localparam ST_IDLE = 5'b00001;
    localparam ST_CALL = 5'b00010;
    localparam ST_WAIT_NEG = 5'b00100;
    localparam ST_WAIT = 5'b01000;
    localparam ST_READ_DATA = 5'b10000;

    reg [4:0] state, next_state;

    reg [$clog2(64) - 1:0] bits_cnt;

    reg start_cnt_data;

    reg [39:0] recv_data;
    wire recv_data_valid;

    assign dht11_data[31:0] = recv_data[39:8];
    assign recv_data_valid = (recv_data[7:0] != 'h0) && (recv_data[7:0] == (recv_data[39:32] + recv_data[31:24] + recv_data[23:16] + recv_data[15:8]));

    always @(posedge clk) begin
        if (!rst_n) begin
            dht11_data_valid <= 1'b0;
        end else begin
            if (state == ST_IDLE) begin
                if (recv_data_valid) begin
                    dht11_data_valid <= 1'b1;
                end else begin
                    dht11_data_valid <= 1'b0;
                end
            end else begin
                dht11_data_valid <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= ST_IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @* begin
        case (state)
            ST_IDLE: begin
                if (cnt_3s == INIT_DELAY_CNT - 1) begin
                    next_state = ST_CALL;
                end else begin
                    next_state = ST_IDLE;
                end
            end
            ST_CALL: begin
                if (cnt == 'd20_000 - 1) begin
                    next_state = ST_WAIT_NEG;
                end else begin
                    next_state = ST_CALL;
                end
            end
            ST_WAIT_NEG: begin
                if (dht11_neg) begin
                    next_state = ST_WAIT;
                end else begin
                    next_state = ST_WAIT_NEG;
                end
            end
            ST_WAIT: begin
                if (dht11_pos) begin
                    next_state = ST_READ_DATA;
                end else begin
                    next_state = ST_WAIT;
                end
            end
            ST_READ_DATA: begin
                if (dht11_pos && bits_cnt == 40) begin
                    next_state = ST_IDLE;
                end else begin
                    next_state = ST_READ_DATA;
                end
            end
            default: next_state = ST_IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            cnt_3s <= 0;
        end else if (state == ST_IDLE) begin
            if (cnt_3s == INIT_DELAY_CNT - 1) begin
                cnt_3s <= 0;
            end else begin
                cnt_3s <= cnt_3s + 1'b1;
            end
        end else begin
            cnt_3s <= 0;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            cnt <= 0;
        end else if (state == ST_CALL) begin
            if (cnt == 'd20_000 - 1) begin
                cnt <= 0;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end else if (state == ST_READ_DATA) begin
            if (dht11_neg) begin
                cnt <= 0;
            end else if (start_cnt_data) begin
                cnt <= cnt + 1'b1;
            end else begin
                cnt <= 0;
            end
        end else begin
            cnt <= 0;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            start_cnt_data <= 1'b0;
        end else if (state == ST_READ_DATA) begin
            if (dht11_pos) begin
                start_cnt_data <= 1'b1;
            end else if (dht11_neg) begin
                start_cnt_data <= 1'b0;
            end
        end else begin
            start_cnt_data <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            bits_cnt <= 0;
        end else if (state == ST_READ_DATA) begin
            if (dht11_neg && (cnt > 0)) begin
                bits_cnt <= bits_cnt + 1'b1;
            end
        end else begin
            bits_cnt <= 0;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            recv_data <= 40'h0;
        end else if (state == ST_READ_DATA && (dht11_neg && (cnt > 0))) begin
            if (cnt > 50) begin
                recv_data <= {recv_data[38:0], 1'b1};
            end else begin
                recv_data <= {recv_data[38:0], 1'b0};
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            o_dht11 <= 1'b1;
            dht11_o_en <= 1'b1;
        end else begin
            case (state)
                ST_IDLE: begin
                    o_dht11 <= 1'b1;
                    dht11_o_en <= 1'b0;
                end
                ST_CALL: begin
                    o_dht11 <= 1'b0;
                    dht11_o_en <= 1'b1;
                end
                ST_WAIT_NEG, ST_WAIT, ST_READ_DATA: begin
                    o_dht11 <= 1'b1;
                    dht11_o_en <= 1'b0;
                end
            endcase
        end
    end

endmodule
