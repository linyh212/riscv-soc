`include "defines.v"

module clint (
    input wire clk_i,
    input wire rst_i,
    input wire req_i,
    input wire we_i,
    input wire[`DATA_WIDTH-1:0] addr_i,
    input wire[`DATA_WIDTH-1:0] data_i,
    output reg[`DATA_WIDTH-1:0] data_o,
    output reg timer_irq_o,
    output reg software_irq_o
);
    localparam MSIP_BASE = 16'h0000;
    localparam MTIMECMP_BASE = 16'h4000;
    localparam TIME_ADDR = 16'hBFF8;
    wire[15:0] raddr = addr_i[15:0];
    reg[`DATA_WIDTH-1:0] mtime_mem[0:1];
    reg[`DATA_WIDTH-1:0] mtimecmp_mem[0:1];
    reg[`DATA_WIDTH-1:0] msip_mem;
    wire[63:0] mtime = {mtime_mem[1], mtime_mem[0]};
    wire[63:0] mtimecmp = {mtimecmp_mem[1], mtimecmp_mem[0]};
    wire carry = (mtime_mem[0] == 32'hFFFF_FFFF);
    wire is_msip_addr = (raddr == MSIP_BASE);
    wire is_mtimecmp_addr0 = (raddr == MTIMECMP_BASE);
    wire is_mtimecmp_addr1 = (raddr == MTIMECMP_BASE + 16'h4);
    wire is_time_addr0 = (raddr == TIME_ADDR);
    wire is_time_addr1 = (raddr == TIME_ADDR + 16'h4);
    always @(posedge clk_i) begin
        if(rst_i == 1'b1) begin
            mtime_mem[0] <= 32'b0;
            mtime_mem[1] <= 32'b0;
            mtimecmp_mem[0] <= 32'b0;
            mtimecmp_mem[1] <= 32'b0;
            msip_mem <= 32'b0;
        end else begin
            mtime_mem[0] <= mtime_mem[0] + 32'b1;
            mtime_mem[1] <= mtime_mem[1] + {31'b0, carry};
            if (req_i == 1'b1 && we_i == `WRITE_ENABLE) begin
                if(is_msip_addr)
                    msip_mem <= data_i;
                else if(is_mtimecmp_addr0)
                    mtimecmp_mem[0] <= data_i;
                else if(is_mtimecmp_addr1)
                    mtimecmp_mem[1] <= data_i;
                else if(is_time_addr0)
                    mtime_mem[0] <= data_i;
                else if(is_time_addr1)
                    mtime_mem[1] <= data_i;
            end
        end
    end
    always @(*) begin
        if(req_i == 1'b1) begin
            if(is_msip_addr)
                data_o = msip_mem;
            else if(is_mtimecmp_addr0)
                data_o = mtimecmp_mem[0];
            else if(is_mtimecmp_addr1)
                data_o = mtimecmp_mem[1];
            else if(is_time_addr0)
                data_o = mtime_mem[0];
            else if(is_time_addr1)
                data_o = mtime_mem[1];
            else
                data_o = `ZERO;
        end else begin
            data_o = `ZERO;
        end
    end
    assign timer_irq_o = (mtime >= mtimecmp) && (|mtimecmp);
    assign software_irq_o = |msip_mem;
endmodule
