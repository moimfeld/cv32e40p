// Copyright 2021 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Wrapper for the Core-V X-Interface and its Accelerators
// Contributor: Moritz Imfeld <moimfeld@student.ethz.ch>

module cv32e40p_cv_x_if_wrapper
  import acc_pkg::*;
  import cv32e40p_x_if_pkg::*;
#(
    parameter PULP_ZFINX = 0
) (
    input logic clk_i,
    input logic rst_ni,

    // x-request channel
    input  logic              x_q_valid_i,
    output logic              x_q_ready_o,
    input  logic [31:0]       x_q_instr_data_i,
    input  logic [ 2:0][31:0] x_q_rs_i,
    input  logic [ 2:0]       x_q_rs_valid_i,
    input  logic              x_q_rd_clean_i,
    output logic              x_k_accept_o,
    output logic              x_k_is_mem_op_o,
    output logic              x_k_writeback_o,

    // x-response channel
    output logic        x_p_valid_o,
    input  logic        x_p_ready_i,
    output logic [ 4:0] x_p_rd_o,
    output logic [31:0] x_p_data_o,
    output logic        x_p_dualwb_o,
    output logic        x_p_error_o,

    // xmem-request channel
    output logic                                    xmem_q_valid_o,
    input  logic                                    xmem_q_ready_i,
    output logic                             [31:0] xmem_q_laddr_o,
    output logic                             [31:0] xmem_q_wdata_o,
    output logic                             [ 2:0] xmem_q_width_o,
    output cv32e40p_x_if_pkg::mem_req_type_e        xmem_q_req_type_o,
    output logic                                    xmem_q_mode_o,
    output logic                                    xmem_q_spec_o,
    output logic                                    xmem_q_endoftransaction_o,

    // xmem-response channel
    input  logic                  xmem_p_valid_i,
    output logic                  xmem_p_ready_o,
    input  logic [          31:0] xmem_p_rdata_i,
    input  logic [$clog2(32)-1:0] xmem_p_range_i,
    input  logic                  xmem_p_status_i
);

  acc_pkg::mem_req_type_e req_type;
  assign xmem_q_req_type_o = cv32e40p_x_if_pkg::mem_req_type_e'(req_type);

  fpu_ss #(
      .PULP_ZFINX(PULP_ZFINX),
      .BUFFER_DEPTH(1),
      .INT_REG_WB_DELAY(1),
      .OUT_OF_ORDER(1),
      .FORWARDING(1),
      .FPU_FEATURES(cv32e40p_fpu_pkg::FPU_FEATURES),
      .FPU_IMPLEMENTATION(cv32e40p_fpu_pkg::FPU_IMPLEMENTATION)
  ) fpu_ss_i (
      // clock and reset
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // c-request channel
      .c_q_valid_i     (x_q_valid_i),
      .c_q_ready_o     (x_q_ready_o),
      .c_q_addr_i      ('0),
      .c_q_rs_i        (x_q_rs_i),
      .c_q_instr_data_i(x_q_instr_data_i),
      .c_q_hart_id_i   ('0),


      .rd_clean_i (x_q_rd_clean_i),
      .rs_valid_i (x_q_rs_valid_i),
      .c_k_accept_o    (x_k_accept_o),
      .c_k_is_mem_op_o (x_k_is_mem_op_o),
      .c_k_writeback_o (x_k_writeback_o),

      // c-response channel
      .c_p_valid_o  (x_p_valid_o),
      .c_p_ready_i  (x_p_ready_i),
      .c_p_data_o   (x_p_data_o),
      .c_p_error_o  (x_p_error_o),
      .c_p_dualwb_o (x_p_dualwb_o),
      .c_p_hart_id_o(),
      .c_p_rd_o     (x_p_rd_o),

      // cmem-request channel
      .cmem_q_valid_o           (xmem_q_valid_o),
      .cmem_q_ready_i           (xmem_q_ready_i),
      .cmem_q_laddr_o           (xmem_q_laddr_o),
      .cmem_q_wdata_o           (xmem_q_wdata_o),
      .cmem_q_width_o           (xmem_q_width_o),
      .cmem_q_req_type_o        (req_type),
      .cmem_q_mode_o            (xmem_q_mode_o),
      .cmem_q_spec_o            (xmem_q_spec_o),
      .cmem_q_endoftransaction_o(xmem_q_endoftransaction_o),
      .cmem_q_hart_id_o         (),
      .cmem_q_addr_o            (),

      // cmem-Response Channel
      .cmem_p_valid_i  (xmem_p_valid_i),
      .cmem_p_ready_o  (xmem_p_ready_o),
      .cmem_p_rdata_i  (xmem_p_rdata_i),
      .cmem_p_range_i  (xmem_p_range_i),
      .cmem_p_status_i (xmem_p_status_i),
      .cmem_p_addr_i   ('0),
      .cmem_p_hart_id_i('0)
  );

endmodule  // cv32e40p_cv_x_if_wrapper
