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


// Thi is the x_disp copy!

module cv32e40p_x_disp #(

) (
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
    input logic [2:0]      x_regs_used_i,
    input logic            x_branch_or_jump_i,

    output logic       x_valid_o,
    input  logic       x_ready_i,
    input  logic       x_accept_i,
    input  logic       x_is_mem_op_i,
    output logic [2:0] x_rs_valid_o,
    output logic       x_rd_clean_o,
    output logic       x_stall_o,
    output logic       x_illegal_insn_o,

    output logic x_rready_o
);

  logic [31:0] scoreboard_q, scoreboard_d;
  logic dep;

  // Core is always ready to receive returning fp instruction results
  assign x_rready_o = 1'b1;
  // One should be sure to encounter no branches before setting x_valid_o to high
  assign x_valid_o = x_illegal_insn_dec_i & ~x_branch_or_jump_i;
  assign x_stall_o = (x_valid_o & ~x_ready_i) | dep | x_is_mem_op_i;

  always_comb begin
    x_illegal_insn_o = 1'b0;
    if (x_valid_o & x_ready_i & ~x_accept_i) begin
      x_illegal_insn_o = 1'b1;
    end
  end

  // Dependency check
  always_comb begin
    // Check if scoreboard is clean and if there are no outstanding writebacks in the ex- or id-stage
    x_rs_valid_o[0] = ~(scoreboard_q[x_rs_addr_i[0]] | ((x_rs_addr_i[0] == x_waddr_ex_i) & x_we_ex_i) | ((x_rs_addr_i[0] == x_waddr_wb_i) & x_we_wb_i));
    x_rs_valid_o[1] = ~(scoreboard_q[x_rs_addr_i[1]] | ((x_rs_addr_i[1] == x_waddr_ex_i) & x_we_ex_i) | ((x_rs_addr_i[1] == x_waddr_wb_i) & x_we_wb_i));
    x_rs_valid_o[2] = ~(scoreboard_q[x_rs_addr_i[2]] | ((x_rs_addr_i[2] == x_waddr_ex_i) & x_we_ex_i) | ((x_rs_addr_i[2] == x_waddr_wb_i) & x_we_wb_i));
    x_rd_clean_o = ~(scoreboard_q[x_waddr_id_i] | ((x_waddr_id_i == x_waddr_ex_i) & x_we_ex_i) | ((x_waddr_id_i == x_waddr_wb_i) & x_we_wb_i));
    // Check if scoreboard is clean for any instruction that stays in the core
    dep = ((x_regs_used_i[0] & scoreboard_q[x_rs_addr_i[0]]) | (x_regs_used_i[1] & scoreboard_q[x_rs_addr_i[1]]) | (x_regs_used_i[2] & scoreboard_q[x_rs_addr_i[2]]));
  end



  // scoreboard with only the offloaded instructions
  always_comb begin
    scoreboard_d = scoreboard_q;
    if (x_writeback_i & x_illegal_insn_dec_i) begin  // update rule for outgoing instructions
      scoreboard_d[x_waddr_id_i] = 1'b1;
    end else if((x_rvalid_i & (x_waddr_id_i != x_rwaddr_i)) | (~x_writeback_i & ~x_illegal_insn_dec_i)) begin // update rule for returning instructions
      scoreboard_d[x_rwaddr_i] = 1'b0;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      scoreboard_q <= 32'b0;
    end else begin
      scoreboard_q <= scoreboard_d;
    end
  end

endmodule : cv32e40p_x_disp
