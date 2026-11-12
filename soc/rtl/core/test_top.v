`include "defines.v"

module test_top (
    input wire                      clk_i,
    input wire                      rst_i,
    output wire[`ADDR_WIDTH-1:0]    pc_o,
    output wire[`DATA_WIDTH-1:0]    if_inst_o,
    output wire[`DATA_WIDTH-1:0]    if_id_inst_o,
    output wire[`RDATA_WIDTH-1:0]   id_op1_o,
    output wire[`RDATA_WIDTH-1:0]   id_op2_o,
    output wire                     halt_o
);
    localparam int NrDevices = 3;
    localparam int NrHosts = 1;
    localparam int MemSize = 32'h100000;
    localparam int MemAddrWidth = 20;

    `define HOST_CORE_PORT  0
    `define DEV_RAM         0
    `define DEV_CONSOLE     1
    `define DEV_TIMER       2

    wire                    host_req[NrHosts];
    /* verilator lint_off UNUSEDSIGNAL */
    wire                    host_gnt[NrHosts];
    /* verilator lint_on UNUSEDSIGNAL */
    wire[`ADDR_WIDTH-1:0]   host_addr[NrHosts];
    wire                    host_we[NrHosts];
    wire[`DATA_WIDTH-1:0]   host_wdata[NrHosts];
    wire[`DATA_WIDTH-1:0]   host_rdata[NrHosts];

    wire                    device_req[NrDevices];
    wire[`ADDR_WIDTH-1:0]   device_addr[NrDevices];
    wire                    device_we[NrDevices];
    wire[`DATA_WIDTH-1:0]   device_wdata[NrDevices];
    wire[`DATA_WIDTH-1:0]   device_rdata[NrDevices];

    wire[`ADDR_WIDTH-1:0]   cfg_device_addr_base[NrDevices];
    wire[`ADDR_WIDTH-1:0]   cfg_device_addr_mask[NrDevices];

    assign cfg_device_addr_base[`DEV_RAM] = 32'h00000000;
    assign cfg_device_addr_mask[`DEV_RAM] = ~32'h000FFFFF;

    assign cfg_device_addr_base[`DEV_CONSOLE] = 32'h00200000;
    assign cfg_device_addr_mask[`DEV_CONSOLE] = 32'hFFFFFF00;

    assign cfg_device_addr_base[`DEV_TIMER] = 32'h00300000;
    assign cfg_device_addr_mask[`DEV_TIMER] = 32'hFFFFFF00;
    
    // ISA test
    wire                    mem_halt_o;
    wire                    console_halt_o;
    assign halt_o = mem_halt_o | console_halt_o;

    // IF Stage
    wire[`ADDR_WIDTH-1:0]   pc_wire;
    wire                    ce_wire;
    reg[`ADDR_WIDTH-1:0]    if_inst_addr_o;
    
    // IF/ID to ID
    wire[`ADDR_WIDTH-1:0]   if_id_inst_addr_o;
    
    // ID to Regfile
    wire[`RADDR_WIDTH-1:0]  id_reg1_addr_o;
    wire                    id_reg1_re_o;
    wire[`RDATA_WIDTH-1:0]  reg1_data_o;
    wire[`RADDR_WIDTH-1:0]  id_reg2_addr_o;
    wire                    id_reg2_re_o;
    wire[`RDATA_WIDTH-1:0]  reg2_data_o;

    // ID to ID/EXE
    wire[`DATA_WIDTH-1:0]       id_inst_o;
    wire                        id_reg_we_o;
    wire[`RADDR_WIDTH-1:0]      id_reg_waddr_o;
    wire                        id_csr_we_o;
    wire[`CSR_ADDR_WIDTH-1:0]   id_csr_addr_o;

    // ID/EXE to EXE
    wire[`DATA_WIDTH-1:0]       id_exe_inst_o;
    wire[`ADDR_WIDTH-1:0]       id_exe_inst_addr_o;
    wire[`RDATA_WIDTH-1:0]      id_exe_op1_o;
    wire[`RDATA_WIDTH-1:0]      id_exe_op2_o;
    wire                        id_exe_reg_we_o;
    wire[`RADDR_WIDTH-1:0]      id_exe_reg_waddr_o;
    wire                        id_exe_csr_we_o;
    wire[`CSR_ADDR_WIDTH-1:0]   id_exe_csr_addr_o;

    // EXE <-> CSR (READ)
    wire[`CSR_ADDR_WIDTH-1:0]   exe_csr_raddr_o;
    wire[`DATA_WIDTH-1:0]       csr_rdata_o;

    // EXE to EXE/MEM
    wire[`RADDR_WIDTH-1:0]      exe_reg_waddr_o;
    wire                        exe_reg_we_o;
    wire[`RDATA_WIDTH-1:0]      exe_reg_wdata_o;
    wire[`ADDR_WIDTH-1:0]       exe_mem_addr_o;
    wire                        exe_mem_we_o;
    wire[`DATA_WIDTH-1:0]       exe_mem_data_o;
    wire[3:0]                   exe_mem_op_o;
    wire                        exe_csr_we_o;
    wire[`CSR_ADDR_WIDTH-1:0]   exe_csr_waddr_o;
    wire[`DATA_WIDTH-1:0]       csr_csr_wdata_o;

    // EXE/MEM to MEM
    wire[`RADDR_WIDTH-1:0]      exe_mem_reg_waddr_o;
    wire                        exe_mem_reg_we_o;
    wire[`RDATA_WIDTH-1:0]      exe_mem_reg_wdata_o;
    wire[`ADDR_WIDTH-1:0]       exe_mem_mem_addr_o;
    wire                        exe_mem_mem_we_o;
    wire[`DATA_WIDTH-1:0]       exe_mem_mem_data_o;
    wire[3:0]                   exe_mem_mem_op_o;
    wire                        exe_mem_csr_we_o;
    wire[`CSR_ADDR_WIDTH-1:0]   exe_mem_csr_waddr_o;
    wire[`DATA_WIDTH-1:0]       csr_mem_csr_wdata_o;

    // MEM to MEM/WB
    wire[`RADDR_WIDTH-1:0]      mem_reg_waddr_o;
    wire                        mem_reg_we_o;
    wire[`RDATA_WIDTH-1:0]      mem_reg_wdata_o;
    wire                        mem_csr_we_o;
    wire[`CSR_ADDR_WIDTH-1:0]   mem_csr_waddr_o;
    wire[`DATA_WIDTH-1:0]       mem_csr_wdata_o;

    // MEM/WB to WB (Regfile Write-Back)
    wire[`RADDR_WIDTH-1:0]  mem_wb_reg_waddr_o;
    wire                    mem_wb_reg_we_o;
    wire[`RDATA_WIDTH-1:0]  mem_wb_reg_wdata_o;

    // MEM/WB to CSR (WRITE)
    wire                        mem_wb_csr_we_o;
    wire[`CSR_ADDR_WIDTH-1:0]   mem_wb_csr_waddr_o;
    wire[`DATA_WIDTH-1:0]       mem_wb_csr_rdata_o;
    
    // Pipeline Control Signal
    /* verilator lint_off UNUSEDSIGNAL */
    wire[5:0]               crtl_stall_o;
    /* verilator lint_on UNUSEDSIGNAL */
    wire                    id_stallreq_o;
    wire                    pre_inst_is_load = (id_exe_inst_o[6:0] == `INST_TYPE_L);

    wire[`ADDR_WIDTH-1:0]   core_ram_addr_o;
    wire[`DATA_WIDTH-1:0]   core_ram_data_o;
    wire[`DATA_WIDTH-1:0]   core_ram_data_i;
    wire                    core_ram_w_request_o;
    wire                    core_ram_ce_o = (core_ram_w_request_o || (exe_mem_mem_op_o != 4'b0));

    wire                    ctrl_flush_jump_o;
    reg                     ctrl_flush_jump_delay;
    wire                    ctrl_flush_fetch_o = ctrl_flush_jump_o | ctrl_flush_jump_delay;
    wire[`ADDR_WIDTH-1:0]   exe_jump_addr_o;
    wire                    exe_jump_enable_o;
    wire                    exe_stallreq_o;
    wire[`ADDR_WIDTH-1:0]   rom_addr_i = ctrl_flush_jump_o ? ctrl_new_pc_o : pc_wire;
    
    wire[`ADDR_WIDTH-1:0]   ctrl_new_pc_o;

    assign pc_o = pc_wire;

    always @(posedge clk_i) begin
        if(rst_i == 1'b1) begin
            ctrl_flush_jump_delay <= 1'b0;
        end else begin
            ctrl_flush_jump_delay <= ctrl_flush_jump_o;
        end
    end
    
    always @(posedge clk_i) begin
        if(rst_i == 1'b1) begin
            if_inst_addr_o <= `ZERO;
        end else if(crtl_stall_o[0] == `NOSTOP) begin
            if_inst_addr_o <= rom_addr_i;
        end
    end

    pc_reg pc_reg0 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(crtl_stall_o[0]),
        .flush_jump_i(ctrl_flush_jump_o),
        .new_pc_i(ctrl_new_pc_o),
        .pc_o(pc_wire),
        .ce_o(ce_wire)
    );
    if_id if_id0 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(crtl_stall_o[2:1]),
        .flush_jump_i(ctrl_flush_fetch_o),
        .inst_addr_i(if_inst_addr_o),
        .inst_i(if_inst_o),
        .inst_addr_o(if_id_inst_addr_o),
        .inst_o(if_id_inst_o)
    );
    id id0 (
        .rst_i(rst_i),
        .inst_addr_i(if_id_inst_addr_o),
        .inst_i(if_id_inst_o),
        .reg1_rdata_i(reg1_data_o),
        .reg2_rdata_i(reg2_data_o),

        // Data Forwarding
        .exe_reg_waddr_i(exe_reg_waddr_o),
        .exe_reg_wdata_i(exe_reg_wdata_o),
        .exe_reg_we_i(exe_reg_we_o),
        .mem_reg_waddr_i(mem_reg_waddr_o),
        .mem_reg_wdata_i(mem_reg_wdata_o),
        .mem_reg_we_i(mem_reg_we_o),
        .exe_rd_i(id_exe_reg_waddr_o),
        .pre_inst_is_load_i(pre_inst_is_load),

        .reg1_raddr_o(id_reg1_addr_o),
        .reg2_raddr_o(id_reg2_addr_o),
        .reg1_re_o(id_reg1_re_o),
        .reg2_re_o(id_reg2_re_o),
        .inst_o(id_inst_o),
        .op1_o(id_op1_o),
        .op2_o(id_op2_o),
        .reg_we_o(id_reg_we_o),
        .reg_waddr_o(id_reg_waddr_o),
        .stallreq_o(id_stallreq_o),
        .csr_we_o(id_csr_we_o),
        .csr_addr_o(id_csr_addr_o)
    );
    regfile regfile0 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .we_i(mem_wb_reg_we_o),
        .waddr_i(mem_wb_reg_waddr_o),
        .wdata_i(mem_wb_reg_wdata_o),
        .re1_i(id_reg1_re_o),
        .raddr1_i(id_reg1_addr_o),
        .rdata1_o(reg1_data_o),
        .re2_i(id_reg2_re_o),
        .raddr2_i(id_reg2_addr_o),
        .rdata2_o(reg2_data_o)
    );
    id_exe id_exe0 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(crtl_stall_o[3:2]),
        .flush_jump_i(ctrl_flush_fetch_o),
        .inst_i(id_inst_o),
        .inst_addr_i(if_id_inst_addr_o),
        .op1_i(id_op1_o),
        .op2_i(id_op2_o),
        .reg_we_i(id_reg_we_o),
        .reg_waddr_i(id_reg_waddr_o),
        .inst_o(id_exe_inst_o),
        .inst_addr_o(id_exe_inst_addr_o),
        .op1_o(id_exe_op1_o),
        .op2_o(id_exe_op2_o),
        .reg_we_o(id_exe_reg_we_o),
        .reg_waddr_o(id_exe_reg_waddr_o),
        .csr_we_i(id_csr_we_o),
        .csr_addr_i(id_csr_addr_o),
        .csr_we_o(id_exe_csr_we_o),
        .csr_addr_o(id_exe_csr_addr_o)
    );
    exe exe0 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .op1_i(id_exe_op1_o),
        .op2_i(id_exe_op2_o),
        .reg_we_i(id_exe_reg_we_o),
        .reg_waddr_i(id_exe_reg_waddr_o),
        .inst_i(id_exe_inst_o),
        .inst_addr_i(id_exe_inst_addr_o),
        .reg_waddr_o(exe_reg_waddr_o),
        .reg_we_o(exe_reg_we_o),
        .reg_wdata_o(exe_reg_wdata_o),
        .mem_addr_o(exe_mem_addr_o),
        .mem_we_o(exe_mem_we_o),
        .mem_data_o(exe_mem_data_o),
        .mem_op_o(exe_mem_op_o),
        .jump_addr_o(exe_jump_addr_o),
        .jump_enable_o(exe_jump_enable_o),
        .stallreq_o(exe_stallreq_o),
        .csr_we_i(id_exe_csr_we_o),
        .csr_addr_i(id_exe_csr_addr_o),
        .csr_raddr_o(exe_csr_raddr_o),
        .csr_rdata_i(csr_rdata_o),
        .mem_csr_we_i(mem_csr_we_o),
        .mem_csr_waddr_i(mem_csr_waddr_o),
        .mem_csr_wdata_i(mem_csr_wdata_o),
        .csr_we_o(exe_csr_we_o),
        .csr_waddr_o(exe_csr_waddr_o),
        .csr_wdata_o(csr_csr_wdata_o)
    );
    exe_mem exe_mem0 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .reg_waddr_i(exe_reg_waddr_o),
        .reg_we_i(exe_reg_we_o),
        .reg_wdata_i(exe_reg_wdata_o),
        .mem_addr_i(exe_mem_addr_o),
        .mem_we_i(exe_mem_we_o),
        .mem_data_i(exe_mem_data_o),
        .mem_op_i(exe_mem_op_o),
        .reg_waddr_o(exe_mem_reg_waddr_o),
        .reg_we_o(exe_mem_reg_we_o),
        .reg_wdata_o(exe_mem_reg_wdata_o),
        .mem_addr_o(exe_mem_mem_addr_o),
        .mem_we_o(exe_mem_mem_we_o),
        .mem_data_o(exe_mem_mem_data_o),
        .mem_op_o(exe_mem_mem_op_o),
        .csr_we_i(exe_csr_we_o),
        .csr_waddr_i(exe_csr_waddr_o),
        .csr_wdata_i(csr_csr_wdata_o),
        .csr_we_o(exe_mem_csr_we_o),
        .csr_waddr_o(exe_mem_csr_waddr_o),
        .csr_wdata_o(csr_mem_csr_wdata_o)
    );
    mem mem0 (
        .rst_i(rst_i),
        .reg_waddr_i(exe_mem_reg_waddr_o),
        .reg_we_i(exe_mem_reg_we_o),
        .reg_wdata_i(exe_mem_reg_wdata_o),
        .mem_addr_i(exe_mem_mem_addr_o),
        .mem_we_i(exe_mem_mem_we_o),
        .mem_data_i(exe_mem_mem_data_o),
        .mem_op_i(exe_mem_mem_op_o),
        .ram_data_i(core_ram_data_i),
        .ram_addr_o(core_ram_addr_o),
        .ram_w_request_o(core_ram_w_request_o),
        .ram_data_o(core_ram_data_o),
        .reg_waddr_o(mem_reg_waddr_o),
        .reg_we_o(mem_reg_we_o),
        .reg_wdata_o(mem_reg_wdata_o),
        .halt_o(mem_halt_o),
        .csr_we_i(exe_mem_csr_we_o),
        .csr_waddr_i(exe_mem_csr_waddr_o),
        .csr_wdata_i(csr_mem_csr_wdata_o),
        .csr_we_o(mem_csr_we_o),
        .csr_waddr_o(mem_csr_waddr_o),
        .csr_wdata_o(mem_csr_wdata_o)
    );
    mem_wb mem_wb0 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .reg_waddr_i(mem_reg_waddr_o),
        .reg_we_i(mem_reg_we_o),
        .reg_wdata_i(mem_reg_wdata_o),
        .reg_waddr_o(mem_wb_reg_waddr_o),
        .reg_we_o(mem_wb_reg_we_o),
        .reg_wdata_o(mem_wb_reg_wdata_o),
        .csr_we_i(mem_csr_we_o),
        .csr_waddr_i(mem_csr_waddr_o),
        .csr_wdata_i(mem_csr_wdata_o),
        .csr_we_o(mem_wb_csr_we_o),
        .csr_waddr_o(mem_wb_csr_waddr_o),
        .csr_wdata_o(mem_wb_csr_rdata_o)
    );
    pipe_crtl pipe_crtl0 (
        .rst_i(rst_i),
        .stallreq_from_id_i(id_stallreq_o),
        .stallreq_from_exe_i(exe_stallreq_o),
        .jump_enable_i(exe_jump_enable_o),
        .jump_addr_i(exe_jump_addr_o),
        .stall_o(crtl_stall_o),
        .flush_jump_o(ctrl_flush_jump_o),
        .new_pc_o(ctrl_new_pc_o)
    );
    csr csr0 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .raddr_i(exe_csr_raddr_o),
        .rdata_o(csr_rdata_o),
        .we_i(mem_wb_csr_we_o),
        .waddr_i(mem_wb_csr_waddr_o),
        .wdata_i(mem_wb_csr_rdata_o),
        .instret_incr_i(1'b0)
    );
    assign host_req[`HOST_CORE_PORT] = core_ram_ce_o;
    assign host_addr[`HOST_CORE_PORT] = core_ram_addr_o;
    assign host_we[`HOST_CORE_PORT] = core_ram_w_request_o;
    assign host_wdata[`HOST_CORE_PORT] = core_ram_data_o;
    assign core_ram_data_i = host_rdata[`HOST_CORE_PORT];
    bus #(
        .NrDevices(NrDevices),
        .NrHosts(NrHosts),
        .DataWidth(`DATA_WIDTH),
        .AddressWidth(`ADDR_WIDTH)
    ) u_bus(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .host_req_i(host_req),
        .host_gnt_o(host_gnt),
        .host_addr_i(host_addr),
        .host_we_i(host_we),
        .host_wdata_i(host_wdata),
        .host_rdata_o(host_rdata),
        .device_req_o(device_req),
        .device_addr_o(device_addr),
        .device_we_o(device_we),
        .device_wdata_o(device_wdata),
        .device_rdata_i(device_rdata),
        .cfg_device_addr_base(cfg_device_addr_base),
        .cfg_device_addr_mask(cfg_device_addr_mask)
    );
    dpram #(
        .RAM_SIZE(MemSize),
        .RAM_ADDR_WIDTH(MemAddrWidth)
    ) data_ram0(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ce_i(device_req[`DEV_RAM]),
        .addr_i(device_addr[`DEV_RAM]),
        .we_i(device_we[`DEV_RAM]),
        .data_i(device_wdata[`DEV_RAM]),
        .data_o(device_rdata[`DEV_RAM]),
        .inst_ce_i(ce_wire && (crtl_stall_o[0] == `NOSTOP)),
        .pc_i(rom_addr_i),
        .inst_o(if_inst_o)
    );

    assign device_rdata[`DEV_CONSOLE] = 32'h0;
    console #(
        .LogName("./log/console.log")
    ) console0(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .req_i(device_req[`DEV_CONSOLE]),
        .we_i(device_we[`DEV_CONSOLE]),
        .addr_i(device_addr[`DEV_CONSOLE]),
        .wdata_i(device_wdata[`DEV_CONSOLE]),
        .halt_o(console_halt_o)
    );
    /* verilator lint_off UNUSEDSIGNAL */
    wire timer_irq;
    /* verilator lint_on UNUSEDSIGNAL */
    timer timer0 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .req_i(device_req[`DEV_TIMER]),
        .we_i(device_we[`DEV_TIMER]),
        .addr_i(device_addr[`DEV_TIMER]),
        .wdata_i(device_wdata[`DEV_TIMER]),
        .rdata_o(device_rdata[`DEV_TIMER]),
        .irq_o(timer_irq)
    );
endmodule
