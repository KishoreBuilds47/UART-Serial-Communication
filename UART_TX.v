`timescale 1ns/1ps

module UART_TX(
    input wire clk,
    input wire rst,
    input wire [7:0] dataout,
    input wire [1:0] baudrate,
    input wire start,
    output reg tx,
    output reg busy,
    output reg finish
);

    reg [1:0] state;
    reg [2:0] bitno;
    reg [7:0] data_out;
    reg [15:0] count;
    reg [15:0] baud_count;
    reg [15:0] bit_timeperiod;

    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter END   = 2'b11;
    parameter frequency = 50000000;

    
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

    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            bitno   <= 0;
            data_out <= 0;
            count   <= 0;
            tx      <= 1;
            busy    <= 0;
            finish  <= 0;
        end
        else begin
            case (state)

                
                IDLE: begin
                    tx     <= 1;
                    busy   <= 0;
                    finish <= 0;
                    count  <= 0;
                    bitno  <= 0;

                    if (start) begin
                        data_out <= dataout;
                        tx       <= 0;
                        busy     <= 1;
                        state    <= START;
                        count    <= 0;
                    end
                end

                START: begin
                    if (count < bit_timeperiod - 1) begin
                        count <= count + 1;
                    end
                    else begin
                        tx      <= data_out[0];
                        data_out <= data_out >> 1;
                        bitno   <= 1;
                        count   <= 0;
                        state   <= DATA;
                    end
                end

                DATA: begin
                    if (count < bit_timeperiod - 1) begin
                        count <= count + 1;
                    end
                    else begin
                        tx    <= data_out[0];
                        count <= 0;

                        if (bitno == 3'd7) begin
                            state <= END;
                        end
                        else begin
                            data_out <= data_out >> 1;
                            bitno <= bitno + 1;
                        end
                    end
                end

                END: begin
                    if (count < bit_timeperiod - 1) begin
                        count <= count + 1;
                    end
                    else begin
                        tx     <= 1;
                        busy   <= 0;
                        finish <= 1;
                        count  <= 0;
                        state  <= IDLE;
                    end
                end

                default: begin
                    state  <= IDLE;
                    tx     <= 1;
                    busy   <= 0;
                    finish <= 0;
                    count  <= 0;
                    bitno  <= 0;
                end

            endcase
        end
    end

endmodule