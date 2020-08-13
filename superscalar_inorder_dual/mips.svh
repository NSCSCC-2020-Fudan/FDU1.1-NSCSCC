`ifndef __MIPS_SVH
`define __MIPS_SVH

`define BPB_ENTRIES         'd64
`define BPB_ENTRY_WIDTH     'd6
`define BPB_ENTRY_WIDTH0    'd6
`define BPB_TAG_WIDTH0      'd24
`define BPB_GLOBAL_WIDTH1   'd1
`define BPB_ENTRY_WIDTH1    'd5
`define BPB_TAG_WIDTH1      'd25
`define BPB_GLOBAL_WIDTH2   'd2
`define BPB_ENTRY_WIDTH2    'd4
`define BPB_TAG_WIDTH2      'd26

`define JR_ENTRIES          'd16
`define JR_ENTRY_WIDTH      'd4          

typedef logic[31:0] word_t;

typedef struct packed{
    logic taken;
    word_t destpc;
} bpb_result_t;

`define MUL_DELAY           4
`define DIV_DELAY           10
`define ALU_DELAY           1

`define ISSUE_QUEUE_SIZE    8
`define ISSUE_QUEUE_WIDTH   3

typedef logic[5:0] op_t;
typedef logic[5:0] func_t;
typedef logic[4:0] shamt_t;

typedef enum logic[4:0] {
    ALU_ADDU, ALU_AND, ALU_OR, ALU_ADD, ALU_SLL, 
    ALU_SRL, ALU_SRA, ALU_SUB, ALU_SLT, ALU_NOR, 
    ALU_XOR, ALU_SUBU, ALU_SLTU, ALU_PASSA, ALU_LUI, 
    ALU_PASSB, ALU_MOVN, ALU_MOVZ
} alufunc_t;

typedef enum logic [3: 0] {
    MUL_ADD, MUL_SUB, MUL_CLO, MUL_CLZ, MUL_PASS 
} mulfunc_t;

// op
`define OP_RT           6'b000000
`define OP_ADDI         6'b001000
`define OP_ADDIU        6'b001001
`define OP_SLTI         6'b001010
`define OP_SLTIU        6'b001011
`define OP_ANDI         6'b001100
`define OP_LUI          6'b001111
`define OP_ORI          6'b001101
`define OP_XORI         6'b001110
`define OP_BEQ          6'b000100
`define OP_BNE          6'b000101
`define OP_BGEZ         6'b000001
`define OP_BGTZ         6'b000111
`define OP_BLEZ         6'b000110
// `define OP_BLTZ         6'b000001
// `define OP_BGEZAL       6'b000001
// `define OP_BLTZAL       6'b000001
`define OP_J            6'b000010
`define OP_JAL          6'b000011
`define OP_LB           6'b100000
`define OP_LBU          6'b100100
`define OP_LH           6'b100001
`define OP_LHU          6'b100101
`define OP_LW           6'b100011
`define OP_SB           6'b101000
`define OP_SH           6'b101001
`define OP_SW           6'b101011
`define OP_PRIV         6'b010000
// `define OP_MFC0         6'b010000
// `define OP_MTC0         6'b010000
`define OP_MUL          6'b011100
`define OP_LL           6'b110000
`define OP_SC           6'b111000
`define OP_TLB          6'b010000
`define OP_LWL          6'b100010
`define OP_LWR          6'b100110
`define OP_SWL          6'b101010
`define OP_SWR          6'b101110


// funct
`define F_ADD           6'b100000
`define F_ADDU          6'b100001
`define F_SUB           6'b100010
`define F_SUBU          6'b100011
`define F_SLT           6'b101010
`define F_SLTU          6'b101011
`define F_DIV           6'b011010
`define F_DIVU          6'b011011
`define F_MULT          6'b011000
`define F_MULTU         6'b011001
`define F_AND           6'b100100
`define F_NOR           6'b100111
`define F_OR            6'b100101
`define F_XOR           6'b100110
`define F_SLLV          6'b000100
`define F_SLL           6'b000000
`define F_SRAV          6'b000111
`define F_SRA           6'b000011
`define F_SRLV          6'b000110
`define F_SRL           6'b000010
`define F_JR            6'b001000
`define F_JALR          6'b001001
`define F_MFHI          6'b010000
`define F_MFLO          6'b010010
`define F_MTHI          6'b010001
`define F_MTLO          6'b010011
`define F_BREAK         6'b001101
`define F_SYSCALL       6'b001100
`define F_MOVZ          6'b001010
`define F_MOVN          6'b001011 

