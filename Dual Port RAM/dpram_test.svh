
`ifndef DPRAM_TEST_SVH
`define DPRAM_TEST_SVH
`include "dpram_environment.svh"
`include "dpram_sequences.svh"
class dpram_test extends uvm_test;
    `uvm_component_utils(dpram_test)
    dpram_env dpramenv;
    
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        dpram_transaction::type_id::set_type_override(readwrite_dpram_transaction::get_type());
        dpramenv = dpram_env::type_id::create(.name("dpramenv"), .parent(this));
    endfunction

    task run_phase(uvm_phase phase);
        one_dpram_sequence dpram_seq;

        phase.raise_objection(.obj(this));
        dpram_seq = one_dpram_sequence::type_id::create(.name("dpram_seq"), .contxt(get_full_name()));
        assert(dpram_seq.randomize());
        `uvm_info("dpram_test", { "\n", dpram_seq.sprint() }, UVM_LOW)
        dpram_seq.start(dpramenv.dpram_agt.dpram_seqr);
        #10
        phase.drop_objection(.obj(this));
    endtask : run_phase
endclass
`endif