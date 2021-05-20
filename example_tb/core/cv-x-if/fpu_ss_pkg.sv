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
    ResNone,
    ResAccBus
  } result_select_e;

  typedef enum logic [1:0] {
    Byte       = 2'b00,
    HalfWord   = 2'b01,
    Word       = 2'b10,
    DoubleWord = 2'b11
  } ls_size_e;

endpackage : fpu_ss_pkg
