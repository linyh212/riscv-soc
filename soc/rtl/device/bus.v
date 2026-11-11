`include "defines.v"

module bus #(
    parameter NrDevices = 1,
    parameter NrHosts = 1,
    parameter DataWidth = 32,
    parameter AddressWidth = 32
) (
    input wire clk_i,
    input wire rst_i,
    
    input wire host_req_i[NrHosts],
    output reg host_gnt_o[NrHosts],
    input wire[AddressWidth-1:0] host_addr_i[NrHosts],
    input wire host_we_i[NrHosts],
    input wire[DataWidth-1:0] host_wdata_i[NrHosts],
    output reg[DataWidth-1:0] host_rdata_o[NrHosts],

    output reg device_req_o[NrDevices],
    output reg[AddressWidth-1:0] device_addr_o[NrDevices],
    output reg device_we_o[NrDevices],
    output reg[DataWidth-1:0] device_wdata_o[NrDevices],
    input wire[DataWidth-1:0] device_rdata_i[NrDevices],

    input wire[AddressWidth-1:0] cfg_device_addr_base[NrDevices],
    input wire[AddressWidth-1:0] cfg_device_addr_mask[NrDevices]
);
    localparam NumBitsHostSel = $clog2(NrHosts) > 0 ? $clog2(NrHosts) : 1;
    localparam NumBitsDeviceSel = $clog2(NrDevices) > 0 ? $clog2(NrDevices) : 1;
    /* verilator lint_off UNUSEDSIGNAL */
    reg[NumBitsHostSel-1:0] host_sel_req, host_sel_resp;
    reg[NumBitsDeviceSel-1:0] device_sel_req, device_sel_resp;
    /* verilator lint_on UNUSEDSIGNAL */
    // 1. Host Prior Arbiter
    always @(*) begin
        host_sel_req = '0;
        for(integer host = NrHosts - 1; host >= 0; host = host - 1) begin
            if(host_req_i[host_sel_req]) begin
                host_sel_req = host[NumBitsHostSel-1:0];
            end
        end
    end
    // 2. Address Decode
    always @(*) begin
        device_sel_req = '0;
        for(integer device = 0; device < NrDevices; device = device + 1) begin
            if(host_req_i[host_sel_req]) begin
                if((host_addr_i[host_sel_req] & cfg_device_addr_mask[device]) == cfg_device_addr_base[device]) begin
                    device_sel_req = device[NumBitsDeviceSel-1:0];
                end
            end
        end
    end
    // 3. Request (Host -> Selected Device)
    always @(*) begin
        for(integer device = 0; device < NrDevices; device = device + 1) begin
            if(device[NumBitsDeviceSel-1:0] == device_sel_req) begin
                device_req_o[device] = host_req_i[host_sel_req];
                device_we_o[device] = host_we_i[host_sel_req];
                device_addr_o[device] = host_addr_i[host_sel_req];
                device_wdata_o[device] = host_wdata_i[host_sel_req];
            end else begin
                device_req_o[device] = 1'b0;
                device_we_o[device] = 1'b0;
                device_addr_o[device] = {AddressWidth{1'b0}};
                device_wdata_o[device] = {DataWidth{1'b0}};
            end
        end
    end
    // 4. Reponse (Device -> Requesting Host)
    always @(*) begin
        for(integer host = 0; host < NrHosts; host = host + 1) begin
            host_gnt_o[host] = 1'b0;
            if(host[NumBitsHostSel-1:0] == host_sel_req && host_req_i[host_sel_req]) begin
                host_rdata_o[host] = device_rdata_i[device_sel_req];
            end else begin
                host_rdata_o[host] = {DataWidth{1'b0}};
            end
        end
        host_gnt_o[host_sel_req] = host_req_i[host_sel_req];
    end
    // 5. Pipeline Alignment
    always @(posedge clk_i) begin
        if(rst_i == 1'b1) begin
            host_sel_resp <= 1'b0;
            device_sel_resp <= '0;
        end else begin
            device_sel_resp <= device_sel_req;
            host_sel_resp <= host_sel_req;
        end
    end
endmodule
