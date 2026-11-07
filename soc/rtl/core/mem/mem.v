`include "defines.v"

module mem (
    input wire rst_i,
    input wire[`RADDR_WIDTH-1:0] reg_waddr_i,
    input wire reg_we_i,
    input wire[`RDATA_WIDTH-1:0] reg_wdata_i,
    input wire[`ADDR_WIDTH-1:0] mem_addr_i,
    input wire mem_we_i,
    input wire[`DATA_WIDTH-1:0] mem_data_i,
    input wire[3:0] mem_op_i,
    
    input wire[`DATA_WIDTH-1:0] ram_data_i,

    output reg[`RADDR_WIDTH-1:0] reg_waddr_o,
    output reg reg_we_o,
    output reg[`RDATA_WIDTH-1:0] reg_wdata_o,

    output reg[`ADDR_WIDTH-1:0] ram_addr_o,
    output reg ram_w_request_o,
    output reg[`RDATA_WIDTH-1:0] ram_data_o,

    output reg halt_o
);
    wire[1:0] ram_addr_offset = mem_addr_i[1:0];
    always @(*) begin
        reg_waddr_o = reg_waddr_i;
        reg_we_o = reg_we_i;
        reg_wdata_o = reg_wdata_i;
        ram_addr_o = `ZERO;
        ram_w_request_o = `WRITE_DISABLE;
        ram_data_o = `ZERO;
        halt_o = 1'b0;
        if(rst_i == 1'b1) begin
            reg_waddr_o = `ZERO_REG;
            reg_we_o = `WRITE_DISABLE;
            reg_wdata_o = `ZERO;
            ram_addr_o = `ZERO;
            ram_w_request_o = `WRITE_DISABLE;
            ram_data_o = `ZERO;
        end else begin
            reg_waddr_o = reg_waddr_i;
            reg_we_o = reg_we_i;
            ram_w_request_o = mem_we_i;
            ram_addr_o = mem_addr_i;
            ram_data_o = `ZERO;
            case (mem_op_i)
                `LB: begin
                    case (ram_addr_offset)
                        2'b00: reg_wdata_o = {{24{ram_data_i[7]}}, ram_data_i[7:0]};
                        2'b01: reg_wdata_o = {{24{ram_data_i[15]}}, ram_data_i[15:8]};
                        2'b10: reg_wdata_o = {{24{ram_data_i[23]}}, ram_data_i[23:16]};
                        2'b11: reg_wdata_o = {{24{ram_data_i[31]}}, ram_data_i[31:24]};
                    endcase
                end
                `LBU: begin
                    case (ram_addr_offset)
                        2'b00: reg_wdata_o = {24'b0, ram_data_i[7:0]};
                        2'b01: reg_wdata_o = {24'b0, ram_data_i[15:8]};
                        2'b10: reg_wdata_o = {24'b0, ram_data_i[23:16]};
                        2'b11: reg_wdata_o = {24'b0, ram_data_i[31:24]};
                    endcase
                end
                `LH: begin
                    if(ram_addr_offset[1] == 1'b0) reg_wdata_o = {{16{ram_data_i[15]}}, ram_data_i[15:0]};
                    else reg_wdata_o = {{16{ram_data_i[31]}}, ram_data_i[31:16]};
                end
                `LHU: begin
                    if(ram_addr_offset[1] == 1'b0) reg_wdata_o = {16'b0, ram_data_i[15:0]};
                    else reg_wdata_o = {16'b0, ram_data_i[31:16]};
                end
                `LW: begin
                    reg_wdata_o = ram_data_i;
                end
                `SB: begin
                    case (ram_addr_offset)
                        2'b00: ram_data_o = {ram_data_i[31:8], mem_data_i[7:0]};
                        2'b01: ram_data_o = {ram_data_i[31:16], mem_data_i[7:0], ram_data_i[7:0]};
                        2'b10: ram_data_o = {ram_data_i[31:24], mem_data_i[7:0], ram_data_i[15:0]};
                        2'b11: ram_data_o = {mem_data_i[7:0], ram_data_i[23:0]};
                    endcase
                end
                `SH: begin
                    if(ram_addr_offset[1] == 1'b0) ram_data_o = {ram_data_i[31:16], mem_data_i[15:0]};
                    else ram_data_o = {mem_data_i[15:0], ram_data_i[15:0]};
                end
                `SW: begin
                    ram_data_o = mem_data_i;
                    if(mem_addr_i == 32'h0020_0008) begin
                        halt_o = 1'b1;
                    end
                end
                default: begin
                    reg_wdata_o = reg_wdata_i;
                    ram_addr_o = `ZERO;
                    ram_data_o = `ZERO;
                    ram_w_request_o = `WRITE_DISABLE;
                    halt_o = 1'b0;
                end
            endcase
        end
    end
endmodule
