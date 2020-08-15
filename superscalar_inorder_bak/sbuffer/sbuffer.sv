`include "sbuffer.svh"

module sbuffer(
        input logic clk, reset,
        input m_q_t in,
        output m_q_t out,
        output logic sbuffer_of,
        output logic finishS,
        input decoded_op_t __op,
        //to commit
        output logic dmem_wt,
        output word_t dmem_addr, dmem_wd, 
        input word_t dmem_rd,
        output logic dmem_en,
        output logic [1: 0] dmem_size,     
        input logic dataOK
        //to memory
    );
    
    logic [`SBUFFER_SIZE - 1: 0] valid;
    m_q_t [`SBUFFER_SIZE - 1: 0] buffer;
    logic [`SBUFFER_WIDTH - 1: 0] head, tail, headplus1, tailplus1;
    assign headplus1 = head + 3'b001;
    assign tailplus1 = tail + 3'b001;
    
    assign sbuffer_of = (valid[tail] && in.en && in.wt);
    assign finishS = (~in.en) || (~valid[head] && ~in.wt && dataOK) || (in.wt && ~sbuffer_of); 
    
    always_ff @(posedge clk)
        begin
            if (~reset)
                begin
                    head <= '0;
                    tail <= '0;
                    valid <= '0; 
                end
            else
                begin
                    if (dataOK && valid[head])
                        begin
                            valid[head] = 1'b0;
                            head = headplus1;
                        end
                    if (in.en && in.wt && ~sbuffer_of)
                        begin
                            valid[tail] = 1'b1;
                            buffer[tail] = in;
                            tail = tailplus1;
                        end
                end
        end
        
    m_q_t top;
    assign top = (valid[head])     ? (buffer[head]) : (
                 (in.en && ~in.wt) ? (in)           : ('0));
    
    assign dmem_wt = top.wt;
    assign dmem_addr = top.addr;
    assign dmem_wd = top.wd;
    assign dmem_en = top.en;
    assign dmem_size = top.size;                  
    
    readdata_format readdata_format (dmem_rd, out.rd, top.addr[1: 0], __op);
    assign dmem_wt = out.wt;
    assign dmem_addr = out.addr;
    assign dmem_wd = out.wd;
    assign dmem_en = out.en;
    assign dmem_size = out.size;        
                
endmodule
