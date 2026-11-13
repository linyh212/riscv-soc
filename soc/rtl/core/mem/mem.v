`include "defines.v"

module mem (
    input wire rst_i,
    input wire[`RADDR_WIDTH-1:0] reg_waddr_i,
    input wire reg_we_i,
    input wire[`RDATA_WIDTH-1:0] reg_wdata_i,
    input wire[`ADDR_WIDTH-1:0] mem_addr_i,
    input wire mem_we_i,
    input wire[`DATA_WIDTH-1:0] mem_data_i,
    input wire[3:0] mem_op_i,
    
    input wire[`DATA_WIDTH-1:0] ram_data_i,

    output reg[`RADDR_WIDTH-1:0] reg_waddr_o,
    output reg reg_we_o,
    output reg[`RDATA_WIDTH-1:0] reg_wdata_o,

    output reg[`ADDR_WIDTH-1:0] ram_addr_o,
    output reg ram_w_request_o,
    output reg[`RDATA_WIDTH-1:0] ram_data_o,

    output reg halt_o,

    input  wire csr_we_i,
    input  wire[`CSR_ADDR_WIDTH-1:0] csr_waddr_i,
    input  wire[`DATA_WIDTH-1:0]     csr_wdata_i,
    output reg csr_we_o,
    output reg[`CSR_ADDR_WIDTH-1:0] csr_waddr_o,
    output reg[`DATA_WIDTH-1:0] csr_wdata_o
);
    always @(*) begin
        reg_waddr_o = reg_waddr_i;
        reg_we_o = reg_we_i;
        reg_wdata_o = reg_wdata_i;
        ram_addr_o = `ZERO;
        ram_w_request_o = `WRITE_DISABLE;
        ram_data_o = `ZERO;
        halt_o = 1'b0;
        if(rst_i == 1'b1) begin
            reg_waddr_o = `ZERO_REG;
            reg_we_o = `WRITE_DISABLE;
            reg_wdata_o = `ZERO;
            ram_addr_o = `ZERO;
            ram_w_request_o = `WRITE_DISABLE;
            ram_data_o = `ZERO;
            csr_we_o = `WRITE_DISABLE;
            csr_waddr_o = {`CSR_ADDR_WIDTH{1'b0}};
            csr_wdata_o = `ZERO;
        end else begin
            reg_waddr_o = reg_waddr_i;
            reg_we_o = reg_we_i;
            ram_w_request_o = mem_we_i;
            ram_addr_o = mem_addr_i;
            ram_data_o = `ZERO;
            csr_we_o = csr_we_i;
            csr_waddr_o = csr_waddr_i;
            csr_wdata_o = csr_wdata_i;
            case (mem_op_i)
                `LB: reg_wdata_o = {{24{ram_data_i[7]}}, ram_data_i[7:0]};
                `LBU: reg_wdata_o = {24'b0, ram_data_i[7:0]};
                `LH: reg_wdata_o = {{16{ram_data_i[15]}}, ram_data_i[15:0]};
                `LHU: reg_wdata_o = {16'b0, ram_data_i[15:0]};
                `LW: begin
                    reg_wdata_o = ram_data_i;
                end
                `SB, `SH: ram_data_o = mem_data_i;
                `SW: begin
                    ram_data_o = mem_data_i;
                    if(mem_addr_i == 32'h0020_0008) begin
                        halt_o = 1'b1;
                    end
                end
                default: begin
                    reg_wdata_o = reg_wdata_i;
                    ram_addr_o = `ZERO;
                    ram_data_o = `ZERO;
                    ram_w_request_o = `WRITE_DISABLE;
                    halt_o = 1'b0;
                end
            endcase
        end
    end
endmodule
