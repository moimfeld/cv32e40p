// Copyright 2021 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// FPU Subsystem Package
// Contributor: Moritz Imfeld <moimfeld@student.ethz.ch>

package fpu_ss_pkg;

  typedef enum logic [2:0] {
    None,
    AccBus,
    RegA,
    RegB,
    RegC,
    RegBRep,  // Replication for vectors
    RegDest
  } op_select_e;

  typedef enum logic [1:0] {
    Byte       = 2'b00,
    HalfWord   = 2'b01,
    Word       = 2'b10,
    DoubleWord = 2'b11
  } ls_size_e;

endpackage : fpu_ss_pkg
