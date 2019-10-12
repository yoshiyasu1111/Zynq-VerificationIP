`timescale 1ns / 1ps

module tb;
    logic tb_ACLK;
    logic tb_ARESETn;

    logic [31:0] read_data;
    logic resp;
    
    wire aclk;
    wire aresetn;

    int i;
    int fd;

    initial begin
        tb_ACLK = 1'b0;
    end

    always #10 tb_ACLK = !tb_ACLK;

    initial begin
    `ifndef XILINX_SIMULATOR
        tb.zynq_sys.design_1_i.processing_system7_0.inst.M_AXI_GP0.master.IF.PC.fatal_to_warnings=1;
        #40;
        tb.zynq_sys.design_1_i.processing_system7_0.inst.M_AXI_GP0.master.IF.PC.fatal_to_warnings=0;
    `endif
    end

    initial begin

        $display ("running the tb");

        tb_ARESETn = 1'b0;
        repeat(2) @(posedge tb_ACLK);
        tb_ARESETn = 1'b1;
        @(posedge tb_ACLK);
        repeat(5) @(posedge tb_ACLK);

        //Reset the PL
        tb.zynq_sys.design_1_i.processing_system7_0.inst.fpga_soft_reset(32'h1);
        tb.zynq_sys.design_1_i.processing_system7_0.inst.fpga_soft_reset(32'h0);

        // start myip
        tb.zynq_sys.design_1_i.processing_system7_0.inst.write_data(32'h43C00000, 4, 32'h00000001, resp);
        tb.zynq_sys.design_1_i.processing_system7_0.inst.read_data(32'h43C00000, 4, read_data, resp);

        if (read_data[0] == 1'b1) begin
           $display ("DATA TX START SUCCESS.");
        end
        else begin
           $display ("DATA TX START FAILED.");
        end

        // myipの終了を待つ
        @(posedge tb.zynq_sys.design_1_i.myip_0.m_axi_txn_done);

        fd = $fopen("dramDump.txt");
        // DRAMの内容を4バイトずつ表示し、4バイト×16回表示で改行する。
        for (i = 0; i < 12'h400; i = i + 4'h4) begin
            tb.zynq_sys.design_1_i.processing_system7_0.inst.read_mem(32'h00080000 + i, 4, read_data);
            
            if (i[5:0] == 6'b111100) begin
                $fdisplay(fd, "%h", read_data);
            end
            else begin
                $fwrite(fd, "%h", read_data);
            end
        end

        $fclose(fd);
        $display ("Simulation completed");
        $stop;
    end

    assign aclk = tb_ACLK;
    assign aresetn = tb_ARESETn;

    design_1_wrapper zynq_sys
    (
        .DDR_addr(),
        .DDR_ba(),
        .DDR_cas_n(),
        .DDR_ck_n(),
        .DDR_ck_p(),
        .DDR_cke(),
        .DDR_cs_n(),
        .DDR_dm(),
        .DDR_dq(),
        .DDR_dqs_n(),
        .DDR_dqs_p(),
        .DDR_odt(),
        .DDR_ras_n(),
        .DDR_reset_n(),
        .DDR_we_n(),
        .FIXED_IO_ddr_vrn(),
        .FIXED_IO_ddr_vrp(),
        .FIXED_IO_mio(),
        .FIXED_IO_ps_clk(aclk),
        .FIXED_IO_ps_porb(aresetn),
        .FIXED_IO_ps_srstb(aresetn)
    );

endmodule
