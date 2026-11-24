`include "defines.v"

module interrupt_ctrl (
    input wire                  clk_i,
    input wire                  rst_i,
    // Pipeline & Exception Inputs
    input wire[`DATA_WIDTH-1:0] exception_i,
    input wire[`DATA_WIDTH-1:0] pc_i,
    input wire[`DATA_WIDTH-1:0] exception_pc_i,
    // CSR Status & Interrupt Enable/Pending Inputs
    input wire                  mstatus_ie_i,
    input wire                  mie_external_i,
    input wire                  mie_timer_i,
    input wire                  mie_sw_i,
    input wire                  mip_external_i,
    input wire                  mip_timer_i,
    input wire                  mip_sw_i,
    input wire[`DATA_WIDTH-1:0] mtvec_i,
    input wire[`DATA_WIDTH-1:0] epc_i,
    // CSR Write & Control Outputs
    output reg                  interrupt_type_o,
    output reg                  cause_we_o,
    output reg[3:0]             trap_cause_o,
    output reg                  epc_we_o,
    output reg[`DATA_WIDTH-1:0] epc_o,
    output reg                  mstatus_ie_clear_o,
    output reg                  mstatus_ie_set_o,
    // Pipeline Flush & Next PC Outputs
    output reg                  flush_o,
    output reg[`DATA_WIDTH-1:0] new_pc_o
);
    // 1. State Machine Parameters & Internal Registers
    localparam RESET = 4'b0001;
    localparam OPERATING = 4'b0010;
    localparam TRAP_TAKEN = 4'b0100;
    localparam TRAP_RETURN = 4'b1000;
    reg[3:0] S, S_nxt;
    reg exception;
    reg[`DATA_WIDTH-1:0] exception_pc;
    // 2. Internal Wires & Trap Detection Logic
    wire mret, ecall;
    wire eip, tip, sip, ip;
    wire trap_happened;
    wire[29:0] mtvec_base;
    wire[31:0] base_offset;
    wire[31:0] vec_mux_out;
    wire[31:0] trap_mux_out;
    assign{ecall, mret} = exception_i[1:0];
    assign eip = mie_external_i & mip_external_i;
    assign tip = mie_timer_i & mip_timer_i;
    assign sip = mie_sw_i & mip_sw_i;
    assign ip = eip | tip | sip;
    assign trap_happened = (mstatus_ie_i & ip) | ecall;
    assign mtvec_base = mtvec_i[31:2];
    assign base_offset = {26'b0, trap_cause_o, 2'b00};
    assign vec_mux_out = mtvec_i[0] ? ({mtvec_base, 2'b00} + base_offset) : {mtvec_base, 2'b00};
    assign trap_mux_out = interrupt_type_o ? vec_mux_out : {mtvec_base, 2'b00};
    // 3. State Register & Exception Latching
    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            S <= RESET;
            exception <= 1'b0;
            exception_pc <= `ZERO;
        end else begin
            S <= S_nxt;
            exception <= (|exception_i);
            if (|exception_i) begin
                exception_pc <= exception_pc_i;
            end
        end
    end
    // 4. Trap Cause & Type Encoding (Priority Order)
    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            trap_cause_o <= 4'b0;
            interrupt_type_o <= 1'b0;
        end else if (S == OPERATING) begin
            if (mstatus_ie_i & eip) begin
                trap_cause_o <= 4'd11;
                interrupt_type_o <= 1'b1;
            end else if (mstatus_ie_i & sip) begin
                trap_cause_o <= 4'd3;
                interrupt_type_o <= 1'b1;
            end else if (mstatus_ie_i & tip) begin
                trap_cause_o <= 4'd7;
                interrupt_type_o <= 1'b1;
            end else if (ecall) begin
                trap_cause_o <= 4'd11;
                interrupt_type_o <= 1'b0;
            end
        end
    end
    // 5. Combinational Logic: Next-State Transition
    always @(*) begin
        case (S)
            RESET: begin
                S_nxt = OPERATING;
            end
            OPERATING: begin
                if (trap_happened) begin
                    S_nxt = TRAP_TAKEN;
                end else if (mret) begin
                    S_nxt = TRAP_RETURN;
                end else begin
                    S_nxt = OPERATING;
                end
            end
            TRAP_TAKEN: begin
                S_nxt = OPERATING;
            end
            TRAP_RETURN: begin
                S_nxt = OPERATING;
            end
            default: begin
                S_nxt = OPERATING;
            end
        endcase
    end
    // 6. Combinational Logic: Output Control Signals
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
                epc_o = exception ? (exception_pc - 32'd4) : pc_i;
                cause_we_o = 1'b1;
                mstatus_ie_clear_o = 1'b1;
            end
            TRAP_RETURN: begin
                flush_o = 1'b1;
                new_pc_o = epc_i;
                mstatus_ie_set_o = 1'b1;
            end
            default: begin
            end
        endcase
    end
endmodule
