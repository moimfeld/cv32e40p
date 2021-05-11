// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Wrapper for a fpnew
// Contributor: Davide Schiavone <davide@openhwgroup.org>
//              Moritz Imfeld <moimfeld@student.ethz.ch>

module cv32e40p_fp_wrapper
(
    // Clock and Reset
    input  logic clk_i,
    input  logic rst_ni,

    // C-Request Channel
    input  logic             c_q_valid_i,
    output logic             c_p_ready_o,
    input  logic [4:0]       c_q_addr_i, //maybe useless
    input  logic [31:0][2:0] c_q_rs_i,
    input  logic [31:0]      c_q_instr_data_i,
    input  logic [31:0]      c_q_hart_id_i, //maybe useless

    // C-Response Channel
    output logic           c_p_valid_o,
    input  logic           c_q_ready_i,
    output logic [31:0]    c_p_data_o,
    output logic           c_p_error_o,
    output logic           c_p_dualwb_o,
    output logic [31:0]    c_p_hart_id_o,
    output logic [4:0]     c_p_rd_o // dont know why this is here. does the interface keep track of the offloaded instrustions writeback adresses or the accelerator

    // TODO: Cmem-Request Channel

    // TODO: Cmem-Response Channel
);

  // test assignments
  assign c_p_ready = 1'b1;


  // import cv32e40p_pkg::*;
  // import fpnew_pkg::*;

  // logic [        fpnew_pkg::OP_BITS-1:0] fpu_op;
  // logic                                  fpu_op_mod;
  // logic                                  fpu_vec_op;

  // logic [ fpnew_pkg::FP_FORMAT_BITS-1:0] fpu_dst_fmt;
  // logic [ fpnew_pkg::FP_FORMAT_BITS-1:0] fpu_src_fmt;
  // logic [fpnew_pkg::INT_FORMAT_BITS-1:0] fpu_int_fmt;
  // logic [                      C_RM-1:0] fp_rnd_mode;



  // // assign apu_rID_o = '0;
  // assign {fpu_vec_op, fpu_op_mod, fpu_op}                     = apu_op_i;

  // assign {fpu_int_fmt, fpu_src_fmt, fpu_dst_fmt, fp_rnd_mode} = apu_flags_i;



  // // -----------
  // // FPU Config
  // // -----------
  // // Features (enabled formats, vectors etc.)
  // localparam fpnew_pkg::fpu_features_t FPU_FEATURES = '{
  // Width:         C_FLEN,
  // EnableVectors: C_XFVEC,
  // EnableNanBox:  1'b0,
  // FpFmtMask:     {
  //   C_RVF, C_RVD, C_XF16, C_XF8, C_XF16ALT
  // }, IntFmtMask: {
  //   C_XFVEC && C_XF8, C_XFVEC && (C_XF16 || C_XF16ALT), 1'b1, 1'b0
  // }};

  // // Implementation (number of registers etc)
  // localparam fpnew_pkg::fpu_implementation_t FPU_IMPLEMENTATION = '{
  // PipeRegs:  '{// FP32, FP64, FP16, FP8, FP16alt
  //     '{
  //         C_LAT_FP32, C_LAT_FP64, C_LAT_FP16, C_LAT_FP8, C_LAT_FP16ALT
  //     },  // ADDMUL
  //     '{default: C_LAT_DIVSQRT},  // DIVSQRT
  //     '{default: C_LAT_NONCOMP},  // NONCOMP
  //     '{default: C_LAT_CONV}
  // },  // CONV
  // UnitTypes: '{
  //     '{default: fpnew_pkg::MERGED},  // ADDMUL
  //     '{default: fpnew_pkg::MERGED},  // DIVSQRT
  //     '{default: fpnew_pkg::PARALLEL},  // NONCOMP
  //     '{default: fpnew_pkg::MERGED}
  // },  // CONV
  // PipeConfig: fpnew_pkg::AFTER};

  // //---------------
  // // FPU instance
  // //---------------

  // fpnew_top #(
  //     .Features      (FPU_FEATURES),
  //     .Implementation(FPU_IMPLEMENTATION),
  //     .TagType       (logic)
  // ) i_fpnew_bulk (
  //     .clk_i         (clk_i),
  //     .rst_ni        (rst_ni),
  //     .operands_i    (apu_operands_i),
  //     .rnd_mode_i    (fpnew_pkg::roundmode_e'(fp_rnd_mode)),
  //     .op_i          (fpnew_pkg::operation_e'(fpu_op)),
  //     .op_mod_i      (fpu_op_mod),
  //     .src_fmt_i     (fpnew_pkg::fp_format_e'(fpu_src_fmt)),
  //     .dst_fmt_i     (fpnew_pkg::fp_format_e'(fpu_dst_fmt)),
  //     .int_fmt_i     (fpnew_pkg::int_format_e'(fpu_int_fmt)),
  //     .vectorial_op_i(fpu_vec_op),
  //     .tag_i         (1'b0),
  //     .in_valid_i    (apu_req_i),
  //     .in_ready_o    (apu_gnt_o),
  //     .flush_i       (1'b0),
  //     .result_o      (apu_rdata_o),
  //     .status_o      (apu_rflags_o),
  //     .tag_o         (  /* unused */),
  //     .out_valid_o   (apu_rvalid_o),
  //     .out_ready_i   (1'b1),
  //     .busy_o        (  /* unused */)
  // );

endmodule  // cv32e40p_fp_wrapper
