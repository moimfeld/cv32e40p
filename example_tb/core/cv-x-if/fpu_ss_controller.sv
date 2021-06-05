// Copyright 2021 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// FPU Subsystem Controller
// Contributor: Moritz Imfeld <moimfeld@student.ethz.ch>

module fpu_ss_controller (
    input  logic clk_i,
    input  logic rst_ni,

    // Signals for buffer pop handshake
    input  logic fpu_out_valid_i,
    input  logic fpu_busy_i,
    input  logic use_fpu_i,
    input  logic pop_valid_i,
    output logic pop_ready_o,

    // Signals for fpu in handshake
    output logic fpu_in_valid_o,

    // Signals for fpu out handshake
    output logic fpu_out_ready_o,

    // Register write enable
    input  logic rd_is_fp_i,
    output logic fpr_we_o,

    // Signals for C-Response Channel Handshake
    input  logic c_p_ready_i,
    input  logic csr_instr_i,
    output logic c_p_valid_o,

    // Memory instruction handling
    input  logic is_load_i,
    input  logic is_store_i,
    // Request Handshake
    output logic                   cmem_q_valid_o,
    input  logic                   cmem_q_ready_i,
    output acc_pkg::mem_req_type_e cmem_q_req_type_o,
    output logic                   cmem_q_mode_o,
    output logic                   cmem_q_spec_o,
    output logic                   cmem_q_endoftransaction_o,
    // Response Handshake --> assert write enable (and subesquently handle what data gets written to the registerfile)
    input  logic cmem_p_valid_i,
    output logic cmem_p_ready_o,
    input  logic cmem_status_i,

    output logic cmem_rsp_hs_o
);

  // logic instr_done_d;
  // logic instr_done_q;
  logic instr_inflight_d;
  logic instr_inflight_q;
  logic instr_offloaded_d;
  logic instr_offloaded_q;

  logic c_rsp_hs;
  logic cmem_req_hs;

  assign c_rsp_hs        = c_p_ready_i & c_p_valid_o;
  assign fpu_out_ready_o = 1'b1; // always accept writebacks from the fpu
  assign cmem_q_mode_o   = 1'b0; // no probing -> harwire to 0 (probing is only for external mode memory oerpations)
  assign cmem_q_spec_o   = 1'b0; // no speculative memory operations -> hardwire to 0
  assign cmem_p_ready_o  = 1'b1; // always accept writebacks from the core (e.g. loads)
  assign cmem_req_hs     = cmem_q_valid_o & cmem_q_ready_i;
  assign cmem_rsp_hs_o   = cmem_p_valid_i & cmem_p_ready_o;

  // Pop Instruction
  always_comb begin
    pop_ready_o = 1'b0;
    // if ((fpu_out_valid_i & pop_valid_i) | cmem_rsp_hs_o | c_rsp_hs) begin
    if ((fpu_out_valid_i & rd_is_fp_i) | c_rsp_hs | cmem_rsp_hs_o) begin
      pop_ready_o = 1'b1;
    end
  end

  // Assert fpu_in_valid_o
  // - When instr uses fpu
  // - When instr has NOT been in fpu
  // - When fifo is NOT empty (important! because after "DEPTH" amount of instruction,
  //   the fifo will expose a valid instruction after a pop (even if the fifo is empty) (pop_valid_i == 0 is equivalent to saying fifo is empty))
  always_comb begin
    fpu_in_valid_o = 1'b0;
    if (use_fpu_i & ~instr_inflight_q & pop_valid_i)begin
      fpu_in_valid_o = 1'b1;
    end
  end

  // Assert fpr_we_o
  // - When fpu has a valid output and When rd is a fp register
  // - When instruction is Load and the valid ready handshake of the cmem response channel occures
  always_comb begin
    fpr_we_o = 1'b0;
    if ((fpu_out_valid_i & rd_is_fp_i) | (is_load_i & cmem_rsp_hs_o)) begin
      fpr_we_o = 1'b1;
    end
  end

  // Assert cmem_q_endoftransaction_o
  // - When the cmem-response handshake happend
  always_comb begin
    cmem_q_endoftransaction_o = 1'b0;
    if (cmem_req_hs) begin
      cmem_q_endoftransaction_o = 1'b1;
    end
  end

  // Assert c_p_valid_o (integer register writeback) (c-response channel handshake)
  // - When fpu_out_valid_i is high
  // - When rd is NOT a fp register
  always_comb begin
    c_p_valid_o = 1'b0;
    if (pop_valid_i & ((fpu_out_valid_i & ~rd_is_fp_i) | csr_instr_i)) begin
      c_p_valid_o = 1'b1;
    end
  end

  // Assert cmem_q_valid_o (load/store offload to the core)
  // - When the current instruction is a load/store instruction
  // - When the fifo is NOT empty
  // - When the instruction has NOT already been offloaded back to the core (instr_done_q signal)
  always_comb begin
    cmem_q_valid_o = 1'b0;
    if ((is_load_i | is_store_i) & pop_valid_i & ~instr_offloaded_q) begin // & ~instr_done_q) begin
      cmem_q_valid_o = 1'b1;
    end
  end

  // Set the cmem_q_req_type_o
  // - When is_load_i  -> req_type = 2'b00
  // - When is_store_i -> req_type = 2'b01
  // (no default in the hope of less switching)
  always_comb begin
    if (is_load_i) begin
      cmem_q_req_type_o = acc_pkg::READ;
    end else if (is_store_i) begin
      cmem_q_req_type_o = acc_pkg::WRITE;
    end
  end

  // Determine whether curretly exposed instruction by the buffer is already done/inflight (sequence of if statement matter,
  // because if there is a pop and a fpu_in_valid at the same time, then the instr_done signal needs to go to low)
  // always_comb begin
  //   instr_done_d = instr_done_q;
  //   if (pop_ready_o) begin
  //     instr_done_d = 1'b0;
  //   end else if (fpu_out_valid_i & rd_is_fp_i) begin
  //     instr_done_d = 1'b1;
  //   end else if (~rd_is_fp_i & c_rsp_hs) begin
  //     instr_done_d = 1'b1;
  //   end else if (~use_fpu_i & ~is_load_i & ~is_store_i & ~rd_is_fp_i & c_rsp_hs) begin
  //     instr_done_d = 1'b1;
  //   end else if (is_load_i & is_store_i & cmem_rsp_hs_o) begin
  //     instr_done_d = 1'b1;
  //   end else if (csr_instr_i & c_rsp_hs) begin
  //     instr_done_d = 1'b1;
  //   end
  // end

  always_comb begin
    instr_inflight_d = instr_inflight_q;
    if (pop_ready_o & pop_valid_i & fpu_out_ready_o) begin
      instr_inflight_d = 1'b0;
    end else if (pop_valid_i) begin
      instr_inflight_d = 1'b1;
    end
  end

  always_comb begin
    instr_offloaded_d = instr_offloaded_q;
    if (pop_valid_i & cmem_req_hs) begin
      instr_offloaded_d = 1'b1;
    end else if (cmem_rsp_hs_o) begin
      instr_offloaded_d = 1'b0;
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if(~rst_ni) begin
      // instr_done_q      <= 1'b0;
      instr_inflight_q  <= 1'b0;
      instr_offloaded_q <= 1'b0;
    end else begin
      // instr_done_q      <= instr_done_d;
      instr_inflight_q  <= instr_inflight_d;
      instr_offloaded_q <= instr_offloaded_d;
    end
  end

endmodule : fpu_ss_controller