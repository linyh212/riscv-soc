`include "defines.v"

module boot_rom #(
    parameter ROM_SIZE = 4096,
    parameter ROM_ADDR_WIDTH = 12
)(
    input wire                  clk_i,
    input wire                  rst_i,
    input wire                  ce_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input wire[`ADDR_WIDTH-1:0] addr_i,
    /* verilator lint_on UNUSEDSIGNAL */
    output reg[`DATA_WIDTH-1:0] data_o,
    input wire                  inst_ce_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input wire[`ADDR_WIDTH-1:0] pc_i,
    /* verilator lint_on UNUSEDSIGNAL */
    output reg[`DATA_WIDTH-1:0] inst_o
);
    reg[7:0] mem[0:ROM_SIZE-1];
    wire[ROM_ADDR_WIDTH-1:0] data_addr = addr_i[ROM_ADDR_WIDTH-1:0];
    wire[ROM_ADDR_WIDTH-1:0] inst_addr = {pc_i[ROM_ADDR_WIDTH-1:2], 2'b00};
    always @(*) begin
        if(rst_i || !ce_i) begin
            data_o = 32'h0;
        end else if (ce_i == 1'b1) begin
            data_o = {mem[data_addr+3], mem[data_addr+2], mem[data_addr+1], mem[data_addr]};
        end else begin
            data_o = `ZERO;
        end
    end
    always @(posedge clk_i) begin
        if(rst_i || !inst_ce_i) begin
            inst_o <= 32'h0;
        end else begin
            inst_o <= {mem[inst_addr+3], mem[inst_addr+2], mem[inst_addr+1], mem[inst_addr]};
        end
    end
// synthesis translate_off
    task writeByte;
        /*verilator public*/
        input integer byte_addr;
        input [7:0] val;
        begin
            if(byte_addr >= 0 && byte_addr < ROM_SIZE) begin
                mem[byte_addr[ROM_ADDR_WIDTH-1:0]] = val;
            end
        end
    endtask
// synthesis translate_on
endmodule
