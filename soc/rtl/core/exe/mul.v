`include "defines.v"

module mul #(
    parameter XLEN = 32
)(
    input wire clk_i,
    input wire rst_i,
    input wire req_i,
    input wire[XLEN-1:0] a_i,
    input wire[XLEN-1:0] b_i,
    output reg ready_o,
    output reg[XLEN*2-1:0] result_o
);
    always @(posedge clk_i) begin
        if(rst_i) begin
            ready_o <= 1'b0;
            result_o <= {(XLEN*2){1'b0}};
        end else if (req_i) begin
            result_o <= {{32{1'b0}}, a_i} * {{32{1'b0}}, b_i};
            ready_o <= 1'b1;
        end else begin
            ready_o <= 1'b0;
        end
    end
endmodule
