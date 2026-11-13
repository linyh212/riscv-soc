`include "defines.v"

module div #(
    parameter XLEN = 32
) (
    input wire clk_i,
    input wire rst_i,
    input wire req_i,
    input wire is_signed_i,
    input wire[XLEN-1:0] a_i,
    input wire[XLEN-1:0] b_i,
    output reg ready_o,
    output reg[XLEN*2-1:0] result_o
);
    localparam STATE_IDLE = 2'b00;
    localparam STATE_CALC = 2'b01;
    localparam STATE_DONE = 2'b10;
    reg[1:0] state;
    reg[5:0] count;
    reg[XLEN-1:0] divisor;
    reg[XLEN*2:0] shift_reg;
    reg dividend_neg;
    reg divisor_neg;
    wire a_is_neg = a_i[XLEN-1] && is_signed_i;
    wire b_is_neg = b_i[XLEN-1] && is_signed_i;
    wire[XLEN-1:0] abs_a = a_is_neg ? (~a_i + 1'b1) : a_i;
    wire[XLEN-1:0] abs_b = b_is_neg ? (~b_i + 1'b1) : b_i;
    always @(posedge clk_i) begin
        if(rst_i) begin
            state <= STATE_IDLE;
            ready_o <= 1'b0;
            result_o <= {(XLEN*2){1'b0}};
            count <= 6'd0;
            shift_reg <= 65'd0;
            dividend_neg <= 1'b0;
            divisor_neg <= 1'b0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    ready_o <= 1'b0;
                    if(req_i) begin
                        dividend_neg <= a_is_neg;
                        divisor_neg <= b_is_neg;
                        if(b_i == {XLEN{1'b0}}) begin
                            state <= STATE_DONE;
                            result_o <= {a_i, {XLEN{1'b1}}};
                        end else if(is_signed_i && a_i == 32'h8000_0000 && b_i == 32'hFFFF_FFFF) begin
                            state <= STATE_DONE;
                            result_o <= {32'h0000_0000, 32'h8000_0000};
                        end else begin
                            state <= STATE_CALC;
                            count <= 6'd0;
                            divisor <= abs_b;
                            shift_reg <= {{XLEN{1'b0}}, abs_a, 1'b0};
                        end
                    end
                end
                STATE_CALC: begin
                    if(count == XLEN - 1) begin
                        state <= STATE_DONE;
                    end
                    count <= count + 1'b1;
                    if(shift_reg[XLEN*2-1:XLEN] >= divisor) begin
                        shift_reg <= {shift_reg[XLEN*2-1:XLEN] - divisor, shift_reg[XLEN-1:1], 1'b1, 1'b0};
                    end else begin
                        shift_reg <= {shift_reg[XLEN*2-1:0], 1'b0};
                    end
                end
                STATE_DONE: begin
                    ready_o <= 1'b1;
                    if(~req_i) begin
                        state <= STATE_IDLE;
                        ready_o <= 1'b0;
                    end else begin
                        if(b_i != {XLEN{1'b0}} && !(is_signed_i && a_i == 32'h8000_0000 && b_i == 32'hFFFF_FFFF)) begin
                            reg[XLEN-1:0] final_quot;
                            reg[XLEN-1:0] final_rem;
                            final_quot = (dividend_neg ^ divisor_neg)? (~shift_reg[XLEN:1] + 1'b1) : shift_reg[XLEN:1];
                            final_rem = dividend_neg ? (~shift_reg[XLEN*2:XLEN+1] + 1'b1) : shift_reg[XLEN*2:XLEN+1];
                            result_o <= {final_rem, final_quot};
                        end
                    end
                end
                default: state <= STATE_IDLE;
            endcase
        end
    end
endmodule
