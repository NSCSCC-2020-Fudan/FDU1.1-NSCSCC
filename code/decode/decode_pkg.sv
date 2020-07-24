//  Package: decode_pkg
//
package decode_pkg;
    import common::*;
    //  Group: Parameters
parameter logic[5:0] OP_RT    =       6'b000000;
parameter logic[5:0] OP_ADDI  =       6'b001000;
parameter logic[5:0] OP_ADDIU =       6'b001001;
parameter logic[5:0] OP_SLTI  =       6'b001010;
parameter logic[5:0] OP_SLTIU =       6'b001011;
parameter logic[5:0] OP_ANDI  =       6'b001100;
parameter logic[5:0] OP_LUI   =       6'b001111;
parameter logic[5:0] OP_ORI   =       6'b001101;
parameter logic[5:0] OP_XORI  =       6'b001110;
parameter logic[5:0] OP_BEQ   =       6'b000100;
parameter logic[5:0] OP_BNE   =       6'b000101;
parameter logic[5:0] OP_BGEZ  =       6'b000001;
parameter logic[5:0] OP_BGTZ  =       6'b000111;
parameter logic[5:0] OP_BLEZ  =       6'b000110;
// parameter logic[5:0] OP_BLTZ  =       6'b000001;
// parameter logic[5:0] OP_BGEZAL=       6'b000001;
// parameter logic[5:0] OP_BLTZAL=       6'b000001;
parameter logic[5:0] OP_J     =       6'b000010;
parameter logic[5:0] OP_JAL   =       6'b000011;
parameter logic[5:0] OP_LB    =       6'b100000;
parameter logic[5:0] OP_LBU   =       6'b100100;
parameter logic[5:0] OP_LH    =       6'b100001;
parameter logic[5:0] OP_LHU   =       6'b100101;
parameter logic[5:0] OP_LW    =       6'b100011;
parameter logic[5:0] OP_SB    =       6'b101000;
parameter logic[5:0] OP_SH    =       6'b101001;
parameter logic[5:0] OP_SW    =       6'b101011;
parameter logic[5:0] OP_ERET  =       6'b010000;
// parameter logic[5:0] OP_MFC0  =       6'b010000;
// parameter logic[5:0] OP_MTC0  =       6'b010000;
parameter logic[5:0] F_ADD    =       6'b100000;
parameter logic[5:0] F_ADDU   =       6'b100001;
parameter logic[5:0] F_SUB    =       6'b100010;
parameter logic[5:0] F_SUBU   =       6'b100011;
parameter logic[5:0] F_SLT    =       6'b101010;
parameter logic[5:0] F_SLTU   =       6'b101011;
parameter logic[5:0] F_DIV    =       6'b011010;
parameter logic[5:0] F_DIVU   =       6'b011011;
parameter logic[5:0] F_MULT   =       6'b011000;
parameter logic[5:0] F_MULTU  =       6'b011001;
parameter logic[5:0] F_AND    =       6'b100100;
parameter logic[5:0] F_NOR    =       6'b100111;
parameter logic[5:0] F_OR     =       6'b100101;
parameter logic[5:0] F_XOR    =       6'b100110;
parameter logic[5:0] F_SLLV   =       6'b000100;
parameter logic[5:0] F_SLL    =       6'b000000;
parameter logic[5:0] F_SRAV   =       6'b000111;
parameter logic[5:0] F_SRA    =       6'b000011;
parameter logic[5:0] F_SRLV   =       6'b000110;
parameter logic[5:0] F_SRL    =       6'b000010;
parameter logic[5:0] F_JR     =       6'b001000;
parameter logic[5:0] F_JALR   =       6'b001001;
parameter logic[5:0] F_MFHI   =       6'b010000;
parameter logic[5:0] F_MFLO   =       6'b010010;
parameter logic[5:0] F_MTHI   =       6'b010001;
parameter logic[5:0] F_MTLO   =       6'b010011;
parameter logic[5:0] F_BREAK  =       6'b001101;
parameter logic[5:0] F_SYSCALL=       6'b001100;

parameter logic[4:0] B_BGEZ   =       5'b00001;
parameter logic[4:0] B_BLTZ   =       5'b00000;
parameter logic[4:0] B_BGEZAL =       5'b10001;
parameter logic[4:0] B_BLTZAL =       5'b10000;
parameter logic[4:0] C_ERET   =       5'b10000;
parameter logic[4:0] C_MFC0   =       5'b00000;
parameter logic[4:0] C_MTC0   =       5'b00100;

    //  Group: Typedefs
typedef enum logic[3:0] {
    ALU_ADDU, ALU_AND, ALU_OR, ALU_ADD, ALU_SLL, ALU_SRL, ALU_SRA, ALU_SUB, ALU_SLT, ALU_NOR, ALU_XOR, 
    ALU_SUBU, ALU_SLTU, ALU_PASSA, ALU_LUI, ALU_PASSB
} alufunc_t;

typedef logic[5:0] op_t;
typedef logic[5:0] func_t;
typedef logic[4:0] shamt_t;

typedef enum logic[1:0] { REGB, IMM} alusrcb_t;
typedef enum logic { RT, RD } regdst_t;
typedef enum logic[2:0] { T_BEQ, T_BNE, T_BGEZ, T_BLTZ, T_BGTZ, T_BLEZ, T_J } branch_t;

typedef struct packed {
    alufunc_t alufunc;
    logic memtoreg, memwrite;
    logic regwrite;
    alusrcb_t alusrc;
    regdst_t regdst;
    logic branch;
    branch_t branch_type;
    logic jump;
    logic jr;
    logic shamt_valid;
    logic zeroext;
    logic cp0write;
    logic is_eret;
    logic hiwrite;
    logic lowrite;
    logic is_bp;
    logic is_sys;
    logic hitoreg, lotoreg, cp0toreg;
    issue_queue_pkg::entry_type_t entry_type;
} control_t;

typedef enum logic [5:0] { 
    // ADDI, ADDIU, SLTI, SLTIU, ANDI, ORI, XORI, 
    ADDU, RESERVED,
    BEQ, BNE, BGEZ, BGTZ, BLEZ, BLTZ, BGEZAL, BLTZAL, J, JAL, 
    LB, LBU, LH, LHU, LW, SB, SH, SW, ERET, MFC0, MTC0,
    ADD, SUB, SUBU, SLT, SLTU, DIV, DIVU, MULT, MULTU, 
    AND, NOR, OR, XOR, SLLV, SLL, SRAV, SRA, SRLV, SRL, 
    JR, JALR, MFHI, MFLO, MTHI, MTLO, BREAK, SYSCALL, LUI
} decoded_op_t;

typedef struct packed {
    areg_addr_t rs, rt, rd;
    creg_addr_t src1, src2, dst;
    decoded_op_t op;
    word_t imm;
    control_t ctl;
} decoded_instr_t;

typedef struct packed {
    decoded_instr_t instr;
    word_t pcplus4;
    logic in_delay_slot;
    exception_pkg::exception_info_t exception;
    cp0_cause_t cp0_cause;
    cp0_status_t cp0_status;
} decode_data_t;

    
endpackage: decode_pkg
