// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Contributor: Moritz Imfeld <moimfeld@student.ethz.ch>
//              Davide Schiavone <davide@openhwgroup.org>
//

package cv32e40p_fpu_pkg;

  // Floating-point extensions configuration
  parameter bit C_RVF = 1'b1;  // Is F extension enabled
  parameter bit C_RVD = 1'b0;  // Is D extension enabled - NOT SUPPORTED CURRENTLY

  // Transprecision floating-point extensions configuration
  parameter bit C_XF16 = 1'b0;  // Is half-precision float extension (Xf16) enabled
  parameter bit C_XF16ALT = 1'b0; // Is alternative half-precision float extension (Xf16alt) enabled
  parameter bit C_XF8 = 1'b0;  // Is quarter-precision float extension (Xf8) enabled
  parameter bit C_XFVEC = 1'b0;  // Is vectorial float extension (Xfvec) enabled

  // Latency of FP operations: 0 = no pipe registers, 1 = 1 pipe register etc.
  parameter int unsigned C_LAT_FP64 = 'd1; // set to 1 to mimic cv32e40p core internal
  parameter int unsigned C_LAT_FP32 = 'd1; // set to 1 to mimic cv32e40p core internal
  parameter int unsigned C_LAT_FP16 = 'd1; // set to 1 to mimic cv32e40p core internal
  parameter int unsigned C_LAT_FP16ALT = 'd1; // set to 1 to mimic cv32e40p core internal
  parameter int unsigned C_LAT_FP8 = 'd1; // set to 1 to break critical path
  parameter int unsigned C_LAT_DIVSQRT = 'd1;  // divsqrt post-processing pipe
  parameter int unsigned C_LAT_CONV = 'd1; // set to 1 to mimic cv32e40p core internal
  parameter int unsigned C_LAT_NONCOMP = 'd1; // set to 1 to mimic cv32e40p core internal

  // General FPU-specific defines

  // Length of widest floating-point format = width of fp regfile
  parameter C_FLEN = C_RVD ? 64 :  // D ext.
  C_RVF ? 32 :  // F ext.
  C_XF16 ? 16 :  // Xf16 ext.
  C_XF16ALT ? 16 :  // Xf16alt ext.
  C_XF8 ? 8 :  // Xf8 ext.
  0;  // Unused in case of no FP

  // -----------
  // FPU Config
  // -----------
  // Features (enabled formats, vectors etc.)
  parameter fpnew_pkg::fpu_features_t FPU_FEATURES = '{
  Width:         cv32e40p_fpu_pkg::C_FLEN,
  EnableVectors: cv32e40p_fpu_pkg::C_XFVEC,
  EnableNanBox:  1'b0,
  FpFmtMask:     {
    cv32e40p_fpu_pkg::C_RVF, cv32e40p_fpu_pkg::C_RVD, cv32e40p_fpu_pkg::C_XF16, cv32e40p_fpu_pkg::C_XF8, cv32e40p_fpu_pkg::C_XF16ALT
  }, IntFmtMask: {
    cv32e40p_fpu_pkg::C_XFVEC && cv32e40p_fpu_pkg::C_XF8, cv32e40p_fpu_pkg::C_XFVEC && (cv32e40p_fpu_pkg::C_XF16 || cv32e40p_fpu_pkg::C_XF16ALT), 1'b1, 1'b0
  }};

  // Implementation (number of registers etc)
  parameter fpnew_pkg::fpu_implementation_t FPU_IMPLEMENTATION = '{
  PipeRegs:  '{// FP32, FP64, FP16, FP8, FP16alt
      '{
          cv32e40p_fpu_pkg::C_LAT_FP32, cv32e40p_fpu_pkg::C_LAT_FP64, cv32e40p_fpu_pkg::C_LAT_FP16, cv32e40p_fpu_pkg::C_LAT_FP8, cv32e40p_fpu_pkg::C_LAT_FP16ALT
      },  // ADDMUL
      '{default: cv32e40p_fpu_pkg::C_LAT_DIVSQRT},  // DIVSQRT
      '{default: cv32e40p_fpu_pkg::C_LAT_NONCOMP},  // NONCOMP
      '{default: cv32e40p_fpu_pkg::C_LAT_CONV}
  },  // CONV
  UnitTypes: '{
      '{default: fpnew_pkg::MERGED},  // ADDMUL
      '{default: fpnew_pkg::MERGED},  // DIVSQRT
      '{default: fpnew_pkg::PARALLEL},  // NONCOMP
      '{default: fpnew_pkg::MERGED}
  },  // CONV
  PipeConfig: fpnew_pkg::BEFORE};

endpackage : cv32e40p_fpu_pkg
