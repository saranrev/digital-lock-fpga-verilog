`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module digital_lock(
    input clk,           // FPGA clock (50MHz)
    input rst,           // Synchronous reset input (active high)
    input [2:0] dip_sw,  // DIP switches for password input

    output reg led_lock,
    output reg led_unlock,
    output reg led_idle,
    output reg led_input,
    output reg led_verify,
    output reg led_error
);

    // ---------------------------------------------------------
    // Clock Dividers (synchronous)
    // 50 MHz -> 1 Hz
    reg [24:0] cnt_1hz;   
    reg clk_1hz;

    always @(posedge clk) begin
        if (rst) begin
            cnt_1hz <= 25'd0;
            clk_1hz <= 1'b0;
        end else if (cnt_1hz == 25'd24_999_999) begin
            cnt_1hz <= 25'd0;
            clk_1hz <= ~clk_1hz;
        end else
            cnt_1hz <= cnt_1hz + 25'd1;
    end

    // 50 MHz -> 1 kHz
    reg [14:0] cnt_1khz;
    reg clk_1khz;

    always @(posedge clk) begin
        if (rst) begin
            cnt_1khz <= 15'd0;
            clk_1khz <= 1'b0;
        end else if (cnt_1khz == 15'd24_999) begin
            cnt_1khz <= 15'd0;
            clk_1khz <= ~clk_1khz;
        end else
            cnt_1khz <= cnt_1khz + 15'd1;
    end

    // ---------------------------------------------------------
    // FSM States
    // ---------------------------------------------------------
    localparam IDLE   = 3'b000;
    localparam INPUT  = 3'b001;
    localparam VERIFY = 3'b010;
    localparam UNLOCK = 3'b011;
    localparam ERROR  = 3'b100;

    localparam [2:0] CORRECT_CODE = 3'b101;

    reg [2:0] state, next_state;
    reg [2:0] dip_prev;
    wire dip_change = (dip_prev != dip_sw);

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            dip_prev <= dip_sw;
        end else begin
            state <= next_state;
            dip_prev <= dip_sw;
        end
    end

    // ---------------------------------------------------------
    // Timers
    // ---------------------------------------------------------
    reg [2:0] timeout;       // 7 sec max
    reg [1:0] stable_cnt;    // 2 sec max
    reg stable;
    reg [2:0] unlock_cnt;    // 5 sec max
    reg [7:0] error_cnt;     // 250 ms max

    // Timeout counter
    always @(posedge clk_1hz) begin
        if (rst)
            timeout <= 3'd0;
        else if (state == INPUT)
            timeout <= (timeout < 3'd7) ? timeout + 3'd1 : timeout;
        else
            timeout <= 3'd0;
    end

    // Stable DIP counter
    always @(posedge clk_1hz) begin
        if (rst) begin
            stable_cnt <= 2'd0;
            stable <= 1'b0;
        end else if (state == INPUT) begin
            if (dip_change) begin
                stable_cnt <= 2'd0;
                stable <= 1'b0;
            end else if (stable_cnt < 2'd2)
                stable_cnt <= stable_cnt + 2'd1;
            else
                stable <= 1'b1;
        end else begin
            stable_cnt <= 2'd0;
            stable <= 1'b0;
        end
    end

    // Unlock counter
    always @(posedge clk_1hz) begin
        if (rst)
            unlock_cnt <= 3'd0;
        else if (state == UNLOCK)
            unlock_cnt <= (unlock_cnt < 3'd5) ? unlock_cnt + 3'd1 : unlock_cnt;
        else
            unlock_cnt <= 3'd0;
    end

    // Error counter
    always @(posedge clk_1khz) begin
        if (rst)
            error_cnt <= 8'd0;
        else if (state == ERROR)
            error_cnt <= (error_cnt < 8'd250) ? error_cnt + 8'd1 : error_cnt;
        else
            error_cnt <= 8'd0;
    end

    // ---------------------------------------------------------
    // Next State Logic
    // ---------------------------------------------------------
    always @(*) begin
        next_state = state; // default

        case (state)
            IDLE:
                if (dip_change) next_state = INPUT;

            INPUT: begin
                if (stable) next_state = VERIFY;
                else if (timeout >= 3'd7) next_state = ERROR;
            end

            VERIFY:
                next_state = (dip_sw == CORRECT_CODE) ? UNLOCK : ERROR;

            UNLOCK:
                if (unlock_cnt >= 3'd5) next_state = IDLE;

            ERROR:
                if (error_cnt >= 8'd250) next_state = IDLE;
        endcase
    end

    // ---------------------------------------------------------
    // Output LED Logic (Combinational)
    // ---------------------------------------------------------
    always @(*) begin
        // Default: all LEDs OFF
        led_lock   = 1'b0;
        led_unlock = 1'b0;
        led_idle   = 1'b0;
        led_input  = 1'b0;
        led_verify = 1'b0;
        led_error  = 1'b0;

        case (state)
            IDLE: begin
                led_lock = 1'b1;
                led_idle = 1'b1;
            end
            INPUT: begin
                led_lock  = 1'b1;
                led_input = 1'b1;
            end
            VERIFY: begin
                led_lock   = 1'b1;
                led_verify = 1'b1;
            end
            UNLOCK: begin
                led_lock   = 1'b0; // turn OFF lock LED
                led_unlock = 1'b1; // turn ON unlock LED
            end
            ERROR: begin
                led_lock  = 1'b1;
                led_error = 1'b1;
            end
        endcase
    end

endmodule


