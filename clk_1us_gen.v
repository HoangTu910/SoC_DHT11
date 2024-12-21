module clk_1us_gen (
    input clk,
    output clk_out_1us
);
    parameter CLK_IN = 50;

    reg [$clog2(CLK_IN+1)-1:0] cnt = 0;

    always @(posedge clk) begin
        if (cnt == CLK_IN - 1) 
            cnt <= 0;
        else 
            cnt <= cnt + 1;
    end

    assign clk_out_1us = (cnt < CLK_IN / 2) ? 1'b1 : 1'b0;
endmodule