
`ifndef DPRAM_TRANSACTION_SVH
`define DPRAM_TRANSACTION_SVH
`include "dpram_types_pkg.svh"
`include "uvm_macros.svh"
import dpram_types_pkg::*;
import uvm_pkg::*;
class dpram_transaction extends uvm_sequence_item;
    `uvm_object_utils(dpram_transaction)

    rand addr_t w_addr, r_addr;
    rand data_t datain;
    rand logic write_en, read_en;
    data_t dataout, r_mem_data, w_mem_data;

    constraint addr_en_con {
        w_addr          inside {[0:MAX_ADDR_VAL]};
        r_addr          inside {[0:MAX_ADDR_VAL]};
        write_en        inside {0,1};
        read_en         inside {0,1};
    }

    function new (string name = "");
        super.new(name);
    endfunction

endclass: dpram_transaction

class read_dpram_transaction extends dpram_transaction;
    `uvm_object_utils(read_dpram_transaction)
    constraint read_con {
        write_en == 0;
        read_en == 1;
    }
    function new (string name = "");
        super.new(name);
    endfunction
endclass: read_dpram_transaction

class write_dpram_transaction extends dpram_transaction;
    `uvm_object_utils(write_dpram_transaction)
    constraint write_con {
        write_en == 1;
        read_en == 0;
    }
    function new (string name = "");
        super.new(name);
    endfunction
endclass: write_dpram_transaction

class readwrite_dpram_transaction extends dpram_transaction;
    `uvm_object_utils(readwrite_dpram_transaction)
    constraint readwrite_con {
        write_en == 1;
        read_en == 1;
        r_addr == w_addr;
    }
    function new (string name = "");
        super.new(name);
    endfunction
endclass: readwrite_dpram_transaction
`endif