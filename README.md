# NDHU CSIE SoC Design

This project implements a RISC-V RV32-based System-on-Chip (SoC) in Verilog, utilizing Verilator for RTL compilation and simulation, and performing functional verification by loading bare-metal firmware via a C++ testbench.

The processor features a pipelined architecture comprising Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write-Back (WB) stages, integrated with RAM, a Console, a Timer, a CLINT (Core-Local Interruptor), interrupt handling, and Machine-mode CSRs (Control and Status Registers).

- **Technical Documentation & Development Logs**: [HackMD note](https://hackmd.io/@linyh212/rJZLTEnpfl)

## Development Environment

- Verilator
- RISC-V GNU Toolchain (`gcc`, `objcopy`, `objdump`)
- GNU Make and a C++ compiler
- Python 3 (for ISA batch testing)
- GTKWave (optional, for waveform analysis)

## Build & Run

```sh
make clean
make
```

The default target compiles the ISA test programs, builds the Verilator simulator, and runs the tests. You can also specify a custom firmware binary image:

```sh
./build/Vtest_top path/to/firmware.bin
```

## Firmware & CoreMark

```sh
make build_c_fw
make run_c

make build_cm
make coremark
```

The firmware outputs execution logs via the MMIO Console. Upon normal completion, it displays `[RESULT] PASS`; if the simulation cycle limit is exceeded, it reports a Timeout.

## ISA Testing

```sh
make test
```

After building the simulator and test images, this runs `soc/test_all_isa.py`. The test script searches the following directories:

- `soc/firmware/isa_tests/isa/generated/*.bin`
- `soc/firmware/riscv-tests/isa/generated/*.bin` (fallback path)

If the generated test images are missing, the full ISA test suite cannot be executed.

## Memory Map

| Device | Base Address | Description |
| --- | --- | --- |
| RAM | `0x00000000` | 1 MiB |
| Console | `0x00200000` | Output and control registers |
| Timer | `0x00300000` | Control, prescaler, counter, and compare registers |
| CLINT | `0x02000000` | Software interrupt, `mtimecmp`, `mtime` |

## Waveform & Cleanup

```sh
make wave
make clean
```

`make wave` executes the default ISA test and opens `wave.vcd` using GTKWave. `make clean` removes build artifacts, waveforms, and log files.

## Project Structure

```text
soc/
├── rtl/
│   ├── core/       # Processor pipeline, control logic, and CSR/interrupt handling
│   ├── memory/     # ROM, RAM, and dual-port RAM modules
│   └── device/     # SoC bus, Console, Timer, and CLINT
├── sim/            # Verilator C++ testbench and simulated memory loader
├── firmware/       # Bare-metal C firmware and ISA test programs
└── coremark/       # CoreMark benchmark
```