`define M_MUL           6'b011000
`define M_CLO           6'b100001
`define M_CLZ           6'b100000
`define M_ADD           6'b000000
`define M_ADDU          6'b000001
`define M_SUB           6'b000100
`define M_SUBU          6'b000101

`define B_BGEZ          5'b00001
`define B_BLTZ          5'b00000
`define B_BGEZAL        5'b10001
`define B_BLTZAL        5'b10000

`define C_MFC0          5'b00000
`define C_MTC0          5'b00100
`define C_ERET          6'b011000
`define C_WAIT          6'b100000
`define C_TLBR          6'b000001
`define C_TLBP          6'b001000
`define C_TLBWI         6'b000010

typedef enum logic[1:0] { REGB, IMM} alusrcb_t;
typedef enum logic[2:0] { T_BEQ, T_BNE, T_BGEZ, T_BLTZ, T_BGTZ, T_BLEZ } branch_t;

typedef enum logic [6: 0] { 
    // ADDI, ADDIU, SLTI, SLTIU, ANDI, ORI, XORI, 
    ADDU, RESERVED,
    BEQ, BNE, BGEZ, BGTZ, BLEZ, BLTZ, BGEZAL, BLTZAL, J, JAL, 
    LB, LBU, LH, LHU, LW, SB, SH, SW, MFC0, MTC0, 
    ADD, SUB, SUBU, SLT, SLTU, DIV, DIVU, MULT, MULTU, 
    AND, NOR, OR, XOR, SLLV, SLL, SRAV, SRA, SRLV, SRL, 
    JR, JALR, MFHI, MFLO, MTHI, MTLO, BREAK, SYSCALL, LUI, ERET,
    CLO, CLZ, MOVN, MOVZ, MADD, MADDU, MSUB, MSUBU, MUL,
    LL, SC, LWL, LWR, SWL, SWR, WAIT_EX, 
    TLBR, TLBP, TLBWI
} decoded_op_t;//64 left


typedef logic[4:0] creg_addr_t;
typedef logic[15:0] halfword_t;
typedef logic[31:0] m_addr_t;
typedef logic[7:0] byte_t;
typedef logic[63:0] dword_t;
typedef logic[3:0] rwen_t; // 1 word has 4 bytes

typedef enum logic { ZERO_EXT, SIGN_EXT } ext_mode;

typedef enum logic[2:0] { NOFORWARD, RESULTW, ALUOUTM, HIM, LOM, HIW, LOW, ALUSRCAE } forward_t;

typedef struct packed {
    alufunc_t alufunc;
    mulfunc_t mulfunc;
    logic memtoreg, memwrite;
    logic regwrite;
    alusrcb_t alusrc;
    logic branch;
    logic branch1, branch2;
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
    logic is_link, is_like;
    logic mul_div_r;
    logic llwrite, is_priv;
    logic delayen;
} control_t;

typedef logic [4:0] cp0_addr_t;

parameter TLB_INDEX = 4;
typedef struct packed {
    logic P;                    // 31, Probe Failure, R
    logic [30:TLB_INDEX] zero;  // [30:n], always 0
    logic [TLB_INDEX-1:0]index; // [n-1:0], TLB index, R/W
} cp0_index_t;

typedef struct packed {
    logic [31:TLB_INDEX] zero;
    logic [TLB_INDEX-1:0] random; // TLB Random Index, R
                                  // with special upper and lower bound 
} cp0_random_t;

parameter PABITS = 32;          // physical address bits
typedef struct packed {
    logic [31:PABITS - 6] fill;     // always 0, R
    logic [PABITS-7:6] pfn;         // page frame number, R/W
    logic [2:0] C;                  // Cacheability and Coherency Attribute of the page R/W
    logic D;                        // Dirty bit, R/W
    logic V;                        // Valid bit, R/W
    logic G;                        // Global bit, R/W
} cp0_entrylo_t;

typedef struct packed {
    logic[8:0]ptebase;              // Page Table Entry, R/W

    logic[18:0]badvpn2;
    // This field is written by hardware on a TLB exception. 
    // It contains bits VA 31..13 of the virtual address that caused the exception.
    // R

    logic[3:0]zero;
} cp0_context_t;

