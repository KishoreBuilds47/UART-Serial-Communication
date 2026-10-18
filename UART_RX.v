
`timescale 1ns/1ps

module UART_RX #(
    parameter integer frequency = 50000000
)(
    input wire clk,
    input wire rst,
    input wire [1:0] baudrate,
    input wire rx,
    output reg [7:0] datain,
    output reg busy,
    output reg finish
);

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state;
    reg [2:0] bitno;
    reg [7:0] shift_data;
    reg [31:0] count;
    reg [31:0] bit_period;

    // Baud-rate timing
    always @(*) begin
        case (baudrate)
            2'b00: bit_period = frequency / 9600;
            2'b01: bit_period = frequency / 19200;
            2'b10: bit_period = frequency / 38400;
            2'b11: bit_period = frequency / 57600;
            default: bit_period = frequency / 9600;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            bitno      <= 0;
            shift_data <= 0;
            count      <= 0;
            datain     <= 0;
            busy       <= 0;
            finish     <= 0;
        end
        else begin
            finish <= 1'b0;

            case (state)

                IDLE: begin
                    count <= 0;
                    bitno <= 0;
                    busy  <= 0;

                    if (rx == 1'b0) begin
                        state <= START;
                        count <= 0;
                        busy  <= 1'b1;
                    end
                end

                START: begin
                    // Verify start bit near its center
                    if (count < (bit_period / 2) - 1) begin
                        count <= count + 1'b1;
                    end
                    else begin
                        count <= 0;

                        if (rx == 1'b0) begin
                            state      <= DATA;
                            bitno      <= 0;
                            shift_data <= 0;
                        end
                        else begin
                            // False start
                            state <= IDLE;
                            busy  <= 0;
                        end
                    end
                end

                DATA: begin
                    // Sample data bits at their centers
                    if (count < bit_period - 1) begin
                        count <= count + 1'b1;
                    end
                    else begin
                        count <= 0;

                        // UART data arrives LSB first
                        shift_data <= {rx, shift_data[7:1]};

                        if (bitno == 3'd7) begin
                            bitno <= 0;
                            state <= STOP;
                        end
                        else begin
                            bitno <= bitno + 1'b1;
                        end
                    end
                end

                STOP: begin
                    if (count < bit_period - 1) begin
                        count <= count + 1'b1;
                    end
                    else begin
                        count <= 0;
                        state <= IDLE;
                        busy  <= 0;

                        if (rx == 1'b1) begin
                            datain <= shift_data;
                            finish <= 1'b1;
                        end
                    end
                end

                default: begin
                    state      <= IDLE;
                    bitno      <= 0;
                    shift_data <= 0;
                    count      <= 0;
                    busy       <= 0;
                    finish     <= 0;
                end

            endcase
        end
    end

endmodule
