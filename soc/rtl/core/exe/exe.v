`include "defines.v"

module exe (
    input wire rst_i,
    input wire[`RDATA_WIDTH-1:0] op1_i,
    input wire[`RDATA_WIDTH-1:0] op2_i,
    input wire[`RADDR_WIDTH-1:0] reg_waddr_i,
    input wire reg_we_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input wire[`DATA_WIDTH-1:0] inst_i,
    /* verilator lint_on UNUSEDSIGNAL */
    output reg[`RADDR_WIDTH-1:0] reg_waddr_o,
    output reg reg_we_o,
    output reg[`RDATA_WIDTH-1:0] reg_wdata_o
);
    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    wire[`RDATA_WIDTH-1:0] r_reg_wdata_o;
    wire r_reg_we_o;
    exe_type_r exe_type_r0(
        .rst_i(rst_i),
        .op1_i(op1_i),
        .op2_i(op2_i),
        .inst_i(inst_i),
        .reg_wdata_o(r_reg_wdata_o),
        .reg_we_o(r_reg_we_o)
    );
    always @(*) begin
        if(rst_i == 1'b1) begin
            reg_waddr_o = `ZERO_REG;
            reg_we_o = `WRITE_DISABLE;
            reg_wdata_o = `ZERO;
        end else begin
            reg_waddr_o = reg_waddr_i;
            case (opcode)
                `INST_TYPE_I: begin
                    case (funct3)
                        `INST_ORI: begin
                            reg_we_o = reg_we_i;
                            reg_wdata_o = op1_i | op2_i;
                        end
                        default: begin
                            reg_we_o = `WRITE_DISABLE;
                            reg_wdata_o = `ZERO;
                        end
                    endcase
                end
                `INST_TYPE_R_M: begin
                    reg_we_o = r_reg_we_o;
                    reg_wdata_o = r_reg_wdata_o;
                end
                default: begin
                    reg_we_o = `WRITE_DISABLE;
                    reg_wdata_o = `ZERO;
                end
            endcase
        end
    end
endmodule
