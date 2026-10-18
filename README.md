# UART-Serial-Communication
UART (Universal Asynchronous Receiver-Transmitter) is a serial communication protocol that transmits and receives data between devices using TX and RX lines. This project implements UART transmission using Verilog.

# UART Transmitter Design Using Verilog HDL

<p align="center">
  <b>A clock-driven UART transmitter RTL design for reliable asynchronous serial communication.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/HDL-Verilog-blue?style=for-the-badge&logo=logic" alt="Verilog"/>
  <img src="https://img.shields.io/badge/Design-Digital%20Logic-purple?style=for-the-badge" alt="Digital Logic"/>
  <img src="https://img.shields.io/badge/Domain-VLSI-orange?style=for-the-badge" alt="VLSI"/>
  <img src="https://img.shields.io/badge/Platform-FPGA-green?style=for-the-badge" alt="FPGA"/>
</p>

---

## Overview

This project implements a **UART (Universal Asynchronous Receiver-Transmitter) transmitter** using Verilog HDL. It converts parallel input data into a serial bit stream suitable for asynchronous communication between digital systems.

The design focuses on sequential logic, clock-cycle control, data serialization, and transmission status management. It demonstrates how a communication protocol can be translated into synthesizable RTL using a structured hardware design approach.

## Key Features

- **Serial Data Transmission** — Converts parallel data into a serial output stream.
- **Finite State Machine (FSM)** — Organizes the transmission process into clearly defined states.
- **Clock-Driven Operation** — Uses a clock and timing logic to control data transmission.
- **Transmission Status** — Provides status signals to indicate transmission activity and completion, where implemented.
- **RTL-Based Design** — Written in Verilog HDL with a focus on digital hardware design principles.
- **FPGA-Oriented Development** — Suitable for RTL simulation and FPGA implementation, subject to verification and constraints.

## UART Frame Format

A typical UART frame consists of a start bit, data bits, an optional parity bit, and stop bit(s). The exact configuration depends on the implementation.

```text
       Idle       Start       Data Bits         Stop
        1           0       D0 D1 ... D7          1
    ─────────┐     ┌───────────────────────┐    ─────
             └─────┘                       └─────────
```

UART transmits data **least-significant bit first (LSB first)** in a conventional frame. Confirm the bit order and frame configuration against your RTL implementation.

## How It Works

1. **Idle:** The transmitter waits for a transmission request.
2. **Load Data:** The input byte is captured into an internal register.
3. **Start Bit:** The serial output is driven low to indicate the beginning of a frame.
4. **Data Transmission:** The stored data bits are transmitted sequentially according to the configured timing.
5. **Stop Bit:** The output returns high to mark the end of the frame.
6. **Completion:** The transmitter indicates that the frame has finished, if a completion signal is implemented.

## Design Concepts Demonstrated

- Verilog procedural blocks and nonblocking assignments
- Finite state machine design
- Counters and clock dividers
- Parallel-to-serial conversion
- UART framing and bit timing
- Reset handling and control-signal sequencing
- RTL simulation and waveform analysis

## Repository Structure

```text
Verilog-UART-Transmitter/
├── UART_TX.v          # UART transmitter RTL
├── testbench.v        # Simulation testbench (if included)
├── constraints.xdc    # FPGA pin and timing constraints (if included)
└── README.md          # Project documentation
```

*Adjust the filenames above to match the actual files in your repository.*

## Tools and Technologies

| Technology | Purpose |
|---|---|
| Verilog HDL | RTL design |
| AMD Vivado | Simulation, synthesis, and FPGA implementation, if used |
| Waveform Viewer | Inspecting timing and signal behavior |
| FPGA Board | Hardware validation, if available |

## Verification Checklist

Before considering the design complete, verify:

- Reset initializes the transmitter correctly.
- A transmission request loads the intended data.
- The start bit and stop bit have the correct logic levels.
- Data bits appear in the correct order.
- Bit duration matches the configured baud rate.
- Completion and busy signals behave correctly, if implemented.
- Back-to-back transmissions work as intended.

## Future Improvements

- Configurable baud-rate generation
- Parameterized data width and stop-bit configuration
- Optional parity-bit support
- UART receiver implementation
- Loopback testing and automated testbench checks
- FPGA hardware demonstration

## Learning Outcomes

This project strengthens practical understanding of **RTL design, finite state machines, synchronous digital logic, counters, serial communication, and FPGA design workflows**. It provides a foundation for developing larger digital systems and communication interfaces.

## AUTHOR

S. KISHORE NAIK 

Interested in VLSI design, digital electronics, Verilog HDL, and FPGA-based system development.

---

*Designed to explore the fundamentals of serial communication through practical RTL development.*
