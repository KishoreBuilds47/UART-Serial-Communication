`timescale 1ns/1ps

module UART_RX(
    input wire clk,
    input wire rst,
    input wire [1:0] baudrate,
    input wire rx,
    output reg [7:0] datain,
    output reg busy,
    output reg finish
);

    reg [1:0] state;
    reg [2:0] bitno;
    reg [7:0] byte8;
    reg [15:0] count;
    reg [15:0] baud_count;
    reg [15:0] bit_timeperiod;

    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter END   = 2'b11;

    parameter frequency = 50000000;

    // Select baud rate and calculate the number of clock cycles per bit
    always @(*) begin
        case (baudrate)
            2'b00: baud_count = 16'd9600;
            2'b01: baud_count = 16'd19200;
            2'b10: baud_count = 16'd38400;
            2'b11: baud_count = 16'd57600;
            default: baud_count = 16'd9600;
        endcase

        bit_timeperiod = frequency / baud_count;
    end

    // UART receiver state machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state  <= IDLE;
            bitno  <= 0;
            byte8  <= 0;
            datain <= 0;
            count  <= 0;
            busy   <= 0;
            finish <= 0;
        end
        else begin
            finish <= 0;

            case (state)
                IDLE: begin
                    count <= 0;
                    bitno <= 0;
                    busy  <= 0;

                    if (rx == 1'b0) begin
                        state <= START;
                        count <= 0;
                        busy  <= 1;
                    end
                end

                START: begin
                    if (count < (bit_timeperiod / 2) - 1) begin
                        count <= count + 1;
                    end
                    else begin
                        count <= 0;

                        if (rx == 1'b0) begin
                            state <= DATA;
                            bitno <= 0;
                        end
                        else begin
                            // False start bit
                            state <= IDLE;
                            busy  <= 0;
                        end
                    end
                end

                DATA: begin
                    if (count < bit_timeperiod - 1) begin
                        count <= count + 1;
                    end
                    else begin
                        count <= 0;
                        byte8 <= {byte8[6:0], rx};

                        if (bitno == 3'd7) begin
                            bitno <= 0;
                            state <= END;
                        end
                        else begin
                            bitno <= bitno + 1;
                        end
                    end
                end

                END: begin
                    if (count < bit_timeperiod - 1) begin
                        count <= count + 1;
                    end
                    else begin
                        count <= 0;
                        state <= IDLE;
                        busy  <= 0;

                        if (rx == 1'b1) begin
                            datain <= byte8;
                            finish <= 1;
                        end
                    end
                end

                default: begin
                    state  <= IDLE;
                    bitno  <= 0;
                    byte8  <= 0;
                    count  <= 0;
                    busy   <= 0;
                    finish <= 0;
                end

            endcase
        end
    end

endmodule