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
  import cv32e40p_x_if_pkg::*;
(
    // clock and reset
    input logic clk_i,
    input logic rst_ni,

    // scoreboard and dependency check/stall
    input logic [4:0]      x_waddr_id_i,
    input logic            x_writeback_i,
    input logic [4:0]      x_waddr_ex_i,
    input logic            x_we_ex_i,
    input logic [4:0]      x_waddr_wb_i,
    input logic            x_we_wb_i,
    input logic [4:0]      x_rwaddr_i,
    input logic            x_rvalid_i,
    input logic [2:0][4:0] x_rs_addr_i,
    input logic [2:0]      x_regs_used_i,
    input logic            x_branch_or_jump_i,
    input logic            x_data_req_dec_i,

    // x-request and response channel signals
    output logic       x_valid_o,
    input  logic       x_ready_i,
    input  logic       x_accept_i,
    input  logic       x_is_mem_op_i,
    output logic [2:0] x_rs_valid_o,
    output logic       x_rd_clean_o,
    output logic       x_stall_o,
    output logic       x_rready_o,

    // xmem-request signals
    input  logic          xmem_valid_i,
    output logic          xmem_ready_o,
    input  mem_req_type_e xmem_req_type_i,
    input  logic          xmem_mode_i,  // unused
    input  logic          xmem_spec_i,  // unused
    input  logic          xmem_endoftransaction_i,  // unused

    // memory request core-internal status signals
    output logic xmem_data_req_o,
    output logic xmem_we_o,
    input  logic xmem_instr_wb_i,

    // xmem-response signals
    output logic xmem_rvalid_o,
    input  logic xmem_rready_i,
    output logic xmem_status_o,

    // additional status signals
    input  logic x_illegal_insn_dec_i,
    output logic x_illegal_insn_o,
    input  logic id_ready_i
);

  // scoreboard and status signals
  logic [31:0] scoreboard_q, scoreboard_d;
  logic instr_offloaded_q, instr_offloaded_d;
  logic mem_wb_complete_q, mem_wb_complete_d;
  logic [3:0] mem_cnt_q, mem_cnt_d;
  logic dep;
  logic pending_mem_op;

  // core is always ready to receive results from the x-interface
  assign x_rready_o = 1'b1;

  // status signal for memory instruction is always 1'b1 since there are no memory access faults
  assign xmem_status_o = 1'b1;

  // core is ready to offload instruction when:
  // - an illegal instruction was decoded
  // - there are no pending jumps or branches
  // - the instruction has not already been offloaded
  assign x_valid_o = x_illegal_insn_dec_i & ~x_branch_or_jump_i & ~instr_offloaded_q;

  // core needs to stall when:
  // - there is a pending x-interface handshake
  // - a dependency for a core-internal instruction is detected
  // - there is an offloaded memory instruction pending and the core encounters an internal memory instruction
  // - an illegal instruction was decoded and there are pending jumps or branches
  // - a memory instruction is incoming through the xmem interface while a core-internal instruction is in the decode stage
  assign x_stall_o = (x_valid_o & ~x_ready_i) | dep | pending_mem_op | (x_illegal_insn_dec_i & (x_branch_or_jump_i)) | (xmem_valid_i & ~(x_valid_o & x_ready_i));

  // check validity of source registers and cleanness of destination register:
  // - valid if scoreboard at the index of the source register is clean
  // - valid if there is no active core-internal instruction with the same destination register address as a source register
  // - valid if there is no active memory instruction with the same destination register address as a source register
  assign x_rs_valid_o[0] = ~(scoreboard_q[x_rs_addr_i[0]] | ((x_rs_addr_i[0] == x_waddr_ex_i) & x_we_ex_i) | ((x_rs_addr_i[0] == x_waddr_wb_i) & x_we_wb_i));
  assign x_rs_valid_o[1] = ~(scoreboard_q[x_rs_addr_i[1]] | ((x_rs_addr_i[1] == x_waddr_ex_i) & x_we_ex_i) | ((x_rs_addr_i[1] == x_waddr_wb_i) & x_we_wb_i));
  assign x_rs_valid_o[2] = ~(scoreboard_q[x_rs_addr_i[2]] | ((x_rs_addr_i[2] == x_waddr_ex_i) & x_we_ex_i) | ((x_rs_addr_i[2] == x_waddr_wb_i) & x_we_wb_i));
  assign x_rd_clean_o = ~((scoreboard_q[x_waddr_id_i] & ~(x_rvalid_i & (x_waddr_id_i == x_rwaddr_i))) | ((x_waddr_id_i == x_waddr_ex_i) & x_we_ex_i) | ((x_waddr_id_i == x_waddr_wb_i) & x_we_wb_i));

  // dependency check
  assign dep = ~x_illegal_insn_o & ((x_regs_used_i[0] & scoreboard_q[x_rs_addr_i[0]]) | (x_regs_used_i[1] & scoreboard_q[x_rs_addr_i[1]]) | (x_regs_used_i[2] & scoreboard_q[x_rs_addr_i[2]]));

  // scoreboard update
  always_comb begin
    scoreboard_d = scoreboard_q;
    if (x_writeback_i & x_valid_o & x_ready_i & ~((x_waddr_id_i == x_rwaddr_i) & x_rvalid_i)) begin  // update rule for outgoing instructions
      scoreboard_d[x_waddr_id_i] = 1'b1;
    end
    if (x_rvalid_i) begin  // update rule for successful writebacks
      scoreboard_d[x_rwaddr_i] = 1'b0;
    end
  end

  // status signal that indicates if an instruction has already been offloaded
  always_comb begin
    instr_offloaded_d = instr_offloaded_q;
    if (id_ready_i) begin
      instr_offloaded_d = 1'b0;
    end else if (x_valid_o & x_ready_i) begin
      instr_offloaded_d = 1'b1;
    end
  end

  // illegal instruction assertion according to x-interface specs
  always_comb begin
    x_illegal_insn_o = 1'b0;
    if (x_valid_o & x_ready_i & ~x_accept_i) begin
      x_illegal_insn_o = 1'b1;
    end
  end

  // memory instruction request handling
  always_comb begin
    xmem_data_req_o = 1'b0;
    xmem_ready_o    = 1'b0;
    if (xmem_valid_i) begin
      xmem_data_req_o = 1'b1;
      xmem_ready_o    = 1'b1;
    end
  end

  // memory instrcution write enable signal
  always_comb begin
    xmem_we_o = 1'b0;
    if ((xmem_req_type_i == WRITE) & xmem_valid_i) begin
      xmem_we_o = 1'b1;
    end
  end

  // memory instruction response handshake
  always_comb begin
    xmem_rvalid_o = 1'b0;
    if (xmem_instr_wb_i & ~mem_wb_complete_q) begin
      xmem_rvalid_o = 1'b1;
    end
  end


  // status signal that is asserted when a memory instruction writeback (to an accelerator) has completed
  always_comb begin
    mem_wb_complete_d = mem_wb_complete_q;
    if (xmem_rvalid_o & xmem_rready_i) begin
      mem_wb_complete_d = 1'b1;
    end else if (xmem_ready_o & xmem_valid_i) begin
      mem_wb_complete_d = 1'b0;
    end
  end

  // check if the core wants to execute a memory instruction while there is still an offloaded memory instruction pending
  always_comb begin
    pending_mem_op = 1'b0;
    if (x_data_req_dec_i & (mem_cnt_q != 4'b0000)) begin
      pending_mem_op = 1'b1;
    end
  end

  // count number of pending memory instructions
  always_comb begin
    mem_cnt_d = mem_cnt_q;
    if (x_valid_o & x_ready_i & x_is_mem_op_i & ~xmem_valid_i) begin
      mem_cnt_d = mem_cnt_q + 4'b0001;
    end else if (~(x_valid_o & x_ready_i & x_is_mem_op_i) & xmem_valid_i) begin
      mem_cnt_d = mem_cnt_q - 4'b0001;
    end
  end

  // scoreboard and status signal register
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      scoreboard_q      <= 32'b0;
      instr_offloaded_q <= 1'b0;
      mem_wb_complete_q <= 1'b0;
      mem_cnt_q         <= 4'b0;
    end else begin
      scoreboard_q      <= scoreboard_d;
      instr_offloaded_q <= instr_offloaded_d;
      mem_wb_complete_q <= mem_wb_complete_d;
      mem_cnt_q         <= mem_cnt_d;
    end
  end

endmodule : cv32e40p_x_disp
