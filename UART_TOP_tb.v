
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

    // Instantiate the top module
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

    // 50 MHz clock: 20 ns period
    always #10 clk = ~clk;

    // Send one byte and check the received result
    
    task send_byte;
        input [7:0] value;
        integer cycles;
        reg received;
        begin
            @(negedge clk);
            dataout = value;
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;

            received = 1'b0;

        // Wait for receiver completion, up to 60,000 clock cycles
            for (cycles = 0; cycles < 60000; cycles = cycles + 1) begin
                @(negedge clk);

                if (rx_finish) begin
                    received = 1'b1;

                    if (datain === value)
                        $display("PASS: Sent=%h Received=%h at time %0t",
                             value, datain, $time);
                    else
                        $display("FAIL: Sent=%h Received=%h at time %0t",
                             value, datain, $time);

                    cycles = 60000;
                end
            end

            if (!received)
                $display("TIMEOUT: No receive finish for byte %h", value);

            repeat (10) @(negedge clk);
        end
    endtask


    initial begin
        clk = 0;
        rst = 1;
        baudrate = 2'b00;  // 9600 baud
        dataout = 8'h00;
        start = 0;

        // Release reset
        repeat (5) @(negedge clk);
        rst = 0;

        // Test different bit patterns
        send_byte(8'hA5);
        send_byte(8'h3C);
        send_byte(8'hFF);

        #1000;
        $display("Simulation completed.");
        $finish;
    end

    // Observe the main signals
    initial begin
        $monitor(
            "t=%0t rst=%b start=%b tx=%b tx_busy=%b rx_busy=%b rx_finish=%b datain=%h",
            $time, rst, start, tx_serial, tx_busy, rx_busy, rx_finish, datain
        );
    end

endmodule
