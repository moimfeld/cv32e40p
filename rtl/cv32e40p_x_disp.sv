// Copyright 2021 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Engineer:       Moritz Imfeld - moimfeld@student.ethz.ch                   //
//                                                                            //
// Design Name:    x-interface dispatcher                                     //
// Project Name:   cv32e40p                                                   //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Dispatcher for sending instructions to the x-interface.    //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module cv32e40p_x_disp
  import cv32e40p_core_v_xif_pkg::*;
(
    // clock and reset
    input logic clk_i,
    input logic rst_ni,

    // scoreboard and dependency check/stall
    input  logic [4:0]      x_waddr_id_i,
    input  logic            x_issue_resp_writeback_i,
    input  logic [4:0]      x_waddr_ex_i,
    input  logic            x_we_ex_i,
    input  logic [4:0]      x_waddr_wb_i,
    input  logic            x_we_wb_i,
    input  logic [4:0]      regfile_waddr_ex_i,
    input  logic            regfile_we_ex_i,
    input  logic [4:0]      x_result_rd_i,
    input  logic            x_result_valid_i,
    input  logic            x_result_we_i,
    input  logic [2:0][4:0] x_rs_addr_i,
    input  logic [2:0]      x_regs_used_i,
    input  logic            x_branch_or_jump_i,
    input  logic            x_data_req_dec_i,
    output logic [2:0]      x_ex_fwd_o,
    output logic [2:0]      x_wb_fwd_o,

    // x-request and response channel signals
    output logic       x_issue_valid_o,
    input  logic       x_issue_ready_i,
    input  logic       x_issue_resp_accept_i,
    input  logic       x_issue_resp_loadstore_i,
    output logic [2:0] x_issue_req_rs_valid_o,
    output logic [3:0] x_issue_req_id_o,
    output logic [1:0] x_issue_req_frs_valid_o,
    output logic [1:0] x_issue_req_mode_o,
    output logic       x_stall_o,
    output logic       x_result_ready_o,

    // commit interface
    output logic       x_commit_valid_o,
    output logic [3:0] x_commit_id_o,
    output logic       x_commit_commit_kill,

    // xmem-request signals
    input  logic          x_mem_valid_i,
    output logic          x_mem_ready_o,
    input  logic [1:0]    x_mem_req_mode_i,  // unused
    input  logic          x_mem_req_spec_i,  // unused
    input  logic          x_mem_req_last_i,  // unused
    output logic          x_mem_resp_exc_o, // hardwired to 0
    output logic [5:0]    x_mem_resp_exccode_o, // hardwired to 0

    // memory request core-internal status signals
    output logic x_mem_data_req_o,
    input  logic x_mem_instr_wb_i,

    // xmem-result signals
    output logic x_mem_result_valid_o,
    output logic x_mem_result_err_o,

    // additional status signals
    input  logic x_illegal_insn_dec_i,
    output logic x_illegal_insn_o,
    input  logic id_ready_i,
    input  logic ex_valid_i,
    input  cv32e40p_pkg::PrivLvl_t current_priv_lvl_i
);

  // scoreboard and status signals
  logic [31:0] scoreboard_q, scoreboard_d;
  logic [ 3:0] id_q, id_d;
  logic instr_offloaded_q, instr_offloaded_d;
  logic [3:0] mem_cnt_q, mem_cnt_d;
  logic dep;
  logic pending_mem_op;

  // core is always ready to receive results from the x-interface
  // Moritz: core might not be always ready anymore since the destination register check is not anymore part of the interface.
  //         So a new destination register clean check has to be done. Could be done before offload, but this might lead to performance regression.
  assign x_result_ready_o = 1'b1;

  // status signal for memory instruction is always 1'b1 since there are no memory access faults
  assign x_mem_result_err_o = 1'b0;

  // hardwire floating-point register valid to 0, according to specifications
  assign x_issue_req_frs_valid_o = '0;

  // hardwire memory exception repsponse signals to 0 because cv32e40p cannot throw memory exceptions
  assign x_mem_resp_exc_o = 1'b0;
  assign x_mem_resp_exccode_o = '0;

  // core is ready to offload instruction when:
  // - an illegal instruction was decoded
  // - there are no pending jumps or branches
  // - the instruction has not already been offloaded
  assign x_issue_valid_o = x_illegal_insn_dec_i & ~x_branch_or_jump_i & ~instr_offloaded_q;

  // commit interface
  // any instruction will be instantly commit after the offload, since the core itself
  // checks for any possible outstanding exceptions. Only when there cannot be any outstanding
  // exceptions in the core, the core will attempt an offload of an unknown instruction.
  assign x_commit_valid_o = x_issue_valid_o;
  assign x_commit_id_o = id_q;
  assign x_commit_commit_kill = 1'b1;

  // core needs to stall when:
  // - there is a pending x-interface handshake
  // - a dependency for a core-internal instruction is detected
  // - there is an offloaded memory instruction pending and the core encounters an internal memory instruction
  // - an illegal instruction was decoded and there are pending jumps or branches
  // - a memory instruction is incoming through the xmem interface while a core-internal instruction is in the decode stage
  assign x_stall_o = (x_issue_valid_o & ~x_issue_ready_i) | dep | (x_illegal_insn_dec_i & (x_branch_or_jump_i)) | (x_mem_valid_i & ~(x_issue_valid_o & x_issue_ready_i)); // Moritz: removed the pending_mem_op signal

  // check validity of source registers and cleanness of destination register:
  // - valid if scoreboard at the index of the source register is clean
  // - valid if there is no active core-internal instruction with the same destination register address as a source register
  // - valid if there is no active memory instruction with the same destination register address as a source register
  assign x_issue_req_rs_valid_o[0] = (~scoreboard_q[x_rs_addr_i[0]] | x_ex_fwd_o[0] | x_wb_fwd_o[0]) & ~(x_rs_addr_i[0] == regfile_waddr_ex_i & regfile_we_ex_i);
  assign x_issue_req_rs_valid_o[1] = (~scoreboard_q[x_rs_addr_i[1]] | x_ex_fwd_o[1] | x_wb_fwd_o[1]) & ~(x_rs_addr_i[1] == regfile_waddr_ex_i & regfile_we_ex_i);
  assign x_issue_req_rs_valid_o[2] = (~scoreboard_q[x_rs_addr_i[2]] | x_ex_fwd_o[2] | x_wb_fwd_o[2]) & ~(x_rs_addr_i[2] == regfile_waddr_ex_i & regfile_we_ex_i);


  // Moritz: unused in the interface
  assign x_rd_clean_o = ~((scoreboard_q[x_waddr_id_i] & ~(x_result_valid_i & (x_waddr_id_i == x_result_rd_i))) | ((x_waddr_id_i == x_waddr_ex_i) & x_we_ex_i) | ((x_waddr_id_i == x_waddr_wb_i) & x_we_wb_i));

  // dependency check
  assign dep = ~x_illegal_insn_o & ((x_regs_used_i[0] & scoreboard_q[x_rs_addr_i[0]]) | (x_regs_used_i[1] & scoreboard_q[x_rs_addr_i[1]]) | (x_regs_used_i[2] & scoreboard_q[x_rs_addr_i[2]]));

  // forwarding
  for (genvar i = 0; i < 3; i++) begin
    always_comb begin
      x_ex_fwd_o[i] = 1'b0;
      if (x_rs_addr_i[i] == x_waddr_ex_i & x_we_ex_i & ex_valid_i) begin
        x_ex_fwd_o[i] = 1'b1;
      end
    end
  end

  for (genvar i = 0; i < 3; i++) begin
    always_comb begin
      x_wb_fwd_o[i] = 1'b0;
      if (x_rs_addr_i[i] == x_waddr_wb_i & x_we_wb_i & ex_valid_i) begin
        x_wb_fwd_o[i] = 1'b1;
      end
    end
  end

  // id generation
  assign x_issue_req_id_o = id_q;
  always_comb begin
    id_d = id_q;
    if (x_issue_valid_o & x_issue_ready_i) begin
      id_d = id_q + 4'b0001;
    end
  end

  // Assign mode according to PrivLvl_t
  always_comb begin
    x_issue_req_mode_o = 2'b11;
    case (current_priv_lvl_i)
      cv32e40p_pkg::PRIV_LVL_M: x_issue_req_mode_o = 2'b11;
      cv32e40p_pkg::PRIV_LVL_H: x_issue_req_mode_o = 2'b10;
      cv32e40p_pkg::PRIV_LVL_S: x_issue_req_mode_o = 2'b01;
      cv32e40p_pkg::PRIV_LVL_U: x_issue_req_mode_o = 2'b00;
      default:    x_issue_req_mode_o = 2'b11;
    endcase
  end

  // scoreboard update
  always_comb begin
    scoreboard_d = scoreboard_q;
    if (x_issue_resp_writeback_i & x_issue_valid_o & x_issue_ready_i & ~((x_waddr_id_i == x_result_rd_i) & x_result_valid_i & x_result_rd_i)) begin  // update rule for outgoing instructions
      scoreboard_d[x_waddr_id_i] = 1'b1;
    end
    if (x_result_valid_i & x_result_we_i) begin  // update rule for successful writebacks
      scoreboard_d[x_result_rd_i] = 1'b0;
    end
  end

  // status signal that indicates if an instruction has already been offloaded
  always_comb begin
    instr_offloaded_d = instr_offloaded_q;
    if (id_ready_i) begin
      instr_offloaded_d = 1'b0;
    end else if (x_issue_valid_o & x_issue_ready_i) begin
      instr_offloaded_d = 1'b1;
    end
  end

  // illegal instruction assertion according to x-interface specs
  always_comb begin
    x_illegal_insn_o = 1'b0;
    if (x_issue_valid_o & x_issue_ready_i & ~x_issue_resp_accept_i) begin
      x_illegal_insn_o = 1'b1;
    end
  end

  // memory instruction request handling
  always_comb begin
    x_mem_data_req_o = 1'b0;
    x_mem_ready_o    = 1'b0;
    if (x_mem_valid_i) begin
      x_mem_data_req_o = 1'b1;
      x_mem_ready_o    = 1'b1;
    end
  end

  // memory instruction response handshake
  always_comb begin
    x_mem_result_valid_o = 1'b0;
    if (x_mem_instr_wb_i) begin
      x_mem_result_valid_o = 1'b1;
    end
  end

  // check if the core wants to execute a memory instruction while there is still an offloaded memory instruction pending
  // Moritz: unnecessary
  always_comb begin
    pending_mem_op = 1'b0;
    if (x_data_req_dec_i & (mem_cnt_q != 4'b0000)) begin
      pending_mem_op = 1'b1;
    end
  end

  // count number of pending memory instructions
  // Moritz: unnecessary
  always_comb begin
    mem_cnt_d = mem_cnt_q;
    if (x_issue_valid_o & x_issue_ready_i & x_issue_resp_loadstore_i & ~x_mem_valid_i) begin
      mem_cnt_d = mem_cnt_q + 4'b0001;
    end else if (~(x_issue_valid_o & x_issue_ready_i & x_issue_resp_loadstore_i) & x_mem_valid_i & mem_cnt_q != 4'b0000) begin
      mem_cnt_d = mem_cnt_q - 4'b0001;
    end
  end

  // scoreboard and status signal register
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      scoreboard_q      <= 32'b0;
      instr_offloaded_q <= 1'b0;
      mem_cnt_q         <= 4'b0;
      id_q              <= 4'b0;
    end else begin
      scoreboard_q      <= scoreboard_d;
      instr_offloaded_q <= instr_offloaded_d;
      mem_cnt_q         <= mem_cnt_d;
      id_q              <= id_d;
    end
  end

endmodule : cv32e40p_x_disp
