# UART Communication Using Verilog and Vivado

## Overview

This project implements a Universal Asynchronous Receiver-Transmitter (UART) communication system using Verilog HDL. It includes a transmitter (TX), receiver (RX), and a top-level module that connects both modules in a loopback configuration.

The design is simulated using AMD Xilinx Vivado to verify serial data transmission and reception at different baud rates.

## Features

- UART transmitter and receiver implemented using Verilog HDL.
- Finite State Machine (FSM)-based control logic.
- 8-bit data transmission.
- One start bit and one stop bit.
- Least Significant Bit (LSB) transmitted first.
- Configurable baud rate.
- Internal TX-to-RX loopback for functional verification.
- Testbench-based simulation with automatic data checking.

## Baud Rates

The baud rate is selected using a 2-bit control input.

| `baudrate` | Baud rate |
|---|---:|
| `2'b00` | 9600 |
| `2'b01` | 19200 |
| `2'b10` | 38400 |
| `2'b11` | 57600 |

The default clock frequency is **50 MHz**.

## UART Frame Format

Each transmitted frame contains 10 bits.

```text
  Start       Data Bits (LSB first)           Stop
    0       D0 D1 D2 D3 D4 D5 D6 D7             1
```

- **Start bit:** Logic 0
- **Data bits:** 8 bits
- **Stop bit:** Logic 1
- **Parity:** Not implemented

## Project Structure

```text
UART_COMMUNICATIONS/
├── UART_TX.v       # UART transmitter
├── UART_RX.v       # UART receiver
├── UART_TOP.v      # Top-level loopback connection
├── UART_TOP_tb.v   # Simulation testbench
└── README.md       # Project documentation
```

## Module Description

### 1. UART_TX

The transmitter accepts an 8-bit parallel input and converts it into serial data. It generates the start bit, transmits the data bits in LSB-first order, and generates the stop bit.

### 2. UART_RX

The receiver monitors the serial input, detects the start bit, samples the incoming data, and reconstructs the original 8-bit parallel data. It asserts a completion signal after receiving a valid stop bit.

### 3. UART_TOP

The top-level module connects the transmitter's serial output directly to the receiver's serial input. This loopback arrangement allows transmission and reception to be tested without an external UART device.

### 4. UART_TOP_tb

The testbench generates a 50 MHz clock, applies reset, sends test bytes, and compares the received data against the transmitted values.

Test patterns:

- `8'hA5`
- `8'h3C`
- `8'hFF`

## Tools Used

- **Hardware Description Language:** Verilog HDL
- **Design and Simulation:** AMD Xilinx Vivado
- **Simulator:** Vivado XSim
- **Clock Frequency:** 50 MHz

## How to Run

1. Open AMD Xilinx Vivado.
2. Create or open the UART project.
3. Add `UART_TX.v`, `UART_RX.v`, and `UART_TOP.v` as design sources.
4. Add `UART_TOP_tb.v` as a simulation source.
5. Set `UART_TOP_tb` as the simulation top module.
6. Run **Behavioral Simulation**.
7. Advance the simulation long enough for all frames to complete.
8. Inspect the transcript or waveform to verify the received data.

## Expected Simulation Results

If all test cases pass, the transcript should display:

```text
PASS: Sent=a5 Received=a5
PASS: Sent=3c Received=3c
PASS: Sent=ff Received=ff
ALL TESTS PASSED
```

These are the expected results; actual successful operation must be confirmed by running the simulation.

## Applications

- Serial communication fundamentals
- Digital system design
- FPGA-based communication interfaces
- Verilog FSM design practice
- UART transmitter and receiver verification

## Future Improvements

- Add parity-bit support.
- Implement configurable data and stop-bit lengths.
- Test communication between separate UART modules.
- Integrate the design with an FPGA development board.
- Add error detection for framing errors and invalid data.

## Author
S. Kishore Naik

Developed as a digital design project to understand UART serial communication, finite state machines, and Verilog simulation.
