`ifndef DPRAM_SB_SVH
`define DPRAM_SB_SVH

typedef class dpram_scoreboard;
class dpram_sb_subscriber extends uvm_subscriber #(dpram_transaction);
    `uvm_component_utils(dpram_sb_subscriber)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void write(dpram_transaction t);
        dpram_scoreboard dpram_sb;
        $cast(dpram_sb, m_parent);
        dpram_sb.check_output(t);
    endfunction
endclass

class dpram_scoreboard extends uvm_scoreboard;
    uvm_analysis_export #(dpram_transaction) dpram_export;
    local dpram_sb_subscriber dpram_sb_sub;
    `uvm_component_utils(dpram_scoreboard)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        dpram_export = new(.name("dpram_export"), .parent(this));
        dpram_sb_sub = dpram_sb_subscriber::type_id::create(.name("dpram_sb_sub"), .parent(this));
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        dpram_export.connect(dpram_sb_sub.analysis_export);
    endfunction

    virtual function void check_output(dpram_transaction dpram_tx);
        uvm_table_printer p = new;
        `uvm_info("DPRAM_TX",
                $sformatf("datain: %h, r_addr: %h, w_addr: %h, wen: %d, ren: %d, dataout: %h, r_mem_data: %h, w_mem_data: %h",
                          dpram_tx.datain, dpram_tx.r_addr, dpram_tx.w_addr, dpram_tx.write_en, dpram_tx.read_en, dpram_tx.dataout, dpram_tx.r_mem_data, dpram_tx.r_mem_data), UVM_MEDIUM)
        if(dpram_tx.write_en == 1 && dpram_tx.read_en == 1 && dpram_tx.r_addr == dpram_tx.w_addr) begin
            if(dpram_tx.datain == dpram_tx.dataout && dpram_tx.datain == dpram_tx.r_mem_data && dpram_tx.r_mem_data == dpram_tx.w_mem_data) begin
                `uvm_info("dpram_scoreboard", {"datain matches dataout.\n"/* , dpram_tx.sprint(p) */}, UVM_LOW);
            end else begin
                `uvm_error("dpram_scoreboard", {"datain doen't match dataout.\n"/* , dpram_tx.sprint(p) */});
            end
        end
        else begin
            if(dpram_tx.write_en == 1) begin
                if(dpram_tx.datain == dpram_tx.w_mem_data) begin
                    `uvm_info("dpram_scoreboard", {"datain matches RAM byte.\n"/* , dpram_tx.sprint(p) */}, UVM_LOW);
                end else begin
                    `uvm_error("dpram_scoreboard", {"datain doesn't match RAM byte.\n"/* , dpram_tx.sprint(p) */});
                end
            end
            if(dpram_tx.read_en == 1) begin
                if(dpram_tx.dataout == dpram_tx.r_mem_data) begin
                    `uvm_info("dpram_scoreboard", {"dataout matches RAM byte.\n"/* , dpram_tx.sprint(p) */}, UVM_LOW);
                end else begin
                    `uvm_error("dpram_scoreboard", {"dataout doesn't match RAM byte.\n"/* , dpram_tx.sprint(p) */});
                end
            end
        end
    endfunction
endclass
`endif