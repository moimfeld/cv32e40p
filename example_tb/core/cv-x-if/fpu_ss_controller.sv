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

module fpu_ss_controller
    import cv32e40p_core_v_xif_pkg::*;
#(
    parameter INT_REG_WB_DELAY = 1,
    parameter OUT_OF_ORDER = 1,
    parameter FORWARDING = 1
) (
    // clock and reset
    input logic clk_i,
    input logic rst_ni,

    // commit interface
    input  logic       x_commit_valid_i,
    input  x_commit_t  x_commit_i,

    // buffer pop handshake
    input  logic in_buf_pop_valid_i,
    output logic in_buf_pop_ready_o,
    input  logic fpu_busy_i,
    input  logic use_fpu_i,

    output logic                      mem_push_valid_o,
    input  logic                      mem_push_ready_i,
    input  logic                      mem_pop_valid_i,
    output logic                      mem_pop_ready_o,
    input  fpu_ss_pkg::mem_metadata_t mem_pop_i,

    // FPnew input handshake
    output logic       fpu_in_valid_o,
    input  logic       fpu_in_ready_i,
    input  logic [3:0] fpu_in_id_i,

    // FPnew output handshake
    input  logic fpu_out_valid_i,
    output logic fpu_out_ready_o,

    // register Write enable and id
    input  logic       rd_is_fp_i,
    input  logic [4:0] fpr_wb_addr_i,
    input  logic [4:0] rd_i,
    output logic       fpr_we_o,
    input  logic [3:0] fpu_out_id_i,

    // c-response handshake
    input  logic x_result_ready_i,
    output logic x_result_valid_o,
    input  logic csr_wb_i,
    input  logic csr_instr_i,

    // dependency check
    input  logic                         rd_in_is_fp_i,
    input  logic                   [4:0] rs1_i,
    input  logic                   [4:0] rs2_i,
    input  logic                   [4:0] rs3_i,
    output logic                   [2:0] fwd_o,
    input  fpu_ss_pkg::op_select_e [2:0] op_select_i,

    // memory instruction handling
    input logic is_load_i,
    input logic is_store_i,

    // request Handshake
    output logic x_mem_valid_o,
    input  logic x_mem_ready_i,
    output logic x_mem_req_we_o,
    output logic x_mem_req_spec_o,
    output logic x_mem_req_last_o,

    // response handshake
    input  logic x_mem_result_valid_i,
    input  logic x_mem_result_err_i, // unused

    // additional signals
    output logic int_wb_o
);

  // status signals
  logic instr_inflight_d;
  logic instr_inflight_q;
  logic instr_offloaded_d;
  logic instr_offloaded_q;

  // rd scoreboard
  logic [31:0] rd_scoreboard_d;
  logic [31:0] rd_scoreboard_q;

  // id scoreboard
  logic [15:0] id_scoreboard_d;
  logic [15:0] id_scoreboard_q;

  // dependencies
  logic dep_rs1;
  logic dep_rs2;
  logic dep_rs3;
  logic dep_rs;
  logic dep_rd;

  // INT_REG_WB_DELAY signals
  logic [INT_REG_WB_DELAY:0] delay_reg_d;
  logic [INT_REG_WB_DELAY:0] delay_reg_q;

  // handshakes
  logic x_result_hs;
  logic x_mem_req_hs;

  assign x_result_hs = x_result_ready_i & x_result_valid_o;
  assign x_mem_req_spec_o = 1'b0;  // no speculative memory operations -> hardwire to 0

  assign fpu_out_ready_o = ~x_mem_result_valid_i;  // only don't accept writebacks from the FPnew when a memory instruction writes back to the fp register file
  assign x_mem_req_hs = x_mem_valid_o & x_mem_ready_i;

  // dependency check (used to avoid data hazards)
  assign dep_rs1 = rd_scoreboard_q[rs1_i] & in_buf_pop_valid_i & (op_select_i[0] == fpu_ss_pkg::RegA | op_select_i[1] == fpu_ss_pkg::RegA | op_select_i[2] == fpu_ss_pkg::RegA);
  assign dep_rs2 = rd_scoreboard_q[rs2_i] & in_buf_pop_valid_i & (op_select_i[0] == fpu_ss_pkg::RegB | op_select_i[1] == fpu_ss_pkg::RegB | op_select_i[2] == fpu_ss_pkg::RegB);
  assign dep_rs3 = rd_scoreboard_q[rs3_i] & in_buf_pop_valid_i & (op_select_i[0] == fpu_ss_pkg::RegC | op_select_i[1] == fpu_ss_pkg::RegC | op_select_i[2] == fpu_ss_pkg::RegC);
  assign dep_rs = (dep_rs1 & ~fwd_o[0]) | (dep_rs2 & ~fwd_o[1]) | (dep_rs3 & ~fwd_o[2]);
  assign dep_rd = rd_scoreboard_q[rd_i] & rd_in_is_fp_i & ~(fpu_out_valid_i & fpu_out_ready_o & rd_is_fp_i & (fpr_wb_addr_i == rd_i));

  // integer writeback delay assignement
  assign int_wb_o = delay_reg_q[INT_REG_WB_DELAY];

  // memory buffer controll logic
  assign mem_push_valid_o = x_mem_req_hs;
  assign mem_pop_ready_o = x_mem_result_valid_i;

  // forwarding
  always_comb begin
    fwd_o[0] = 1'b0;
    fwd_o[1] = 1'b0;
    fwd_o[2] = 1'b0;
    if (FORWARDING) begin
      fwd_o[0] = dep_rs1 & fpu_out_valid_i & rd_is_fp_i & rs1_i == fpr_wb_addr_i;
      fwd_o[1] = dep_rs2 & fpu_out_valid_i & rd_is_fp_i & rs2_i == fpr_wb_addr_i;
      fwd_o[2] = dep_rs3 & fpu_out_valid_i & rd_is_fp_i & rs3_i == fpr_wb_addr_i;
    end
  end

  // pop instruction
  always_comb begin
    in_buf_pop_ready_o = 1'b0;
    if ((fpu_in_valid_o & fpu_in_ready_i) | (x_result_hs & int_wb_o) | x_mem_req_hs) begin
      in_buf_pop_ready_o = 1'b1;
    end
  end

  // assert fpu_in_valid_o
  // - when instr uses fpu
  // - when there are no dependencies
  // - when fifo is NOT empty
  // Note: out-of-order execution is enabled/disabled here
  always_comb begin
    fpu_in_valid_o = 1'b0;
    if (use_fpu_i & in_buf_pop_valid_i & (id_scoreboard_q[fpu_in_id_i] | ((x_commit_i.id == fpu_in_id_i) & x_commit_i.commit_kill)) & ~dep_rs & ~dep_rd & OUT_OF_ORDER) begin
      fpu_in_valid_o = 1'b1;
    end else if (use_fpu_i  & in_buf_pop_valid_i & (id_scoreboard_q[fpu_in_id_i] | ((x_commit_i.id == fpu_in_id_i) & x_commit_i.commit_kill)) & ~dep_rs & ~dep_rd & (fpu_out_valid_i | ~instr_inflight_q) & ~OUT_OF_ORDER) begin
      fpu_in_valid_o = 1'b1;
    end
  end

  // assert fpr_we_o
  // - when fpu has a valid output and When rd is a fp register
  // - when instruction is load and there is a valid memory result
  always_comb begin
    fpr_we_o = 1'b0;
    if ((fpu_out_valid_i & rd_is_fp_i) | (mem_pop_i.we & x_mem_result_valid_i)) begin
      fpr_we_o = 1'b1;
    end
  end

  // assert x_mem_req_last_o
  // - every memory only does a single memory access
  always_comb begin
    x_mem_req_last_o = 1'b0;
    if (x_mem_valid_o) begin
      x_mem_req_last_o = 1'b1;
    end
  end

  // assert x_result_valid_o
  // - when fpu_out_valid_i is high
  // - when int_wb is high (int_wb controlls integer register writebacks of instructions that do not go though the fpu (e.g. csr))
  always_comb begin
    x_result_valid_o = 1'b0;
    if (fpu_out_valid_i | int_wb_o) begin
      x_result_valid_o = 1'b1;
    end
  end

  // assert x_mem_valid_o (load/store offload to the core)
  // - when the current instruction is a load/store instruction
  // - when the fifo is NOT empty
  // - when the instruction has NOT already been offloaded back to the core (instr_offloaded_q signal)
  always_comb begin
    x_mem_valid_o = 1'b0;
    if ((is_load_i | is_store_i) & ~dep_rs & ~dep_rd & in_buf_pop_valid_i) begin
      x_mem_valid_o = 1'b1;
    end
  end

  // assert write enable signal
  always_comb begin
    x_mem_req_we_o = 1'b0;
    if (is_store_i) begin
      x_mem_req_we_o = 1'b1;
    end
  end

  // update for the instr_inflight status signal
  always_comb begin
    instr_inflight_d = instr_inflight_q;
    if ((fpu_out_valid_i & fpu_out_ready_o) & ~fpu_in_valid_o) begin
      instr_inflight_d = 1'b0;
    end else if (fpu_in_valid_o) begin
      instr_inflight_d = 1'b1;
    end
  end

  // update for the instr_offloaded status signal
  always_comb begin
    instr_offloaded_d = instr_offloaded_q;
    if (in_buf_pop_valid_i & x_mem_req_hs) begin
      instr_offloaded_d = 1'b1;
    end else if (x_mem_result_valid_i) begin
      instr_offloaded_d = 1'b0;
    end
  end

  // update for the rd scoreboard
  always_comb begin
    rd_scoreboard_d = rd_scoreboard_q;
    if ((fpu_in_valid_o & fpu_in_ready_i & rd_in_is_fp_i) | (x_mem_req_hs & is_load_i)) begin
      rd_scoreboard_d[rd_i] = 1'b1;
    end
    if ((fpu_out_ready_o & fpu_out_valid_i) & ~(fpu_in_valid_o & fpu_in_ready_i & fpr_wb_addr_i == rd_i)) begin
      rd_scoreboard_d[fpr_wb_addr_i] = 1'b0;
    end else if (x_mem_result_valid_i & mem_pop_i.we) begin
      rd_scoreboard_d[mem_pop_i.rd] = 1'b0;
    end
  end

  // update for the id scoreboard
  always_comb begin
    id_scoreboard_d = id_scoreboard_q;
    if (x_commit_valid_i & x_commit_i.commit_kill) begin
      id_scoreboard_d[x_commit_i.id] = 1'b1;
    end
    if (fpu_out_ready_o & fpu_out_valid_i) begin
      id_scoreboard_d[fpu_out_id_i] = 1'b0;
    end
  end

  // status signal register
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      instr_inflight_q  <= 1'b0;
      instr_offloaded_q <= 1'b0;
      rd_scoreboard_q   <= '0;
      id_scoreboard_q   <= '0;
    end else begin
      instr_inflight_q  <= instr_inflight_d;
      instr_offloaded_q <= instr_offloaded_d;
      rd_scoreboard_q   <= rd_scoreboard_d;
      id_scoreboard_q   <= id_scoreboard_d;
    end
  end

  // start integer delay when:
  // - when there is a csr instruction
  // - when there is an instruction that does not use the fpu, does write back to an integer register and is not a load or store
  always_comb begin
    delay_reg_q[0] = 1'b0;
    if (in_buf_pop_valid_i & (csr_instr_i | (~use_fpu_i & ~is_load_i & ~is_store_i))) begin
      delay_reg_q[0] = 1'b1;
    end
  end

  // register array that delays integer writebacks which do not go through the fpu
  // - this can be used to break the critical path of instructions that would otherwise write back to the core
  //   in the same cycle as they were offloaded
  for (genvar i = 0; i < INT_REG_WB_DELAY; i++) begin
    always_comb begin
      delay_reg_d[i+1] = delay_reg_q[i];
      if (~delay_reg_q[0] | in_buf_pop_ready_o | fpu_busy_i | fpu_out_valid_i | is_load_i | is_store_i | ~in_buf_pop_valid_i) begin
        delay_reg_d[i+1] = 1'b0;
      end
    end

    always_ff @(posedge clk_i, negedge rst_ni) begin
      if (~rst_ni) begin
        delay_reg_q[i+1] <= '0;
      end else begin
        delay_reg_q[i+1] <= delay_reg_d[i+1];
      end
    end
  end

endmodule : fpu_ss_controller
