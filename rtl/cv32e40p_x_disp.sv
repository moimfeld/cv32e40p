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

    // Scoreboard & Dependency Check
    input logic [4:0]      x_waddr_id_i,
    input logic            x_writeback_i,
    input logic [4:0]      x_waddr_ex_i,
    input logic            x_we_ex_i,
    input logic [4:0]      x_waddr_wb_i,
    input logic            x_we_wb_i,
    input logic [4:0]      x_rwaddr_i,
    input logic            x_rvalid_i,
    input logic [2:0][4:0] x_rs_addr_i,
    input logic [2:0]      x_regs_used_i,  // assumption, that when illegal instruction is decoded, x_regs_used_i is = 3'b000
    input logic            x_branch_or_jump_i,

    output logic       x_valid_o,
    input  logic       x_ready_i,
    input  logic       x_accept_i,
    input  logic       x_is_mem_op_i,
    output logic [2:0] x_rs_valid_o,
    output logic       x_rd_clean_o,
    output logic       x_stall_o,
    output logic       x_illegal_insn_o,

    output logic       x_rready_o,

    input  logic          xmem_valid_i,
    output logic          xmem_ready_o,
    input  mem_req_type_e xmem_req_type_i,
    input  logic          xmem_mode_i, // unused
    input  logic          xmem_spec_i, // unused
    input  logic          xmem_endoftransaction_i,

    output logic                       xmem_data_req_o,
    output logic                       xmem_we_o,
    input  logic                       xmem_instr_wb_i,

    output logic                       xmem_rvalid_o,
    input  logic                       xmem_rready_i,
    output logic                       xmem_status_o,

    input  logic                       id_ready_i,
    input  logic                       data_req_ex_i
);

  logic [31:0] scoreboard_q, scoreboard_d;
  logic instr_offloaded_q, instr_offloaded_d;
  logic mem_wb_complete_q, mem_wb_complete_d;
  logic dep;

  // Core is always ready to receive returning fp instruction results
  assign x_rready_o = 1'b1;

  // Core is always ready to receive memory requests from the accelerator
  // assign xmem_ready_o = 1'b1;

  // Status for memory instruction is always 1'b1 since there are no memory access faults
  assign xmem_status_o = 1'b1;

  // One should be sure to encounter no branches before setting x_valid_o to high
  assign x_valid_o = x_illegal_insn_dec_i & ~x_branch_or_jump_i & ~instr_offloaded_q;
  assign x_stall_o = (x_valid_o & ~x_ready_i) | dep | (x_is_mem_op_i & ~xmem_rvalid_o);

  // Offload handshake
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
    if (xmem_valid_i & ~data_req_ex_i) begin
      xmem_data_req_o = 1'b1;
      xmem_ready_o    = 1'b1;
    end
  end

  // Memory instruction response handshake
  always_comb begin
    xmem_rvalid_o = 1'b0;
    if (xmem_instr_wb_i & ~mem_wb_complete_q) begin
      xmem_rvalid_o = 1'b1;
    end
  end

  always_comb begin
    xmem_we_o = 1'b0;
    if ((xmem_req_type_i == WRITE) & xmem_valid_i) begin
      xmem_we_o = 1'b1;
    end
  end

  // Dependency check
  always_comb begin
    // Check if scoreboard is clean and if there are no outstanding writebacks in the ex- or id-stage
    x_rs_valid_o[0] = ~(scoreboard_q[x_rs_addr_i[0]] | ((x_rs_addr_i[0] == x_waddr_ex_i) & x_we_ex_i) | ((x_rs_addr_i[0] == x_waddr_wb_i) & x_we_wb_i));
    x_rs_valid_o[1] = ~(scoreboard_q[x_rs_addr_i[1]] | ((x_rs_addr_i[1] == x_waddr_ex_i) & x_we_ex_i) | ((x_rs_addr_i[1] == x_waddr_wb_i) & x_we_wb_i));
    x_rs_valid_o[2] = ~(scoreboard_q[x_rs_addr_i[2]] | ((x_rs_addr_i[2] == x_waddr_ex_i) & x_we_ex_i) | ((x_rs_addr_i[2] == x_waddr_wb_i) & x_we_wb_i));
    x_rd_clean_o = ~((scoreboard_q[x_waddr_id_i]) | ((x_waddr_id_i == x_waddr_ex_i) & x_we_ex_i) | ((x_waddr_id_i == x_waddr_wb_i) & x_we_wb_i));
    // Check if scoreboard is clean for any instruction that stays in the core
    dep = ((x_regs_used_i[0] & scoreboard_q[x_rs_addr_i[0]]) | (x_regs_used_i[1] & scoreboard_q[x_rs_addr_i[1]]) | (x_regs_used_i[2] & scoreboard_q[x_rs_addr_i[2]]));
  end

  // scoreboard with only the offloaded instructions
  always_comb begin
    scoreboard_d = scoreboard_q;
    if (x_writeback_i & x_illegal_insn_dec_i & x_valid_o & x_ready_i) begin  // update rule for outgoing instructions
      scoreboard_d[x_waddr_id_i] = 1'b1;
    end
    if(x_rvalid_i | (~x_writeback_i & ~x_illegal_insn_dec_i)) begin // update rule for successful writebacks
      scoreboard_d[x_rwaddr_i] = 1'b0;
    end
  end

  // update register that keeps track of already offloaded instructions
  always_comb begin
    instr_offloaded_d = instr_offloaded_q;
    if (id_ready_i) begin
      instr_offloaded_d = 1'b0;
    end else if (x_valid_o & x_ready_i) begin
      instr_offloaded_d = 1'b1;
    end
  end

  // update register that keeps completed memory instruction writeback; NOTE: For a "multi access" memory instruction, this update rule breaks
  always_comb begin
    mem_wb_complete_d = mem_wb_complete_q;
    if (xmem_rvalid_o & xmem_rready_i) begin
      mem_wb_complete_d = 1'b1;
    end else if (xmem_ready_o & xmem_valid_i) begin
      mem_wb_complete_d = 1'b0;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      scoreboard_q      <= 32'b0;
      instr_offloaded_q <= 1'b0;
      mem_wb_complete_q <= 1'b0;
    end else begin
      scoreboard_q      <= scoreboard_d;
      instr_offloaded_q <= instr_offloaded_d;
      mem_wb_complete_q <= mem_wb_complete_d;
    end
  end


endmodule : cv32e40p_x_disp
