`include "defines.v"

/* verilator lint_off UNUSEDSIGNAL */
module regfile (
    input wire clk_i,
    input wire rst_i,
    
    input wire re1_i,
    input wire[`RADDR_WIDTH-1:0] raddr1_i,
    output reg[`RDATA_WIDTH-1:0] rdata1_o,
    
    input wire re2_i,
    input wire[`RADDR_WIDTH-1:0] raddr2_i,
    output reg[`RDATA_WIDTH-1:0] rdata2_o
);
/* verilator lint_on UNUSEDSIGNAL */
    reg[`RDATA_WIDTH-1:0] regs[0:`RNUM-1];
    integer i;
    initial begin
        for(i = 0; i < `RNUM; i = i + 1)
            regs[i] = `ZERO;
    end
    always @(*) begin
        if(raddr1_i == `ZERO_REG) begin
            rdata1_o = `ZERO;
        end else if(re1_i == `READ_ENABLE) begin
            rdata1_o = regs[raddr1_i];
        end else begin
            rdata1_o = `ZERO;
        end
    end
    always @(*) begin
        if(raddr2_i == `ZERO_REG) begin
            rdata2_o = `ZERO;
        end else if(re2_i == `READ_ENABLE) begin
            rdata2_o = regs[raddr2_i];
        end else begin
            rdata2_o = `ZERO;
        end
    end
endmodule
