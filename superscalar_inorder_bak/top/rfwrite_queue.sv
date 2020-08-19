`include "mips.svh"

module rfwrite_queue(
        input logic clk, reset,
        input rf_w_t [1: 0] rfw,
        input word_t [1: 0] rt_pc,
        output rf_w_t rfw_out,
        output word_t rt_pc_out 
    );
    
    logic [9: 0] head, headplus1, headplus2; 
    logic [9: 0] tail, tailplus1, tailplus2;
    logic [1023: 0] en_queue;
    rf_w_t [1023: 0] rf_queue;
    word_t [1023: 0] pc_queue;
    
    assign headplus1 = head + 3'b001;
    assign tailplus1 = tail + 3'b001;
    assign headplus2 = head + 3'b010;
    assign tailplus2 = tail + 3'b010;
    
    always_ff @(posedge clk)
        begin
            if (~reset)
                begin
                    head = '0;
                    tail = '0;
                    rf_queue = '0;
                    pc_queue = '0;       
                    en_queue = '0;
                    rfw_out = '0;     
                    rt_pc_out = '0; 
                end
            else
                begin
                    case ({rfw[1].wen, rfw[0].wen})
                        2'b01:
                            begin
                                rf_queue[tail] = rfw[0];
                                pc_queue[tail] = rt_pc[0];
                                en_queue[tail] = 1'b1;
                            end
                        2'b10:
                            begin
                                rf_queue[tail] = rfw[1];
                                pc_queue[tail] = rt_pc[1];
                                en_queue[tail] = 1'b1;
                            end
                        2'b11:
                            begin
                                rf_queue[tail] = rfw[1];
                                rf_queue[tailplus1] = rfw[0];
                                pc_queue[tail] = rt_pc[1];
                                pc_queue[tailplus1] = rt_pc[0];
                                en_queue[tail] = 1'b1;
                                en_queue[tailplus1] = 1'b1;
                            end
                        default: tail = tail;
                    endcase
                    
                    case ({rfw[1].wen, rfw[0].wen})
                        2'b01: tail = tailplus1;
                        2'b10: tail = tailplus1;
                        2'b11: tail = tailplus2;
                        default: tail = tail;
                    endcase
                    
                    if (en_queue[head])
                        begin
                            rfw_out = rf_queue[head];
                            rt_pc_out = pc_queue[head];
                        end
                    else
                        begin
                            rfw_out = '0;
                            rt_pc_out = '0;
                        end
                    if (en_queue[head])
                        begin
                            en_queue[head] = '0;    
                            head = headplus1;
                        end
                end
        end
    
endmodule
