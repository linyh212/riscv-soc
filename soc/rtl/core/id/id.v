`include "defines.v"

/* verilator lint_off UNUSEDSIGNAL */
module id (
    input wire rst_i,
    input wire[`ADDR_WIDTH-1:0] inst_addr_i,
    input wire[`DATA_WIDTH-1:0] inst_i,
    
    input wire[`RDATA_WIDTH-1:0] reg1_rdata_i,
    input wire[`RDATA_WIDTH-1:0] reg2_rdata_i,

    output reg[`RADDR_WIDTH-1:0] reg1_raddr_o,
    output reg reg1_re_o,
    output reg[`RADDR_WIDTH-1:0] reg2_raddr_o,
    output reg reg2_re_o,

    output reg[`DATA_WIDTH-1:0] inst_o,
    output reg[`RDATA_WIDTH-1:0] op1_o,
    output reg[`RDATA_WIDTH-1:0] op2_o,
    output reg reg_we_o,
    output reg[`RADDR_WIDTH-1:0] reg_waddr_o
);
/* verilator lint_on UNUSEDSIGNAL */
    wire[6:0] opcode = inst_i[6:0];
    
    wire[`RADDR_WIDTH-1:0] i_reg1_raddr_o;
    wire i_reg1_re_o;
    wire[`RDATA_WIDTH-1:0] i_op1_o;
    
    wire[`RADDR_WIDTH-1:0] i_reg2_raddr_o;
    wire i_reg2_re_o;
    wire[`RDATA_WIDTH-1:0] i_op2_o;

    wire[`RADDR_WIDTH-1:0] i_reg_waddr_o;
    wire i_reg_we_o;
    id_type_i INST_TYPE_I(
        .inst_i (inst_i),
        .reg1_rdata_i (reg1_rdata_i),
        .reg2_rdata_i (reg2_rdata_i),
        .reg1_raddr_o (i_reg1_raddr_o),
        .reg2_raddr_o (i_reg2_raddr_o),
        .reg1_re_o (i_reg1_re_o),
        .reg2_re_o (i_reg2_re_o),
        .op1_o (i_op1_o),
        .op2_o (i_op2_o),
        .reg_we_o (i_reg_we_o),
        .reg_waddr_o (i_reg_waddr_o)
    );
    always @(*) begin
        if (rst_i == 1'b1) begin
            inst_o = `NOP;
            reg1_raddr_o = `ZERO_REG;
            reg2_raddr_o = `ZERO_REG;
            reg1_re_o = `READ_DISABLE;
            reg2_re_o = `READ_DISABLE;
            op1_o = `ZERO;
            op2_o = `ZERO;
            reg_we_o = `WRITE_DISABLE;
            reg_waddr_o = `ZERO_REG;
        end else begin
            inst_o = `NOP;
            reg1_raddr_o = `ZERO_REG;
            reg2_raddr_o = `ZERO_REG;
            reg1_re_o = `READ_DISABLE;
            reg2_re_o = `READ_DISABLE;
            op1_o = `ZERO;
            op2_o = `ZERO;
            reg_we_o = `WRITE_DISABLE;
            reg_waddr_o = `ZERO_REG;
            case (opcode)
                `INST_TYPE_I: begin
                    inst_o = inst_i;
                    reg1_raddr_o = i_reg1_raddr_o;
                    reg2_raddr_o = i_reg2_raddr_o;
                    reg1_re_o = i_reg1_re_o;
                    reg2_re_o = i_reg2_re_o;
                    op1_o = i_op1_o;
                    op2_o = i_op2_o;
                    reg_we_o = i_reg_we_o;
                    reg_waddr_o = i_reg_waddr_o;
                end 
                default: begin
                end
            endcase
        end
    end
endmodule
