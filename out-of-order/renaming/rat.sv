`include "interface.svh"
// renaming aliasing table
module rat 
    import common::*;
    import rat_pkg::*;(
    input logic clk, resetn, flush,
    renaming_intf.rat renaming,
    retire_intf.rat retire
);
    // table
    table_t mapping_table, mapping_table_new, mapping_table_temp;

    // write
    // logic [WRITE_PORTS-1:0] wen;
    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
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
        mapping_table_new = mapping_table_temp;
        // retire
        for (int i=0; i<RELEASE_PORTS; i++) begin
            for (int j=0; j<TABLE_LEN; j++) begin
                if (retire.retire[i].valid && 
                    retire.retire[i].dst == j && 
                    retire.retire[i].preg == mapping_table_new[j].id) begin
                    mapping_table_new[j].id = '0;
                    mapping_table_new[j].valid = 1'b0;
                end
            end
            if (retire.retire[i].valid && 
                retire.retire[i].dst == 7'b1000011) begin
                if (retire.retire[i].preg == mapping_table_new[7'b1000001].id) begin
                    mapping_table_new[7'b1000001].id = '0;
                    mapping_table_new[7'b1000001].valid = 1'b0;
                end
                if (retire.retire[i].preg == mapping_table_new[7'b1000010].id) begin
                    mapping_table_new[7'b1000010].id = '0;
                    mapping_table_new[7'b1000010].valid = 1'b0;
                end
            end
        end
        // write

        // for (int i=0; i<TABLE_LEN; i++) begin
        //     for (int j=0; j<MACHINE_WIDTH; j++) begin
        //         renaming.renaming_info[j].src1.valid = mapping_table_new[renaming.instr[j].src1].valid;
        //         renaming.renaming_info[j].src1.id = mapping_table_new[renaming.instr[j].src1].id;
        //         renaming.renaming_info[j].src2.valid = mapping_table_new[renaming.instr[j].src2].valid;
        //         renaming.renaming_info[j].src2.id = mapping_table_new[renaming.instr[j].src2].id;
        //         if (renaming.instr[j].valid && renaming.instr[j].dst != 0 && renaming.instr[j].dst == i) begin
        //             mapping_table_new[i].id = renaming.rob_addr_new[j];
        //             mapping_table_new[i].valid = 1'b1;
        //         end
        //     end
        // end
    end
    always_comb begin
        mapping_table_temp = mapping_table;
        for (int i=0; i<MACHINE_WIDTH; i++) begin
            renaming.renaming_info[i].src1.valid = mapping_table_temp[renaming.instr[i].src1].valid;
            renaming.renaming_info[i].src1.id = mapping_table_temp[renaming.instr[i].src1].id;
            renaming.renaming_info[i].src2.valid = mapping_table_temp[renaming.instr[i].src2].valid;
            renaming.renaming_info[i].src2.id = mapping_table_temp[renaming.instr[i].src2].id;
            for (int j=0; j<TABLE_LEN; j++) begin
                if (renaming.instr[i].valid && renaming.instr[i].dst != 0 && renaming.instr[i].dst == j) begin
                    mapping_table_temp[j].id = renaming.rob_addr_new[i];
                    mapping_table_temp[j].valid = 1'b1;
                end
            end
            if (renaming.instr[i].valid && renaming.instr[i].dst == 7'b1000011) begin
                mapping_table_temp[66].id = renaming.rob_addr_new[i];
                mapping_table_temp[66].valid = 1'b1;
                mapping_table_temp[65].id = renaming.rob_addr_new[i];
                mapping_table_temp[65].valid = 1'b1;
            end
        end
    end
    // read; mode = write first
    for (genvar i=0; i<MACHINE_WIDTH; i++) begin
        // assign renaming.renaming_info[i].src1.valid = mapping_table[renaming.instr[i].src1].valid;
        // assign renaming.renaming_info[i].src1.id = mapping_table[renaming.instr[i].src1].id;
        // assign renaming.renaming_info[i].src2.valid = mapping_table[renaming.instr[i].src2].valid;
        // assign renaming.renaming_info[i].src2.id = mapping_table[renaming.instr[i].src2].id;
        assign renaming.renaming_info[i].dst = mapping_table_temp[renaming.instr[i].dst];
    end


endmodule