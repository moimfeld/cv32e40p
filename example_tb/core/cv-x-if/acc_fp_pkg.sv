// Copyright 2021 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Package for the FPU predecoder
// Contributor: Moritz Imfeld <moimfeld@student.ethz.ch>

package acc_fp_pkg;

// parameter int unsigned NumInstr="NUMBER OF FP INSTR";
parameter int unsigned NumInstr=26;
parameter acc_pkg::offload_instr_t OffloadInstr[26] = '{
  '{
    instr_data: 32'b 000000000000_00000_010_00000_0000111, // FLW
    instr_mask: 32'b 000000000000_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b1,
      p_use_rs : 3'b001
   }
  },
  '{
    instr_data: 32'b 0000000_00000_00000_010_00000_0000111, // FSW
    instr_mask: 32'b 0000000_00000_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b1,
      p_use_rs : 3'b001
   }
  },
  '{
    instr_data: 32'b 00000_00_00000_00000_000_00000_1000011, // FMADD.S
    instr_mask: 32'b 00000_11_00000_00000_000_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 00000_00_00000_00000_000_00000_1000111, // FMSUB.S
    instr_mask: 32'b 00000_11_00000_00000_000_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 00000_00_00000_00000_000_00000_1001011, // FNMSUB.S
    instr_mask: 32'b 00000_11_00000_00000_000_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 00000_00_00000_00000_000_00000_1001111, // FNMADD.S
    instr_mask: 32'b 00000_11_00000_00000_000_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 0000000_00000_00000_000_00000_1010011, // FADD.S
    instr_mask: 32'b 1111111_00000_00000_000_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 0000100_00000_00000_000_00000_1010011, // FSUB.S
    instr_mask: 32'b 1111111_00000_00000_000_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 0001000_00000_00000_000_00000_1010011, // FMUL.S
    instr_mask: 32'b 1111111_00000_00000_000_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 0001100_00000_00000_000_00000_1010011, // FDIV.S
    instr_mask: 32'b 1111111_00000_00000_000_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 0101100_00000_00000_000_00000_1010011, // FSQRT.S
    instr_mask: 32'b 1111111_11111_00000_000_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 0010000_00000_00000_000_00000_1010011, // FSGNJ.S
    instr_mask: 32'b 1111111_00000_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 0010000_00000_00000_001_00000_1010011, // FSGNJN.S
    instr_mask: 32'b 1111111_00000_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 0010000_00000_00000_010_00000_1010011, // FSGNJX.S
    instr_mask: 32'b 1111111_00000_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 0010100_00000_00000_000_00000_1010011, // FMIN.S
    instr_mask: 32'b 1111111_00000_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 0010100_00000_00000_001_00000_1010011, // FMAX.S
    instr_mask: 32'b 1111111_00000_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 1100000_00000_00000_000_00000_1010011, // FCVT.W.S
    instr_mask: 32'b 1111111_11111_00000_000_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b01,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 1100000_00001_00000_000_00000_1010011, // FCVT.WU.S
    instr_mask: 32'b 1111111_11111_00000_000_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b01,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 1110000_00000_00000_000_00000_1010011, // FMV.X.W
    instr_mask: 32'b 1111111_11111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b01,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 1010000_00000_00000_010_00000_1010011, // FEQ.S
    instr_mask: 32'b 1111111_00000_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b01,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 1010000_00000_00000_001_00000_1010011, // FLT.S
    instr_mask: 32'b 1111111_00000_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b01,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 1010000_00000_00000_000_00000_1010011, // FLE.S
    instr_mask: 32'b 1111111_00000_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b01,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 1110000_00000_00000_001_00000_1010011, // FCLASS.S
    instr_mask: 32'b 1111111_11111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b01,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
    }
  },
  '{
    instr_data: 32'b 1101000_00000_00000_000_00000_1010011, // FCVT.S.W
    instr_mask: 32'b 1111111_11111_00000_000_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b001
    }
  },
  '{
    instr_data: 32'b 1101000_00001_00000_000_00000_1010011, // FCVT.S.WU
    instr_mask: 32'b 1111111_11111_00000_000_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b001
    }
  },
  '{
    instr_data: 32'b 1111000_00000_00000_000_00000_1010011, // FMV.W.X
    instr_mask: 32'b 1111111_11111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b001
    }
  }
};

endpackage
