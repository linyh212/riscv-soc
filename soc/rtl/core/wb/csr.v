`include "defines.v"

module csr (
    input wire clk_i,
    input wire rst_i,
    input wire[`CSR_ADDR_WIDTH-1:0] raddr_i,
    output reg[`DATA_WIDTH-1:0] rdata_o,
    input wire we_i,
    input wire[`CSR_ADDR_WIDTH-1:0] waddr_i,
    input wire[`DATA_WIDTH-1:0] wdata_i,
    input wire instret_incr_i,

    input wire irq_timer_i,
    input wire irq_software_i,
    input wire irq_external_i,
    output reg mstatus_ie_o,
    output reg mie_external_o,
    output reg mie_timer_o,
    output reg mie_software_o,
    output reg mip_external_o,
    output reg mip_timer_o,
    output reg mip_software_o,
    output reg[`DATA_WIDTH-1:0] mtvec_o,
    output reg[`DATA_WIDTH-1:0] mepc_o,
    input wire interrupt_type_i,
    input wire cause_we_i,
    input wire[3:0] cause_i,
    input wire epc_we_i,
    input wire[`DATA_WIDTH-1:0] epc_i,
    input wire mstatus_ie_clear_i,
    input wire mstatus_ie_set_i
);
    localparam CSR_MVENDORID_VALUE = 32'b0;
    localparam CSR_MARCHID_VALUE = {1'b0, 31'd22};
    localparam CSR_MIMPID_VALUE = 32'b0;
    localparam CSR_MHARTID_VALUE = 32'b0;
    wire[1:0] mxl = 2'b01;
    wire[25:0] mextensions = 26'b00000000000001000100000000;
    wire[`DATA_WIDTH-1:0] misa = {mxl, 4'b0, mextensions};
    reg[63:0] mcycle;
    reg[63:0] minstret;
    reg mstatus_mpie;
    reg mstatus_mie;
    wire[1:0] mstatus_mpp = 2'b11;
    wire[`DATA_WIDTH-1:0] mstatus = {19'b0, mstatus_mpp, 3'b0, mstatus_mpie, 3'b0, mstatus_mie, 3'b0};
    reg[`DATA_WIDTH-1:0] mie;
    reg mip_external;
    reg mip_timer;
    reg mip_sw;
    wire[`DATA_WIDTH-1:0] mip = {20'b0, mip_external, 3'b0, mip_timer, 3'b0, mip_sw, 3'b0};
    reg[`DATA_WIDTH-1:0] mtvec;
    reg[`DATA_WIDTH-1:0] mscratch;
    reg[`DATA_WIDTH-1:0] mepc;
    reg[`DATA_WIDTH-1:0] mcause;
    reg[`DATA_WIDTH-1:0] mtval;
    assign mstatus_ie_o = mstatus_mie;
    assign mie_external_o = mie[11];
    assign mie_timer_o = mie[7];
    assign mie_software_o = mie[3];
    assign mip_external_o = mip_external;
    assign mip_timer_o = mip_timer;
    assign mip_software_o = mip_sw;
    assign mtvec_o = mtvec;
    assign mepc_o = mepc;
    wire w_mstatus = (waddr_i == `CSR_MSTATUS_ADDR) && (we_i == `WRITE_ENABLE);
    wire w_mie = (waddr_i == `CSR_MIE_ADDR) && (we_i == `WRITE_ENABLE);
    wire w_mtvec = (waddr_i == `CSR_MTVEC_ADDR) && (we_i == `WRITE_ENABLE);
    wire w_mscratch = (waddr_i == `CSR_MSCRATCH_ADDR) && (we_i == `WRITE_ENABLE);
    wire w_mepc = (waddr_i == `CSR_MEPC_ADDR) && (we_i == `WRITE_ENABLE);
    wire w_mcause = (waddr_i == `CSR_MCAUSE_ADDR) && (we_i == `WRITE_ENABLE);
    wire w_mip = (waddr_i == `CSR_MIP_ADDR) && (we_i == `WRITE_ENABLE);
    wire w_mtval = (waddr_i == `CSR_MTVAL_ADDR) && (we_i == `WRITE_ENABLE);
    always @(posedge clk_i) begin
        if(rst_i == 1'b1) begin
            mcycle <= 64'd0;
            minstret <= 64'd0;
            mstatus_mie <= 1'b0;
            mstatus_mpie <= 1'b1;
            mie <= 32'h00000000;
            mtvec <= 32'h00000000;
            mscratch <= 32'h00000000;
            mepc <= 32'h00000000;
            mcause <= 32'h00000000;
            mip_external <= 1'b0;
            mip_timer <= 1'b0;
            mip_sw <= 1'b0;
            mtval <= 32'h00000000;
        end else begin
            if((waddr_i == `CSR_MCYCLE_ADDR) && (we_i == `WRITE_ENABLE))
                mcycle[31:0] <= wdata_i;
            else if((waddr_i == `CSR_MCYCLEH_ADDR) && (we_i == `WRITE_ENABLE))
                mcycle[63:32] <= wdata_i;
            else mcycle <= mcycle + 64'd1;
            if((waddr_i == `CSR_MINSTRET_ADDR) && (we_i == `WRITE_ENABLE))
                minstret[31:0] <= wdata_i;
            else if((waddr_i == `CSR_MINSTRETH_ADDR) && (we_i == `WRITE_ENABLE))
                minstret[63:32] <= wdata_i;
            else if(instret_incr_i)
                minstret <= minstret + 64'd1;
            
            if(mstatus_ie_clear_i) begin
                mstatus_mpie <= mstatus_mie;
                mstatus_mie <= 1'b0;
            end else if(mstatus_ie_set_i) begin
                mstatus_mie <= mstatus_mpie;
                mstatus_mpie <= 1'b1;
            end else if(w_mstatus) begin
                mstatus_mie <= wdata_i[3];
                mstatus_mpie <= wdata_i[7];
            end
            mip_external <= irq_external_i;
            mip_timer <= irq_timer_i;
            mip_sw <= irq_software_i;
            if(epc_we_i) mepc <= {epc_i[31:2], 2'b00};
            else if(w_mepc) mepc <= {wdata_i[31:2], 2'b00};
            if(cause_we_i) mcause <= {interrupt_type_i, 27'b0, cause_i};
            else if(w_mcause) mcause <= wdata_i;

            if(w_mie) mie <= wdata_i;
            if(w_mtvec) mtvec <= {wdata_i[31:2], 1'b0, wdata_i[0]};
            if(w_mscratch) mscratch <= wdata_i;
            if(w_mtval) mtval <= wdata_i;
        end
    end
    always @(*) begin
        if((waddr_i == raddr_i) && (we_i == `WRITE_ENABLE) && (raddr_i != `CSR_MIP_ADDR)) begin
            rdata_o = wdata_i;
        end else begin
            case (raddr_i)
                `CSR_MVENDORID_ADDR: rdata_o = CSR_MVENDORID_VALUE;
                `CSR_MARCHID_ADDR: rdata_o = CSR_MARCHID_VALUE;
                `CSR_MIMPID_ADDR: rdata_o = CSR_MIMPID_VALUE;
                `CSR_MHARTID_ADDR: rdata_o = CSR_MHARTID_VALUE;
                `CSR_MISA_ADDR: rdata_o = misa;
                
                `CSR_MCYCLE_ADDR, `CSR_CYCLE_ADDR: rdata_o = mcycle[31:0];
                `CSR_MCYCLEH_ADDR, `CSR_CYCLEH_ADDR: rdata_o = mcycle[63:32];
                `CSR_MINSTRET_ADDR: rdata_o = minstret[31:0];
                `CSR_MINSTRETH_ADDR: rdata_o = minstret[63:32];
                
                `CSR_MSTATUS_ADDR: rdata_o = mstatus;
                `CSR_MIE_ADDR: rdata_o = mie;
                `CSR_MTVEC_ADDR: rdata_o = mtvec;
                `CSR_MSCRATCH_ADDR: rdata_o = mscratch;
                `CSR_MEPC_ADDR: rdata_o = mepc;
                `CSR_MCAUSE_ADDR: rdata_o = mcause;
                `CSR_MIP_ADDR: rdata_o = mip;
                `CSR_MTVAL_ADDR: rdata_o = mtval;
                default: rdata_o = `ZERO;
            endcase
        end
    end
endmodule
