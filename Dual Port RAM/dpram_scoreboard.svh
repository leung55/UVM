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
    dpram_reg_block dpram_reg_blk;
    uvm_status_e status;
    rand uvm_reg_data_logic_t data;
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
                $sformatf("datain: %h, r_addr: %h, w_addr: %h, wen: %d, ren: %d, dataout: %h",
                          dpram_tx.datain, dpram_tx.r_addr, dpram_tx.w_addr, dpram_tx.write_en, dpram_tx.read_en, dpram_tx.dataout), UVM_MEDIUM)
        if(dpram_tx.write_en == 1 && dpram_tx.read_en == 1 && dpram_tx.r_addr == dpram_tx.w_addr) begin
            if(dpram_tx.datain == dpram_tx.dataout) begin
                `uvm_info("dpram_scoreboard", {"datain matches dataout.\n", dpram_tx.sprint(p)}, UVM_LOW);
            end else begin
                `uvm_error("dpram_scoreboard", {"failed testcase.\n", dpram_tx.sprint(p)});
            end
        end
        else if(dpram_tx.write_en == 1) begin
            dpram_reg_blk.mem.read(status, .offset(dpram_tx.w_addr), .value(data), .path(UVM_BACKDOOR), .parent(this));
            if(dpram_tx.datain == data) begin
                `uvm_info("dpram_scoreboard", {"datain matches RAM byte.\n", dpram_tx.sprint(p)}, UVM_LOW);
            end else begin
                `uvm_error("dpram_scoreboard", {"failed testcase.\n", dpram_tx.sprint(p)});
            end
        end
        else if(dpram_tx.read_en == 1) begin
            dpram_reg_blk.mem.read(status, .offset(dpram_tx.r_addr), .value(data), .path(UVM_BACKDOOR), .parent(this));
            if(dpram_tx.dataout == data) begin
                `uvm_info("dpram_scoreboard", {"dataout matches RAM byte.\n", dpram_tx.sprint(p)}, UVM_LOW);
            end else begin
                `uvm_error("dpram_scoreboard", {"failed testcase.\n", dpram_tx.sprint(p)});
            end
        end
    endfunction
endclass
`endif