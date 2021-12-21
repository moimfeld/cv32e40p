module cv32e40p_core_and_coprocessor_wrapper
    import cv32e40p_core_v_xif_pkg::*;
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

  // Compressed interface
  logic x_compressed_valid;
  logic x_compressed_ready;
  x_compressed_req_t x_compressed_req;
  x_compressed_resp_t x_compressed_resp;

  // Issue Interface
  logic x_issue_valid;
  logic x_issue_ready;
  x_issue_req_t x_issue_req;
  x_issue_resp_t x_issue_resp;

  // Commit Interface
  logic x_commit_valid;
  x_commit_t x_commit;

  // Memory request/response Interface
  logic x_mem_valid;
  logic x_mem_ready;
  x_mem_req_t x_mem_req;
  x_mem_resp_t x_mem_resp;

  // Memory Result Interface
  logic x_mem_result_valid;
  x_mem_result_t x_mem_result;

  // Result Interface
  logic x_result_valid;
  logic x_result_ready;
  x_result_t x_result;

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

    // CORE-V-XIF

    // Compressed interface
    .x_compressed_valid_o(x_compressed_valid),
    .x_compressed_ready_i(x_compressed_ready),
    .x_compressed_req_o(x_compressed_req),
    .x_compressed_resp_i(x_compressed_resp),

    // Issue Interface
    .x_issue_valid_o(x_issue_valid),
    .x_issue_ready_i(x_issue_ready),
    .x_issue_req_o(x_issue_req),
    .x_issue_resp_i(x_issue_resp),

    // Commit Interface
    .x_commit_valid_o(x_commit_valid),
    .x_commit_o(x_commit),

    // Memory request/response Interface
    .x_mem_valid_i(x_mem_valid),
    .x_mem_ready_o(x_mem_ready),
    .x_mem_req_i(x_mem_req),
    .x_mem_resp_o(x_mem_resp),

    // Memory Result Interface
    .x_mem_result_valid_o(x_mem_result_valid),
    .x_mem_result_o(x_mem_result),

    // Result Interface
    .x_result_valid_i(x_result_valid),
    .x_result_ready_o(x_result_ready),
    .x_result_i(x_result),

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
    if (FPU) begin : gen_fpu_ss
    fpu_ss_wrapper #(
      .PULP_ZFINX(PULP_ZFINX),
      .INPUT_BUFFER_DEPTH(1),
      .INT_REG_WB_DELAY(1),
      .OUT_OF_ORDER(1),
      .FORWARDING(1),
      .FPU_FEATURES(cv32e40p_fpu_pkg::FPU_FEATURES),
      .FPU_IMPLEMENTATION(cv32e40p_fpu_pkg::FPU_IMPLEMENTATION)
  ) fpu_ss_wrapper_i (
    // clock and reset
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    // Compressed Interface
    .x_compressed_valid_i(x_compressed_valid),
    .x_compressed_ready_o(x_compressed_ready),
    .x_compressed_req_i  (x_compressed_req),
    .x_compressed_resp_o (x_compressed_resp),

    // Issue Interface
    .x_issue_valid_i(x_issue_valid),
    .x_issue_ready_o(x_issue_ready),
    .x_issue_req_i(x_issue_req),
    .x_issue_resp_o(x_issue_resp),

    // Commit Interface
    .x_commit_valid_i(x_commit_valid),
    .x_commit_i(x_commit),

    // Memory request/response Interface
    .x_mem_valid_o(x_mem_valid),
    .x_mem_ready_i(x_mem_ready),
    .x_mem_req_o(x_mem_req),
    .x_mem_resp_i(x_mem_resp),

    // Memory Result Interface
    .x_mem_result_valid_i(x_mem_result_valid),
    .x_mem_result_i(x_mem_result),

    // Result Interface
    .x_result_valid_o(x_result_valid),
    .x_result_ready_i(x_result_ready),
    .x_result_o(x_result)
  );
    end else begin : no_gen_cv_x_if_wrapper
      assign x_issue_ready          = '0;
      assign x_issue_resp.accept    = '0;
      assign x_issue_resp.writeback = '0;
      assign x_issue_resp.float     = '0;
      assign x_issue_resp.dualwrite = '0;
      assign x_issue_resp.dualread  = '0;
      assign x_issue_resp.loadstore = '0;
      assign x_issue_resp.exc       = '0;

      assign x_mem_valid            = '0;
      assign x_mem_req.id           = '0;
      assign x_mem_req.addr         = '0;
      assign x_mem_req.mode         = '0;
      assign x_mem_req.we           = '0;
      assign x_mem_req.wdata        = '0;
      assign x_mem_req.last         = '0;
      assign x_mem_req.spec         = '0;

      assign x_result_valid         = '0;
      assign x_result.id            = '0;
      assign x_result.data          = '0;
      assign x_result.rd            = '0;
      assign x_result.we            = '0;
      assign x_result.float         = '0;
      assign x_result.exc           = '0;
      assign x_result.exccode       = '0;
    end
  endgenerate



endmodule : cv32e40p_core_and_coprocessor_wrapper