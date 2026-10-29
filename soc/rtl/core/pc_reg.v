`include "defines.v"

module pc_reg (
    input wire clk_i,
    input wire rst_i,
    output reg[`ADDR_WIDTH-1:0] pc_o,
    output reg ce_o
);
    localparam[`ADDR_WIDTH-1:0] PC_RESET = {`ADDR_WIDTH{1'b0}};
    localparam[`ADDR_WIDTH-1:0] PC_INC = {{(`ADDR_WIDTH-32){1'b0}}, 32'd4};
    always @(posedge clk_i) begin
        if(rst_i) begin
            ce_o <= 1'b0;
        end else begin
            ce_o <= 1'b1;
        end
    end
    always @(posedge clk_i) begin
        if(ce_o == 1'b0) begin
            pc_o <= PC_RESET;
        end else begin
            pc_o <= pc_o + PC_INC;
        end
    end
endmodule
