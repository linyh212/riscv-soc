`include "defines.v"

module exe (
    input wire rst_i,
    input wire[`RDATA_WIDTH-1:0] op1_i,
    input wire[`RDATA_WIDTH-1:0] op2_i,
    input wire[`RADDR_WIDTH-1:0] reg_waddr_i,
    input wire reg_we_i,
    input wire[`DATA_WIDTH-1:0] inst_i,
    input wire[`ADDR_WIDTH-1:0] inst_addr_i,

    output reg[`RADDR_WIDTH-1:0] reg_waddr_o,
    output reg reg_we_o,
    output reg[`RDATA_WIDTH-1:0] reg_wdata_o,
    output reg[`ADDR_WIDTH-1:0] mem_addr_o,
    output reg mem_we_o,
    output reg[`DATA_WIDTH-1:0] mem_data_o,
    output reg[3:0] mem_op_o,
    output wire[`ADDR_WIDTH-1:0] jump_addr_o,
    output wire jump_enable_o,
    output wire stallreq_o
);
    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    wire[`RDATA_WIDTH-1:0] r_reg_wdata_o;
    wire r_reg_we_o;
    wire[`RDATA_WIDTH-1:0] sl_reg_wdata_o;
    wire sl_reg_we_o;
    wire[`ADDR_WIDTH-1:0] sl_mem_addr_o;
    wire[`DATA_WIDTH-1:0] sl_mem_data_o;
    wire sl_mem_we_o;
    wire[3:0] sl_mem_op_o;

    assign stallreq_o = 1'b0;
    
    exe_type_r exe_type_r0(
        .rst_i(rst_i),
        .op1_i(op1_i),
        .op2_i(op2_i),
        .inst_i(inst_i),
        .reg_wdata_o(r_reg_wdata_o),
        .reg_we_o(r_reg_we_o)
    );
    exe_type_s_l exe_type_s_l0(
        .rst_i(rst_i),
        .op1_i(op1_i),
        .op2_i(op2_i),
        .inst_i(inst_i),
        .reg_wdata_o(sl_reg_wdata_o),
        .reg_we_o(sl_reg_we_o),
        .mem_addr_o(sl_mem_addr_o),
        .mem_data_o(sl_mem_data_o),
        .mem_we_o(sl_mem_we_o),
        .mem_op_o(sl_mem_op_o)
    );
    exe_type_b_j exe_type_b_j0(
        .rst_i(rst_i),
        .op1_i(op1_i),
        .op2_i(op2_i),
        .inst_i(inst_i),
        .inst_addr_i(inst_addr_i),
        .jump_addr_o(jump_addr_o),
        .jump_enable_o(jump_enable_o)
    );
    always @(*) begin
        reg_waddr_o = `ZERO_REG;
        reg_we_o = `WRITE_DISABLE;
        reg_wdata_o = `ZERO;
        mem_addr_o = `ZERO;
        mem_we_o = `WRITE_DISABLE;
        mem_data_o = `ZERO;
        mem_op_o = `MEM_NOP;
        if(rst_i == 1'b1) begin
        end else begin
            case (opcode)
                `INST_TYPE_I: begin
                    reg_waddr_o = reg_waddr_i;
                    case (funct3)
                        `INST_ADDI: begin
                            reg_we_o = reg_we_i;
                            reg_wdata_o = op1_i + op2_i;
                        end
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
                    reg_waddr_o = reg_waddr_i;
                    reg_we_o = r_reg_we_o;
                    reg_wdata_o = r_reg_wdata_o;
                end
                `INST_TYPE_LUI, `INST_TYPE_AUIPC: begin
                    reg_waddr_o = reg_waddr_i;
                    reg_we_o = reg_we_i;
                    reg_wdata_o = op1_i + op2_i;
                end
                `INST_TYPE_JAL, `INST_TYPE_JALR: begin
                    reg_waddr_o = reg_waddr_i;
                    reg_we_o = reg_we_i;
                    reg_wdata_o = inst_addr_i + 32'd4;
                end
                `INST_TYPE_S, `INST_TYPE_L: begin
                    reg_waddr_o = reg_waddr_i;
                    reg_we_o = sl_reg_we_o;
                    reg_wdata_o = sl_reg_wdata_o;
                    mem_addr_o = sl_mem_addr_o;
                    mem_we_o = sl_mem_we_o;
                    mem_data_o = sl_mem_data_o;
                    mem_op_o = sl_mem_op_o;
                end
                default: begin
                end
            endcase
        end
    end
endmodule
