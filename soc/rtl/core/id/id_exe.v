`include "defines.v"

module id_exe (
    input wire clk_i,
    input wire rst_i,
    input wire[3:2] stall_i,
    input wire flush_jump_i,
    input wire[`DATA_WIDTH-1:0] inst_i,
    input wire[`ADDR_WIDTH-1:0] inst_addr_i,
    input wire[`RDATA_WIDTH-1:0] op1_i,
    input wire[`RDATA_WIDTH-1:0] op2_i,
    input wire reg_we_i,
    input wire[`RADDR_WIDTH-1:0] reg_waddr_i,

    output reg[`DATA_WIDTH-1:0] inst_o,
    output reg[`ADDR_WIDTH-1:0] inst_addr_o,
    output reg[`RDATA_WIDTH-1:0] op1_o,
    output reg[`RDATA_WIDTH-1:0] op2_o,
    output reg reg_we_o,
    output reg[`RADDR_WIDTH-1:0] reg_waddr_o,

    input wire csr_we_i,
    input wire[`CSR_ADDR_WIDTH-1:0] csr_addr_i,
    output reg csr_we_o,
    output reg[`CSR_ADDR_WIDTH-1:0] csr_addr_o
);
    always @(posedge clk_i) begin
        if(rst_i == 1'b1 || flush_jump_i == 1'b1) begin
            inst_o <= `NOP;
            inst_addr_o <= `ZERO;
            op1_o <= `ZERO;
            op2_o <= `ZERO;
            reg_we_o <= `WRITE_DISABLE;
            reg_waddr_o <= `ZERO_REG;
            csr_we_o <= `WRITE_DISABLE;
            csr_addr_o <= {`CSR_ADDR_WIDTH{1'b0}};
        end else if(stall_i[3] == `STOP) begin
            inst_o <= inst_o;
            inst_addr_o <= inst_addr_o;
            op1_o <= op1_o;
            op2_o <= op2_o;
            reg_we_o <= reg_we_o;
            reg_waddr_o <= reg_waddr_o;
            csr_we_o <= csr_we_o;
            csr_addr_o <= csr_addr_o;
        end else if(stall_i[2] == `STOP) begin
            inst_o <= `NOP;
            inst_addr_o <= `ZERO;
            op1_o <= `ZERO;
            op2_o <= `ZERO;
            reg_we_o <= `WRITE_DISABLE;
            reg_waddr_o <= `ZERO_REG;
            csr_we_o <= `WRITE_DISABLE;
            csr_addr_o <= {`CSR_ADDR_WIDTH{1'b0}};
        end else begin
            inst_o <= inst_i;
            inst_addr_o <= inst_addr_i;
            op1_o <= op1_i;
            op2_o <= op2_i;
            reg_we_o <= reg_we_i;
            reg_waddr_o <= reg_waddr_i;
            csr_we_o <= csr_we_i;
            csr_addr_o <= csr_addr_i;
        end
    end
endmodule
