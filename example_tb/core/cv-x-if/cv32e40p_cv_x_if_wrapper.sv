// Copyright 2021 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Wrapper for the RISC-V Extention Interface and all its accelerators
// Contributor: Moritz Imfeld <moimfeld@student.ethz.ch>

module cv32e40p_cv_x_if_wrapper
    import acc_pkg::*; import cv32e40p_x_if_pkg::*;
  (
    input logic clk_i,
    input logic rst_ni,

    // X-Request Channel
    input  logic              x_q_valid_i,
    output logic              x_q_ready_o,
    input  logic [31:0]       x_q_instr_data_i,
    input  logic [ 2:0][31:0] x_q_rs_i,
    input  logic [ 2:0]       x_q_rs_valid_i,
    input  logic              x_q_rd_clean_i,
    output logic              x_k_accept_o,
    output logic              x_k_is_mem_op_o,
    output logic              x_k_writeback_o,

    // X-Response Channel
    output logic        x_p_valid_o,
    input  logic        x_p_ready_i,
    output logic [ 4:0] x_p_rd_o,
    output logic [31:0] x_p_data_o,
    output logic        x_p_dualwb_o,
    output logic        x_p_error_o,

    // Xmem-Request channel
    output logic                             xmem_q_valid_o,
    input  logic                             xmem_q_ready_i,
    output logic                      [31:0] xmem_q_laddr_o,
    output logic                      [31:0] xmem_q_wdata_o,
    output logic                      [ 2:0] xmem_q_width_o,
    output cv32e40p_x_if_pkg::mem_req_type_e xmem_q_req_type_o,
    output logic                             xmem_q_mode_o,
    output logic                             xmem_q_spec_o,
    output logic                             xmem_q_endoftransaction_o,

    // Xmem-Response channel
    input  logic                  xmem_p_valid_i,
    output logic                  xmem_p_ready_o,
    input  logic [31:0]           xmem_p_rdata_i,
    input  logic [$clog2(32)-1:0] xmem_p_range_i,
    input  logic                  xmem_p_status_i
);

  logic [31:0] hart_id;

  acc_x_req_t x_req;
  acc_x_rsp_t x_rsp;

  acc_c_req_t c_req_adapter;
  acc_c_rsp_t c_rsp_adapter;

  acc_c_req_t [NumRsp[0]-1:0] c_req;
  acc_c_rsp_t [NumRsp[0]-1:0] c_rsp;

  acc_xmem_req_t xmem_req;
  acc_xmem_rsp_t xmem_rsp;

  acc_cmem_req_t cmem_req_adapter;
  acc_cmem_rsp_t cmem_rsp_adapter;

  acc_cmem_req_t [NumRsp[0]-1:0] cmem_req;
  acc_cmem_rsp_t [NumRsp[0]-1:0] cmem_rsp;

  acc_prd_req_t [NumRspTot-1:0] prd_req;
  acc_prd_rsp_t [NumRspTot-1:0] prd_rsp;

  acc_c_rsp_t [NumRsp[0]-1:0] c_mst_next_rsp;
  acc_cmem_req_t [NumRsp[0]-1:0] cmem_slv_next_req;

  acc_c_req_t    c_req_o;
  acc_cmem_rsp_t cmem_rsp_o;

  // X-Request Channel assignment
  assign x_req.q_valid = x_q_valid_i;
  assign x_q_ready_o = x_rsp.q_ready;
  assign x_req.q.instr_data = x_q_instr_data_i;
  assign x_req.q.rs = x_q_rs_i;
  assign x_req.q.rs_valid = x_q_rs_valid_i;
  assign x_req.q.rd_clean = x_q_rd_clean_i;
  assign x_k_accept_o = x_rsp.k.accept;
  assign x_k_is_mem_op_o = x_rsp.k.is_mem_op;
  assign x_k_writeback_o = x_rsp.k.writeback;

  // X-Response Channel assignment
  assign x_p_valid_o = x_rsp.p_valid;
  assign x_req.p_ready = x_p_ready_i;
  assign x_p_rd_o = x_rsp.p.rd;
  assign x_p_data_o = x_rsp.p.data;
  assign x_p_dualwb_o = x_rsp.p.dualwb;
  // assign p_type_o = // commented out because it is not implemented (maybe it was removed when xmem and cmem channels were created)
  assign x_p_error_o = x_rsp.p.error;

  // Xmem-Request Channel assignment
  assign xmem_q_valid_o    = xmem_req.q_valid;
  assign xmem_rsp.q_ready  = xmem_q_ready_i;
  assign xmem_q_laddr_o    = xmem_req.q.laddr;
  assign xmem_q_wdata_o    = xmem_req.q.wdata;
  assign xmem_q_width_o    = xmem_req.q.width;
  assign xmem_q_req_type_o = cv32e40p_x_if_pkg::mem_req_type_e'(xmem_req.q.req_type); // cast from acc_pkg enum to cv32e40p_x_if_pkg enum (both enum are equivalent)
  assign xmem_q_mode_o     = xmem_req.q.mode;
  assign xmem_q_spec_o     = xmem_req.q.spec;
  assign xmem_q_endoftransaction_o = xmem_req.q.endoftransaction;

  // Xmem-Response Channel assignment
  assign xmem_rsp.p_valid = xmem_p_valid_i;
  assign xmem_p_ready_o = xmem_req.p_ready;
  assign xmem_rsp.p.rdata = xmem_p_rdata_i;
  assign xmem_rsp.p.range = xmem_p_range_i;
  assign xmem_rsp.p.status = xmem_p_status_i;


  assign hart_id = 32'h0; // what does the hart id do? (it is assigned to 0 in the cv32e40p_tb_subsystem.sv)
  assign c_mst_next_rsp[0].p.hart_id = 32'd0;
  assign c_mst_next_rsp[0].p_valid = '0;

  assign cmem_slv_next_req[0].q.hart_id = 32'd0;
  assign cmem_slv_next_req[0].q_valid = '0;


  acc_adapter acc_adapter_i (
      .clk_i         (clk_i),
      .rst_ni        (rst_ni),
      .hart_id_i     (hart_id),
      .acc_x_req_i   (x_req),
      .acc_x_rsp_o   (x_rsp),
      .acc_c_req_o   (c_req_adapter),
      .acc_c_rsp_i   (c_rsp_adapter),
      .acc_xmem_req_o(xmem_req),
      .acc_xmem_rsp_i(xmem_rsp),
      .acc_cmem_req_i(cmem_req_adapter),
      .acc_cmem_rsp_o(cmem_rsp_adapter),
      .acc_prd_req_o (prd_req),
      .acc_prd_rsp_i (prd_rsp)
  );

  acc_predecoder #(
      .NumInstr(acc_fp_pkg::NumInstr),
      .OffloadInstr(acc_fp_pkg::OffloadInstr)
  ) acc_fp_predecoder_i (
      .prd_req_i(prd_req[0]),
      .prd_rsp_o(prd_rsp[0])
  );

  acc_interconnect #(
      .HierLevel  (0),
      .NumReq     (1),
      .NumRsp     (NumRsp[0]),
      .RegisterReq(RegisterReq[0]),
      .RegisterRsp(RegisterRsp[0])
  ) acc_interconnect_i (
      .clk_i                  (clk_i),
      .rst_ni                 (rst_ni),
      .acc_c_slv_req_i        (c_req_adapter),
      .acc_c_slv_rsp_o        (c_rsp_adapter),
      .acc_cmem_mst_req_o     (cmem_req_adapter),
      .acc_cmem_mst_rsp_i     (cmem_rsp_adapter),
      .acc_c_mst_next_req_o   (c_req_o),
      .acc_c_mst_next_rsp_i   (c_mst_next_rsp),
      .acc_cmem_slv_next_req_i(cmem_slv_next_req),
      .acc_cmem_slv_next_rsp_o(cmem_rsp_o),
      .acc_c_mst_req_o        (c_req),
      .acc_c_mst_rsp_i        (c_rsp),
      .acc_cmem_slv_req_i     (cmem_req),
      .acc_cmem_slv_rsp_o     (cmem_rsp)
  );


  fpu_ss #(
      .BUFFER_DEPTH(4),
      .FPU_FEATURES(cv32e40p_fpu_pkg::FPU_FEATURES),
      .FPU_IMPLEMENTATION(cv32e40p_fpu_pkg::FPU_IMPLEMENTATION),
      .FPU_TAG_TYPE(logic)
    )fpu_ss_i (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .c_q_valid_i     (c_req[0].q_valid),
      .c_q_ready_o     (c_rsp[0].q_ready),
      .c_q_addr_i      (c_req[0].q.addr),
      .c_q_rs_i        (c_req[0].q.rs),
      .c_q_instr_data_i(c_req[0].q.instr_data),
      .c_q_hart_id_i   (c_req[0].q.hart_id),

      .c_p_valid_o  (c_rsp[0].p_valid),
      .c_p_ready_i  (c_req[0].p_ready),
      .c_p_data_o   (c_rsp[0].p.data),
      .c_p_error_o  (c_rsp[0].p.error),
      .c_p_dualwb_o (c_rsp[0].p.dualwb),
      .c_p_hart_id_o(c_rsp[0].p.hart_id),
      .c_p_rd_o     (c_rsp[0].p.rd),

      .cmem_q_valid_o            (cmem_req[0].q_valid),
      .cmem_q_ready_i            (cmem_rsp[0].q_ready),
      .cmem_q_laddr_o            (cmem_req[0].q.laddr),
      .cmem_q_wdata_o            (cmem_req[0].q.wdata),
      .cmem_q_width_o            (cmem_req[0].q.width),
      .cmem_q_req_type_o         (cmem_req[0].q.req_type),
      .cmem_q_mode_o             (cmem_req[0].q.mode),
      .cmem_q_spec_o             (cmem_req[0].q.spec),
      .cmem_q_endoftransaction_o (cmem_req[0].q.endoftransaction),
      .cmem_q_hart_id_o          (cmem_req[0].q.hart_id),
      .cmem_q_addr_o             (cmem_req[0].q.addr),

      .cmem_p_valid_i   (cmem_rsp[0].p_valid),
      .cmem_p_ready_o   (cmem_req[0].p_ready),
      .cmem_p_rdata_i   (cmem_rsp[0].p.rdata),
      .cmem_p_range_i   (cmem_rsp[0].p.range),
      .cmem_p_status_i  (cmem_rsp[0].p.status),
      .cmem_p_addr_i    (cmem_rsp[0].p.addr),
      .cmem_p_hart_id_i (cmem_rsp[0].p.hart_id)
  );

endmodule  // cv32e40p_cv_x_if_wrapper
