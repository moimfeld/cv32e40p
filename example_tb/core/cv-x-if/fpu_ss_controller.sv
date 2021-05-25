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

    input  logic [BUFFER_ADDR_DEPTH-1:0] fifo_usage_i
);
    // assign pop_ready_o = pop_valid_i & (fpu_out_valid_i | ~fpu_busy_i) & use_fpu_i; // also add pop for load, store and csr
    assign fpu_in_valid_o = pop_ready_o; // whenever there is a pop, in the same clockcycle should be a
    assign fpu_out_ready_o = 1'b1; // always accept writebacks from the fpu

    always_comb begin // pop_ready has to be asigned in an always comb because it would not be always well defined if one would only use an assign statement
        pop_ready_o = 1'b0;
        if(pop_valid_i & (fpu_out_valid_i | ~fpu_busy_i) & use_fpu_i) begin
            pop_ready_o = 1'b1;
        end
        else if (fpu_out_valid_i & ~rd_is_fp_i & ~csr_instr_i) begin
            pop_ready_o = 1'b1;
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
        if(fpu_out_valid_i & ~rd_is_fp_i & ~csr_instr_i & (fifo_usage_i != '0)) begin
            c_p_valid_o = 1'b1;
        end
    end

endmodule : fpu_ss_controller