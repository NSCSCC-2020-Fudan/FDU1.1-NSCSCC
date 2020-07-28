`include "interface.svh"
module renaming 
    import common::*;
    import renaming_pkg::*;(
    renaming_intf.renaming self,
    rreg_intf.renaming rreg,
    ireg_intf.renaming ireg
);
    decode_pkg::decode_data_t [MACHINE_WIDTH-1:0] dataD;
    renaming_data_t [MACHINE_WIDTH-1:0] dataR;

    areg_addr_t [MACHINE_WIDTH-1:0] src1, src2, dst;
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        assign src1[i] = dataD[i].instr.src1;
    end
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        assign src2[i] = dataD[i].instr.src2;
    end
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        assign dst[i] = dataD[i].instr.dst;
    end
    struct packed {
        logic valid;
        preg_addr_t id;
    } [MACHINE_WIDTH-1:0] psrc1, psrc2, psrc1_rat, psrc2_rat, pdst_fl;
    for (genvar i = 0; i < MACHINE_WIDTH ; i++) begin
        assign psrc1_rat[i] =  self.renaming_info[i].src1;
        assign psrc2_rat[i] =  self.renaming_info[i].src2;
        assign pdst_fl[i] = self.renaming_info[i].dst;
    end
    raw_check raw_check(.psrc1_rat,
                        .psrc2_rat,
                        .pdst_fl,
                        .src1,
                        .src2,
                        .dst,
                        .psrc1,
                        .psrc2);

    // self                    
    for (genvar i = 0; i < MACHINE_WIDTH ; i++) begin
        assign dataR[i].valid = dataD[i].valid;
        assign dataR[i].dst = self.renaming_info[i].dst.id;
        assign dataR[i].src1 = psrc1[i];
        assign dataR[i].src2 = psrc2[i];
        assign dataR[i].dst_ = dataD[i].instr.dst;
        assign dataR[i].src1_ = dataD[i].instr.src1;
        assign dataR[i].src2_ = dataD[i].instr.src2;
        assign dataR[i].ctl = dataD[i].instr.ctl;
        assign dataR[i].op = dataD[i].instr.op;
        assign dataR[i].imm = dataD[i].instr.imm;
        assign dataR[i].pcplus8 = dataD[i].pcplus8;
        assign dataR[i].exception = dataD[i].exception;
    end
    
    for (genvar i = 0; i < MACHINE_WIDTH ; i++) begin
        assign self.instr[i].valid = dataD[i].valid;
        assign self.instr[i].src1 = dataD[i].instr.src1;
        assign self.instr[i].src2 = dataD[i].instr.src2;
        assign self.instr[i].dst = dataD[i].instr.dst;
        assign self.instr[i].pcplus8 = dataD[i].pcplus8;
        assign self.instr[i].ctl = dataD[i].instr.ctl;
    end
    assign dataD = rreg.dataD;
    assign ireg.dataR_new = dataR;
endmodule