`ifndef _DEFINES_V_
`define _DEFINES_V_

// 1. Architecture & Memory Parameters
`define RNUM            32
`define RADDR_WIDTH     5
`define RDATA_WIDTH     32
`define ADDR_WIDTH      32
`define DATA_WIDTH      32

`define MEM_SIZE        32'h200000
`define MEM_OFFSET      32'h00000000
`define PART_ADDR_WIDTH 21
`define RAM_SIZE        65536
`define RAM_ADDR_WIDTH  16

`define BOOT_ROM_ADDR   32'h1000_0000

// 2. General Constants & System Control Signals
`define ZERO            32'h00000000
`define ZERO_REG        5'b0
`define NOP             32'h00000013

`define WRITE_ENABLE    1'b1
`define WRITE_DISABLE   1'b0
`define READ_ENABLE     1'b1
`define READ_DISABLE    1'b0
`define STOP            1'b1
`define NOSTOP          1'b0

// 3. RISC-V Main Instruction Opcodes (inst[6:0])
`define INST_TYPE_L      7'b0000011
`define INST_TYPE_I      7'b0010011
`define INST_TYPE_AUIPC  7'b0010111
`define INST_TYPE_S      7'b0100011
`define INST_TYPE_R_M    7'b0110011
`define INST_TYPE_LUI    7'b0110111
`define INST_TYPE_B      7'b1100011
`define INST_TYPE_JALR   7'b1100111
`define INST_TYPE_JAL    7'b1101111
`define INST_TYPE_SYSTEM 7'b1110011

// 4. RISC-V Instruction Function Codes (Funct3 - inst[14:12])
// --- I-Type ---
`define INST_ADDI       3'b000
`define INST_SLTI       3'b010
`define INST_SLTIU      3'b011
`define INST_XORI       3'b100
`define INST_ORI        3'b110
`define INST_ANDI       3'b111

// --- R-Type (funct7 distinguishes ADD/SUB and SRL/SRA) ---
`define INST_ADD_SUB    3'b000
`define INST_SLL        3'b001
`define INST_SLT        3'b010
`define INST_SLTU       3'b011
`define INST_XOR        3'b100
`define INST_SR         3'b101
`define INST_OR         3'b110
`define INST_AND        3'b111

// --- M-Type (requires funct7 = 7'b0000001) ---
`define INST_MUL        3'b000
`define INST_MULH       3'b001
`define INST_MULHSU     3'b010
`define INST_MULHU      3'b011
`define INST_DIV        3'b100
`define INST_DIVU       3'b101
`define INST_REM        3'b110
`define INST_REMU       3'b111

// --- L-Type ---
`define INST_LB         3'b000
`define INST_LH         3'b001
`define INST_LW         3'b010
`define INST_LBU        3'b100
`define INST_LHU        3'b101

// --- S-Type ---
`define INST_SB         3'b000
`define INST_SH         3'b001
`define INST_SW         3'b010

// --- B-Type ---
`define INST_BEQ        3'b000
`define INST_BNE        3'b001
`define INST_BLT        3'b100
`define INST_BGE        3'b101
`define INST_BLTU       3'b110
`define INST_BGEU       3'b111

// --- System & CSR Privileged Instructions ---
`define INST_CSR_PRIV   3'b000
`define INST_CSRRW      3'b001
`define INST_CSRRS      3'b010
`define INST_CSRRC      3'b011
`define INST_CSRRWI     3'b101
`define INST_CSRRSI     3'b110
`define INST_CSRRCI     3'b111

// 5. Internal Decoded Control Codes
`define MEM_NOP         4'b0000
`define SB              4'b0001
`define SH              4'b0010
`define SW              4'b0011
`define LB              4'b1001
`define LH              4'b1010
`define LW              4'b1011
`define LBU             4'b1100
`define LHU             4'b1101

// 6. CSR Addresses (Machine Mode)
`define CSR_ADDR_WIDTH          12

// --- Machine Information (Read-Only) ---
`define CSR_MVENDORID_ADDR      12'hF11
`define CSR_MARCHID_ADDR        12'hF12
`define CSR_MIMPID_ADDR         12'hF13
`define CSR_MHARTID_ADDR        12'hF14

// --- Machine Trap Setup & Control ---
`define CSR_MSTATUS_ADDR        12'h300
`define CSR_MISA_ADDR           12'h301
`define CSR_MIE_ADDR            12'h304
`define CSR_MTVEC_ADDR          12'h305
`define CSR_MCOUNTEREN_ADDR     12'h306
`define CSR_MCOUNTINHIBIT_ADDR  12'h320

// --- Machine Trap Handling ---
`define CSR_MSCRATCH_ADDR       12'h340
`define CSR_MEPC_ADDR           12'h341
`define CSR_MCAUSE_ADDR         12'h342
`define CSR_MTVAL_ADDR          12'h343
`define CSR_MIP_ADDR            12'h344

// --- Machine Counter & Timer ---
`define CSR_MCYCLE_ADDR         12'hB00
`define CSR_MCYCLEH_ADDR        12'hB80
`define CSR_MINSTRET_ADDR       12'hB02
`define CSR_MINSTRETH_ADDR      12'hB82
`define CSR_CYCLE_ADDR          12'hC00
`define CSR_CYCLEH_ADDR         12'hC80

`endif
