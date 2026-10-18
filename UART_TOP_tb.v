
`timescale 1ns/1ps

module UART_TOP_tb;

    reg clk;
    reg rst;
    reg [1:0] baudrate;
    reg [7:0] dataout;
    reg start;

    wire [7:0] datain;
    wire tx_serial;
    wire tx_busy;
    wire tx_finish;
    wire rx_busy;
    wire rx_finish;

    integer errors;
    integer cycles;

    UART_TOP dut (
        .clk(clk),
        .rst(rst),
        .baudrate(baudrate),
        .dataout(dataout),
        .start(start),
        .datain(datain),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy),
        .tx_finish(tx_finish),
        .rx_busy(rx_busy),
        .rx_finish(rx_finish)
    );

    // 50 MHz clock
    always #10 clk = ~clk;

    task send_byte;
        input [7:0] value;
        reg received;
        begin
            // Wait for transmitter to be ready
            wait (tx_busy == 1'b0);
            @(negedge clk);

            dataout = value;
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;

            received = 1'b0;
            cycles = 0;

            // 60000 cycles allows a full 9600-baud frame
            while ((cycles < 60000) && !received) begin
                @(negedge clk);

                if (rx_finish) begin
                    received = 1'b1;

                    if (datain === value) begin
                        $display(
                            "PASS: Sent=%h Received=%h Time=%0t",
                            value, datain, $time
                        );
                    end
                    else begin
                        $display(
                            "FAIL: Sent=%h Received=%h Time=%0t",
                            value, datain, $time
                        );
                        errors = errors + 1;
                    end
                end

                cycles = cycles + 1;
            end

            if (!received) begin
                $display(
                    "TIMEOUT: No RX finish for byte %h",
                    value
                );
                errors = errors + 1;
            end

            // Do not start another frame until both modules are idle
            wait (tx_busy == 1'b0);
            wait (rx_busy == 1'b0);
            repeat (10) @(negedge clk);
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        baudrate = 2'b00;  // 9600 baud
        dataout = 8'h00;
        start = 0;
        errors = 0;

        repeat (5) @(negedge clk);
        rst = 0;

        send_byte(8'hA5);
        send_byte(8'h3C);
        send_byte(8'hFF);

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED: %0d error(s)", errors);

        $display("Simulation completed at %0t", $time);
        $finish;
    end

    initial begin
        $monitor(
            "t=%0t rst=%b start=%b tx=%b tx_busy=%b rx_busy=%b rx_finish=%b datain=%h",
            $time, rst, start, tx_serial,
            tx_busy, rx_busy, rx_finish, datain
        );
    end

endmodule
