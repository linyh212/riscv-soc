`include "defines.v"

module plic #(
    parameter NUM_SOURCES = 8
) (
    input wire                  clk_i,
    input wire                  rst_i,
    input wire                  req_i,
    input wire                  we_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input wire[`ADDR_WIDTH-1:0] addr_i,
    input wire[`DATA_WIDTH-1:0] wdata_i,
    /* verilator lint_on UNUSEDSIGNAL */
    output reg[`DATA_WIDTH-1:0] rdata_o,
    input wire[NUM_SOURCES:1]   irq_sources_i,
    output wire                 eip_o
);
    localparam PRIO_WIDTH = 3;
    reg[PRIO_WIDTH-1:0] priority_reg[1:NUM_SOURCES];
    reg[NUM_SOURCES:1]  ip_reg;
    reg[NUM_SOURCES:1]  ie_reg;
    reg[NUM_SOURCES:1]  claimed_reg;
    reg[NUM_SOURCES:1]  sw_trig_reg;
    reg[PRIO_WIDTH-1:0] threshold_reg;
    wire[23:0] offset = addr_i[23:0];
    wire[NUM_SOURCES:1] effective_irq = irq_sources_i | sw_trig_reg;
    // 1. Priority Arbiter
    reg[4:0]            max_id;
    reg[PRIO_WIDTH-1:0] max_prio;
    integer i;
    always @(*) begin
        max_id = 5'd0;
        max_prio = {PRIO_WIDTH{1'b0}};
        for(i = 1; i <= NUM_SOURCES; i = i + 1) begin
            if(ip_reg[i] && ie_reg[i] && (priority_reg[i] > max_prio)) begin
                max_prio = priority_reg[i];
                max_id = i[4:0];
            end
        end
    end
    assign eip_o = (max_prio > threshold_reg);
    // 2. Gateway Pending Latch & Claim/Complete Status Update
    wire is_claim_read = req_i && !we_i && (offset == 24'h200004);
    wire is_comp_write = req_i && we_i && (offset == 24'h200004);
    integer s;
    always @(posedge clk_i) begin
        if(rst_i) begin
            ip_reg <= {NUM_SOURCES{1'b0}};
            claimed_reg <= {NUM_SOURCES{1'b0}};
            sw_trig_reg <= {NUM_SOURCES{1'b0}};
            ie_reg <= {NUM_SOURCES{1'b0}};
            threshold_reg <= {PRIO_WIDTH{1'b0}};
            for (s = 1; s <= NUM_SOURCES; s = s + 1) begin
                priority_reg[s] <= {PRIO_WIDTH{1'b0}};
            end
        end else begin
            for (s = 1; s <= NUM_SOURCES; s = s + 1) begin
                if(effective_irq[s] && !claimed_reg[s]) begin
                    ip_reg[s] <= 1'b1;
                end
            end
            if(is_claim_read && (max_id != 5'd0)) begin
                ip_reg[max_id] <= 1'b0;
                claimed_reg[max_id] <= 1'b1;
            end
            if(is_comp_write && (wdata_i[4:0] >= 5'd1) && (wdata_i[4:0] <= NUM_SOURCES[4:0])) begin
                claimed_reg[wdata_i[4:0]] <= 1'b0;
            end
            if(req_i && we_i) begin
                if(offset >= 24'h000004 && offset <= (NUM_SOURCES * 4)) begin
                    priority_reg[offset[6:2]] <= wdata_i[PRIO_WIDTH-1:0];
                end else if(offset == 24'h002000) begin
                    ie_reg <= wdata_i[NUM_SOURCES:1];
                end else if(offset == 24'h200000) begin
                    threshold_reg <= wdata_i[PRIO_WIDTH-1:0];
                end else if (offset == 24'h200008) begin
                    sw_trig_reg <= wdata_i[NUM_SOURCES:1];
                end
            end
        end
    end
    // 3. MMIO Read Decode
    always @(*) begin
        rdata_o = 32'h0;
        if (req_i && !we_i) begin
            if (offset >= 24'h000004 && offset <= (NUM_SOURCES * 4)) begin
                rdata_o = {{(32-PRIO_WIDTH){1'b0}}, priority_reg[offset[6:2]]};
            end else if (offset == 24'h001000) begin
                rdata_o = {{(31-NUM_SOURCES){1'b0}}, ip_reg, 1'b0};
            end else if (offset == 24'h002000) begin
                rdata_o = {{(31-NUM_SOURCES){1'b0}}, ie_reg, 1'b0};
            end else if (offset == 24'h200000) begin
                rdata_o = {{(32-PRIO_WIDTH){1'b0}}, threshold_reg};
            end else if (offset == 24'h200004) begin
                rdata_o = {27'd0, max_id};
            end else if (offset == 24'h200008) begin
                rdata_o = {{(31-NUM_SOURCES){1'b0}}, sw_trig_reg, 1'b0};
            end
        end
    end
endmodule
