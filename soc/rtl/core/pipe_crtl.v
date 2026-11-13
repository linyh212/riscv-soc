`include "defines.v"

module pipe_crtl (
    input wire rst_i,
    input wire stallreq_from_id_i,
    input wire stallreq_from_exe_i,
    input wire jump_en_i,
    input wire[`ADDR_WIDTH-1:0] jump_addr_i,
    input wire return_en_i,
    input wire[`ADDR_WIDTH-1:0] return_addr_i,
    input wire int_en_i,
    input wire[`DATA_WIDTH-1:0] isr_pc_i,
    output reg[5:0] stall_o,
    output reg flush_jump_o,
    output reg flush_return_o,
    output reg flush_int_o,
    output reg[`ADDR_WIDTH-1:0] new_pc_o
);
    always @(*) begin
        stall_o = 6'b000000;
        flush_jump_o = 1'b0;
        flush_return_o = 1'b0;
        flush_int_o = 1'b0;
        new_pc_o = `ZERO;
        if(rst_i == 1'b1) begin
        end else begin
            if(int_en_i) begin
                flush_int_o = 1'b1;
                new_pc_o = isr_pc_i;
            end else if(return_en_i) begin
                flush_return_o = 1'b1;
                new_pc_o = return_addr_i;
            end else if(jump_en_i) begin
                flush_jump_o = 1'b1;
                new_pc_o = jump_addr_i;
            end

            if(stallreq_from_exe_i == `STOP) begin
            stall_o = 6'b001111;
            end else if(stallreq_from_id_i == `STOP) begin
                stall_o = 6'b000111;
            end
        end
    end
endmodule
