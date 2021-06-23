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
    // Clock and Reset
    input logic clk_i,
    input logic rst_ni,

    input logic x_illegal_insn_dec_i,

    // Scoreboard & Dependency Check & Stall
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
    input logic            x_branch_taken_ex_i,
    input logic            x_load_stall_i,
    input logic            x_ex_valid_i,
    input logic            x_data_req_dec_i,

    // X-Request and Response Channel Signals
    output logic       x_valid_o,
    input  logic       x_ready_i,
    input  logic       x_accept_i,
    input  logic       x_is_mem_op_i,
    output logic [2:0] x_rs_valid_o,
    output logic       x_rd_clean_o,
    output logic       x_stall_o,
    output logic       x_illegal_insn_o,
    output logic       x_rready_o,

    // Xmem-Request signals
    input  logic          xmem_valid_i,
    output logic          xmem_ready_o,
    input  mem_req_type_e xmem_req_type_i,
    input  logic          xmem_mode_i,  // unused
    input  logic          xmem_spec_i,  // unused
    input  logic          xmem_endoftransaction_i,

    // Memory instruction status signals
    output logic xmem_data_req_o,
    output logic xmem_we_o,
    input  logic xmem_instr_wb_i,

    // Xmem-Response signals
    output logic xmem_rvalid_o,
    input  logic xmem_rready_i,
    output logic xmem_status_o,

    input logic id_ready_i,
    input logic data_req_ex_i
);

  // Scoreboard and status signals
  logic [31:0] scoreboard_q, scoreboard_d;
  logic instr_offloaded_q, instr_offloaded_d;
  logic mem_wb_complete_q, mem_wb_complete_d;
  logic [3:0] mem_cnt_q, mem_cnt_d;
  logic dep;
  logic outstanding_mem_op;

  // Core is always ready to receive returning fp instruction results
  assign x_rready_o = 1'b1;

  // Status for memory instruction is always 1'b1 since there are no memory access faults
  assign xmem_status_o = 1'b1;

  // core is ready to offload instruction when:
  // - an illegal instruction was decoded
  // - there are no outstanding jumps or branches
  // - the branch was not taken
  // - if there is no load stall
  // - the instruction has not already been offloaded
  assign x_valid_o = x_illegal_insn_dec_i & ~x_branch_or_jump_i & ~x_branch_taken_ex_i & ~x_load_stall_i & ~instr_offloaded_q;

  // core needs to stall when:
  // - there is an outstanding x-interface handshake
  // - a dependency is detected
  // - when a offloaded memory instruction is ongoing
  // - an illegal instruction was decoded and:
  //     - there are outstanding jumps or branches
  //     - if there is a load stall
  assign x_stall_o = (x_valid_o & ~x_ready_i) | dep | outstanding_mem_op | (x_illegal_insn_dec_i & (x_branch_or_jump_i | x_load_stall_i));// | (xmem_valid_i & ~(x_valid_o & x_ready_i));// | (x_is_mem_op_i & ~(xmem_rvalid_o & xmem_rready_i));

  // Check validity of source registers and cleanness of destination register:
  // - valid if scoreboard at the index of the source register is clean
  // - valid if there is no active core side instruction currently writing back to the source register (if x_ex_valid_i is high the instruction is done and the result will be forwarded)
  // - valid if there is no memory instruction writing back to the source register (if x_ex_valid_i is high the instruction is done and the result will be forwarded)
  assign x_rs_valid_o[0] = ~(scoreboard_q[x_rs_addr_i[0]] | ((x_rs_addr_i[0] == x_waddr_ex_i) & x_we_ex_i & ~x_ex_valid_i) | ((x_rs_addr_i[0] == x_waddr_wb_i) & x_we_wb_i & ~x_ex_valid_i));
  assign x_rs_valid_o[1] = ~(scoreboard_q[x_rs_addr_i[1]] | ((x_rs_addr_i[1] == x_waddr_ex_i) & x_we_ex_i & ~x_ex_valid_i) | ((x_rs_addr_i[1] == x_waddr_wb_i) & x_we_wb_i & ~x_ex_valid_i));
  assign x_rs_valid_o[2] = ~(scoreboard_q[x_rs_addr_i[2]] | ((x_rs_addr_i[2] == x_waddr_ex_i) & x_we_ex_i & ~x_ex_valid_i) | ((x_rs_addr_i[2] == x_waddr_wb_i) & x_we_wb_i & ~x_ex_valid_i));
  assign x_rd_clean_o = ~((scoreboard_q[x_waddr_id_i]) | ((x_waddr_id_i == x_waddr_ex_i) & x_we_ex_i) | ((x_waddr_id_i == x_waddr_wb_i) & x_we_wb_i));

  // Dependency check
  assign dep = ~x_illegal_insn_o & ((x_regs_used_i[0] & scoreboard_q[x_rs_addr_i[0]]) | (x_regs_used_i[1] & scoreboard_q[x_rs_addr_i[1]]) | (x_regs_used_i[2] & scoreboard_q[x_rs_addr_i[2]]));

  always_comb begin
    outstanding_mem_op = 1'b0;
    if (x_data_req_dec_i & (mem_cnt_q != 4'b0000)) begin
      outstanding_mem_op = 1'b1;
    end
  end

  // Illegal instruction assertion according to x-interface specs
  always_comb begin
    x_illegal_insn_o = 1'b0;
    if (x_valid_o & x_ready_i & ~x_accept_i) begin
      x_illegal_insn_o = 1'b1;
    end
  end

  // Memory instruction request handling
  always_comb begin
    xmem_data_req_o = 1'b0;
    xmem_ready_o    = 1'b0;
    if (xmem_valid_i) begin
      xmem_data_req_o = 1'b1;
      xmem_ready_o    = 1'b1;
    end
  end

  // Memory instrcution write enable signal
  always_comb begin
    xmem_we_o = 1'b0;
    if ((xmem_req_type_i == WRITE) & xmem_valid_i) begin
      xmem_we_o = 1'b1;
    end
  end

  // Memory instruction response handshake
  always_comb begin
    xmem_rvalid_o = 1'b0;
    if (xmem_instr_wb_i & ~mem_wb_complete_q) begin
      xmem_rvalid_o = 1'b1;
    end
  end

  // Scoreboard update (only destination registers with writeback mark the scoreboard)
  always_comb begin
    scoreboard_d = scoreboard_q;
    if (x_writeback_i & (x_valid_o & x_ready_i) & ~((x_waddr_id_i == x_rwaddr_i) & x_rvalid_i)) begin  // Update rule for outgoing instructions
      scoreboard_d[x_waddr_id_i] = 1'b1;
    end
    if(x_rvalid_i | (~x_writeback_i & ~x_illegal_insn_dec_i)) begin // Update rule for successful writebacks
      scoreboard_d[x_rwaddr_i] = 1'b0;
    end
  end

  // Status signal which indicates if an instruction has already been offloaded
  always_comb begin
    instr_offloaded_d = instr_offloaded_q;
    if (id_ready_i) begin
      instr_offloaded_d = 1'b0;
    end else if (x_valid_o & x_ready_i) begin
      instr_offloaded_d = 1'b1;
    end
  end

  // Status signal that is high when a memory instruction writeback (to the accelerator) has been completed
  always_comb begin
    mem_wb_complete_d = mem_wb_complete_q;
    if (xmem_rvalid_o & xmem_rready_i) begin
      mem_wb_complete_d = 1'b1;
    end else if (xmem_ready_o & xmem_valid_i) begin
      mem_wb_complete_d = 1'b0;
    end
  end

  // Count of outstanding memory instructions
  always_comb begin
    mem_cnt_d = mem_cnt_q;
    if (x_valid_o & x_ready_i & x_is_mem_op_i & ~xmem_valid_i) begin
      mem_cnt_d = mem_cnt_q + 4'b0001;
    end else if (~(x_valid_o & x_ready_i & x_is_mem_op_i) & xmem_valid_i) begin
      mem_cnt_d = mem_cnt_q - 4'b0001;
    end
  end

  // Scoreboard and status signal register
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

  // some measurements
  int outstanding_mem_op_stall;
  initial begin
    outstanding_mem_op_stall = 0;
  end

  cover property (@(posedge clk_i) outstanding_mem_op) begin
    outstanding_mem_op_stall = outstanding_mem_op_stall + 1;
    $display("Number of outstanding_mem_op_stall %d \n", outstanding_mem_op_stall);
  end
  ;

endmodule : cv32e40p_x_disp
