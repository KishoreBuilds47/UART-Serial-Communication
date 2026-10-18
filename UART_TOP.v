
`timescale 1ns/1ps

module UART_TOP (
    input wire clk,
    input wire rst,
    input wire [1:0] baudrate,
    input wire [7:0] dataout,
    input wire start,

    output wire [7:0] datain,
    output wire tx_serial,
    output wire tx_busy,
    output wire tx_finish,
    output wire rx_busy,
    output wire rx_finish
);

    UART_TX transmitter (
        .clk(clk),
        .rst(rst),
        .baudrate(baudrate),
        .dataout(dataout),
        .start(start),
        .tx(tx_serial),
        .busy(tx_busy),
        .finish(tx_finish)
    );

    UART_RX receiver (
        .clk(clk),
        .rst(rst),
        .baudrate(baudrate),
        .rx(tx_serial),
        .datain(datain),
        .busy(rx_busy),
        .finish(rx_finish)
    );

endmodule
