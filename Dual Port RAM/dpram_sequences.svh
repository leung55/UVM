`ifndef DPRAM_SEQUENCES_SVH
`define DPRAM_SEQUENCES_SVH

`include "dpram_types_pkg.svh"
`include "dpram_transaction.svh"
import dpram_types_pkg::*;

class one_dpram_sequence extends uvm_sequence #(dpram_transaction);
    `uvm_object_utils(one_dpram_sequence)

    function new (string name = "");
        super.new(name);
    endfunction

    task body();
        dpram_transaction dpram_tx;
        dpram_tx = dpram_transaction::type_id::create(.name("dpram_tx"), .contxt(get_full_name()));
        start_item(dpram_tx);
        assert(dpram_tx.randomize());
        `uvm_info("DPRAM_TX",
        $sformatf("datain: %h, r_addr: %h, w_addr: %h, wen: %d, ren: %d, dataout: %h",
                    dpram_tx.datain, dpram_tx.r_addr, dpram_tx.w_addr, dpram_tx.write_en, dpram_tx.read_en, dpram_tx.dataout), UVM_MEDIUM)
        finish_item(dpram_tx);
    endtask

endclass

class write_dpram_sequence extends uvm_sequence #(dpram_transaction);
    `uvm_object_utils(write_dpram_sequence)
    
    function new (string name = "");
        super.new(name);
    endfunction

    task body();
        dpram_transaction write_tx;
        write_tx = dpram_transaction::type_id::create(.name("write_tx"), .contxt(get_full_name()));
        start_item(write_tx);
        assert(write_tx.randomize() with {write_tx.write_en == 1;});
        finish_item(write_tx);
    endtask
endclass

class write_multiple_dpram_sequence extends uvm_sequence #(dpram_transaction);
    int unsigned num_write_transactions = 5;
    `uvm_object_utils(write_multiple_dpram_sequence)

    function new (string name = "");
        super.new(name);
    endfunction

    task body();
        write_dpram_sequence wr_seq;
        repeat(num_write_transactions) begin
            wr_seq = write_dpram_sequence::type_id::create(.name("wr_seq"), .contxt(get_full_name()));
            assert(wr_seq.randomize());
            wr_seq.start(.sequencer(m_sequencer), .parent_sequence(this));
        end
    endtask
endclass
`endif