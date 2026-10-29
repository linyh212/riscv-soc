`include "defines.v"

module inst_fetch (
    input wire clk_i,
    input  wire rst_i,
    output wire[`ADDR_WIDTH-1:0] pc_o,
    output wire[`DATA_WIDTH-1:0] inst_o
);
    wire ce_wire;
    pc_reg pc_reg0 (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .pc_o  (pc_o),
        .ce_o  (ce_wire)
    );
    rom rom0 (
        .clk_i  (clk_i),
        .ce_i   (ce_wire),
        .addr_i (pc_o),
        .inst_o (inst_o)
    );
endmodule
