`include "defines.v"

module dpram #(
    parameter RAM_SIZE = 65536,
    parameter RAM_ADDR_WIDTH = 16
)(
    input wire clk_i,
    input wire rst_i,
    
    input wire we_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input wire[`ADDR_WIDTH-1:0] addr_i,
    /* verilator lint_on UNUSEDSIGNAL */
    input wire[`DATA_WIDTH-1:0] data_i,
    output reg[`DATA_WIDTH-1:0] data_o,

    input wire inst_ce_i,
    input wire[`ADDR_WIDTH-1:0] pc_i,
    output reg[`DATA_WIDTH-1:0] inst_o
);
    reg[7:0] mem[0:`RAM_SIZE-1];
    wire[`RAM_ADDR_WIDTH-1:0] data_addr = {addr_i[RAM_ADDR_WIDTH-1:2], 2'b00};
    wire[`RAM_ADDR_WIDTH-1:0] inst_addr = {pc_i[RAM_ADDR_WIDTH-1:2], 2'b00};
    always @(posedge clk_i) begin
        if((we_i == `WRITE_ENABLE) && (rst_i == 1'b0)) begin
            mem[addr_i[`RAM_ADDR_WIDTH]] <= data_i[31:24];
            mem[addr_i[`RAM_ADDR_WIDTH+1]] <= data_i[23:16];
            mem[addr_i[`RAM_ADDR_WIDTH+2]] <= data_i[15:8];
            mem[addr_i[`RAM_ADDR_WIDTH+3]] <= data_i[7:0];
        end
    end
    always @(*) begin
        if(rst_i == 1'b1) begin
            data_o = `ZERO;
        end else if(we_i == `WRITE_DISABLE) begin
            data_o = {mem[addr_i], mem[addr_i+1], mem[addr_i+2], mem[addr_i+3]};
        end else begin
            data_o = `ZERO;
        end
    end
    always @(*) begin
        if(inst_ce_i == 1'b0 || rst_i == 1'b1) begin
            inst_o = `NOP;
        end else begin
            inst_o = {mem[inst_i], mem[inst_i+1], mem[inst_i+2], mem[inst_i+3]};
        end
    end
// synthesis translate_off
    task writeByte;
        /*verilator public*/
        input integer byte_addr;
        input [7:0] val;
        begin
            if(byte_addr >= 0 && byte_addr < (`RAM_SIZE * 4)) begin
                case (byte_addr[1:0])
                    2'b00: mem[byte_addr[`RAM_ADDR_WIDTH+1:2]][7:0] = val;
                    2'b01: mem[byte_addr[`RAM_ADDR_WIDTH+1:2]][15:8] = val;
                    2'b10: mem[byte_addr[`RAM_ADDR_WIDTH+1:2]][23:16] = val;
                    2'b11: mem[byte_addr[`RAM_ADDR_WIDTH+1:2]][31:24] = val;
                endcase
            end
        end
    endtask
// synthesis translate_on
endmodule
