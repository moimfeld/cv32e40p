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

module fpu_ss #(
    parameter                                 BUFFER_DEPTH       = 4,
    parameter fpnew_pkg::fpu_features_t       FPU_FEATURES       = fpnew_pkg::RV64D_Xsflt,
    parameter fpnew_pkg::fpu_implementation_t FPU_IMPLEMENTATION = fpnew_pkg::DEFAULT_NOREGS,
    parameter type                            FPU_TAG_TYPE       = logic,
    // DO NOT OVERWRITE THIS PARAMETER
    parameter int unsigned BUFFER_ADDR_DEPTH  = (BUFFER_DEPTH > 1) ? $clog2(BUFFER_DEPTH) : 1
) (
    // Clock and Reset
    input logic clk_i,
    input logic rst_ni,

    // C-Request Channel
    input  logic                                 c_q_valid_i,
    output logic                                 c_q_ready_o, // Signal belongs to the c-rsp channel typedef but is part of the request handshake
    input  logic [acc_pkg::AddrWidth-1:0]        c_q_addr_i,
    input  logic [                   2:0] [31:0] c_q_rs_i,
    input  logic [                  31:0]        c_q_instr_data_i,
    input  logic [                  31:0]        c_q_hart_id_i,

    // C-Response Channel
    output logic        c_p_valid_o,
    input  logic        c_p_ready_i, // Signal belongs to the c-req channel typedef but is part of the response handshake
    output logic [31:0] c_p_data_o,
    output logic        c_p_error_o,
    output logic        c_p_dualwb_o,
    output logic [31:0] c_p_hart_id_o,
    output logic [ 4:0] c_p_rd_o,

    // Cmem-Request Channel
    output logic                          cmem_q_valid_o,
    input  logic                          cmem_q_ready_i, // Signal belongs to the cmem-rsp channel typedef but is part of the request handshake
    output logic [                  31:0] cmem_q_laddr_o, // Note: ss
    output logic [                  31:0] cmem_q_wdata_o, // Note: ss
    output logic [                   2:0] cmem_q_width_o, // Note: controller
    output acc_pkg::mem_req_type_e        cmem_q_req_type_o, // Note: controller
    output logic                          cmem_q_mode_o, // Note: controller
    output logic                          cmem_q_spec_o, // Note: controller
    output logic                          cmem_q_endoftransaction_o, // Note: controller
    output logic [                  31:0] cmem_q_hart_id_o, // Note: ss
    output logic [acc_pkg::AddrWidth-1:0] cmem_q_addr_o, // Note: ss

    // Cmem-Response Channel
    input  logic                          cmem_p_valid_i,
    output logic                          cmem_p_ready_o, // Signal belongs to the cmem-req channel typedef but is part of the request handshake
    input  logic [                  31:0] cmem_p_rdata_i,
    input  logic [        $clog2(32)-1:0] cmem_p_range_i,
    input  logic                          cmem_p_status_i,
    input  logic [acc_pkg::AddrWidth-1:0] cmem_p_addr_i,
    input  logic [                  31:0] cmem_p_hart_id_i
);

  typedef struct packed {
    logic [acc_pkg::AddrWidth:0] addr;
    logic [2:0][31:0] rs;
    logic [31:0] instr_data;
    logic [31:0] hart_id;
  } offloaded_data_t;

  offloaded_data_t                           offloaded_data_push;
  offloaded_data_t                           offloaded_data_pop;

  logic                     [31:0]           instr;
  logic                     [ 2:0]   [31:0]  fpu_operands;
  logic                     [ 2:0]   [31:0]  int_operands;

  // Register Operands and Adresses
  logic                     [ 2:0]   [31:0]  fpr_operands;
  logic                     [ 2:0]   [ 4:0]  fpr_raddr;
  logic                     [31:0]           fpr_wb_data;
  logic                     [ 4:0]           wb_address;
  logic                                      fpr_we;

  // Adresses
  logic                     [ 4:0]           rs1;
  logic                     [ 4:0]           rs2;
  logic                     [ 4:0]           rs3;
  logic                     [ 4:0]           rd;

  // FPU Result
  logic                     [31:0]           fpu_result;

  // Decoder Signals
  fpnew_pkg::operation_e                     fpu_op;
  fpu_ss_pkg::op_select_e [       2:0      ] op_select;
  fpnew_pkg::roundmode_e                     fpu_rnd_mode;
  logic                                      set_dyn_rm;
  fpnew_pkg::fp_format_e                     src_fmt;
  fpnew_pkg::fp_format_e                     dst_fmt;
  fpnew_pkg::int_format_e                    int_fmt;
  logic                                      rd_is_fp;
  logic                                      csr_instr;
  logic                                      vectorial_op;
  logic                                      op_mode;
  logic                                      use_fpu;
  logic                                      is_store;
  logic                                      is_load;
  fpu_ss_pkg::ls_size_e                      ls_size;
  logic                                      error;

  // Handshake Signals
  logic                                      fpu_out_valid;
  logic                                      pop_valid;
  logic                                      pop_ready;
  logic                                      fpu_in_valid;
  logic                                      fpu_out_ready;
  logic                                      cmem_rsp_hs;

  // Fifo Usage
  logic [BUFFER_ADDR_DEPTH-1:0] fifo_usage;

  // FPU signals
  logic fpu_busy;

  // CSR
  logic [31:0] csr_rdata;
  logic [ 2:0] frm;
  logic        csr_wb;

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
  assign rd                             = instr[11:7];

  assign c_p_error_o   = 1'b0; // no errors can occur for now
  assign c_p_dualwb_o  = 1'b0;
  assign c_p_hart_id_o = offloaded_data_pop.hart_id;
  assign c_p_rd_o      = rd;

  // cmem-request channel assignements
  assign cmem_q_wdata_o   = fpu_operands[1];
  assign cmem_q_width_o   = instr[14:12];
  assign cmem_q_hart_id_o = offloaded_data_pop.hart_id;
  assign cmem_q_addr_o    = offloaded_data_pop.addr;

  // load and store have different immediate encoding :(
  always_comb begin
    if (cmem_q_req_type_o == acc_pkg::READ) begin
      cmem_q_laddr_o   = int_operands[0] + instr[31:20];
      if (instr[31]) begin
        cmem_q_laddr_o = int_operands[0] + {20'b1111_1111_1111_1111_1111, instr[31:20]};
      end
    end else begin
      cmem_q_laddr_o   = int_operands[0] + {instr[31:25], instr[11:7]};
      if (instr[31]) begin
        cmem_q_laddr_o = int_operands[0] + {20'b1111_1111_1111_1111_1111, instr[31:25], instr[11:7]};
      end
    end
  end



// assign cmem_q_laddr_o   = int_operands[0] + instr[31:20];
  // fp register writeback mux
  always_comb begin
    fpr_wb_data = fpu_result;
    if (cmem_rsp_hs) begin
      fpr_wb_data = cmem_p_rdata_i;
    end
  end

  // int register writeback mux
  always_comb begin
    c_p_data_o = fpu_result;
    if (~rd_is_fp & ~csr_wb) begin
      c_p_data_o = fpu_operands[0];
    end else if (csr_wb) begin
      c_p_data_o = csr_rdata;
    end
  end




  // Fifo with built in Handshake protocol
  stream_fifo #(
      .FALL_THROUGH(1'b0),
      .DATA_WIDTH  (32),
      .DEPTH       (BUFFER_DEPTH),
      .T           (offloaded_data_t)
  ) stream_fifo_i (
      .clk_i     (clk_i),
      .rst_ni    (rst_ni),
      .flush_i   (1'b0),
      .testmode_i(1'b0),
      .usage_o   (fifo_usage),

      .data_i (offloaded_data_push),
      .valid_i(c_q_valid_i),
      .ready_o(c_q_ready_o),

      .data_o (offloaded_data_pop),
      .valid_o(pop_valid),
      .ready_i(pop_ready)
  );

  // "F"-Extension and "xfvec"-Extension Decoder
  fpu_ss_decoder fpu_ss_decoder_i (  // Note: Remove Double Precision Instr form the decoder (not required at the moment --> only contributes to area)
      .instr_i(instr),
      .fpu_rnd_mode_i(fpnew_pkg::roundmode_e'(frm)),
      .fpu_op_o(fpu_op),
      .op_select_o(op_select),
      .fpu_rnd_mode_o(fpu_rnd_mode),
      .set_dyn_rm_o(set_dyn_rm),
      .src_fmt_o(src_fmt),
      .dst_fmt_o(dst_fmt),
      .int_fmt_o(int_fmt),
      .rd_is_fp_o(rd_is_fp),
      .vectorial_op_o(vectorial_op),
      .op_mode_o(op_mode),
      .use_fpu_o(use_fpu),
      .is_store_o(is_store),
      .is_load_o(is_load),
      .ls_size_o(ls_size)
  );

  fpu_ss_csr fpu_ss_csr_i (
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    .instr_i(instr),
    .csr_data_i(int_operands[0]),
    .csr_rdata_o(csr_rdata),
    .frm_o(frm),
    .csr_wb_o(csr_wb),
    .csr_instr_o(csr_instr)
    );

  fpu_ss_controller fpu_ss_controller_i (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      // Signals for buffer pop handshake
      .fpu_out_valid_i(fpu_out_valid),
      .fpu_busy_i(fpu_busy),
      .use_fpu_i(use_fpu),
      .pop_valid_i(pop_valid),
      .pop_ready_o(pop_ready),

      // Signals for fpu in handshake
      .fpu_in_valid_o(fpu_in_valid),

      // Signals for fpu out handshake
      .fpu_out_ready_o(fpu_out_ready),

      // Register Write enable
      .rd_is_fp_i(rd_is_fp),
      .fpr_we_o(fpr_we),

      // Signals for C-Response handshake
      .c_p_ready_i(c_p_ready_i),
      .csr_instr_i(csr_instr),
      .c_p_valid_o(c_p_valid_o),

      // Memory instruction handling
      .is_load_i(is_load),
      .is_store_i(is_store),
    // Request Handshake
      .cmem_q_valid_o(cmem_q_valid_o),
      .cmem_q_ready_i(cmem_q_ready_i),
      .cmem_q_req_type_o(cmem_q_req_type_o),
      .cmem_q_mode_o(cmem_q_mode_o),
      .cmem_q_spec_o(cmem_q_spec_o),
      .cmem_q_endoftransaction_o(cmem_q_endoftransaction_o),
    // Response Handshake --> assert write enable (and subesquently handle what data gets written to the registerfile)
      .cmem_p_valid_i(cmem_p_valid_i),
      .cmem_p_ready_o(cmem_p_ready_o),
      .cmem_status_i(cmem_status_i),

      .cmem_rsp_hs_o (cmem_rsp_hs)
  );

  // fp Register File
  fpu_ss_regfile fpu_ss_regfile_i (
      .clk_i(clk_i),

      .raddr_i(fpr_raddr),
      .rdata_o(fpr_operands),

      .waddr_i(rd),
      .wdata_i(fpr_wb_data),
      .we_i   (fpr_we)
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
      default: ;
    endcase

    unique case (op_select[2])
      fpu_ss_pkg::RegB, fpu_ss_pkg::RegBRep: begin
        fpr_raddr[2] = rs2;
      end
      fpu_ss_pkg::RegDest: begin
        fpr_raddr[2] = rd;
      end
      default: ;
    endcase
  end

  // Operand Selection
  for (genvar i = 0; i < 3; i++) begin : gen_operand_select
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
              fpnew_pkg::FP32: fpu_operands[i] = {(32 / 32) {fpu_operands[i][31:0]}};
              fpnew_pkg::FP16, fpnew_pkg::FP16ALT:
              fpu_operands[i] = {(32 / 16) {fpu_operands[i][15:0]}};
              fpnew_pkg::FP8: fpu_operands[i] = {(32 / 8) {fpu_operands[i][7:0]}};
              default: fpu_operands[i] = fpu_operands[i][32-1:0];
            endcase
          end
        end
        default: begin
          fpu_operands[i] = '0;
        end
      endcase
    end
  end

  // fpnew
  fpnew_top #(
      .Features      (FPU_FEATURES),
      .Implementation(FPU_IMPLEMENTATION),
      .TagType       (FPU_TAG_TYPE)
  ) i_fpnew_bulk (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .operands_i(fpu_operands),
      .rnd_mode_i(fpnew_pkg::RNE), //fpnew_pkg::roundmode_e'(fpu_rnd_mode)
      .op_i(fpnew_pkg::operation_e'(fpu_op)),
      .op_mod_i(op_mode),
      .src_fmt_i(fpnew_pkg::fp_format_e'(src_fmt)),
      .dst_fmt_i(fpnew_pkg::fp_format_e'(dst_fmt)),
      .int_fmt_i(fpnew_pkg::int_format_e'(int_fmt)),
      .vectorial_op_i(vectorial_op),
      .tag_i(1'b0),
      .in_valid_i(fpu_in_valid),
      .in_ready_o(  /* unused */), // Note: unused since its assumed to be high whenever in_valid_i is high
      .flush_i(1'b0),
      .result_o(fpu_result),
      .status_o(  /* unused */),  // Note: discuss with supervisor if needed
      .tag_o(  /* unused */),
      .out_valid_o(fpu_out_valid),
      .out_ready_i(fpu_out_ready),  // Note: always high at the moment
      .busy_o(fpu_busy)
  );

endmodule  // fpu_ss
