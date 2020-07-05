/*                
    Branch:     Branch_ContidionMode_Store                  
                00 ==; 01 !=; 10 <(0 <=; 1 <); 11: >(0 >=; 1>);
                5_bit
    JumpReg:    JumpReg_Store                           
                2_bit
    Jump:       Jump_Store                              
                2_bit
    Exception:  Exception_Mode
                0: SystemCall; 1:Break
                2_bit
    Move:       Move_Job_Reg
                0: Load; 1: Save
                0: High; 1: Low
                3_bit
    Memory:     Memory_Job_Mode_MemoryExtend
                0 Load; 1 Save;
                00 1; 01 2; 11 4;
                0 Zero; 1 Sig;
                5_bit
    Machine:    Machine_Flush_Job_Sel
                0: CP0; 1: Flush 
                0: Load; 1: Save
                6_bit
*/

module MainDec(
        input logic [31: 0] Instr,
        output logic [4: 0] Branch,
        output logic [1: 0] JumpReg, Jump,
        output logic [1: 0] Exception
        output logic [2: 0] Move,
        output logic [4: 0] Memory,
        output logic [5: 0] Machine,
        output logic [2: 0] Type
    );

    logic [5: 0] Opcode, Func;
    assign Opcode = Instr[31: 25];
    assign Func = Instr[5: 0];

    always @(*)
        begin
            {Branch, Jump, JumpReg, Exception, Move, Memory, Machine, Type} <= 25'b0;
            case(Opcode[5: 3]):
                3'b000:
                    begin
                        case(Opcode[2: 0])
                            3'b000:
                                begin
                                    case(Func)
                                        6'b001000: 
                                            {JumpReg, Type} = 5'b10_010;
                                        6'b001001: 
                                            {JumpReg, Type} = 5'b11_010;
                                        
                                        6'b001100: 
                                            {Exception, Type} = 5'b10_101;
                                        6'b001101: 
                                            {Exception, Type} = 5'b11_101;

                                        6'b010000:
                                            {Move, Type} = 6'b100_011;
                                        6'b010010:
                                            {Move, Type} = 6'b101_011;
                                        6'b010001:
                                            {Move, Type} = 6'b110_011;
                                        6'b010011:
                                            {Move, Type} = 6'b111_011;
                                        
                                        default: Type = 3'b000;
                                    endcase
                                end

                            3'b001: 
                                Branch = {1'b1, 1'b1, (Instr[21]) ? (2'b01) : (2'b10), Instr[25]};
                            3'b010: 
                                Jump = 2'b10;
                            3'b011:
                                Jump = 2'b11;
                            3'b100: 
                                Branch = 5'b1_000_0;
                            3'b101: 
                                Branch = 5'b1_010_0;
                            3'b110:
                                Branch = 5'b1_100_0;        
                            3'b111:
                                Branch = 5'b1_111_0;
                                

                        endcase
                    end
                    /*
                        Branch:     Branch_ContidionMode_Store
                                    00 =; 01 !=; 10 <(0 <=; 1 <); 11: >(0 >=; 1>);
                        Jump:       Jump_Store
                        JumpReg:    JumpReg_Store
                        Exception:  Exception_Mode
                                    0: SystemCall; 1:Break
                        Move:       Move_Job_Reg
                                    0: Load; 1: Save
                                    0: High; 1: Low
                    */

                3'b001:
                    Type = 3'b001;
                    //I-Type

                3'b100:
                    begin
                        Type = 3'100;
                        Memory = {2'b10, Opcode[1: 0], Opcode[2]};
                    end
                3'b101:
                    begin
                        Type = 3'100;
                        Memory = {2'b11, Opcode[1: 0], Opcode[2]};
                    end
                    /*
                        Memory:    Memory_Job_LoadMemory_Mode_MemoryExtend
                                   0 Load; 1 Save;
                                   00 1; 01 2; 11 4;
                                   0 Zero; 1 Sig;
                    */

                3'b010:
                    begin
                        Type = 3'b110;
                        if (Func[5: 3] == 3'b011)
                            Machine = 6'b11_0_000;
                        else
                            Machine = {2'b10, Instr[23], Instr[2: 0]};
                    end
                    /*
                        Machine:    Machine_Flush_Job_Sel
                                    0: CP0; 1: Flush 
                                    0: Load; 1: Save
                    */
            endcase
        end
endmodule