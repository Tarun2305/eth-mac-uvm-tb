// design.sv - wrapper around eth_mac_1g with GMII loopback
`timescale 1ns/1ps
`default_nettype none
`include "eth_mac_1g.v"
`include "axis_gmii_tx.v"
`include "axis_gmii_rx.v"
`include "lfsr.v"


module mac_top #(
    parameter int DATA_WIDTH    = 8,
    parameter bit PTP_TS_ENABLE = 0,
    parameter bit PFC_ENABLE    = 0,
    parameter bit PAUSE_ENABLE  = 0
)(
    input  logic                  clk,
    input  logic                  rst,

    // AXI-Stream TX (into MAC)
    input  logic [DATA_WIDTH-1:0] tx_axis_tdata,
    input  logic                  tx_axis_tvalid,
    output logic                  tx_axis_tready,
    input  logic                  tx_axis_tlast,
    input  logic [0:0]            tx_axis_tuser,   // bit0 = error flag

    // AXI-Stream RX (from MAC)
    output logic [DATA_WIDTH-1:0] rx_axis_tdata,
    output logic                  rx_axis_tvalid,
    output logic                  rx_axis_tlast,
    output logic [0:0]            rx_axis_tuser,   // bit0 = bad frame

    // Handy status to probe
    output logic                  rx_error_bad_frame,
    output logic                  rx_error_bad_fcs
);

    // GMII loopback
    logic [7:0] gmii_txd, gmii_rxd;
    logic       gmii_tx_en, gmii_rx_dv;
    logic       gmii_tx_er, gmii_rx_er;

    assign gmii_rxd   = gmii_txd;
    assign gmii_rx_dv = gmii_tx_en;
    assign gmii_rx_er = gmii_tx_er;

    // PTP disabled
    logic [95:0] ptp_zero = '0;

    // Unused wires (kept for completeness)
    logic        tx_start_packet, tx_error_underflow;
    logic        rx_start_packet;
    logic        stat_tx_mcf, stat_rx_mcf;
    logic        stat_tx_lfc_pkt, stat_tx_lfc_xon, stat_tx_lfc_xoff, stat_tx_lfc_paused;
    logic        stat_tx_pfc_pkt;
    logic [7:0]  stat_tx_pfc_xon, stat_tx_pfc_xoff, stat_tx_pfc_paused;
    logic        stat_rx_lfc_pkt, stat_rx_lfc_xon, stat_rx_lfc_xoff, stat_rx_lfc_paused;
    logic        stat_rx_pfc_pkt;
    logic [7:0]  stat_rx_pfc_xon, stat_rx_pfc_xoff, stat_rx_pfc_paused;
    logic        rx_lfc_req;
    logic [7:0]  rx_pfc_req;

    // DUT
    eth_mac_1g #(
        .DATA_WIDTH    (DATA_WIDTH),
        .PTP_TS_ENABLE (PTP_TS_ENABLE),
        .PFC_ENABLE    (PFC_ENABLE),
        .PAUSE_ENABLE  (PAUSE_ENABLE)
    ) dut (
        .rx_clk                 (clk),
        .rx_rst                 (rst),
        .tx_clk                 (clk),
        .tx_rst                 (rst),

        // AXI TX in
        .tx_axis_tdata          (tx_axis_tdata),
        .tx_axis_tvalid         (tx_axis_tvalid),
        .tx_axis_tready         (tx_axis_tready),
        .tx_axis_tlast          (tx_axis_tlast),
        .tx_axis_tuser          (tx_axis_tuser),

        // AXI RX out
        .rx_axis_tdata          (rx_axis_tdata),
        .rx_axis_tvalid         (rx_axis_tvalid),
        .rx_axis_tlast          (rx_axis_tlast),
        .rx_axis_tuser          (rx_axis_tuser),

        // GMII
        .gmii_rxd               (gmii_rxd),
        .gmii_rx_dv             (gmii_rx_dv),
        .gmii_rx_er             (gmii_rx_er),
        .gmii_txd               (gmii_txd),
        .gmii_tx_en             (gmii_tx_en),
        .gmii_tx_er             (gmii_tx_er),

        // PTP (disabled)
        .tx_ptp_ts              (ptp_zero),
        .rx_ptp_ts              (ptp_zero),
        .tx_axis_ptp_ts         (),
        .tx_axis_ptp_ts_tag     (),
        .tx_axis_ptp_ts_valid   (),

        // Link-level flow control & PFC (tied off)
        .tx_lfc_req             (1'b0),
        .tx_lfc_resend          (1'b0),
        .rx_lfc_en              (1'b0),
        .rx_lfc_req             (rx_lfc_req),
        .rx_lfc_ack             (1'b0),
        .tx_pfc_req             (8'd0),
        .tx_pfc_resend          (1'b0),
        .rx_pfc_en              (8'd0),
        .rx_pfc_req             (rx_pfc_req),
        .rx_pfc_ack             (8'd0),

        // Pause interface (unused)
        .tx_lfc_pause_en        (1'b0),
        .tx_pause_req           (1'b0),
        .tx_pause_ack           (),

        // Control
        .rx_clk_enable          (1'b1),
        .tx_clk_enable          (1'b1),
        .rx_mii_select          (1'b0),   // 0 = GMII (8-bit)
        .tx_mii_select          (1'b0),

        // Status
        .tx_start_packet        (tx_start_packet),
        .tx_error_underflow     (tx_error_underflow),
        .rx_start_packet        (rx_start_packet),
        .rx_error_bad_frame     (rx_error_bad_frame),
        .rx_error_bad_fcs       (rx_error_bad_fcs),
        .stat_tx_mcf            (stat_tx_mcf),
        .stat_rx_mcf            (stat_rx_mcf),
        .stat_tx_lfc_pkt        (stat_tx_lfc_pkt),
        .stat_tx_lfc_xon        (stat_tx_lfc_xon),
        .stat_tx_lfc_xoff       (stat_tx_lfc_xoff),
        .stat_tx_lfc_paused     (stat_tx_lfc_paused),
        .stat_tx_pfc_pkt        (stat_tx_pfc_pkt),
        .stat_tx_pfc_xon        (stat_tx_pfc_xon),
        .stat_tx_pfc_xoff       (stat_tx_pfc_xoff),
        .stat_tx_pfc_paused     (stat_tx_pfc_paused),
        .stat_rx_lfc_pkt        (stat_rx_lfc_pkt),
        .stat_rx_lfc_xon        (stat_rx_lfc_xon),
        .stat_rx_lfc_xoff       (stat_rx_lfc_xoff),
        .stat_rx_lfc_paused     (stat_rx_lfc_paused),
        .stat_rx_pfc_pkt        (stat_rx_pfc_pkt),
        .stat_rx_pfc_xon        (stat_rx_pfc_xon),
        .stat_rx_pfc_xoff       (stat_rx_pfc_xoff),
        .stat_rx_pfc_paused     (stat_rx_pfc_paused),

        // Config
        .cfg_ifg                (8'd12),
        .cfg_tx_enable          (1'b1),
        .cfg_rx_enable          (1'b1),
        .cfg_mcf_rx_eth_dst_mcast       (48'd0),
        .cfg_mcf_rx_check_eth_dst_mcast (1'b0),
        .cfg_mcf_rx_eth_dst_ucast       (48'd0),
        .cfg_mcf_rx_check_eth_dst_ucast (1'b0),
        .cfg_mcf_rx_eth_src             (48'd0),
        .cfg_mcf_rx_check_eth_src       (1'b0),
        .cfg_mcf_rx_eth_type            (16'd0),
        .cfg_mcf_rx_opcode_lfc          (16'd0),
        .cfg_mcf_rx_check_opcode_lfc    (1'b0),
        .cfg_mcf_rx_opcode_pfc          (16'd0),
        .cfg_mcf_rx_check_opcode_pfc    (1'b0),
        .cfg_mcf_rx_forward             (1'b0),
        .cfg_mcf_rx_enable              (1'b0),
        .cfg_tx_lfc_eth_dst             (48'd0),
        .cfg_tx_lfc_eth_src             (48'd0),
        .cfg_tx_lfc_eth_type            (16'd0),
        .cfg_tx_lfc_opcode              (16'd0),
        .cfg_tx_lfc_en                  (1'b0),
        .cfg_tx_lfc_quanta              (16'd0),
        .cfg_tx_lfc_refresh             (16'd0),
        .cfg_tx_pfc_eth_dst             (48'd0),
        .cfg_tx_pfc_eth_src             (48'd0),
        .cfg_tx_pfc_eth_type            (16'd0),
        .cfg_tx_pfc_opcode              (16'd0),
        .cfg_tx_pfc_en                  (1'b0),
        .cfg_tx_pfc_quanta              ({8{16'd0}}),
        .cfg_tx_pfc_refresh             ({8{16'd0}}),
        .cfg_rx_lfc_opcode              (16'd0),
        .cfg_rx_lfc_en                  (1'b0),
        .cfg_rx_pfc_opcode              (16'd0),
        .cfg_rx_pfc_en                  (1'b0)
    );

endmodule

`default_nettype wire
