`include "defines.v"

module exe_type_s_l (
    input wire rst_i,
    input wire[`DATA_WIDTH-1:0] op1_i,
    input wire[`DATA_WIDTH-1:0] op2_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input wire[`RDATA_WIDTH-1:0] inst_i,
    /* verilator lint_on UNUSEDSIGNAL */
    output reg[`RDATA_WIDTH-1:0] reg_wdata_o,
    output reg reg_we_o,
    output reg[`ADDR_WIDTH-1:0] mem_addr_o,
    output reg[`DATA_WIDTH-1:0] mem_data_o,
    output reg mem_we_o,
    output reg[3:0] mem_op_o
);
    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    wire[`ADDR_WIDTH-1:0] store_offset = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
    wire[`ADDR_WIDTH-1:0] load_offset = {{20{inst_i[31]}}, inst_i[31:20]};
    always @(*) begin
        reg_wdata_o = `ZERO;
        reg_we_o = `WRITE_DISABLE;
        mem_addr_o = `ZERO;
        mem_data_o = `ZERO;
        mem_we_o = `WRITE_DISABLE;
        mem_op_o = `MEM_NOP;
        if(rst_i) begin
        end else begin
            case (opcode)
                `INST_TYPE_S: begin
                    mem_addr_o = op1_i + store_offset;
                    mem_data_o = op2_i;
                    case(funct3)
                        `INST_SB: begin
                            mem_op_o = `SB;
                            mem_we_o = `WRITE_ENABLE;
                        end
                        `INST_SH: begin
                            mem_op_o = `SH;
                            mem_we_o = `WRITE_ENABLE;
                        end
                        `INST_SW: begin
                            mem_op_o = `SW;
                            mem_we_o = `WRITE_ENABLE;
                        end
                        default: begin
                        end
                    endcase
                end
                `INST_TYPE_L: begin
                    mem_addr_o = op1_i + load_offset;
                    case(funct3)
                        `INST_LB: begin
                            mem_op_o = `LB;
                            reg_we_o = `WRITE_ENABLE;
                        end
                        `INST_LH: begin
                            mem_op_o = `LH;
                            reg_we_o = `WRITE_ENABLE;
                        end
                        `INST_LW: begin
                            mem_op_o = `LW;
                            reg_we_o = `WRITE_ENABLE;
                        end
                        `INST_LBU: begin
                            mem_op_o = `LBU;
                            reg_we_o = `WRITE_ENABLE;
                        end
                        `INST_LHU: begin
                            mem_op_o = `LHU;
                            reg_we_o = `WRITE_ENABLE;
                        end
                        default: begin
                        end
                    endcase
                end
                default: begin
                end
            endcase
        end
    end
endmodule
