`include "defines.v"

module interrupt_ctrl (
    input wire clk_i,
    input wire rst_i,
    input wire[`DATA_WIDTH-1:0] exception_i,
    input wire[`DATA_WIDTH-1:0] pc_i,
    input wire mstatus_ie_i,
    input wire mie_external_i,
    input wire mie_timer_i,
    input wire mie_sw_i,
    input wire mip_external_i,
    input wire mip_timer_i,
    input wire mip_sw_i,
    input wire[`DATA_WIDTH-1:0] mtvec_i,
    input wire[`DATA_WIDTH-1:0] epc_i,
    output reg interrupt_type_o,
    output reg cause_we_o,
    output reg[3:0] trap_cause_o,
    output reg epc_we_o,
    output reg[`DATA_WIDTH-1:0] epc_o,
    output reg mstatus_ie_clear_o,
    output reg mstatus_ie_set_o,
    output reg flush_o,
    output reg[`DATA_WIDTH-1:0] new_pc_o
);
    localparam RESET = 4'b0001;
    localparam OPERATING = 4'b0010;
    localparam TRAP_TAKEN = 4'b0100;
    localparam TRAP_RETURN = 4'b1000;
    reg[3:0] S, S_nxt;
    wire mret, ecall;
    assign {ecall, mret} = exception_i[1:0];
    wire eip = mie_external_i & mip_external_i;
    wire tip = mie_timer_i & mip_timer_i;
    wire sip = mie_sw_i & mip_sw_i;
    wire ip = eip | tip | sip;
    wire trap_happened = (mstatus_ie_i & ip) | ecall;
    always @(posedge clk_i) begin
        if(rst_i == 1'b1) S <= RESET;
        else S <= S_nxt;
    end
    always @(*) begin
        case (S)
            RESET: S_nxt = OPERATING;
            OPERATING: begin
                if(trap_happened) S_nxt = TRAP_TAKEN;
                else if(mret) S_nxt = TRAP_RETURN;
                else S_nxt = OPERATING;
            end
            TRAP_TAKEN: S_nxt = OPERATING;
            TRAP_RETURN: S_nxt = OPERATING;
            default: S_nxt = OPERATING;
        endcase
    end
    always @(posedge clk_i) begin
        if(rst_i == 1'b1) begin
            trap_cause_o <= 4'b0;
            interrupt_type_o <= 1'b0;
        end else if(S == OPERATING) begin
            if(mstatus_ie_i & eip) begin
                trap_cause_o <= 4'd11;
                interrupt_type_o <= 1'b1;
            end else if(mstatus_ie_i & sip) begin
                trap_cause_o <= 4'd3;
                interrupt_type_o <= 1'b1;
            end else if(mstatus_ie_i & tip) begin
                trap_cause_o <= 4'd7;
                interrupt_type_o <= 1'b1;
            end else if(ecall) begin
                trap_cause_o <= 4'd11;
                interrupt_type_o <= 1'b0;
            end
        end
    end
    wire[29:0] mtvec_base = mtvec_i[31:2];
    wire[31:0] base_offset = {26'b0, trap_cause_o, 2'b00};
    wire[31:0] vec_mux_out = mtvec_i[0] ? ({mtvec_base, 2'b00} + base_offset) : {mtvec_base, 2'b00};
    wire[31:0] trap_mux_out = interrupt_type_o ? vec_mux_out : {mtvec_base, 2'b00};
    always @(*) begin
        flush_o = 1'b0;
        new_pc_o = `ZERO;
        epc_we_o = 1'b0;
        epc_o = `ZERO;
        cause_we_o = 1'b0;
        mstatus_ie_clear_o = 1'b0;
        mstatus_ie_set_o = 1'b0;
        case (S)
            TRAP_TAKEN: begin
                flush_o = 1'b1;
                new_pc_o = trap_mux_out;
                epc_we_o = 1'b1;
                epc_o = pc_i;
                cause_we_o = 1'b1;
                mstatus_ie_clear_o = 1'b1;
            end
            TRAP_RETURN: begin
                flush_o = 1'b1;
                new_pc_o = epc_i;
                mstatus_ie_set_o = 1'b1;
            end
            default: ;
        endcase
    end
endmodule
