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

  // Compressed predecoder request type
  typedef struct packed {
    logic [16:0] comp_instr;
  } comp_prd_req_t;

  // Compressed predecoder response type
  typedef struct packed {
    logic        accept;
    logic [32:0] decomp_instr;
  } comp_prd_rsp_t;

  // Predecoder request type
  typedef struct packed {
    logic [31:0] q_instr_data;
  } acc_prd_req_t;

  // Predecoder response type
  typedef struct packed {
    logic       p_accept;
    logic       p_is_mem_op;
    logic       p_writeback;
    logic [2:0] p_use_rs;
  } acc_prd_rsp_t;

  // Predecoder internal instruction metadata
  typedef struct packed {
    logic [31:0]  instr_data;
    logic [31:0]  instr_mask;
    acc_prd_rsp_t prd_rsp;
  } offload_instr_t;

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

  typedef struct packed {
    logic [2:0][31:0] rs;
    logic [31:0]      instr_data;
    logic [3:0]       id;
    logic [1:0]       mode;
  } offloaded_data_t;

  typedef struct packed {
    logic [ 3:0] id;
    logic [ 4:0] rd;
    logic        we;
  } mem_metadata_t;

  typedef struct packed {
    logic [ 4:0] addr;
    logic        rd_is_fp;
    logic [3:0]  id;
  } fpu_tag_t;

endpackage : fpu_ss_pkg