typedef struct packed {
    logic[2:0]zero_0;
    logic[15:0]mask;
    /*
    The Mask field is a bit mask in which a �?1�? bit
    indicates that the corresponding bit of the vir-
    tual address should not participate in the TLB
    match.
    R/W
    */
    logic[12:0]zero_1;
} cp0_pagemask_t;

typedef struct packed {
    logic[31:TLB_INDEX]zero;
    logic[TLB_INDEX-1:0]wired; // TLB wired boundary, R/W
} cp0_wired_t;

typedef struct packed {
    logic[18:0]vpn2;
    /*
    VA 31..13 of the virtual address (virtual page number / 2).
    This field is written by hardware on a TLB exception or
    on a TLB read, and is written by software before a TLB
    write.
    R/W
    */
    logic[4:0]zero;
    logic[7:0]asid;
    /*
    Address space identifier. This field is written by hard-
    ware on a TLB read and by software to establish the cur-
    rent ASID value for TLB write and against which TLB
    references match each entry’s TLB ASID field.
    R/W
    */
} cp0_entryhi_t;

typedef struct packed {
    logic M;        // 31, reset as 1
    logic [2:0]K23; // [30:28], fixed mapping MMU?, R/W
    logic [2:0]KU;  // [27:25], fixed mapping MMU?, R/W
    logic [14:0]zero_0; // [24:10]
    logic [2:0]MT;  // [9:7] MMU Type, R
    logic [2:0]zero_1; // [6:4]
    logic VI;       // 3, Virtual instruction cache, R
    logic [2:0]K0; // [2:0] Kseg0 cacheability and coherency attribute, R/W
} cp0_config_t;

typedef struct packed {
    logic BD;           // 31, Branch Delay Slot. Updated only if status.exl is 0. R
    logic TI;           // 30, Timer Interrupt. R
    logic [1:0] CE;     // [29:28], cp number when the coprocessor is unusable. Always 0 in this work.
    logic DC;           // 27, Disable Count register. Always 0 in this work.
    logic PCI;          // 26, Performance Counter Interrupt. Always 0 in this work.
    logic [1:0] ASE_0;  // [25:24], reserved for the MCU ASE. Always 0 in this work.
    logic IV;           // 23, 0: general(0x180); 1: special(0x200). Always 0 in this work.
    logic WP;           // 22, Watch Exception. Always 0 in this work.
    logic FDCI;         // 21, Fase Debug Channel Interrupt. Always 0 in this work.
    logic [2:0] zero_0; // [20:18]
    logic [1:0] ASE_1;  // [17:16], reserved for the MCU ASE. Always 0 in this work.
    logic [7:0] IP;     // [15:8], Interrupt Pending. [7:2] R, [1:0] R/W
    logic zero_1;       // 7
    logic [4:0] exccode;// [6:2], Exception Code. R
    logic [1:0] zero_2; // [1:0]
} cp0_cause_t;

typedef struct packed {
    logic [3:0] CU;     // [31:28], access to cp unit 3 to 0. Always 0 in this work.
    logic RP;           // 27, Reduced Rower mode. Always 0 in this work.
    logic FR;           // 26, Floating point Register mode. Always 0 in this work.
    logic RE;           // 25, Reverse Endian. Always 0 in this work.
    logic MX;           // 24, MDMX and MIPS DSP. Always 0 in this work.
    logic zero_0;       // 23
    logic BEV;          // 22, location of exception vectors. Always 1 in this work.
    logic TS;           // 21, mutiple TLB entries. Always 0 in this work.
    logic SR;           // 20, Soft Reset. Always 0 in this work.
    logic NMI;          // 19, reset due to NMI exception. Always 0 in this work.
    logic ASE;          // 18, reserved for ASE. Always 0 in this work.
    logic [1:0] IMPL;   // [17:16], implementation dependent. Always 0 in this work.
    logic [7:0] IM;     // [15:8], Interrupt Mask. R/W
    logic [2:0] zero_1; // [7:5]
    logic UM;           // 4, 0: Kernel Mode. 1: User Mode. Always 0 in this work.
    logic R0;           // 3, reserved. Always 0 in this work.
    logic ERL;          // 2, Error Level. Always 0 in this work.
    logic EXL;          // 1, Exception Level. R/W
    logic IE;           // 0, Interrupt Enable. R/W
} cp0_status_t;

