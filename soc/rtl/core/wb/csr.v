`include "defines.v"

module csr (
    input wire clk_i,
    input wire rst_i,
    input wire[`CSR_ADDR_WIDTH-1:0] raddr_i,
    output reg[`DATA_WIDTH-1:0] rdata_o,
    input wire we_i,
    input wire[`CSR_ADDR_WIDTH-1:0] waddr_i,
    input wire[`DATA_WIDTH-1:0] wdata_i,
    input wire instret_incr_i
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
    reg[`DATA_WIDTH-1:0] mstatus;
    reg[`DATA_WIDTH-1:0] mie;
    reg[`DATA_WIDTH-1:0] mtvec;
    reg[`DATA_WIDTH-1:0] mscratch;
    reg[`DATA_WIDTH-1:0] mepc;
    reg[`DATA_WIDTH-1:0] mcause;
    reg[`DATA_WIDTH-1:0] mip;
    reg[`DATA_WIDTH-1:0] mtval;
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
            mstatus <= 32'h00000000;
            mie <= 32'h00000000;
            mtvec <= 32'h00000000;
            mscratch <= 32'h00000000;
            mepc <= 32'h00000000;
            mcause <= 32'h00000000;
            mip <= 32'h00000000;
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
            if(w_mstatus) mstatus <= wdata_i;
            if(w_mie) mie <= wdata_i;
            if(w_mtvec) mtvec <= {wdata_i[31:2], 2'b00};
            if(w_mscratch) mscratch <= wdata_i;
            if(w_mepc) mepc <= {wdata_i[31:2], 2'b00};
            if(w_mcause) mcause <= wdata_i;
            if(w_mip) mip <= wdata_i;
            if(w_mtval) mtval <= wdata_i;
        end
    end
    always @(*) begin
        if((waddr_i == raddr_i) && (we_i == `WRITE_ENABLE)) begin
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
