`include "defines.v"

module dpram #(
    parameter RAM_SIZE = 65536,
    parameter RAM_ADDR_WIDTH = 16
)(
    input wire clk_i,
    input wire rst_i,
    input wire ce_i,
    
    input wire we_i,
    input wire[3:0] mem_op_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input wire[`ADDR_WIDTH-1:0] addr_i,
    /* verilator lint_on UNUSEDSIGNAL */
    input wire[`DATA_WIDTH-1:0] data_i,
    output reg[`DATA_WIDTH-1:0] data_o,

    input wire inst_ce_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input wire[`ADDR_WIDTH-1:0] pc_i,
    /* verilator lint_on UNUSEDSIGNAL */
    output reg[`DATA_WIDTH-1:0] inst_o
);
    reg[7:0] mem[0:RAM_SIZE-1];
    wire[RAM_ADDR_WIDTH-1:0] data_addr = addr_i[RAM_ADDR_WIDTH-1:0];
    wire[RAM_ADDR_WIDTH-1:0] inst_addr = {pc_i[RAM_ADDR_WIDTH-1:2], 2'b00};
    always @(posedge clk_i) begin
        if((ce_i == 1'b1) && (we_i == `WRITE_ENABLE) && (rst_i == 1'b0)) begin
            case (mem_op_i)
                `SB: mem[data_addr] <= data_i[7:0];
                `SH: begin
                    mem[data_addr] <= data_i[7:0];
                    mem[data_addr+1] <= data_i[15:8];
                end
                `SW: begin
                    mem[data_addr] <= data_i[7:0];
                    mem[data_addr+1] <= data_i[15:8];
                    mem[data_addr+2] <= data_i[23:16];
                    mem[data_addr+3] <= data_i[31:24];
                end
                default: begin
                end
            endcase
        end
    end
    always @(*) begin
        if(rst_i == 1'b1) begin
            data_o = `ZERO;
        end else if(ce_i == 1'b1) begin
            data_o = {mem[data_addr+3], mem[data_addr+2], mem[data_addr+1], mem[data_addr]};
        end else begin
            data_o = `ZERO;
        end
    end
    always @(posedge clk_i) begin
        if(rst_i == 1'b1) begin
            inst_o <= `NOP;
        end else if(inst_ce_i == 1'b1) begin
            inst_o <= {mem[inst_addr+3], mem[inst_addr+2], mem[inst_addr+1], mem[inst_addr]};
        end
    end
// synthesis translate_off
    task writeByte;
        /*verilator public*/
        input integer byte_addr;
        input [7:0] val;
        begin
            if(byte_addr >= 0 && byte_addr < RAM_SIZE) begin
                mem[byte_addr] = val;
            end
        end
    endtask
// synthesis translate_on
endmodule
