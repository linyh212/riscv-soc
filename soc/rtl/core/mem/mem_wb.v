`include "defines.v"

module mem_wb (
    input wire clk_i,
    input wire rst_i,
    input wire[`RADDR_WIDTH-1:0] reg_waddr_i,
    input wire reg_we_i,
    input wire[`RDATA_WIDTH-1:0] reg_wdata_i,
    output reg[`RADDR_WIDTH-1:0] reg_waddr_o,
    output reg reg_we_o,
    output reg[`RDATA_WIDTH-1:0] reg_wdata_o,

    input  wire csr_we_i,
    input  wire[`CSR_ADDR_WIDTH-1:0] csr_waddr_i,
    input  wire[`DATA_WIDTH-1:0] csr_wdata_i,
    output reg csr_we_o,
    output reg[`CSR_ADDR_WIDTH-1:0] csr_waddr_o,
    output reg[`DATA_WIDTH-1:0] csr_wdata_o
);
    always @(posedge clk_i) begin
        if(rst_i == 1'b1) begin
            reg_waddr_o <= `ZERO_REG;
            reg_we_o <= `WRITE_DISABLE;
            reg_wdata_o <= `ZERO;
            csr_we_o <= `WRITE_DISABLE;
            csr_waddr_o <= {`CSR_ADDR_WIDTH{1'b0}};
            csr_wdata_o <= `ZERO;
        end else begin
            reg_waddr_o <= reg_waddr_i;
            reg_we_o <= reg_we_i;
            reg_wdata_o <= reg_wdata_i;
            csr_we_o <= csr_we_i;
            csr_waddr_o <= csr_waddr_i;
            csr_wdata_o <= csr_wdata_i;
        end
    end
endmodule
