module cv32e40p_core_and_coprocessor_wrapper
    import cv32e40p_x_if_pkg::*;
  #(
    parameter INSTR_RDATA_WIDTH = 32,
    parameter BOOT_ADDR = 'h180,
    parameter PULP_XPULP = 0,
    parameter PULP_CLUSTER = 0,
    parameter FPU = 1,
    parameter PULP_ZFINX = 0,
    parameter NUM_MHPMCOUNTERS = 1,
    parameter DM_HALTADDRESS = 32'h1A110800
) (
    input logic clk_i,
    input logic rst_ni,

    input  logic                               fetch_enable_i,

    // signals connecting core to memory
    output logic                               instr_req_o,
    input  logic                               instr_gnt_i,
    input  logic                               instr_rvalid_i,
    output logic [                 31:0]       instr_addr_o,
    input  logic [INSTR_RDATA_WIDTH-1:0]       instr_rdata_i,

    output logic                               data_req_o,
    input  logic                               data_gnt_i,
    input  logic                               data_rvalid_i,
    output logic [                 31:0]       data_addr_o,
    output logic                               data_we_o,
    output logic [                  3:0]       data_be_o,
    input  logic [                 31:0]       data_rdata_i,
    output logic [                 31:0]       data_wdata_o,

    // signals to debug unit
    input  logic                               debug_req_i,

    // irq signals
    output logic                               irq_ack_o,
    output logic [                  4:0]       irq_id_out_o,
    input  logic                               irq_software_i,
    input  logic                               irq_timer_i,
    input  logic                               irq_external_i,
    input  logic [                 15:0]       irq_fast_i
);

  logic                               core_sleep;



  // X-Interface
  logic                               x_valid;
  logic                               x_ready;
  logic [                 31:0]       x_instr_data;
  logic [                  2:0][31:0] x_rs;
  logic [                  2:0]       x_rs_valid;
  logic                               x_rd_clean;
  logic                               x_accept;
  logic                               x_is_mem_op;
  logic                               x_writeback;

  logic                               x_rvalid;
  logic                               x_rready;
  logic [                  4:0]       x_rd;
  logic [                 31:0]       x_data;
  logic                               x_dualwb;
  logic                               x_error;

  logic                               xmem_valid;
  logic                               xmem_ready;
  logic [                 31:0]       xmem_laddr;
  logic [                 31:0]       xmem_wdata;
  logic [                  2:0]       xmem_width;
  mem_req_type_e                      xmem_req_type;
  logic                               xmem_mode;
  logic                               xmem_spec;
  logic                               xmem_endoftransaction;

  logic                               xmem_rvalid;
  logic                               xmem_rready;
  logic [                 31:0]       xmem_rdata;
  logic [       $clog2(32)-1:0]       xmem_range;
  logic                               xmem_status;


  cv32e40p_wrapper #(
    .PULP_XPULP      (PULP_XPULP),
    .PULP_CLUSTER    (PULP_CLUSTER),
    .FPU             (FPU),
    .PULP_ZFINX      (PULP_ZFINX),
    .NUM_MHPMCOUNTERS(NUM_MHPMCOUNTERS)
  ) wrapper_i (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .pulp_clock_en_i(1'b1),
    .scan_cg_en_i   (1'b0),

    .boot_addr_i        (BOOT_ADDR),
    .mtvec_addr_i       (32'h0),
    .dm_halt_addr_i     (DM_HALTADDRESS),
    .hart_id_i          (32'h0),
    .dm_exception_addr_i(32'h0),

    .instr_addr_o  (instr_addr_o),
    .instr_req_o   (instr_req_o),
    .instr_rdata_i (instr_rdata_i),
    .instr_gnt_i   (instr_gnt_i),
    .instr_rvalid_i(instr_rvalid_i),

    .data_addr_o  (data_addr_o),
    .data_wdata_o (data_wdata_o),
    .data_we_o    (data_we_o),
    .data_req_o   (data_req_o),
    .data_be_o    (data_be_o),
    .data_rdata_i (data_rdata_i),
    .data_gnt_i   (data_gnt_i),
    .data_rvalid_i(data_rvalid_i),

    .x_valid_o     (x_valid),
    .x_ready_i     (x_ready),
    .x_instr_data_o(x_instr_data),
    .x_rs_o        (x_rs),
    .x_rs_valid_o  (x_rs_valid),
    .x_rd_clean_o  (x_rd_clean),
    .x_accept_i    (x_accept),
    .x_is_mem_op_i (x_is_mem_op),
    .x_writeback_i (x_writeback),

    .x_rvalid_i    (x_rvalid),
    .x_rready_o    (x_rready),
    .x_rd_i        (x_rd),
    .x_data_i      (x_data),
    .x_dualwb_i    (x_dualwb),
    .x_error_i     (x_error),

    .xmem_valid_i            (xmem_valid),
    .xmem_ready_o            (xmem_ready),
    .xmem_laddr_i            (xmem_laddr),
    .xmem_wdata_i            (xmem_wdata),
    .xmem_width_i            (xmem_width),
    .xmem_req_type_i         (xmem_req_type),
    .xmem_mode_i             (xmem_mode),
    .xmem_spec_i             (xmem_spec),
    .xmem_endoftransaction_i (xmem_endoftransaction),

    .xmem_rvalid_o (xmem_rvalid),
    .xmem_rready_i (xmem_rready),
    .xmem_rdata_o  (xmem_rdata),
    .xmem_range_o  (xmem_range),
    .xmem_status_o (xmem_status),

    .irq_i    ({irq_fast_i, 4'b0, irq_external_i, 3'b0, irq_timer_i, 3'b0, irq_software_i, 3'b0}),
    .irq_ack_o(irq_ack_o),
    .irq_id_o (irq_id_out_o),

    .debug_req_i      (debug_req_i),
    .debug_havereset_o(),
    .debug_running_o  (),
    .debug_halted_o   (),

    .fetch_enable_i(fetch_enable_i),
    .core_sleep_o  (/* unused*/ )
  );

  generate
    if (FPU) begin : gen_cv_x_if_wrapper
      cv32e40p_cv_x_if_wrapper #(
        .PULP_ZFINX(PULP_ZFINX)
      ) cv_x_if_wrapper_i (
        .clk_i (clk_i),
        .rst_ni(rst_ni),

        // X-Request Channel
        .x_q_valid_i     (x_valid ),
        .x_q_ready_o     (x_ready),
        .x_q_instr_data_i(x_instr_data),
        .x_q_rs_i        (x_rs),
        .x_q_rs_valid_i  (x_rs_valid),
        .x_q_rd_clean_i  (x_rd_clean),
        .x_k_accept_o    (x_accept),
        .x_k_is_mem_op_o (x_is_mem_op),
        .x_k_writeback_o (x_writeback),

        // X-Response Channel
        .x_p_valid_o (x_rvalid),
        .x_p_ready_i (x_rready),
        .x_p_rd_o    (x_rd),
        .x_p_data_o  (x_data),
        .x_p_dualwb_o(x_dualwb),
        .x_p_error_o (x_error),

        // Xmem-Request channel
        .xmem_q_valid_o            (xmem_valid),
        .xmem_q_ready_i            (xmem_ready),
        .xmem_q_laddr_o            (xmem_laddr),
        .xmem_q_wdata_o            (xmem_wdata),
        .xmem_q_width_o            (xmem_width),
        .xmem_q_req_type_o         (xmem_req_type),
        .xmem_q_mode_o             (xmem_mode),
        .xmem_q_spec_o             (xmem_spec),
        .xmem_q_endoftransaction_o (xmem_endoftransaction),

        // Xmem-Response channel
        .xmem_p_valid_i  (xmem_rvalid),
        .xmem_p_ready_o  (xmem_rready),
        .xmem_p_rdata_i  (xmem_rdata),
        .xmem_p_range_i  (xmem_range),
        .xmem_p_status_i (xmem_status)
      );
    end else begin : no_gen_cv_x_if_wrapper
      assign x_ready     = '0;
      assign x_accept    = '0;
      assign x_is_mem_op = '0;
      assign x_writeback = '0;
      assign x_rvalid    = '0;
      assign x_rd        = '0;
      assign x_data      = '0;
      assign x_dualwb    = '0;
      assign x_error     = '0;
    end
  endgenerate



endmodule : cv32e40p_core_and_coprocessor_wrapper