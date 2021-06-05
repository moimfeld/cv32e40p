// Copyright 2021 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// FPU Subsystem Register File
// Contributor: Moritz Imfeld <moimfeld@student.ethz.ch>

module fpu_ss_regfile (
    // clock and reset
    input  logic              clk_i,
    // read port
    input  logic [ 2:0][ 4:0] raddr_i,
    output logic [ 2:0][31:0] rdata_o,
    // write port
    input  logic [ 4:0]       waddr_i,
    input  logic [31:0]       wdata_i,
    input  logic              we_i
);

  localparam int unsigned NumWords = 32;

  logic [NumWords-1:0][31:0] mem;
  logic [NumWords-1:0]       we_dec;


  always_comb begin : we_decoder
    for (int unsigned i = 0; i < NumWords; i++) begin
      if (waddr_i == i) we_dec[i] = we_i;
      else we_dec[i] = 1'b0;
    end
  end

  // loop from 1 to NumWords-1 as R0 is nil
  always_ff @(posedge clk_i) begin : register_write_behavioral
    for (int unsigned i = 0; i < NumWords; i++) begin
      if (we_dec[i]) begin //(1'b1) begin // NOTE: JUST AN EXAMPLE
        mem[i] <= wdata_i;//32'b0000_0000_0000_0000_0000_0000_0000_1111;// wdata_i;// NOTE: JUST AN EXAMPLE
      end
    end
  end

  for (genvar i = 0; i < 3; i++) begin : gen_read_port
    assign rdata_o[i] = mem[raddr_i[i]];
  end

endmodule
