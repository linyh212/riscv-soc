`include "defines.v"

module pipe_crtl (
    input wire rst_i,
    input wire stallreq_from_id_i,
    output reg[5:0] stall_o
);
    always @(*) begin
        if(rst_i == 1'b1) begin
            stall_o = 6'b000000;
        end else if(stallreq_from_id_i == `STOP) begin
            stall_o = 6'b000111;
        end else begin
            stall_o = 6'b000000;
        end
    end
endmodule
