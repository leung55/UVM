`ifndef DPRAM_MONITOR_SVH
`define DPRAM_MONITOR_SVH
`include "dpram_transaction.svh"
class dpram_monitor extends uvm_monitor;
    `uvm_component_utils(dpram_monitor)

    uvm_analysis_port #(dpram_transaction) dpram_ap;
    virtual dpram_if dpram_vif;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        assert(uvm_config_db #(virtual dpram_if)::get(.cntxt(this), .inst_name(""), .field_name("dpram_if"), .value(dpram_vif)));
        dpram_ap = new(.name("dpram_ap"), .parent(this));
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            dpram_transaction dpram_tx;
            dpram_tx = dpram_transaction::type_id::create(.name("dpram_tx"), .contxt(get_full_name()));
            dpram_tx.w_addr = dpram_vif.w_addr;
            dpram_tx.r_addr = dpram_vif.r_addr;
            dpram_tx.write_en = dpram_vif.write_en;
            dpram_tx.read_en = dpram_vif.read_en;
            dpram_tx.datain = dpram_vif.datain;
            @(posedge dpram_vif.clk);
            dpram_tx.dataout = dpram_vif.dataout;
            `uvm_info("DPRAM_IF",
            $sformatf("datain: %h, r_addr: %h, w_addr: %h, wen: %d, ren: %d, dataout: %h",
                        dpram_vif.datain, dpram_vif.r_addr, dpram_vif.w_addr, dpram_vif.write_en, dpram_vif.read_en, dpram_vif.dataout), UVM_MEDIUM)
            `uvm_info("DPRAM_TX",
            $sformatf("datain: %h, r_addr: %h, w_addr: %h, wen: %d, ren: %d, dataout: %h",
                        dpram_tx.datain, dpram_tx.r_addr, dpram_tx.w_addr, dpram_tx.write_en, dpram_tx.read_en, dpram_tx.dataout), UVM_MEDIUM)          
            dpram_ap.write(dpram_tx);
        end
    endtask : run_phase
endclass : dpram_monitor
`endif