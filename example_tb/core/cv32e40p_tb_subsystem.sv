// Copyright 2018 Robert Balas <balasr@student.ethz.ch>
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Wrapper for a RI5CY testbench, containing RI5CY, Memory and stdout peripheral
// Contributor: Robert Balas <balasr@student.ethz.ch>

module cv32e40p_tb_subsystem #(
    parameter INSTR_RDATA_WIDTH = 32,
    parameter RAM_ADDR_WIDTH = 20,
    parameter BOOT_ADDR = 'h180,
    parameter PULP_XPULP = 0,
    parameter PULP_CLUSTER = 0,
    parameter FPU = 0,
    parameter PULP_ZFINX = 0,
    parameter NUM_MHPMCOUNTERS = 1,
    parameter DM_HALTADDRESS = 32'h1A110800
) (
    input logic clk_i,
    input logic rst_ni,

    input  logic        fetch_enable_i,
    output logic        tests_passed_o,
    output logic        tests_failed_o,
    output logic [31:0] exit_value_o,
    output logic        exit_valid_o
);

  // signals connecting core to memory
  logic                               instr_req;
  logic                               instr_gnt;
  logic                               instr_rvalid;
  logic [                 31:0]       instr_addr;
  logic [INSTR_RDATA_WIDTH-1:0]       instr_rdata;

  logic                               data_req;
  logic                               data_gnt;
  logic                               data_rvalid;
  logic [                 31:0]       data_addr;
  logic                               data_we;
  logic [                  3:0]       data_be;
  logic [                 31:0]       data_rdata;
  logic [                 31:0]       data_wdata;
  logic [                  5:0]       data_atop = 6'b0;

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
  logic                               x_type;
  logic                               x_error;

  logic                               xmem_valid;
  logic                               xmem_ready;
  logic [                 31:0]       xmem_laddr;
  logic [                 31:0]       xmem_wdata;
  logic [                  2:0]       xmem_width;
  cv_x_if_pkg::mem_req_type_e         xmem_req_type;
  logic                               xmem_mode;
  logic                               xmem_spec;
  logic                               xmem_endoftransaction;

  logic                               xmem_rvalid;
  logic                               xmem_rready;
  logic [                 31:0]       xmem_rdata;
  logic [       $clog2(32)-1:0]       xmem_range;
  logic                               xmem_status;

  // signals to debug unit
  logic                               debug_req_i;

  // irq signals
  logic                               irq_ack;
  logic [                  4:0]       irq_id_out;
  logic                               irq_software;
  logic                               irq_timer;
  logic                               irq_external;
  logic [                 15:0]       irq_fast;

  logic                               core_sleep_o;

  assign debug_req_i = 1'b0;

  // instantiate the core
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

      .instr_addr_o  (instr_addr),
      .instr_req_o   (instr_req),
      .instr_rdata_i (instr_rdata),
      .instr_gnt_i   (instr_gnt),
      .instr_rvalid_i(instr_rvalid),

      .data_addr_o  (data_addr),
      .data_wdata_o (data_wdata),
      .data_we_o    (data_we),
      .data_req_o   (data_req),
      .data_be_o    (data_be),
      .data_rdata_i (data_rdata),
      .data_gnt_i   (data_gnt),
      .data_rvalid_i(data_rvalid),

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
      .x_type_i      (x_type),
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

      .irq_i    ({irq_fast, 4'b0, irq_external, 3'b0, irq_timer, 3'b0, irq_software, 3'b0}),
      .irq_ack_o(irq_ack),
      .irq_id_o (irq_id_out),

      .debug_req_i      (debug_req_i),
      .debug_havereset_o(),
      .debug_running_o  (),
      .debug_halted_o   (),

      .fetch_enable_i(fetch_enable_i),
      .core_sleep_o  (core_sleep_o)
  );

  generate
    if (FPU) begin : gen_cv_x_if_wrapper
      cv32e40p_cv_x_if_wrapper cv_x_if_wrapper_i (
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
          .x_p_type_o  (x_type),
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
      assign x_type      = '0;
      assign x_error     = '0;
    end
  endgenerate

  // this handles read to RAM and memory mapped pseudo peripherals
  mm_ram #(
      .RAM_ADDR_WIDTH(RAM_ADDR_WIDTH),
      .INSTR_RDATA_WIDTH(INSTR_RDATA_WIDTH)
  ) ram_i (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .instr_req_i   (instr_req),
      .instr_addr_i  (instr_addr[RAM_ADDR_WIDTH-1:0]),
      .instr_rdata_o (instr_rdata),
      .instr_rvalid_o(instr_rvalid),
      .instr_gnt_o   (instr_gnt),

      .data_req_i   (data_req),
      .data_addr_i  (data_addr),
      .data_we_i    (data_we),
      .data_be_i    (data_be),
      .data_wdata_i (data_wdata),
      .data_rdata_o (data_rdata),
      .data_rvalid_o(data_rvalid),
      .data_gnt_o   (data_gnt),
      .data_atop_i  (data_atop),

      .irq_id_i (irq_id_out),
      .irq_ack_i(irq_ack),

      // output irq lines to Core
      .irq_software_o(irq_software),
      .irq_timer_o   (irq_timer),
      .irq_external_o(irq_external),
      .irq_fast_o    (irq_fast),

      .pc_core_id_i(wrapper_i.core_i.pc_id),

      .tests_passed_o(tests_passed_o),
      .tests_failed_o(tests_failed_o),
      .exit_valid_o  (exit_valid_o),
      .exit_value_o  (exit_value_o)
  );

endmodule  // cv32e40p_tb_subsystem
