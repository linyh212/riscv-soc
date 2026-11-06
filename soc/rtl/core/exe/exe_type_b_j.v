`include "defines.v"

module exe_type_b_j (
    input wire rst_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input wire[`DATA_WIDTH-1:0] inst_i,
    /* verilator lint_on UNUSEDSIGNAL */
    input wire[`ADDR_WIDTH-1:0] inst_addr_i,
    input wire[`DATA_WIDTH-1:0] op1_i,
    input wire[`DATA_WIDTH-1:0] op2_i,
    output reg[`ADDR_WIDTH-1:0] jump_addr_o,
    output reg jump_enable_o
);
    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    wire op1_eq_op2 = (op1_i == op2_i);
    wire op1_lt_op2 = ($signed(op1_i) < $signed(op2_i));
    wire op1_ltu_op2 = (op1_i < op2_i);
    wire[`DATA_WIDTH-1:0] jal_imm = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
    wire[`DATA_WIDTH-1:0] jalr_imm = {{20{inst_i[31]}}, inst_i[31:20]};
    wire[`DATA_WIDTH-1:0] b_imm = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
    always @(*) begin
        jump_addr_o = `ZERO;
        jump_enable_o = 1'b0;
        if(!rst_i) begin
            case (opcode)
            `INST_TYPE_JAL: begin
                jump_addr_o = inst_addr_i + jal_imm;
                jump_enable_o = 1'b1;
            end
            `INST_TYPE_JALR: begin
                jump_addr_o = (op1_i + jalr_imm) & ~32'h1;
                jump_enable_o = 1'b1;
            end
            `INST_TYPE_B: begin
                jump_addr_o = inst_addr_i + b_imm;
                case (funct3)
                    `INST_BEQ: jump_enable_o = op1_eq_op2;
                    `INST_BNE: jump_enable_o = ~op1_eq_op2;
                    `INST_BLT: jump_enable_o = op1_lt_op2;
                    `INST_BGE: jump_enable_o = ~op1_lt_op2;
                    `INST_BLTU: jump_enable_o = op1_ltu_op2;
                    `INST_BGEU: jump_enable_o = ~op1_ltu_op2;
                    default: jump_enable_o = 1'b0;
                endcase
            end
            default: ;
        endcase
        end
    end
endmodule
