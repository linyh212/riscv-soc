`include "defines.v"

module pipe_crtl (
    input wire rst_i,
    input wire stallreq_from_id_i,
    input wire stallreq_from_exe_i,
    input wire jump_enable_i,
    input wire[`ADDR_WIDTH-1:0] jump_addr_i,
    output reg[5:0] stall_o,
    output reg flush_jump_o,
    output reg[`ADDR_WIDTH-1:0] new_pc_o
);
    always @(*) begin
        flush_jump_o = jump_enable_i;
        new_pc_o = jump_addr_i;
        if(rst_i == 1'b1) begin
            stall_o = 6'b000000;
        end else if(stallreq_from_exe_i == `STOP) begin
            stall_o = 6'b001111;
        end else if(stallreq_from_id_i == `STOP) begin
            stall_o = 6'b000111;
        end else begin
            stall_o = 6'b000000;
        end
    end
endmodule
