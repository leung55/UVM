`ifndef DPRAM_DRIVER_SVH
`define DPRAM_DRIVER_SVH
`include "dpram_transaction.svh"

class dpram_driver extends uvm_driver#(dpram_transaction);
    `uvm_component_utils(dpram_driver)

    virtual dpram_if dpram_vif;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        assert(uvm_config_db #(virtual dpram_if)::get(.cntxt(this), .inst_name(""), .field_name("dpram_if"), .value(dpram_vif)));
    endfunction

    task main_phase(uvm_phase phase);
        dpram_transaction dpram_tx;
        forever begin
            @(posedge dpram_vif.clk);
            seq_item_port.get_next_item(dpram_tx);
            dpram_vif.write_en  <= dpram_tx.write_en;
            dpram_vif.read_en   <= dpram_tx.read_en;
            dpram_vif.w_addr    <= dpram_tx.w_addr;
            dpram_vif.r_addr    <= dpram_tx.r_addr;
            dpram_vif.datain    <= dpram_tx.datain;
            @(posedge dpram_vif.clk);
            seq_item_port.item_done();
        end
    endtask : main_phase
endclass : dpram_driver
`endif