// This file was created by the predecoder_generator script
// Date and Time of creation: 2021-07-14 19:47:46.981738
//
// xfvec Predecoder
// Contributor: Moritz Imfeld <moimfeld@student.ethz.ch>
//


package fpu_ss_prd_xfvec_pkg;

parameter int unsigned NumInstr = 252;
parameter fpu_ss_pkg::offload_instr_t OffloadInstr[252] = '{
  '{
    instr_data: 32'b 1000001_0000000000_000_00000_0110011, // VFADD_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000001_0000000000_100_00000_0110011, // VFADD_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000010_0000000000_000_00000_0110011, // VFSUB_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000010_0000000000_100_00000_0110011, // VFSUB_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000011_0000000000_000_00000_0110011, // VFMUL_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000011_0000000000_100_00000_0110011, // VFMUL_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000100_0000000000_000_00000_0110011, // VFDIV_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000100_0000000000_100_00000_0110011, // VFDIV_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000101_0000000000_000_00000_0110011, // VFMIN_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000101_0000000000_100_00000_0110011, // VFMIN_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000110_0000000000_000_00000_0110011, // VFMAX_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000110_0000000000_100_00000_0110011, // VFMAX_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100011100000_00000_000_00000_0110011, // VFSQRT_S
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001000_0000000000_000_00000_0110011, // VFMAC_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001000_0000000000_100_00000_0110011, // VFMAC_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001001_0000000000_000_00000_0110011, // VFMRE_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001001_0000000000_100_00000_0110011, // VFMRE_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000001_00000_000_00000_0110011, // VFCLASS_S
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001101_0000000000_000_00000_0110011, // VFSGNJ_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001101_0000000000_100_00000_0110011, // VFSGNJ_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001110_0000000000_000_00000_0110011, // VFSGNJN_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001110_0000000000_100_00000_0110011, // VFSGNJN_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001111_0000000000_000_00000_0110011, // VFSGNJX_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001111_0000000000_100_00000_0110011, // VFSGNJX_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010000_0000000000_000_00000_0110011, // VFEQ_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010000_0000000000_100_00000_0110011, // VFEQ_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010001_0000000000_000_00000_0110011, // VFNE_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010001_0000000000_100_00000_0110011, // VFNE_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010010_0000000000_000_00000_0110011, // VFLT_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010010_0000000000_100_00000_0110011, // VFLT_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010011_0000000000_000_00000_0110011, // VFGE_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010011_0000000000_100_00000_0110011, // VFGE_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010100_0000000000_000_00000_0110011, // VFLE_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010100_0000000000_100_00000_0110011, // VFLE_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010101_0000000000_000_00000_0110011, // VFGT_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010101_0000000000_100_00000_0110011, // VFGT_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000000_00000_000_00000_0110011, // VFMV_X_S
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000000_00000_100_00000_0110011, // VFMV_S_X
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000010_00000_000_00000_0110011, // VFCVT_X_S
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000010_00000_100_00000_0110011, // VFCVT_XU_S
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000011_00000_000_00000_0110011, // VFCVT_S_X
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000011_00000_100_00000_0110011, // VFCVT_S_XU
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011000_0000000000_000_00000_0110011, // VFCPKA_S_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011000_0000000000_100_00000_0110011, // VFCPKB_S_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011001_0000000000_000_00000_0110011, // VFCPKC_S_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011001_0000000000_100_00000_0110011, // VFCPKD_S_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011010_0000000000_000_00000_0110011, // VFCPKA_S_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011010_0000000000_100_00000_0110011, // VFCPKB_S_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011011_0000000000_000_00000_0110011, // VFCPKC_S_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011011_0000000000_100_00000_0110011, // VFCPKD_S_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000001_0000000000_010_00000_0110011, // VFADD_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000001_0000000000_110_00000_0110011, // VFADD_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000010_0000000000_010_00000_0110011, // VFSUB_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000010_0000000000_110_00000_0110011, // VFSUB_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000011_0000000000_010_00000_0110011, // VFMUL_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000011_0000000000_110_00000_0110011, // VFMUL_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000100_0000000000_010_00000_0110011, // VFDIV_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000100_0000000000_110_00000_0110011, // VFDIV_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000101_0000000000_010_00000_0110011, // VFMIN_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000101_0000000000_110_00000_0110011, // VFMIN_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000110_0000000000_010_00000_0110011, // VFMAX_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000110_0000000000_110_00000_0110011, // VFMAX_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100011100000_00000_010_00000_0110011, // VFSQRT_H
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001000_0000000000_010_00000_0110011, // VFMAC_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001000_0000000000_110_00000_0110011, // VFMAC_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001001_0000000000_010_00000_0110011, // VFMRE_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001001_0000000000_110_00000_0110011, // VFMRE_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000001_00000_010_00000_0110011, // VFCLASS_H
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001101_0000000000_010_00000_0110011, // VFSGNJ_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001101_0000000000_110_00000_0110011, // VFSGNJ_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001110_0000000000_010_00000_0110011, // VFSGNJN_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001110_0000000000_110_00000_0110011, // VFSGNJN_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001111_0000000000_010_00000_0110011, // VFSGNJX_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001111_0000000000_110_00000_0110011, // VFSGNJX_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010000_0000000000_010_00000_0110011, // VFEQ_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010000_0000000000_110_00000_0110011, // VFEQ_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010001_0000000000_010_00000_0110011, // VFNE_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010001_0000000000_110_00000_0110011, // VFNE_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010010_0000000000_010_00000_0110011, // VFLT_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010010_0000000000_110_00000_0110011, // VFLT_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010011_0000000000_010_00000_0110011, // VFGE_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010011_0000000000_110_00000_0110011, // VFGE_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010100_0000000000_010_00000_0110011, // VFLE_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010100_0000000000_110_00000_0110011, // VFLE_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010101_0000000000_010_00000_0110011, // VFGT_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010101_0000000000_110_00000_0110011, // VFGT_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000000_00000_010_00000_0110011, // VFMV_X_H
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000000_00000_110_00000_0110011, // VFMV_H_X
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000010_00000_010_00000_0110011, // VFCVT_X_H
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000010_00000_110_00000_0110011, // VFCVT_XU_H
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000011_00000_010_00000_0110011, // VFCVT_H_X
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000011_00000_110_00000_0110011, // VFCVT_H_XU
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011000_0000000000_010_00000_0110011, // VFCPKA_H_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011000_0000000000_110_00000_0110011, // VFCPKB_H_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011001_0000000000_010_00000_0110011, // VFCPKC_H_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011001_0000000000_110_00000_0110011, // VFCPKD_H_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011010_0000000000_010_00000_0110011, // VFCPKA_H_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011010_0000000000_110_00000_0110011, // VFCPKB_H_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011011_0000000000_010_00000_0110011, // VFCPKC_H_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011011_0000000000_110_00000_0110011, // VFCPKD_H_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000110_00000_000_00000_0110011, // VFCVT_S_H
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000110_00000_100_00000_0110011, // VFCVTU_S_H
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000100_00000_010_00000_0110011, // VFCVT_H_S
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000100_00000_110_00000_0110011, // VFCVTU_H_S
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000001_0000000000_001_00000_0110011, // VFADD_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000001_0000000000_101_00000_0110011, // VFADD_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000010_0000000000_001_00000_0110011, // VFSUB_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000010_0000000000_101_00000_0110011, // VFSUB_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000011_0000000000_001_00000_0110011, // VFMUL_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000011_0000000000_101_00000_0110011, // VFMUL_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000100_0000000000_001_00000_0110011, // VFDIV_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000100_0000000000_101_00000_0110011, // VFDIV_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000101_0000000000_001_00000_0110011, // VFMIN_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000101_0000000000_101_00000_0110011, // VFMIN_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000110_0000000000_001_00000_0110011, // VFMAX_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000110_0000000000_101_00000_0110011, // VFMAX_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100011100000_00000_001_00000_0110011, // VFSQRT_AH
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001000_0000000000_001_00000_0110011, // VFMAC_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001000_0000000000_101_00000_0110011, // VFMAC_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001001_0000000000_001_00000_0110011, // VFMRE_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001001_0000000000_101_00000_0110011, // VFMRE_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000001_00000_001_00000_0110011, // VFCLASS_AH
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001101_0000000000_001_00000_0110011, // VFSGNJ_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001101_0000000000_101_00000_0110011, // VFSGNJ_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001110_0000000000_001_00000_0110011, // VFSGNJN_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001110_0000000000_101_00000_0110011, // VFSGNJN_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001111_0000000000_001_00000_0110011, // VFSGNJX_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001111_0000000000_101_00000_0110011, // VFSGNJX_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010000_0000000000_001_00000_0110011, // VFEQ_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010000_0000000000_101_00000_0110011, // VFEQ_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010001_0000000000_001_00000_0110011, // VFNE_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010001_0000000000_101_00000_0110011, // VFNE_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010010_0000000000_001_00000_0110011, // VFLT_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010010_0000000000_101_00000_0110011, // VFLT_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010011_0000000000_001_00000_0110011, // VFGE_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010011_0000000000_101_00000_0110011, // VFGE_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010100_0000000000_001_00000_0110011, // VFLE_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010100_0000000000_101_00000_0110011, // VFLE_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010101_0000000000_001_00000_0110011, // VFGT_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010101_0000000000_101_00000_0110011, // VFGT_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000000_00000_001_00000_0110011, // VFMV_X_AH
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000000_00000_101_00000_0110011, // VFMV_AH_X
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000010_00000_001_00000_0110011, // VFCVT_X_AH
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000010_00000_101_00000_0110011, // VFCVT_XU_AH
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000011_00000_001_00000_0110011, // VFCVT_AH_X
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000011_00000_101_00000_0110011, // VFCVT_AH_XU
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011000_0000000000_001_00000_0110011, // VFCPKA_AH_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011000_0000000000_101_00000_0110011, // VFCPKB_AH_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011001_0000000000_001_00000_0110011, // VFCPKC_AH_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011001_0000000000_101_00000_0110011, // VFCPKD_AH_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011010_0000000000_001_00000_0110011, // VFCPKA_AH_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011010_0000000000_101_00000_0110011, // VFCPKB_AH_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011011_0000000000_001_00000_0110011, // VFCPKC_AH_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011011_0000000000_101_00000_0110011, // VFCPKD_AH_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000101_00000_000_00000_0110011, // VFCVT_S_AH
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000101_00000_100_00000_0110011, // VFCVTU_S_AH
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000100_00000_001_00000_0110011, // VFCVT_AH_S
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000100_00000_101_00000_0110011, // VFCVTU_AH_S
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000101_00000_010_00000_0110011, // VFCVT_H_AH
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000101_00000_110_00000_0110011, // VFCVTU_H_AH
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000110_00000_001_00000_0110011, // VFCVT_AH_H
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000110_00000_101_00000_0110011, // VFCVTU_AH_H
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000001_0000000000_011_00000_0110011, // VFADD_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000001_0000000000_111_00000_0110011, // VFADD_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000010_0000000000_011_00000_0110011, // VFSUB_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000010_0000000000_111_00000_0110011, // VFSUB_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000011_0000000000_011_00000_0110011, // VFMUL_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000011_0000000000_111_00000_0110011, // VFMUL_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000100_0000000000_011_00000_0110011, // VFDIV_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000100_0000000000_111_00000_0110011, // VFDIV_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000101_0000000000_011_00000_0110011, // VFMIN_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000101_0000000000_111_00000_0110011, // VFMIN_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000110_0000000000_011_00000_0110011, // VFMAX_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1000110_0000000000_111_00000_0110011, // VFMAX_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100011100000_00000_011_00000_0110011, // VFSQRT_B
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001000_0000000000_011_00000_0110011, // VFMAC_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001000_0000000000_111_00000_0110011, // VFMAC_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001001_0000000000_011_00000_0110011, // VFMRE_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001001_0000000000_111_00000_0110011, // VFMRE_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001101_0000000000_011_00000_0110011, // VFSGNJ_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001101_0000000000_111_00000_0110011, // VFSGNJ_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001110_0000000000_011_00000_0110011, // VFSGNJN_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001110_0000000000_111_00000_0110011, // VFSGNJN_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001111_0000000000_011_00000_0110011, // VFSGNJX_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001111_0000000000_111_00000_0110011, // VFSGNJX_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010000_0000000000_011_00000_0110011, // VFEQ_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010000_0000000000_111_00000_0110011, // VFEQ_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010001_0000000000_011_00000_0110011, // VFNE_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010001_0000000000_111_00000_0110011, // VFNE_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010010_0000000000_011_00000_0110011, // VFLT_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010010_0000000000_111_00000_0110011, // VFLT_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010011_0000000000_011_00000_0110011, // VFGE_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010011_0000000000_111_00000_0110011, // VFGE_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010100_0000000000_011_00000_0110011, // VFLE_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010100_0000000000_111_00000_0110011, // VFLE_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010101_0000000000_011_00000_0110011, // VFGT_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010101_0000000000_111_00000_0110011, // VFGT_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000000_00000_011_00000_0110011, // VFMV_X_B
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000000_00000_111_00000_0110011, // VFMV_B_X
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000001_00000_011_00000_0110011, // VFCLASS_B
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000010_00000_011_00000_0110011, // VFCVT_X_B
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000010_00000_111_00000_0110011, // VFCVT_XU_B
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000011_00000_011_00000_0110011, // VFCVT_B_X
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000011_00000_111_00000_0110011, // VFCVT_B_XU
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011000_0000000000_011_00000_0110011, // VFCPKA_B_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011000_0000000000_111_00000_0110011, // VFCPKB_B_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011001_0000000000_011_00000_0110011, // VFCPKC_B_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011001_0000000000_111_00000_0110011, // VFCPKD_B_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011010_0000000000_011_00000_0110011, // VFCPKA_B_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011010_0000000000_111_00000_0110011, // VFCPKB_B_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011011_0000000000_011_00000_0110011, // VFCPKC_B_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1011011_0000000000_111_00000_0110011, // VFCPKD_B_D
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000111_00000_000_00000_0110011, // VFCVT_S_B
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000111_00000_100_00000_0110011, // VFCVTU_S_B
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000100_00000_011_00000_0110011, // VFCVT_B_S
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000100_00000_111_00000_0110011, // VFCVTU_B_S
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000111_00000_010_00000_0110011, // VFCVT_H_B
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000111_00000_110_00000_0110011, // VFCVTU_H_B
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000110_00000_011_00000_0110011, // VFCVT_B_H
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000110_00000_111_00000_0110011, // VFCVTU_B_H
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000111_00000_001_00000_0110011, // VFCVT_AH_B
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000111_00000_101_00000_0110011, // VFCVTU_AH_B
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000101_00000_011_00000_0110011, // VFCVT_B_AH
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 100110000101_00000_111_00000_0110011, // VFCVTU_B_AH
    instr_mask: 32'b 111111111111_00000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001010_0000000000_000_00000_0110011, // VFDOTP_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001010_0000000000_100_00000_0110011, // VFDOTP_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010110_0000000000_000_00000_0110011, // VFAVG_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010110_0000000000_100_00000_0110011, // VFAVG_R_S
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 0100110_000000000000000000_1010011, // FMULEX_S_H
    instr_mask: 32'b 1111111_000000000000000000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 0101010_000000000000000000_1010011, // FMACEX_S_H
    instr_mask: 32'b 1111111_000000000000000000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001010_0000000000_010_00000_0110011, // VFDOTP_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001010_0000000000_110_00000_0110011, // VFDOTP_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001011_0000000000_010_00000_0110011, // VFDOTPEX_S_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001011_0000000000_110_00000_0110011, // VFDOTPEX_S_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010110_0000000000_010_00000_0110011, // VFAVG_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010110_0000000000_110_00000_0110011, // VFAVG_R_H
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 0100110_0000000000_101_00000_1010011, // FMULEX_S_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 0101010_0000000000_101_00000_1010011, // FMACEX_S_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001010_0000000000_001_00000_0110011, // VFDOTP_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001010_0000000000_101_00000_0110011, // VFDOTP_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001011_0000000000_001_00000_0110011, // VFDOTPEX_S_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001011_0000000000_101_00000_0110011, // VFDOTPEX_S_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010110_0000000000_001_00000_0110011, // VFAVG_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010110_0000000000_101_00000_0110011, // VFAVG_R_AH
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 0100111_000000000000000000_1010011, // FMULEX_S_B
    instr_mask: 32'b 1111111_000000000000000000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 0101011_000000000000000000_1010011, // FMACEX_S_B
    instr_mask: 32'b 1111111_000000000000000000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001010_0000000000_011_00000_0110011, // VFDOTP_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001010_0000000000_111_00000_0110011, // VFDOTP_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001011_0000000000_011_00000_0110011, // VFDOTPEX_S_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1001011_0000000000_111_00000_0110011, // VFDOTPEX_S_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010110_0000000000_011_00000_0110011, // VFAVG_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  },
  '{
    instr_data: 32'b 1010110_0000000000_111_00000_0110011, // VFAVG_R_B
    instr_mask: 32'b 1111111_0000000000_111_00000_1111111,
    prd_rsp : '{
      p_accept : 1'b1,
      p_writeback : 2'b00,
      p_is_mem_op : 1'b0,
      p_use_rs : 3'b000
   }
  }
};

endpackage