typedef struct packed {
    word_t config_1; // preset
    word_t 
        desave,     // 31, EJTAG debug exception save register
        errorepc,   // 30, Program counter at last error
        taghi,      // 29, High-order portion of cache tag interface
        taglo,      // 28, Low-order portion of cache tag interface
        cacheerr,   // 27, Cache parity error control and status
        errctl,     // 26, Parity/ECC error control and status
        perfcnt,    // 25, Performance counter interface
        depc,       // 24, Program counter at last EJTAG debug exception 
        debug,      // 23, EJTAG Debug register
        reserved22, // 22, reserved
        reserved21, // 21, reserved
        reserved20, // 20, reserved
        watchhi,    // 19, Watchpoint control
        watchlo,    // 18, Watchpoint address
        lladdr;     // 17, Load linked address
    cp0_config_t
        config_;    // 16, Configuration register
    word_t 
        prid,       // 15, Processor identification and revision
        epc;        // 14, Program counter at last exception, R/W
    cp0_cause_t 
        cause;      // 13, Cause of last general exception
    cp0_status_t
        status;     // 12, Processor status and control
    word_t
        compare;    // 11, Timer interrupt control, R/W, normally write only
    cp0_entryhi_t
        entryhi;    // 10, High-order portion of the TLB entry
    word_t
        count,      // 09, Processor cycle count, R/W
        badvaddr,   // 08, Reports the address for the most recent address-related exception, R
        hwrena;     // 07, Enables access via the RDHWR instruction to selected hardware registers
    cp0_wired_t
        wired;      // 06, Controls the number of fixed ("wired") TLB entries
    cp0_pagemask_t    
        pagemask;   // 05, Control for variable page size in TLB entries
    cp0_context_t
        context_;   // 04, Pointer to page table entry in memory
    cp0_entrylo_t
        entrylo1,   // 03, Low-order portion of the TLB entry for odd-numbered virtual pages
        entrylo0;   // 02, Low-order portion of the TLB entry for even-numbered virtual pages
    cp0_random_t    
        random;     // 01, Randomly generated index into the TLB array
    cp0_index_t
        index;       // 00, Index into the TLB array
} cp0_regs_t;

`define CP0_INIT {                                      \
    32'b00_11111_000_101_111_000_101_011_0000000,       \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'h80000080,                                       \
    32'h4220,                                           \
    32'b0,                                              \
    32'b0,                                              \
    32'b0000_0000_0100_0000_0000_0000_0000_0000,        \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0,                                              \
    32'b0                                               \
};

typedef struct packed {
    logic ren;
    logic [1: 0] size;
    m_addr_t addr;
} m_r_t;

typedef struct packed {
    logic wen;
    logic [1: 0] size;
    m_addr_t addr;
    word_t wd;
} m_w_t;

typedef struct packed {
    logic en, wt;
    logic [1: 0] size;
    m_addr_t addr;
    word_t wd, rd;
} m_q_t;

typedef struct packed {
    logic wen_h, wen_l;
    word_t wd_h, wd_l;
} hilo_w_t;

typedef struct packed {
    logic wen;
    creg_addr_t addr;
    word_t wd;
} rf_w_t; // write regfile request

typedef struct packed {
    // creg_addr_t rs, rt, rd;
    decoded_op_t op;
    word_t extended_imm;
    word_t pcjump, pcbranch;
    control_t ctl;
    shamt_t shamt;
} decoded_instr_t;

typedef struct packed {
    word_t instr_;
    word_t pcplus4;
    logic exception_instr, instr_tlb_invalid, instr_tlb_refill;
    logic tlb_refill_instr;
    logic en;
    bpb_result_t pred;
    logic [`JR_ENTRY_WIDTH - 1: 0] jrtop;
} fetch_data_t;

`define EXC_BASE 32'hbfc0_0000
`define EXC_ENTRY 32'hbfc0_0380
typedef logic [7:0] interrupt_info_t;
typedef logic [11:0] exception_offset_t;
typedef logic[4:0] exc_code_t;
typedef struct packed {
    logic mod;
    logic instr;
    logic instr_tlb;
    logic load;
    logic save;
    logic load_tlb;
    logic save_tlb;
    logic sys;
    logic bp;
    logic ri;
    logic cpu;
    logic of;
    logic tr;
} exception_info_t;
typedef struct packed {
    logic valid;
    word_t location;
    word_t pc;
    logic in_delay_slot;
    exc_code_t code;
    word_t badvaddr;
} exception_t;

