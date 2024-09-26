`ifndef DPRAM_AGENT_SVH
`define DPRAM_AGENT_SVH
`include "dpram_transaction.svh"
`include "dpram_driver.svh"
`include "dpram_monitor.svh"

typedef uvm_sequencer #(dpram_transaction) dpram_sequencer;

class dpram_agent extends uvm_agent;
    `uvm_component_utils(dpram_agent)
    uvm_analysis_port #(dpram_transaction) dpram_ap;
    
    dpram_sequencer dpram_seqr;
    dpram_driver dpram_drvr;
    dpram_monitor dpram_mntr;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        dpram_ap = new(.name("dpram_ap"), .parent(this));
        dpram_seqr = dpram_sequencer::type_id::create(.name("dpram_seqr"), .parent(this));
        dpram_drvr = dpram_driver::type_id::create(.name("dpram_drvr"), .parent(this));
        dpram_mntr = dpram_monitor::type_id::create(.name("dpram_mntr"), .parent(this));
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        dpram_drvr.seq_item_port.connect(dpram_seqr.seq_item_export);
        dpram_mntr.dpram_ap.connect(dpram_ap);
    endfunction : connect_phase
endclass : dpram_agent
`endif