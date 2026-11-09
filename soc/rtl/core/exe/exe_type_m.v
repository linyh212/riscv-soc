`include "defines.v"

module exe_type_m (
    input wire clk_i,
    input wire rst_i,
    input wire[`DATA_WIDTH-1:0] op1_i,
    input wire[`DATA_WIDTH-1:0] op2_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input wire[`RDATA_WIDTH-1:0] inst_i,
    /* verilator lint_on UNUSEDSIGNAL */
    output wire stall_o,
    output reg[`RDATA_WIDTH-1:0] reg_wdata_o,
    output reg reg_we_o
);
    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    wire[6:0] funct7 = inst_i[31:25];
    wire isType_m = (opcode == `INST_TYPE_R_M) && (funct7 == 7'b0000001);
    reg[`DATA_WIDTH-1:0] a_o, b_o;
    reg mult_req_o, div_req_o;
    wire mult_ready_i, div_ready_i;
    wire[`DATA_WIDTH*2-1:0] mult_result_i, div_result_i;
    reg div_signed;
    mul #(.XLEN(`DATA_WIDTH)) mul0(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .req_i(mult_req_o),
        .a_i(a_o),
        .b_i(b_o),
        .ready_o(mult_ready_i),
        .result_o(mult_result_i)
    );
    div #(.XLEN(`DATA_WIDTH)) div0(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .req_i(div_req_o),
        .is_signed_i(div_signed),
        .a_i(op1_i),
        .b_i(op2_i),
        .ready_o(div_ready_i),
        .result_o(div_result_i)
    );
    assign stall_o = (mult_req_o & ~mult_ready_i) | (div_req_o & ~div_ready_i);
    wire is_a_neg = op1_i[`DATA_WIDTH-1];
    wire is_b_neg = op2_i[`DATA_WIDTH-1];
    wire signed_adjust = is_a_neg ^ is_b_neg;
    wire[`DATA_WIDTH-1:0] invert_result = (mult_req_o)?
        (~mult_result_i[`DATA_WIDTH*2-1:`DATA_WIDTH] +
         (mult_result_i[`DATA_WIDTH-1:0] == {`DATA_WIDTH{1'b0}})) : {`DATA_WIDTH{1'b0}};
    always @(*) begin
        reg_wdata_o = `ZERO;
        reg_we_o = `WRITE_DISABLE;
        mult_req_o = 1'b0;
        div_req_o = 1'b0;
        div_signed = 1'b0;
        a_o = `ZERO;
        b_o = `ZERO;
        if(~rst_i && isType_m) begin
            reg_we_o = `WRITE_ENABLE;
            case (funct3)
                // MULT
                `INST_MUL: begin
                    a_o = op1_i;
                    b_o = op2_i;
                    mult_req_o = 1'b1;
                    reg_wdata_o = mult_result_i[`DATA_WIDTH-1:0];
                end
                `INST_MULH: begin
                    a_o = is_a_neg ? (~op1_i + 1'b1) : op1_i;
                    b_o = is_b_neg ? (~op2_i + 1'b1) : op2_i;
                    mult_req_o = 1'b1;
                    reg_wdata_o = signed_adjust ? invert_result : mult_result_i[`DATA_WIDTH*2-1:`DATA_WIDTH];
                end
                `INST_MULHU: begin
                    a_o = op1_i;
                    b_o = op2_i;
                    mult_req_o = 1'b1;
                    reg_wdata_o = mult_result_i[`DATA_WIDTH*2-1:`DATA_WIDTH];
                end
                `INST_MULHSU: begin
                    a_o = is_a_neg ? (~op1_i + 1'b1) : op1_i;
                    b_o = op2_i;
                    mult_req_o = 1'b1;
                    reg_wdata_o = is_a_neg ? invert_result : mult_result_i[`DATA_WIDTH*2-1:`DATA_WIDTH];
                end
                // DIV & Remainder
                3'b100: begin
                    div_req_o = 1'b1;
                    div_signed = 1'b1;
                    reg_wdata_o = div_result_i[`DATA_WIDTH-1:0];
                end
                3'b101: begin
                    div_req_o = 1'b1;
                    div_signed = 1'b0;
                    reg_wdata_o = div_result_i[`DATA_WIDTH-1:0];
                end
                3'b110: begin
                    div_req_o = 1'b1;
                    div_signed = 1'b1;
                    reg_wdata_o = div_result_i[`DATA_WIDTH*2-1:`DATA_WIDTH];
                end
                3'b111: begin
                    div_req_o = 1'b1;
                    div_signed = 1'b0;
                    reg_wdata_o = div_result_i[`DATA_WIDTH*2-1:`DATA_WIDTH];
                end
                default: ;
            endcase
        end
    end
endmodule
