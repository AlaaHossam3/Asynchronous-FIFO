# Asynchronous FIFO Verification

## Project Overview
This repository contains the RTL implementation and a robust SystemVerilog verification environment for a **Synchronous FIFO (First-In-First-Out)** memory buffer. The design is parameterized and includes a suite of status flags to handle flow control. The verification environment utilizes a class-based layered testbench approach, including randomization, functional coverage, and self-checking mechanisms.


## Design Specifications (RTL)
The Design Under Test (DUT) is a synchronous FIFO with the following characteristics:
* **Parameters:** Configurable Data Width (default: 16) and FIFO Depth (default: 8).
* **Reset:** Active low asynchronous reset.
* **Status Flags:**
    * `full` / `empty`: Standard flow control.
    * `almostfull` / `almostempty`: Triggered when only one slot remains or is filled.
    * `overflow` / `underflow`: Sequential error flags for invalid operations.
    * `wr_ack`: Write acknowledgement signal.
* **Corner Case Logic:**
    * If `wr_en` and `rd_en` occur simultaneously when **Full**: Only Reading takes place.
    * If `wr_en` and `rd_en` occur simultaneously when **Empty**: Only Writing takes place.

## Verification Environment 
The testbench is built using SystemVerilog and follows a layered architecture.

### 1. Components
* **Transaction Class (`FIFO_transaction`):** Encapsulates inputs (`data_in`, `rst_n`, enables) and outputs. Includes constrained randomization to assert write/read enables with specific distributions (default: 70% write, 30% read).
* **Monitor:** Samples the interface signals on the negative edge of the clock using events to ensure accurate sampling order. It broadcasts transactions to the Scoreboard and Coverage objects.
* **Scoreboard (`FIFO_scoreboard`):** Implements a **Golden Reference Model**. It mimics expected FIFO behavior, predicts outputs, and compares them against the DUT outputs to flag errors.
* **Functional Coverage (`FIFO_coverage`):** Collects Cross Coverage between `wr_en`, `rd_en`, and output flags (overflow, underflow, etc.) to ensure all control combinations are verified.

### 2. Assertions (SVA)
SystemVerilog Assertions are embedded in the design to verify:
* Reset behavior (pointers/counters clearing).
* Overflow/Underflow triggering.
* Pointer wraparound and threshold safety.
