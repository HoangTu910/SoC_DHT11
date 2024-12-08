module DHT11 (
    input wire clk,            
    input wire reset,          
    inout wire data,            
    output reg [7:0] humidity,  
    output reg [7:0] temperature, 
    output reg valid           
);
	
    parameter IDLE = 3'b000;
    parameter START = 3'b001;
    parameter RESPONSE = 3'b010;
    parameter READ_DATA = 3'b011;
    parameter PROCESS = 3'b100;

    reg [2:0] current_state, next_state;
	reg data_out; 
    reg [39:0] data_buffer;     // Data buffer to hold 40 bits of data
    reg [5:0] bit_index;        // Index to track bits being read
    reg [19:0] counter;         // Counter for timing purposes
    reg data_prev;              // Previous data state for edge detection

    // Timing parameters 
    parameter START_LOW = 900000;    // 18 ms 
    parameter RESPONSE_WAIT = 4000;  // 80 µs 
    parameter IDLE_WAIT = 1000;
	 
	assign data = (data_out) ? 1'bz : 1'b0;

    assign start_condition = (counter >= START_LOW);
    assign response_received = (counter >= RESPONSE_WAIT); 
    assign idle_wait_completed = (counter >= IDLE_WAIT);
	
    /* Rising edge detection for data signal */
    wire data_signal_detected = (data_prev == 0 && data == 1); 

    /* Counter Logic */
	always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
        end 
        else if(current_state != next_state) begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
        end
    end

    /* FSM Logic */ 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    /* State transitions logic */
    always @(*) begin
        case (current_state)
            IDLE: begin
                /* wire start_condition = (counter >= START_LOW); */
                if (idle_wait_completed) next_state = START;
                else next_state = IDLE;
            end
            START: begin
                if (counter >= START_LOW) next_state = RESPONSE;
                else next_state = START;
            end
            RESPONSE: begin
                /* wire response_received = (counter >= RESPONSE_WAIT); */
                if (response_received) next_state = READ_DATA;
                else next_state = RESPONSE;
            end
            READ_DATA: begin
                if (bit_index == 40) next_state = PROCESS;
                else next_state = READ_DATA;
            end
            PROCESS: begin
                next_state = IDLE; 
            end
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 1;
        end else if (current_state == START && counter < START_LOW) begin
            data_out <= 0; 
        end else if (current_state == START && counter >= START_LOW) begin
            data_out <= 1;  
        end
    end

    // Reading data from DHT11 (store in data_buffer)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_buffer <= 0;
            bit_index <= 0;
        end else if (current_state == READ_DATA) begin
            if (data_signal_detected) begin
                data_buffer[39 - bit_index] <= data; // Shift data into buffer
                bit_index <= bit_index + 1;
            end
        end
    end

    // Processing the data and extracting humidity and temperature
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            humidity <= 0;
            temperature <= 0;
            valid <= 0;
        end else if (current_state == PROCESS) begin
            humidity <= data_buffer[39:32];      // Extract humidity (8 bits)
            temperature <= data_buffer[23:16];   // Extract temperature (8 bits)
            valid <= 1;                          // Set valid flag
        end
    end

    // Update previous data state (for edge detection)
    always @(posedge clk) begin
        data_prev <= data;
    end

endmodule
