`include "uvm_macros.svh"
import uvm_pkg::*;

// Pull UVM TB sources into the same compile unit
`include "axi_stream_if.sv"
`include "axi_stream_pkt.sv"
`include "axi_stream_driver.sv"
`include "axi_stream_monitor.sv"
`include "axi_stream_agent.sv"
`include "axi_stream_seq.sv"
`include "scoreboard.sv"
`include "env.sv"
`include "test.sv"


module tb_top;

    logic clk=0, rst=1;
    always #4 clk = ~clk;

    initial begin
        #40 rst = 0;
    end

    axi_stream_if tx_if(clk, rst);
    axi_stream_if rx_if(clk, rst);

    mac_top DUT (
        .clk(clk),
        .rst(rst),
        .tx_axis_tdata(tx_if.tdata),
        .tx_axis_tvalid(tx_if.tvalid),
        .tx_axis_tready(tx_if.tready),
        .tx_axis_tlast(tx_if.tlast),
        .tx_axis_tuser(tx_if.tuser),

        .rx_axis_tdata(rx_if.tdata),
        .rx_axis_tvalid(rx_if.tvalid),
        .rx_axis_tlast(rx_if.tlast),
        .rx_axis_tuser(rx_if.tuser),
        .rx_error_bad_frame(),
        .rx_error_bad_fcs()
    );

    initial begin
       $dumpfile("waves.vcd");
      $dumpvars(0, tb_top);
        uvm_config_db#(virtual axi_stream_if)::set(null, "uvm_test_top.e.agent_tx.*", "vif", tx_if);
        uvm_config_db#(virtual axi_stream_if)::set(null, "uvm_test_top.e.agent_rx.*", "vif", rx_if);
        run_test("simple_test");
    end

endmodule
