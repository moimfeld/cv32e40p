// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Description: Top level Module of the FPU subsystem
//
// Parameters:  PULP_ZFINX:       Unused at the moment
//
//              BUFFER_DEPTH:     This parameter can be used to set the depth of the stream_fifo buffer.
//                                Minimum value is 0
//
//              INT_REG_WB_DELAY: INTeger REGister WriteBack DELAY can be used to cut combinational
//                                paths of instructions that do not go through the FPnew.
//                                Instructions that cause such paths are for example the CSR instructions.
//                                Setting this parameter to 0 can lead to writebacks to the core
//                                in the same cycle as an instruction was offloaded.
//                                Minimum value is 0
//
//              OUT_OF_ORDER:     Enable or diable out-of-order execution for instructions that go through
//                                the FPnew.
//                                For example with OUT_OF_ORDER = 1
//                                    fdiv.s fa1, fa2, fa3 // supporse takes 3 cycles
//                                    fmul.s fa4, fa5, fa6 // supporse takes 1 cycles
//                                    fmul.s fa2, fa5, fa6 // supporse takes 1 cycles
//                                    fmul.s fa3, fa5, fa6 // supporse takes 1 cycles
//                                --> This sequence takes 4 clock cycles
//                                With OUT_OF_ORDER this instruction sequence would take 5 clock cycles
//                                Possible values for this parameter are 0 and 1
//
//             FORWARDING:        With this parameter forwarding of floating-point results in the subsystem
//                                can be enabled/disabled.
//                                For examle take this sequence:
//                                    fmul.s fa4, fa5, fa6 // supporse takes 1 cycles
//                                    fmul.s fa1, fa4, fa6 // supporse takes 1 cycles
//                                There is a source register dependency for the second instruction on the
//                                first instruction. With FORWARDING = 1 this sequence takes 2 clock cycles
//                                while with FORWARDING = 0 this sequence takes 3 clock cycles.
//
//             FPU_FEATURES:      Parameter to configure the FPnew, the subsystem was designed for the configuration found here:
//                                https://github.com/moimfeld/cv32e40p/blob/x-interface/example_tb/core/cv-x-if/cv32e40p_fpu_pkg.sv
//                                Other configurations might not work
//
//             FPU_IMPLEMENTATION:Parameter to configure the FPnew, the subsystem was designed for the configuration found here:
//                                https://github.com/moimfeld/cv32e40p/blob/x-interface/example_tb/core/cv-x-if/cv32e40p_fpu_pkg.sv
//                                Other configurations might not work
//
// Contributor: Moritz Imfeld <moimfeld@student.ethz.ch>
//              Davide Schiavone <davide@openhwgroup.org>

