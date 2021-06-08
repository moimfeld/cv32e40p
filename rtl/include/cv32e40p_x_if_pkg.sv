// Copyright 2018 ETH Zurich and University of Bologna.
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
//                                                                            //
// Design Name:    RISC-V processor core                                      //
// Project Name:   cv32e40p                                                   //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Defines for various constants used by the x-interface.     //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

package cv32e40p_x_if_pkg;

  typedef enum logic [1:0] {
  READ     = 2'b00,
  WRITE    = 2'b01,
  EXECUTE  = 2'b10
  } mem_req_type_e;

endpackage : cv32e40p_x_if_pkg