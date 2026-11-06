`include "defines.v"

module pc_reg (
    input wire clk_i,
    input wire rst_i,
    input wire stall_i,
    input wire flush_jump_i,
    input wire[`ADDR_WIDTH-1:0] new_pc_i,
    output reg[`ADDR_WIDTH-1:0] pc_o,
    output reg ce_o
);
    always @(posedge clk_i) begin
        if(rst_i) begin
            ce_o <= 1'b0;
        end else begin
            ce_o <= 1'b1;
        end
    end
    always @(posedge clk_i) begin
        if(ce_o == 1'b0) begin
            pc_o <= `ZERO;
        end else if(flush_jump_i == 1'b1) begin
            pc_o <= new_pc_i;
        end else if(stall_i == `STOP) begin
            pc_o <= pc_o;
        end else begin
            pc_o <= pc_o + 32'h4;
        end
    end
endmodule
