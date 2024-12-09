module HEX (
    input wire [7:0] value,    
    output reg [6:0] hex      
);

    always @(*) begin
		 case(value)
			  8'h00: hex = 7'b1000000; // 0
			  8'h01: hex = 7'b1111001; // 1
			  8'h02: hex = 7'b0100100; // 2
			  8'h03: hex = 7'b0110000; // 3
			  8'h04: hex = 7'b0011001; // 4
			  8'h05: hex = 7'b0010010; // 5
			  8'h06: hex = 7'b0000010; // 6
			  8'h07: hex = 7'b1111000; // 7
			  8'h08: hex = 7'b0000000; // 8
			  8'h09: hex = 7'b0010000; // 9
			  8'h0A: hex = 7'b0001000; // A
			  8'h0B: hex = 7'b0000011; // b
			  8'h0C: hex = 7'b1000110; // C
			  8'h0D: hex = 7'b0100001; // d
			  8'h0E: hex = 7'b0000110; // E
			  8'h0F: hex = 7'b0001110; // F
			  default: hex = 7'b0000000; // Default to all on
		 endcase
	end
endmodule

