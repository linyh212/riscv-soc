`include "defines.v"

module test_top (
    input wire clk_i,
    input wire rst_i,
    output wire[`ADDR_WIDTH-1:0] pc_o,
    output wire[`DATA_WIDTH-1:0] if_inst_o,
    output wire[`DATA_WIDTH-1:0] if_id_inst_o,
    output wire[`RDATA_WIDTH-1:0] id_op1_o,
    output wire[`RDATA_WIDTH-1:0] id_op2_o
);
    wire[`ADDR_WIDTH-1:0] pc_wire;
    wire ce_wire;
    wire [`ADDR_WIDTH-1:0] if_inst_addr_o;

    wire[`ADDR_WIDTH-1:0] if_id_inst_addr_o;

    wire[`RADDR_WIDTH-1:0] id_reg1_addr_o;
    wire id_reg1_re_o;
    wire[`RDATA_WIDTH-1:0] reg1_data_o;
    wire[`RADDR_WIDTH-1:0] id_reg2_addr_o;
    wire id_reg2_re_o;
    wire[`RDATA_WIDTH-1:0] reg2_data_o;

    wire[`DATA_WIDTH-1:0] id_inst_o;
    wire id_reg_we_o;
    wire[`RADDR_WIDTH-1:0] id_reg_waddr_o;

    /* verilator lint_off UNUSEDSIGNAL */
    wire[`DATA_WIDTH-1:0] id_exe_inst_o;
    wire[`RDATA_WIDTH-1:0] id_exe_op1_o;
    wire[`RDATA_WIDTH-1:0] id_exe_op2_o;
    wire id_exe_reg_we_o;
    wire[`RADDR_WIDTH-1:0] id_exe_reg_waddr_o;
    /* verilator lint_on UNUSEDSIGNAL */
    assign pc_o = pc_wire;
    assign if_inst_addr_o = pc_wire;
    pc_reg pc_reg0(
        .clk_i (clk_i),
        .rst_i (rst_i),
        .pc_o (pc_wire),
        .ce_o (ce_wire)
    );
    rom rom0(
        .clk_i (clk_i),
        .ce_i (ce_wire),
        .addr_i (pc_wire),
        .inst_o (if_inst_o)
    );
    if_id if_id0 (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .inst_addr_i (if_inst_addr_o),
        .inst_i (if_inst_o),
        .inst_addr_o (if_id_inst_addr_o),
        .inst_o (if_id_inst_o)
    );
    id id0(
        .rst_i (rst_i),
        .inst_addr_i (if_id_inst_addr_o),
        .inst_i (if_id_inst_o),
        .reg1_rdata_i (reg1_data_o),
        .reg2_rdata_i (reg2_data_o),
        .reg1_raddr_o (id_reg1_addr_o),
        .reg2_raddr_o (id_reg2_addr_o),
        .reg1_re_o (id_reg1_re_o),
        .reg2_re_o (id_reg2_re_o),
        .inst_o (id_inst_o),
        .op1_o (id_op1_o),
        .op2_o (id_op2_o),
        .reg_we_o (id_reg_we_o),
        .reg_waddr_o (id_reg_waddr_o)
    );
    regfile regfile0(
        .clk_i (clk_i),
        .rst_i (rst_i),
        .re1_i (id_reg1_re_o),
        .raddr1_i (id_reg1_addr_o),
        .rdata1_o (reg1_data_o),
        .re2_i (id_reg2_re_o),
        .raddr2_i (id_reg2_addr_o),
        .rdata2_o (reg2_data_o)
    );
    id_exe id_exe0(
        .clk_i (clk_i),
        .rst_i (rst_i),
        .inst_i (id_inst_o),
        .op1_i (id_op1_o),
        .op2_i (id_op2_o),
        .reg_we_i (id_reg_we_o),
        .reg_waddr_i (id_reg_waddr_o),
        .inst_o (id_exe_inst_o),
        .op1_o (id_exe_op1_o),
        .op2_o (id_exe_op2_o),
        .reg_we_o (id_exe_reg_we_o),
        .reg_waddr_o (id_exe_reg_waddr_o)
    );
endmodule
