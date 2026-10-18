
`timescale 1ns/1ps

module UART_TX #(
    parameter integer frequency = 50000000
)(
    input wire clk,
    input wire rst,
    input wire [1:0] baudrate,
    input wire [7:0] dataout,
    input wire start,
    output reg tx,
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
            tx         <= 1'b1;
            busy       <= 1'b0;
            finish     <= 1'b0;
        end
        else begin
            finish <= 1'b0;

            case (state)

                IDLE: begin
                    tx    <= 1'b1;
                    busy  <= 1'b0;
                    count <= 0;
                    bitno <= 0;

                    if (start) begin
                        shift_data <= dataout;
                        tx         <= 1'b0;
                        busy       <= 1'b1;
                        count      <= 0;
                        state      <= START;
                    end
                end

                START: begin
                    if (count < bit_period - 1) begin
                        count <= count + 1'b1;
                    end
                    else begin
                        count      <= 0;
                        tx         <= shift_data[0];
                        shift_data <= shift_data >> 1;
                        bitno      <= 0;
                        state      <= DATA;
                    end
                end

                DATA: begin
                    if (count < bit_period - 1) begin
                        count <= count + 1'b1;
                    end
                    else begin
                        count <= 0;

                        if (bitno == 3'd7) begin
                            tx    <= 1'b1;
                            state <= STOP;
                        end
                        else begin
                            tx         <= shift_data[0];
                            shift_data <= shift_data >> 1;
                            bitno      <= bitno + 1'b1;
                        end
                    end
                end

                STOP: begin
                    tx <= 1'b1;

                    if (count < bit_period - 1) begin
                        count <= count + 1'b1;
                    end
                    else begin
                        count  <= 0;
                        busy   <= 1'b0;
                        finish <= 1'b1;
                        state  <= IDLE;
                    end
                end

                default: begin
                    state  <= IDLE;
                    tx     <= 1'b1;
                    busy   <= 1'b0;
                    finish <= 1'b0;
                    count  <= 0;
                    bitno  <= 0;
                end

            endcase
        end
    end

endmodule