typedef struct packed{
    exception_info_t exc_info;
    logic in_delay_slot;
    interrupt_info_t interrupt_info; 
    word_t vaddr, pc;
    logic tlb_refill;
} exception_pipeline_t;

`define CODE_INT   5'h00  // Interrupt
`define CODE_MOD   5'h01  // TLB modification exception
`define CODE_TLBL  5'h02  // TLB exception (load or instruction fetch)
`define CODE_TLBS  5'h03  // TLB exception (store)
`define CODE_ADEL  5'h04  // Address exception (load or instruction fetch)
`define CODE_ADES  5'h05  // Address exception (store)
`define CODE_SYS   5'h08  // Syscall
`define CODE_BP    5'h09  // Breakpoint
`define CODE_RI    5'h0a  // Reserved Instruction exception
`define CODE_CPU   5'h0b  // CoProcesser Unusable exception
`define CODE_OF    5'h0c  // OVerflow
`define CODE_TR    5'h0d  // TRap


typedef struct packed {
    logic readya, readyb, ready;
} pipe_state_t;

typedef struct packed {
    decoded_instr_t instr;
    word_t pcplus4;
    logic [2: 0] cp0_sel;
    creg_addr_t srcrega, srcregb, destreg, cp0_addr;
    logic exception_instr, exception_ri, instr_tlb_invalid, instr_tlb_refill;
    logic in_delay_slot;
    bpb_result_t pred;
    //cp0_cause_t cp0_cause;
    //cp0_status_t cp0_status;
    logic [`JR_ENTRY_WIDTH - 1: 0] jrtop;
} decode_data_t;

typedef struct packed {
    decoded_instr_t instr;
    creg_addr_t writereg;
    word_t result;
    word_t hi, lo;
} wb_data_t;

typedef struct packed {
    logic valid;
    decoded_instr_t instr;
    word_t pcplus4;
    logic exception_instr, exception_ri, instr_tlb_invalid, instr_tlb_refill;
    logic taken; 
    bpb_result_t pred;
    word_t srca, srcb;
    logic [2: 0] cp0_sel;
    creg_addr_t srcrega, srcregb, destreg, cp0_addr;
    word_t result;
    logic in_delay_slot;
    word_t srchi, srclo;
    logic [`JR_ENTRY_WIDTH - 1: 0] jrtop;
    pipe_state_t state;
} issue_data_t;

typedef struct packed {
    logic valid;
    decoded_instr_t instr;
    word_t pcplus4;
    logic exception_instr, exception_ri, exception_of, instr_tlb_invalid, instr_tlb_refill;
    logic taken;
    bpb_result_t pred;
    word_t srca, srcb;
    logic [2: 0] cp0_sel;
    creg_addr_t srcrega, srcregb, destreg, cp0_addr;
    word_t result, hiresult, loresult;
    logic in_delay_slot;
    logic [`JR_ENTRY_WIDTH - 1: 0] jrtop;
    pipe_state_t state;
} exec_data_t;

typedef struct packed{
    creg_addr_t [1: 0] destreg;
    word_t [1: 0] result;
    logic [1: 0] ready;
    logic [1: 0] wen;
    logic [1: 0] lowrite, hiwrite;
    word_t [1: 0] hidata, lodata;
} bypass_upd_t;

typedef struct packed{
    logic exception_valid, is_eret, tlb_ex, branch, jump, jr;
    word_t pcexception, epc, pctlb, pcbranch, pcjump, pcjr; 
} pc_data_t;

`define JR_STACK_INIT {                                                                                             \
    32'hbfc00000, 32'hbfc00000, 32'hbfc00000, 32'hbfc00000, 32'hbfc00000, 32'hbfc00000, 32'hbfc00000, 32'hbfc00000, \
    32'hbfc00000, 32'hbfc00000, 32'hbfc00000, 32'hbfc00000, 32'hbfc00000, 32'hbfc00000, 32'hbfc00000, 32'hbfc00000  \
};

`endif