`ifndef DPRAM_SUBSCRIBER_SVH
`define DPRAM_SUBSCRIBER_SVH

`include "dpram_transaction.svh"
class dpram_fc_subscriber extends uvm_subscriber #(dpram_transaction);
    `uvm_component_utils(dpram_fc_subscriber)
    
    dpram_transaction dpram_tx;
    
    covergroup dpram_cg;
        w_addr_cp     :  coverpoint dpram_tx.w_addr;
        r_addr_cp     :  coverpoint dpram_tx.r_addr;
        write_en_cp   :  coverpoint dpram_tx.write_en;
        read_en_cp    :  coverpoint dpram_tx.read_en;
        datain_cp     :  coverpoint dpram_tx.datain;
        cross w_addr_cp, r_addr_cp, write_en_cp, read_en_cp, datain_cp;
    endgroup

    function new (string name, uvm_component parent);
        super.new(name, parent);
        dpram_cg = new;
    endfunction

    function void write(dpram_transaction t);
        dpram_tx = t;
        dpram_cg.sample();
    endfunction : write

endclass : dpram_fc_subscriber
`endif