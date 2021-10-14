// Copyright 2021 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// CORE-V-XIF Package
// Contributor: Moritz Imfeld <moimfeld@student.ethz.ch>

package core_v_xif_pkg;

  // ADJUST THE PARAMETERS ACCORDING TO YOUR IMPLEMENTATION
  parameter X_DATAWIDTH = 32;
  parameter X_NUM_RS    = 3;
  parameter X_NUM_FRS   = 2;
  parameter X_ID_WIDTH  = 4;
  parameter X_MEM_WIDTH = 32;
  parameter X_RFR_WIDTH = 32;
  parameter X_RFW_WIDTH = 32;
  parameter X_MISA      = 32'h0000_0000;
  parameter FLEN        = 32;
  parameter XLEN        = 32;

  // DO NOT CHANGE THE STRUCTS
  typedef struct packed {
    logic [          15:0] instr;
    logic [           1:0] mode;
    logic [X_ID_WIDTH-1:0] id;
  } x_compressed_req_t;

  typedef struct packed {
    logic [31:0] instr;
    logic        accept;
  } x_compressed_resp_t;

  typedef struct packed {
    logic [31:0] instr; // ok
    logic [ 1:0] mode; // ok
    logic [X_ID_WIDTH-1:0] id; // only changed for fifo and fpu_tag
    logic [X_NUM_RS-1:0][X_RFR_WIDTH-1:0] rs; // ok
    logic [X_NUM_RS-1:0] rs_valid; // ok
    logic [X_NUM_FRS-1:0][FLEN-1:0] frs; // ok, unused
    logic [X_NUM_FRS-1:0] frs_valid; // ok, unused
  } x_issue_req_t;

  typedef struct packed {
    logic accept; // ok
    logic writeback; // ok
    logic float; // ok
    logic dualwrite; // ok, why does it need the dual write
    logic dualread; // ok
    logic loadstore; // ok
    logic exc; // ok
  } x_issue_resp_t;

  typedef struct packed {
    logic [X_ID_WIDTH-1:0] id; // ok
    logic commit_kill; // ok
  } x_commit_t;

  typedef struct packed {
    logic [X_ID_WIDTH-1:0] id; // ok
    logic [31:0] addr; // ok
    logic [1:0] mode; // ok
    logic [1:0] size; // ok
    logic we; // ok
    logic [X_MEM_WIDTH-1:0] wdata; // ok
    logic last; // ok
    logic spec; // ok
  } x_mem_req_t;

  typedef struct packed {
    logic exc; // ok, unused
    logic [5:0] exccode; // ok, unused
  } x_mem_resp_t;

    typedef struct packed {
    logic [X_ID_WIDTH-1:0] id; // unused for now, but is needed to handle result interface propperly
    logic [X_MEM_WIDTH-1:0] rdata; // ok
    logic err; // ok
  } x_mem_result_t;

  typedef struct packed { // not done. Need to think how to avoid congestions
                          // maybe prioritice memory instruction for the result interface --> if
                          // result interface is used by memory instruction, do not accept FPU
                          // output so the FPU itself "stalls" and keeps the results
    logic [X_ID_WIDTH-1:0] id; // ok
    logic [X_RFW_WIDTH-1:0] data; // ok
    logic [4:0] rd; // ok
    logic [X_RFW_WIDTH-XLEN:0] we; // ok
    logic float; // ok
    logic exc; // ok
    logic [5:0] exccode; // ok
  } x_result_t;
endpackage
