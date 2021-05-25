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

module fpu_ss_controller #(
    parameter BUFFER_ADDR_DEPTH = 0
) (
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
    output logic c_p_valid_o
);

    logic instr_done_d;
    logic instr_done_q;
    logic fpu_out_valid_q;

    assign fpu_out_ready_o = 1'b1; // always accept writebacks from the fpu

    // Pop Instruction (instruction completion from non fpu instruction not included yet)
    always_comb begin
        pop_ready_o = 1'b0;
            if(fpu_out_valid_i & pop_valid_i) begin  // if instr completed, pop the complete instruction from the buffer (including writeback, thats why one has one more clockcycle latency)
                pop_ready_o = 1'b1;
            end
    end

    always_comb begin
        fpu_in_valid_o = 1'b0;
        if(use_fpu_i & ~instr_done_q & pop_valid_i)begin
            fpu_in_valid_o = 1'b1;
        end
    end

    always_comb begin
        fpr_we_o = 1'b0;
        if(fpu_out_valid_i & rd_is_fp_i) begin
            fpr_we_o = 1'b1;
        end
    end

    always_comb begin
        c_p_valid_o = 1'b0;
        if(fpu_out_valid_i & ~rd_is_fp_i & ~csr_instr_i & pop_valid_i) begin
            c_p_valid_o = 1'b1;
        end
    end

    // Determin whether curretly exposed instruction by the buffer is already done/inflight (sequence of if statement matter,
    // because if there is a pop and a fpu_in_valid at the same time, then the instr_done signal needs to go to low)
    always_comb begin
        instr_done_d = instr_done_q;
        if(pop_ready_o) begin
            instr_done_d = 1'b0;
        end else if (fpu_in_valid_o) begin
            instr_done_d = 1'b1;
        end
    end

    always_ff @(posedge clk_i, negedge rst_ni) begin
        if(~rst_ni) begin
            instr_done_q <= 1'b0;
        end else begin
            instr_done_q <= instr_done_d;
            fpu_out_valid_q <= fpu_out_valid_i;
        end
    end

endmodule : fpu_ss_controller