`include "defines.v"

module ram (
    input wire clk_i,
    input wire rst_i,
    input wire we_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input wire[`ADDR_WIDTH-1:0] addr_i,
    /* verilator lint_on UNUSEDSIGNAL */
    input wire[`DATA_WIDTH-1:0] data_i,
    output reg[`DATA_WIDTH-1:0] data_o
);
    reg[`DATA_WIDTH-1:0] mem[0:`RAM_SIZE-1];
    always @(posedge clk_i) begin
        if(we_i == `WRITE_ENABLE && rst_i == 1'b0) begin
            mem[addr_i[`RAM_ADDR_WIDTH+1:2]] <= data_i;
        end
    end
    always @(*) begin
        if(rst_i == 1'b1) begin
            data_o = `ZERO;
        end else begin
            data_o = mem[addr_i[`RAM_ADDR_WIDTH+1:2]];
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
