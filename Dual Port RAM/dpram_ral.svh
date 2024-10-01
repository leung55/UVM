
`ifndef DPRAM_RAL_SVH
`define DPRAM_RAL_SVH

import dpram_types_pkg::*;
// class dpram_mem extends uvm_reg;
//     `uvm_object_utils(dpram_mem)
//     rand uvm_reg_field word;
    
//     constraint word_con {word inside {[0:MAX_ADDR_VAL]};}
//     function new (string name = "dpram_mem");
//         super.new(.name(name), .n_bits(8), .has_coverage(UVM_NO_COVERAGE));
//     endfunction

//     virtual function void build();
//         word = uvm_reg_field::type_id::create("word");
//         word.configure(
//             .parent(this),
//             .size(BYTE),
//             .lsb_pos(0),
//             .access("RW"),
//             .volatile(1),
//             .reset(0),
//             .has_reset(1),
//             .is_rand(1),
//             .individually_accessible(1)
//         );
//     endfunction : build
// endclass : dpram_mem

class dpram_reg_block extends uvm_reg_block;
    `uvm_object_utils(dpram_reg_block)
    uvm_mem dpram_mem;
    uvm_reg_map reg_map;
    function new(string name = "dpram_reg_block");
        super.new(.name(name), .has_coverage(UVM_NO_COVERAGE));
    endfunction

    virtual function void build();
        dpram_mem = new("dpram_mem", BYTES_IN_RAM, BYTE);
        dpram_mem.add_hdl_path_slice("ram", 0, dpram_mem.get_n_bits());
        dpram_mem.configure(this);
    
        reg_map = create_map(
            .name("reg_map"),
            .base_addr(8'h00),
            .n_bytes(1),
            .endian(UVM_LITTLE_ENDIAN)
        );

        default_map = reg_map;
        reg_map.add_mem(dpram_mem, .offset(0));
        add_hdl_path("tb_top.dpram0");
        lock_model();
    endfunction
endclass

// class dpram_reg_block extends uvm_reg_block;
//     `uvm_object_utils(dpram_reg_block)
//     rand dpram_reg regs[BYTES_IN_RAM];
//     uvm_reg_map reg_map;
//     function new(string name = "dpram_reg_block");
//         super.new(.name(name), .has_coverage(UVM_NO_COVERAGE));
//     endfunction

//     virtual function void build();
//         for(int i = 0; i < BYTES_IN_RAM; i++) begin
//             regs[i] = dpram_reg::type_id::create($sformatf("regs[%0d]", i));
//             regs[i].configure(.blk_parent(this));
//             regs[i].build();
//         end
        
//         reg_map = create_map(
//             .name("reg_map"),
//             .base_addr(8'h00),
//             .n_bytes(1),
//             .endian(UVM_LITTLE_ENDIAN)
//         );

//         reg_map.

//     endfunction
// endclass

`endif