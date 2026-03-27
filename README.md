# Hardware-Accelerated DMA Controller (RTL)

## Project Overview
This project implements a **Direct Memory Access (DMA) Controller** in Verilog. The goal was to design a hardware module capable of offloading memory-to-memory block transfers from a CPU, thereby reducing system latency and increasing CPU availability for computational tasks.

## Key Features
* **4-State Finite State Machine (FSM):** Optimized transitions between `IDLE`, `READ`, `WRITE`, and `DONE` to ensure timing accuracy.
* **Cycle-Accurate Simulation:** Verified using Icarus Verilog and GTKWave.
* **Resource Efficiency:** Uses a minimal 8-bit data bus architecture (scalable to 32/64-bit).

---

## The Engineering Process: Evolution & Debugging
I intentionally documented the development process through Git commits to demonstrate hardware debugging skills:

### 1. Initial 3-State Implementation (The Bug)
The first version used a simplified 3-state FSM. During simulation, I identified a **synchronous write latency issue** where the final byte of a transfer (e.g., `0xCC`) was not being latched into memory because the `done` signal fired one clock cycle too early.

### 2. 4-State Refinement (The Fix)
I resolved the "off-by-one" error by introducing a dedicated `DONE` state. This provides the necessary clock cycle for the final memory write to settle before the controller returns to `IDLE`, ensuring 100% data integrity across all block sizes.

> Athough at time of final git push I had only the final 4 state FSM & Testbench I intentionally undid and temporally went back to the 3 state FSM & Testbech to illustrate my entire workflow and design process.

---

## Performance Benchmarks
Benchmarked against a standard software-driven memory loop (typically 4-5 cycles per byte):

| Metric | Software (CPU) | DMA (Hardware) | Improvement |
| :--- | :--- | :--- | :--- |
| **Cycles per Byte** | ~4 Cycles | 2 Cycles | **2x Speedup** |
| **1KB Transfer** | 4,096 Cycles | 2,048 Cycles | **50% Latency Reduction** |
| **CPU Overhead** | 100% | ~0% (Offloaded) | **100% CPU Freedom** |

---

## How to Run Locally
### Prerequisites
* [Icarus Verilog](http://iverilog.icarus.com/)
* [GTKWave](http://gtkwave.sourceforge.net/)

### Execution
1. **Compile:**
   ```bash
   iverilog -o dma_sim dma_controller.v tb_dma.v
   vvp dma_sim
   gtkwave dump.vcd```

---

### Future Extensibility
**Burst Mode:** Implementing multi-word transfers per bus request.
**Bus Arbitration:** Adding `HOLD/HLDA` logic for multi-master system integration.