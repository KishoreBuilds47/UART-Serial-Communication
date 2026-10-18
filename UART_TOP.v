
`timescale 1ns/1ps

module UART_TOP(
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

    // Serial communication line between TX and RX
    wire serial_line;

    // UART Transmitter
    UART_TX transmitter (
        .clk(clk),
        .rst(rst),
        .dataout(dataout),
        .baudrate(baudrate),
        .start(start),
        .tx(serial_line),
        .busy(tx_busy),
        .finish(tx_finish)
    );

    // UART Receiver
    UART_RX receiver (
        .clk(clk),
        .rst(rst),
        .baudrate(baudrate),
        .rx(serial_line),
        .datain(datain),
        .busy(rx_busy),
        .finish(rx_finish)
    );

    // Expose the serial line for waveform observation
    assign tx_serial = serial_line;

endmodule
