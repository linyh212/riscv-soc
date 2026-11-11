`include "defines.v"

module timer (
    input wire clk_i,
    input wire rst_i,
    input wire req_i,
    input wire we_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input wire[31:0] addr_i,
    /* verilator lint_on UNUSEDSIGNAL */
    input wire[31:0] wdata_i,
    output reg[31:0] rdata_o,
    output reg irq_o
);
    localparam reg[7:0] TIMER_CTRL_ADDR = 8'h00;
    localparam reg[7:0] TIMER_PRESCALER_ADDR = 8'h04;
    localparam reg[7:0] TIMER_VALUE_ADDR = 8'h08;
    localparam reg[7:0] TIMER_COMPARE_ADDR = 8'h0C;
    reg[31:0] ctrl_reg;
    reg[31:0] prescaler_reg;
    reg[31:0] value_reg;
    reg[31:0] compare_reg;
    reg[31:0] prescale_cnt;
    wire timer_en = ctrl_reg[0];
    wire auto_reload = ctrl_reg[1];
    wire[7:0] offset = addr_i[7:0];

    always @(*) begin
        if(req_i && !we_i) begin
            case (offset)
                TIMER_CTRL_ADDR: rdata_o = ctrl_reg;
                TIMER_PRESCALER_ADDR: rdata_o = prescaler_reg;
                TIMER_COMPARE_ADDR: rdata_o = compare_reg;
                TIMER_VALUE_ADDR: rdata_o = value_reg; 
                default: rdata_o = 32'h0;
            endcase
        end else begin
            rdata_o = 32'h0;
        end
    end
    always @(posedge clk_i) begin
        if(rst_i == 1'b1) begin
            ctrl_reg <= 32'h0;
            prescaler_reg <= 32'h0;
            value_reg <= 32'h0;
            compare_reg <= 32'h0;
            prescale_cnt <= 32'h0;
            irq_o <= 1'b0;
        end else begin
            if(req_i && we_i) begin
                case(offset)
                    TIMER_CTRL_ADDR: begin
                        ctrl_reg <= wdata_i;
                        if(!wdata_i[0]) begin
                            irq_o <= 1'b0;
                        end
                    end
                    TIMER_PRESCALER_ADDR: prescaler_reg <= wdata_i;
                    TIMER_VALUE_ADDR: begin
                        value_reg <= wdata_i;
                        prescale_cnt <= 32'h0;
                        irq_o <= 1'b0;
                    end
                    TIMER_COMPARE_ADDR: compare_reg <= wdata_i;
                    default: ;
                endcase
            end else if(timer_en) begin
                if(prescale_cnt >= prescaler_reg) begin
                    prescale_cnt <= 32'h0;
                    if(compare_reg != 32'h0 && value_reg >= compare_reg) begin
                        irq_o <= 1'b1;
                        if(auto_reload) begin
                            value_reg <= 32'h0;
                        end else begin
                            ctrl_reg[0] <= 1'b0;
                        end
                    end else begin
                        value_reg <= value_reg + 1'b1;
                    end
                end else begin
                    prescale_cnt <= prescale_cnt + 1'b1;
                end
            end
        end
    end
endmodule
