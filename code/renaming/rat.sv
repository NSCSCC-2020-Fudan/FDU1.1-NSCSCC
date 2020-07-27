`include "interface.svh"
// renaming aliasing table
module rat 
    import common::*;
    import rat_pkg::*;(
    input logic clk, resetn,
    renaming_intf.rat renaming,
    retire_intf.rat retire
);
    // table
    table_t mapping_table, mapping_table_new;

    // write
    logic [WRITE_PORTS-1:0] wen;
    always_ff @(posedge clk) begin
        if (reset) begin
            mapping_table <= '0;
        end else begin
            mapping_table <= mapping_table_new;
        end
    end
    // get write enable
    // assign wen[WRITE_PORTS-1] = (write[WRITE_PORTS].id != '0);
    // always_comb begin
    //     for (int i=0; i<WRITE_PORTS-1; i++) begin
    //         if (write[i].id != 0) begin
    //             wen[i] = 1'b1;
    //             for (int j=i+1; j<WRITE_PORTS; j++) begin
    //                 if (write[i].id == write[j].id) begin
    //                     wen[i] = 1'b0;
    //                     break;
    //                 end
    //             end
    //         end else begin
    //             wen[i] = 1'b0;
    //         end
    //     end
    // end

    // write
    always_comb begin
        mapping_table_new = mapping_table;
        // retire
        for (int i=0; i<TABLE_LEN; i++) begin
            for (int j=0; j<RELEASE_PORTS; j++) begin
                if (retire.retire[j].valid && 
                    retire.retire[j].id == i && 
                    retire.retire[j].preg == mapping_table_new[i].id) begin
                    mapping_table_new[i].id = '0;
                    mapping_table_new[i].valid = 1'b0;
                end
            end
        end
        // write
        for (int i=0; i<TABLE_LEN; i++) begin
            for (int j=0; j<MACHINE_WIDTH; j++) begin
                if (renaming.instr[i].valid && renaming.instr[i].dst != 0 && renaming.instr[i].dst == i) begin
                    mapping_table_new[i].id = renaming.rob_addr_new[j];
                    mapping_table_new[i].valid = 1'b1;
                end
            end
        end
    end
    // read; mode = write first
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        assign renaming.renaming_info[i].src1.valid = mapping_table_new[renaming.instr.src1].valid;
        assign renaming.renaming_info[i].src1.id = mapping_table_new[renaming.instr.src1].id;
        assign renaming.renaming_info[i].src2.valid = mapping_table_new[renaming.instr.src2].valid;
        assign renaming.renaming_info[i].src2.id = mapping_table_new[renaming.instr.src2].id;
        assign renaming.renaming_info[i].dst = mapping_table_new[renaming.instr.dst].id;
    end


endmodule