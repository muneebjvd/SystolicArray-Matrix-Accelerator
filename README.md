# Configurable 2D Systolic Array Hardware Accelerator

[cite_start]A parameterizable, bare-metal **2D Systolic Array Accelerator Core** designed in Verilog HDL[cite: 3522, 3526, 3952]. [cite_start]Optimized for Deep Learning inference and high-speed digital signal processing workloads, this chip architecture supports runtime array structural configurations, spatial computing paradigms, and variable dataflow scheduling profiles[cite: 3523, 3525, 3681]. 

[cite_start]The complete system includes the hardware processor matrix array, a memory-mapped interface decoder layer, custom full-duplex UART transceivers, and an integrated 32-bit PicoRV32 RISC-V soft processor core[cite: 3863, 3909, 3913].

---

## 🚀 Key Architectural Features
* [cite_start]**Parameterizable Matrix Grid:** Supports runtime-configurable array shapes from $3\times3$ up to $5\times5$ computing cells using reusable processing elements[cite: 3526, 3677].
* [cite_start]**Dual Dataflow Infrastructures:** Selective compilation/runtime execution targeting **Weight-Stationary (WS)** for 2D convolutions or **Output-Stationary (OS)** modes for General Matrix Multiplications (GEMM)[cite: 3523, 3527, 3701].
* [cite_start]**Arithmetic Units:** Hardware pipelines handling 16-bit signed operands (2's complement arithmetic via `$signed()`) yielding 32-bit accumulated results[cite: 3528, 3583, 3705].
* [cite_start]**Data Ingestion Model:** Employs a skewed **Diagonal Wavefront Data Feeding** model to guarantee 100% processing element allocation efficiency following initial pipeline scheduling ramps[cite: 3530, 3707, 3711].
* [cite_start]**Multi-Route I/O Architecture:** 1. *ROM/RAM Static Mode:* Controlled file initializations parsing input vectors natively via automated `.hex` file writers[cite: 3539, 3540].
  2. [cite_start]*UART Serial Communication:* Standard interactive interface streaming bytes full-duplex over a 9600-baud configuration layer[cite: 3863, 3889, 3987].
  3. [cite_start]*RISC-V Coprocessor Mode:* Memory-mapped register bus translation hooks enabling custom bare-metal runtime software execution from within a local CPU[cite: 3909, 3995].

---

## 🗺️ Functional Hardware System Layout

```text
       ┌──────────────┐         ┌───────────────┐
       │  Input ROM   ├────────►│  Control FSM  │
       │ (.hex files) │ 16-bit  │ (State Machine│
       └──────────────┘  Data   └───────┬───────┘
                                        │ Start / Reset
                                        ▼
 ┌──────────────┐ Size & Flow  ┌─────────────────────────┐
 │Configuration ├─────────────►│   5x5 Systolic Array    │
 │ Registers    │ Signals      │ (25 Processing Elements)│
 └──────────────┘              └────────┬────────────────┘
                                        │ 32-bit Results
                                        ▼
 ┌──────────────┐ Capture      ┌─────────────────────────┐
 │ File Writer  │◄─────────────┤       Output RAM        │
 │ (.hex export)│ Signal       │     (25 Registers)      │
 └──────────────┘              └─────────────────────────┘
💻 Hardware Micro-Architecture Specs1. Processing Element (PE) DesignEach structural computation cell wraps an isolated signed multiplier-accumulator pipeline stage alongside dedicated data forwarding registers:
  $$\text{ans} \leftarrow \text{ans} + (\text{inp\_a} \times \text{inp\_b})$$  Plaintext inp_a (16-bit) ───┬──────────────────┐
                   ▼                  │
             ┌───────────┐            ▼
             │16x16 mult │     ┌────────────┐
             └─────┬─────┘     │ Register A │───► out_a (to East PE)
                   │ 32-bit    └────────────┘
                   ▼                  ▲
             ┌───────────┐            │
             │32-bit Add │     ┌────────────┐
             └─────┬─────┘     │ Register B │───► out_b (to South PE)
                   │           └────────────┘
                   ▼                  ▲
           ┌──────────────┐           │
           │ Accumulator  ├───────────┴─ inp_b (16-bit)
           └──────┬───────┘
                  ▼
            ans (32-bit output)
2. RISC-V Memory Map Interface AllocationsWhen processing internally via the embedded soft core system, the matrix array accelerator sits mapped within the standard CPU programmatic address range space starting from address block 0x10000000:  Byte Address Address RangeAssigned Name RegistryAccess ModeHardware/Software Functional Context0x10000000CONTROLR/WSetting bit[0] = 1 issues an instant evaluation start trigger.  0x10000004STATUSRTrack pipeline conditions: bit[0] = done, bit[1] = busy.  0x10000008INPUT_A0WLoads the structural element coordinate 0 buffer entry for Matrix A.  0x10000018INPUT_A4WLoads the structural element coordinate 4 buffer entry for Matrix A.  0x1000001CINPUT_B0WLoads the structural element coordinate 0 buffer entry for Matrix B.  0x1000002CINPUT_B4WLoads the structural element coordinate 4 buffer entry for Matrix B.  0x10000030OUTPUT_C00RExtract computed product matrix array coordinate position [0][0].  0x10000090OUTPUT_C44RExtract computed product matrix array coordinate position [4][4].  📊 Synthesis, Performance, & Benchmarking DataPost-synthesis metrics evaluated on a host Xilinx Nexys 4 Development Board (Artix-7 FPGA) utilizing standard Vivado compile timing suites:  Estimated Maximum Clock Frequency ($F_{max}$): $\sim 250\text{ MHz}$.  Peak Computational Throughput Density: $25\text{ MAC operations / cycle}$ (Running on a $5\times5$ configuration setup).  Maximum Theoretical Hardware Ingestion Bandwidth: $40\text{ Gbps}$ operating sustained at 250MHz system clock rates.  Total Static Processing Latency Profile ($5\times5$ Matrix): $15\text{ clock cycles total}$ ($60\text{ ns}$ execution bounds at 250MHz).  Resource Allocation Reports (Post-Synthesis)Target FPGA Hardware Resource Block3×3 Grid Deployment Mode5×5 Grid Deployment ModeOperational Engineering Context / JustificationLook-Up Tables (LUTs)~1,800~5,000Core processing grid combinational logic mapping.  Flip-Flops (FFs)~1,200~3,300Multi-stage hardware internal storage registers.  DSP Micro Slices925Dedicated hard $16\times16$ MAC primitives mapped per cell.  Block RAM Blocks (BRAM)22Divided blocks handling dedicated ROM/RAM storage steps.  
