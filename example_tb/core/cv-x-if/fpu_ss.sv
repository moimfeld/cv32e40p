// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// FPU Subsystem
// Contributor: Davide Schiavone <davide@openhwgroup.org>
//              Moritz Imfeld <moimfeld@student.ethz.ch>

module fpu_ss (
    // Clock and Reset
    input logic clk_i,
    input logic rst_ni,

    // C-Request Channel
    input  logic             c_q_valid_i,
    output logic             c_q_ready_o, // Signal belongs to the rsp channel but is part of the request handshake
    input  logic [4:0]       c_q_addr_i,
    input  logic [2:0][31:0] c_q_rs_i,
    input  logic [31:0]      c_q_instr_data_i,
    input  logic [31:0]      c_q_hart_id_i,

    // C-Response Channel
    output logic           c_p_valid_o,
    input  logic           c_p_ready_i, // Signal belongs to the req channel but is part of the response handshake
    output logic [31:0]    c_p_data_o,
    output logic           c_p_error_o,
    output logic           c_p_dualwb_o,
    output logic [31:0]    c_p_hart_id_o,
    output logic [4:0]     c_p_rd_o // dont know why this is here. does the interface keep track of the offloaded instrustions writeback adresses or the accelerator

    // TODO: Cmem-Request Channel

    // TODO: Cmem-Response Channel
);
  typedef struct packed {
    logic [4:0] addr;  // Note: Do I need to store this address?
    logic [2:0][31:0] rs;
    logic [31:0] instr_data;
    logic [31:0] hart_id;  // Note: Do i need to store the hart_id?
  } offloaded_data_t;

  offloaded_data_t offloaded_data_push;
  offloaded_data_t offloaded_data_pop;

  logic                               [31:0]           instr;
  logic                               [ 2:0]   [31:0]  fpu_operands;
  logic                               [ 2:0]   [31:0]  int_operands;
  logic                               [ 2:0]   [31:0]  fpr_operands;
  logic                               [ 2:0]   [ 4:0]  fpr_raddr;
  logic                                        [ 4:0]  rs1;
  logic                                        [ 4:0]  rs2;
  logic                                        [ 4:0]  rs3;
  logic                                        [ 4:0]  rd;

  fpnew_pkg::operation_e                               fpu_op;
  fpu_ss_pkg::op_select_e     [       2:0      ]       op_select;
  fpnew_pkg::roundmode_e                               fpu_rnd_mode;
  logic                                                set_dyn_rm;
  fpnew_pkg::fp_format_e                               src_fmt;
  fpnew_pkg::fp_format_e                               dst_fmt;
  fpnew_pkg::int_format_e                              int_fmt;
  fpu_ss_pkg::result_select_e                          result_select;
  logic                                                rd_is_fp;
  logic                                                csr_instr;
  logic                                                vectorial_op;
  logic                                                op_mode;
  logic                                                use_fpu;
  logic                                                is_store;
  logic                                                is_load;
  fpu_ss_pkg::ls_size_e                                ls_size;
  logic                                                error;

  assign offloaded_data_push.addr       = c_q_addr_i;
  assign offloaded_data_push.rs         = c_q_rs_i;
  assign offloaded_data_push.instr_data = c_q_instr_data_i;
  assign offloaded_data_push.hart_id    = c_q_hart_id_i;

  assign instr                          = offloaded_data_pop.instr_data;
  assign int_operands[0]                = offloaded_data_pop.rs[0];
  assign int_operands[1]                = offloaded_data_pop.rs[1];
  assign int_operands[2]                = offloaded_data_pop.rs[2];

  assign rs1                            = instr[19:15];
  assign rs2                            = instr[24:20];
  assign rs3                            = instr[31:27];
  assign rd                             = instr[11: 7];


  // Fifo with built in Handshake protocol
  stream_fifo #(
      .FALL_THROUGH(1'b0),
      .DATA_WIDTH  (32),
      .DEPTH       (4),
      .T           (offloaded_data_t)
  ) i_stream_fifo (
      .clk_i     (clk_i),
      .rst_ni    (rst_ni),
      .flush_i   (1'b0),
      .testmode_i(1'b0),
      .usage_o   (  /* unused */),

      .data_i (offloaded_data_push),
      .valid_i(c_q_valid_i),
      .ready_o(c_q_ready_o),

      .data_o (offloaded_data_pop),
      .valid_o(  /* unused for now */),
      .ready_i(1'b0)
  );

  // "F"-Extension and "xfvec"-Extension Decoder
  fpu_ss_decoder i_fpu_ss_decoder (  // Note: Remove Double Precision Instr form the decoder (not required at the moment --> only contributes to area)
      .instr_i (instr),
      .fpu_rnd_mode_i  (fpnew_pkg::RNE), // Note: just an example to get the decoder running (normally this would come from CSR)
      .fpu_op_o (fpu_op),
      .op_select_o (op_select),
      .fpu_rnd_mode_o (fpu_rnd_mode),
      .set_dyn_rm_o (set_dyn_rm),
      .src_fmt_o (src_fmt),
      .dst_fmt_o (dst_fmt),
      .int_fmt_o (int_fmt),
      .result_select_o (result_select),
      .rd_is_fp_o (rd_is_fp),
      .csr_instr_o (csr_instr),
      .vectorial_op_o (vectorial_op),
      .op_mode_o (op_mode),
      .use_fpu_o (use_fpu),
      .is_store_o (is_store),
      .is_load_o (is_load),
      .ls_size_o (ls_size),
      .error_o (error)
  );

  // fp Register File
  fpu_ss_regfile i_fpu_ss_regfile (
      .clk_i(clk_i),

      .raddr_i(fpr_raddr),
      .rdata_o(fpr_operands),

      .waddr_i(5'b1),  // Note: some random address for testing
      .wdata_i(32'b1),  // Note: some random data for testing
      .we_i   (1'b0)  // Note: always set to 0 for testing
  );

  // FP Register Address Selection
  always_comb begin
    fpr_raddr[0] = rs1;
    fpr_raddr[1] = rs2;
    fpr_raddr[2] = rs3;

    unique case (op_select[1])
      fpu_ss_pkg::RegA: begin
        fpr_raddr[1] = rs1;
      end
      default:;
    endcase

    unique case (op_select[2])
      fpu_ss_pkg::RegB,
      fpu_ss_pkg::RegBRep: begin
        fpr_raddr[2] = rs2;
      end
      fpu_ss_pkg::RegDest: begin
        fpr_raddr[2] = rd;
      end
      default:;
    endcase
  end

  // Operand Selection
  for (genvar i = 0; i < 3; i++) begin: gen_operand_select
    always_comb begin
      unique case (op_select[i])
        fpu_ss_pkg::None: begin
          fpu_operands[i] = '1;
        end
        fpu_ss_pkg::AccBus: begin
          fpu_operands[i] = int_operands[i];
        end
        fpu_ss_pkg::RegA, fpu_ss_pkg::RegB, fpu_ss_pkg::RegBRep, fpu_ss_pkg::RegC, fpu_ss_pkg::RegDest: begin
          fpu_operands[i] = fpr_operands[i];
          // Replicate if needed
          if (op_select[i] == fpu_ss_pkg::RegBRep) begin
            unique case (src_fmt)
              fpnew_pkg::FP32:    fpu_operands[i] = {(32 / 32){fpu_operands[i][31:0]}};
              fpnew_pkg::FP16,
              fpnew_pkg::FP16ALT: fpu_operands[i] = {(32 / 16){fpu_operands[i][15:0]}};
              fpnew_pkg::FP8:     fpu_operands[i] = {(32 /  8){fpu_operands[i][ 7:0]}};
              default:            fpu_operands[i] = fpu_operands[i][32-1:0];
            endcase
          end
        end
        default: begin
          fpu_operands[i] = '0;
        end
      endcase
    end
  end

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
  // Width:         C_32,
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

endmodule  // fpu_ss