module fpu_ss #(
    parameter                                 PULP_ZFINX         = 0,
    parameter                                 BUFFER_DEPTH       = 1,
    parameter                                 INT_REG_WB_DELAY   = 1,
    parameter                                 OUT_OF_ORDER       = 1,
    parameter                                 FORWARDING         = 1,
    parameter fpnew_pkg::fpu_features_t       FPU_FEATURES       = fpnew_pkg::RV64D_Xsflt,
    parameter fpnew_pkg::fpu_implementation_t FPU_IMPLEMENTATION = fpnew_pkg::DEFAULT_NOREGS
) (
    // clock and reset
    input logic clk_i,
    input logic rst_ni,

    // c-request channel
    input logic c_q_valid_i,
    output logic                                 c_q_ready_o, // signal belongs to the c-rsp channel typedef but is part of the request handshake
    input logic [acc_pkg::AddrWidth-1:0] c_q_addr_i,
    input logic [2:0][31:0] c_q_rs_i,
    input logic [31:0] c_q_instr_data_i,
    input logic [31:0] c_q_hart_id_i,

    // predecoder responses
    input logic  rd_clean_i,
    input logic [2:0]  rs_valid_i,
    output logic c_k_accept_o,
    output logic c_k_is_mem_op_o,
    output logic c_k_writeback_o,

    // c-response channel
    output logic c_p_valid_o,
    input  logic        c_p_ready_i, // signal belongs to the c-req channel typedef but is part of the response handshake
    output logic [31:0] c_p_data_o,
    output logic c_p_error_o,
    output logic c_p_dualwb_o,
    output logic [31:0] c_p_hart_id_o,
    output logic [4:0] c_p_rd_o,

    // cmem-request channel
    output logic cmem_q_valid_o,
    input  logic                          cmem_q_ready_i, // signal belongs to the cmem-rsp channel typedef but is part of the request handshake
    output logic [31:0] cmem_q_laddr_o,
    output logic [31:0] cmem_q_wdata_o,
    output logic [2:0] cmem_q_width_o,
    output acc_pkg::mem_req_type_e cmem_q_req_type_o,
    output logic cmem_q_mode_o,
    output logic cmem_q_spec_o,
    output logic cmem_q_endoftransaction_o,
    output logic [31:0] cmem_q_hart_id_o,
    output logic [acc_pkg::AddrWidth-1:0] cmem_q_addr_o,

    // cmem-Response Channel
    input logic cmem_p_valid_i,
    output logic                          cmem_p_ready_o, // signal belongs to the cmem-req channel typedef but is part of the response handshake
    input logic [31:0] cmem_p_rdata_i,
    input logic [$clog2(32)-1:0] cmem_p_range_i,
    input logic cmem_p_status_i,
    input logic [acc_pkg::AddrWidth-1:0] cmem_p_addr_i,
    input logic [31:0] cmem_p_hart_id_i
);

  // predecoder signals
  acc_pkg::acc_prd_req_t  prd_req;
  acc_pkg::acc_prd_rsp_t  prd_rsp;
  logic buffer_ready;


  // stream_fifo input and output data
  fpu_ss_pkg::offloaded_data_t                    offloaded_data_push;
  fpu_ss_pkg::offloaded_data_t                    offloaded_data_pop;
  logic                                           pop_valid;
  logic                                           pop_ready;

  // FPnew signals
  fpu_ss_pkg::fpu_tag_t                           fpu_tag_in;
  fpu_ss_pkg::fpu_tag_t                           fpu_tag_out;
  logic                                           fpu_in_valid;
  logic                                           fpu_in_ready;
  logic                                           fpu_out_valid;
  logic                                           fpu_out_ready;
  logic                          [31:0]           fpu_result;
  logic                                           fpu_busy;

  // instruction data, operands and adresses
  logic                          [31:0]           instr;
  logic                          [ 2:0]   [31:0]  fpu_operands;
  logic                          [ 2:0]   [31:0]  int_operands;
  logic                          [ 2:0]   [31:0]  fpr_operands;
  logic                          [ 4:0]           rs1;
  logic                          [ 4:0]           rs2;
  logic                          [ 4:0]           rs3;
  logic                          [ 4:0]           rd;
  logic                          [31:0]           offset;
  logic                          [ 2:0]   [ 4:0]  fpr_raddr;
  logic                          [ 4:0]           fpr_wb_addr;
  logic                          [31:0]           fpr_wb_data;
  logic                                           fpr_we;

  // forwarding
  logic                          [ 2:0]           fwd;

  // decoder signals
  fpnew_pkg::operation_e                          fpu_op;
  fpu_ss_pkg::op_select_e      [       2:0      ] op_select;
  fpnew_pkg::roundmode_e                          fpu_rnd_mode;
  logic                                           set_dyn_rm;
  fpnew_pkg::fp_format_e                          src_fmt;
  fpnew_pkg::fp_format_e                          dst_fmt;
  fpnew_pkg::int_format_e                         int_fmt;
  logic                                           rd_is_fp;
  logic                                           csr_instr;
  logic                                           vectorial_op;
  logic                                           op_mode;
  logic                                           use_fpu;
  logic                                           is_store;
  logic                                           is_load;
  fpu_ss_pkg::ls_size_e                           ls_size;
  logic                                           error;

  // writeback to core
  logic                          [ 4:0]           wb_rd;
  logic                          [31:0]           wb_hart_id;
  logic                          [31:0]           wb_csr_rdata;

  // CSR
  logic                          [31:0]           csr_rdata;
  logic                                           csr_wb;
  logic                          [ 2:0]           frm;
  fpnew_pkg::status_t                             fpu_status;

  // additional signals
  logic                                           cmem_rsp_hs;
  logic                                           int_wb;

  // predecoder signal assignments
  assign prd_req.q_instr_data = c_q_instr_data_i;
  assign c_k_accept_o = prd_rsp.p_accept;
  assign c_k_writeback_o = prd_rsp.p_writeback;
  assign c_k_is_mem_op_o = prd_rsp.p_is_mem_op;

  always_comb begin
    c_q_ready_o = 1'b0;
    if (((prd_rsp.p_writeback & rd_clean_i) | !prd_rsp.p_writeback)
        & ((prd_rsp.p_use_rs[0] & rs_valid_i[0]) | !prd_rsp.p_use_rs[0])
        & ((prd_rsp.p_use_rs[1] & rs_valid_i[1]) | !prd_rsp.p_use_rs[1])
        & ((prd_rsp.p_use_rs[2] & rs_valid_i[2]) | !prd_rsp.p_use_rs[2])
        & buffer_ready) begin
      c_q_ready_o = 1'b1;
    end
  end


  // default assignment for unused x-interface signals
  assign c_p_error_o = 1'b0;  // no errors can occur for now
  assign c_p_dualwb_o = 1'b0;  // no dual writeback

  // stream_fifo input and output
  assign offloaded_data_push.addr = c_q_addr_i;
  assign offloaded_data_push.rs = c_q_rs_i;
  assign offloaded_data_push.instr_data = c_q_instr_data_i;
  assign offloaded_data_push.hart_id = c_q_hart_id_i;
  assign instr = offloaded_data_pop.instr_data;
  assign int_operands[0] = offloaded_data_pop.rs[0];
  assign int_operands[1] = offloaded_data_pop.rs[1];
  assign int_operands[2] = offloaded_data_pop.rs[2];

  // addresses
  assign rs1 = instr[19:15];
  assign rs2 = instr[24:20];
  assign rs3 = instr[31:27];
  assign rd = instr[11:7];

  // FPnew tag
  assign fpu_tag_in.addr = rd;
  assign fpu_tag_in.rd_is_fp = rd_is_fp;
  assign fpu_tag_in.hart_id = offloaded_data_pop.hart_id;

  // int register writeback data mux
  always_comb begin
    c_p_data_o = fpu_result;
    if (~rd_is_fp & ~use_fpu & ~csr_wb & ~fpu_out_valid & int_wb) begin
      c_p_data_o = fpu_operands[0];
    end else if (csr_wb & ~fpu_out_valid & int_wb & ~fpu_out_valid) begin
      c_p_data_o = wb_csr_rdata;
    end
  end

  // int writeback core and hart.id mux
  always_comb begin
    c_p_rd_o      = '0;
    c_p_hart_id_o = '0;
    if (fpu_out_valid & c_p_valid_o & c_p_ready_i) begin
      c_p_rd_o      = fpu_tag_out.addr;
      c_p_hart_id_o = fpu_tag_out.hart_id;
    end else if (c_p_valid_o & c_p_ready_i & ~fpu_out_valid) begin
      c_p_rd_o      = wb_rd;
      c_p_hart_id_o = wb_hart_id;
    end
  end

  // cmem-request channel assignements
  assign cmem_q_width_o   = instr[14:12];
  assign cmem_q_hart_id_o = offloaded_data_pop.hart_id;
  assign cmem_q_addr_o    = offloaded_data_pop.addr;
  always_comb begin
    cmem_q_wdata_o = fpu_operands[1];
    if (fwd[0]) begin
      cmem_q_wdata_o = fpu_result;
    end
  end

  // load and store address calculation
  always_comb begin
    if (cmem_q_req_type_o == acc_pkg::READ) begin
      offset = instr[31:20];
      if (instr[31]) begin
        offset = {20'b1111_1111_1111_1111_1111, instr[31:20]};
      end
    end else begin
      offset = {instr[31:25], instr[11:7]};
      if (instr[31]) begin
        offset = {20'b1111_1111_1111_1111_1111, instr[31:25], instr[11:7]};
      end
    end
    cmem_q_laddr_o = int_operands[0] + offset;
  end

  // fp register writeback data mux
  always_comb begin
    fpr_wb_data = fpu_result;
    if (cmem_rsp_hs) begin
      fpr_wb_data = cmem_p_rdata_i;
    end
  end

  // fp register addr writeback mux
  always_comb begin
    fpr_wb_addr = fpu_tag_out.addr;
    if (~use_fpu & ~fpu_out_valid) begin
      fpr_wb_addr = rd;
    end
  end

  // Predecoder, that checks validity of source registers and cleanness of source/destination register before accepting an instruction
  fpu_ss_predecoder #(
      .NumInstr(acc_fp_pkg::NumInstr),
      .OffloadInstr(acc_fp_pkg::OffloadInstr)
  ) fpu_ss_predecoder_i (
      .prd_req_i(prd_req),
      .prd_rsp_o(prd_rsp)
  );


  // FIFO with built in Handshake protocol (FALL_THROUGH enabled)
  stream_fifo #(
      .FALL_THROUGH(1),
      .DATA_WIDTH  (32),
      .DEPTH       (BUFFER_DEPTH),
      .T           (fpu_ss_pkg::offloaded_data_t)
  ) stream_fifo_i (
      .clk_i     (clk_i),
      .rst_ni    (rst_ni),
      .flush_i   (1'b0),
      .testmode_i(1'b0),
      .usage_o   (  /* unused */),

      .data_i (offloaded_data_push),
      .valid_i(c_q_valid_i),
      .ready_o(buffer_ready),

      .data_o (offloaded_data_pop),
      .valid_o(pop_valid),
      .ready_i(pop_ready)
  );

  // "F"-Extension and "xfvec"-Extension Decoder
  fpu_ss_decoder #(
      .PULP_ZFINX(PULP_ZFINX)
  ) fpu_ss_decoder_i (  // Note: Remove Double Precision Instr form the decoder (not required at the moment --> only contributes to area)
      .instr_i       (instr),
      .fpu_rnd_mode_i(fpnew_pkg::roundmode_e'(frm)),
      .fpu_op_o      (fpu_op),
      .op_select_o   (op_select),
      .fpu_rnd_mode_o(fpu_rnd_mode),
      .set_dyn_rm_o  (set_dyn_rm),
      .src_fmt_o     (src_fmt),
      .dst_fmt_o     (dst_fmt),
      .int_fmt_o     (int_fmt),
      .rd_is_fp_o    (rd_is_fp),
      .vectorial_op_o(vectorial_op),
      .op_mode_o     (op_mode),
      .use_fpu_o     (use_fpu),
      .is_store_o    (is_store),
      .is_load_o     (is_load),
      .ls_size_o     (ls_size)
  );

  // FPU subsystem CSR
  fpu_ss_csr fpu_ss_csr_i (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .instr_i     (instr),
      .csr_data_i  (int_operands[0]),
      .fpu_status_i(fpu_status),
      .fpu_busy_i  (fpu_busy),
      .csr_rdata_o (csr_rdata),
      .frm_o       (frm),
      .csr_wb_o    (csr_wb),
      .csr_instr_o (csr_instr)
  );

  // FPU subsystem controller
  fpu_ss_controller #(
      .INT_REG_WB_DELAY(INT_REG_WB_DELAY),
      .OUT_OF_ORDER(OUT_OF_ORDER),
      .FORWARDING(FORWARDING)
  ) fpu_ss_controller_i (
      // clock and reset
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // buffer pop handshake
      .pop_valid_i    (pop_valid),
      .pop_ready_o    (pop_ready),
      .fpu_busy_i     (fpu_busy),
      .use_fpu_i      (use_fpu),

      // FPnew input handshake
      .fpu_in_valid_o(fpu_in_valid),
      .fpu_in_ready_i(fpu_in_ready),

      // FPnew output handshake
      .fpu_out_valid_i(fpu_out_valid),
      .fpu_out_ready_o(fpu_out_ready),

      // register Write enable
      .rd_is_fp_i(fpu_tag_out.rd_is_fp),
      .fpr_wb_addr_i(fpr_wb_addr),
      .rd_i(rd),
      .fpr_we_o(fpr_we),

      // c-response handshake
      .c_p_ready_i(c_p_ready_i),
      .csr_wb_i(csr_wb),
      .csr_instr_i(csr_instr),
      .c_p_valid_o(c_p_valid_o),

      // dependency check
      .rd_in_is_fp_i(rd_is_fp),
      .rs1_i(rs1),
      .rs2_i(rs2),
      .rs3_i(rs3),
      .fwd_o(fwd),
      .op_select_i(op_select),

      // memory instruction handling
      .is_load_i (is_load),
      .is_store_i(is_store),

      // request Handshake
      .cmem_q_valid_o           (cmem_q_valid_o),
      .cmem_q_ready_i           (cmem_q_ready_i),
      .cmem_q_req_type_o        (cmem_q_req_type_o),
      .cmem_q_mode_o            (cmem_q_mode_o),
      .cmem_q_spec_o            (cmem_q_spec_o),
      .cmem_q_endoftransaction_o(cmem_q_endoftransaction_o),

      // response handshake
      .cmem_p_valid_i(cmem_p_valid_i),
      .cmem_p_ready_o(cmem_p_ready_o),
      .cmem_status_i (cmem_status_i),

      // additional signals
      .int_wb_o(int_wb),
      .cmem_rsp_hs_o(cmem_rsp_hs)
  );

  // FPU subsystem dedicated floating-point register file
  fpu_ss_regfile fpu_ss_regfile_i (
      .clk_i(clk_i),
      .rst_ni(rst_ni),

      .raddr_i(fpr_raddr),
      .rdata_o(fpr_operands),

      .waddr_i(fpr_wb_addr),
      .wdata_i(fpr_wb_data),
      .we_i   (fpr_we)
  );

  // FP rgister address selection
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

  // operand selection
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
          if (fwd[i]) begin
            fpu_operands[i] = fpu_result;
          end
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

  // FPnew
  fpnew_top #(
      .Features      (FPU_FEATURES),
      .Implementation(FPU_IMPLEMENTATION),
      .TagType       (fpu_ss_pkg::fpu_tag_t)
  ) i_fpnew_bulk (
      .clk_i         (clk_i),
      .rst_ni        (rst_ni),
      .operands_i    (fpu_operands),
      .rnd_mode_i    (fpnew_pkg::roundmode_e'(fpu_rnd_mode)),
      .op_i          (fpnew_pkg::operation_e'(fpu_op)),
      .op_mod_i      (op_mode),
      .src_fmt_i     (fpnew_pkg::fp_format_e'(src_fmt)),
      .dst_fmt_i     (fpnew_pkg::fp_format_e'(dst_fmt)),
      .int_fmt_i     (fpnew_pkg::int_format_e'(int_fmt)),
      .vectorial_op_i(vectorial_op),
      .tag_i         (fpu_tag_in),
      .in_valid_i    (fpu_in_valid),
      .in_ready_o    (fpu_in_ready),
      .flush_i       (1'b0),
      .result_o      (fpu_result),
      .status_o      (fpu_status),
      .tag_o         (fpu_tag_out),
      .out_valid_o   (fpu_out_valid),
      .out_ready_i   (fpu_out_ready),
      .busy_o        (fpu_busy)
  );

  // with this generate block combinational paths of instructions that do not go through the fpnew are cut
  // It had to be added, because timing arcs were formed at synthesis time
  // --> Re-Implementing the c_p_valid_o signal in the fpu_ss_controller could make this generate block obsolete
  generate
    if (INT_REG_WB_DELAY > 0) begin : gen_wb_delay
      always_ff @(posedge clk_i, negedge rst_ni) begin
        if (~rst_ni) begin
          wb_csr_rdata <= '0;
          wb_rd        <= '0;
          wb_hart_id   <= '0;
        end else begin
          wb_csr_rdata <= csr_rdata;
          wb_rd        <= rd;
          wb_hart_id   <= offloaded_data_pop.hart_id;
        end
      end
    end else begin : gen_no_wb_delay
      assign wb_csr_rdata = csr_rdata;
      assign wb_rd        = rd;
      assign wb_hart_id   = offloaded_data_pop.hart_id;
    end : gen_no_wb_delay
  endgenerate


  // some measurements
  int offloaded, writebacks, memory, csr;
  initial begin
    offloaded = 0;
    writebacks = 0;
    memory = 0;
    csr = 0;
  end

`ifdef COREVXIF_COVER_ON
  cover property (@(posedge clk_i) c_q_valid_i & c_q_ready_o) begin
    offloaded = offloaded + 1;
    $display("Number of offloaded instructions %d \n", offloaded);
  end
  ;
  cover property (@(posedge clk_i) c_p_valid_o & c_p_ready_i) begin
    writebacks = writebacks + 1;
    $display("Number of writebacks %d \n", writebacks);
  end
  ;
  cover property (@(posedge clk_i) c_p_valid_o & c_p_ready_i & csr_instr) begin
    csr = csr + 1;
    $display("Number of csr instructions %d \n", csr);
  end
  ;
  cover property (@(posedge clk_i) cmem_q_valid_o & cmem_q_ready_i) begin
    memory = memory + 1;
    $display("Number of memory instructions %d \n", memory);
  end
  ;
`endif
endmodule  // fpu_ss
