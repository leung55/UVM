
`ifndef DPRAM_ENV_SVH
`define DPRAM_ENV_SVH
`include "dpram_agent.svh"
`include "dpram_subscriber.svh"
`include "dpram_scoreboard.svh"
class dpram_env extends uvm_env;
    `uvm_component_utils(dpram_env)

    dpram_agent dpram_agt;
    dpram_fc_subscriber dpram_fc_sub;
    dpram_scoreboard dpram_sb;
    dpram_reg_block dpram_reg_blk;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        dpram_agt = dpram_agent::type_id::create(.name("dpram_agt"), .parent(this));
        dpram_fc_sub = dpram_fc_subscriber::type_id::create(.name("dpram_fc_sub"), .parent(this));
        dpram_sb = dpram_scoreboard::type_id::create(.name("dpram_sb"), .parent(this));
        dpram_reg_blk = dpram_reg_block::type_id::create(.name("dpram_reg_blk"), .parent(this));
        dpram_reg_blk.build();
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        dpram_agt.dpram_ap.connect(dpram_fc_sub.analysis_export);
        dpram_agt.dpram_ap.connect(dpram_sb.dpram_export);
        dpram_sb.dpram_reg_blk = dpram_reg_blk;
    endfunction : connect_phase
endclass
`endif