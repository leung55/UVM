
`ifndef DPRAM_TEST_SVH
`define DPRAM_TEST_SVH
`include "dpram_environment.svh"
`include "dpram_sequences.svh"
class dpram_test extends uvm_test;
    `uvm_component_utils(dpram_test)
    dpram_env dpramenv;
    dpram_reg_block dpram_reg_blk;
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // dpram_transaction::type_id::set_type_override(readwrite_dpram_transaction::get_type());
        dpramenv = dpram_env::type_id::create(.name("dpramenv"), .parent(this));
        dpram_reg_blk = dpram_reg_block::type_id::create(.name("dpram_reg_blk"), .parent(this));
        dpram_reg_blk.build();
        uvm_config_db #(dpram_reg_block)::set(null, "uvm_test_top.*", "dpram_reg_blk", dpram_reg_blk);
    endfunction

    task check_reset_state();
        uvm_status_e status;
        uvm_reg_data_logic_t data;
        addr_t i = 0;
        repeat(BYTES_IN_RAM) begin
            dpram_reg_blk.dpram_mem.read(status, .offset(i++), .value(data), .path(UVM_BACKDOOR));
            assert(status == UVM_IS_OK);
            if(data === '0)
                `uvm_info(get_name(), "check byte reset pass\n", UVM_LOW)
            else
                `uvm_error(get_name(),"Failed reset check")
        end
    endtask
    
    //scramble values in RAM and then assert and deassert reset after a clock cycle
    task scramble_reset_dpram();
        randomize_dpram_sequence scramble_ram_seq;
        uvm_event assert_rst, release_rst;
        uvm_event_pool event_pool = uvm_event_pool::get_global_pool();
        assert_rst = event_pool.get("reset_after_scramble");
        release_rst = event_pool.get("release_reset");

        scramble_ram_seq = randomize_dpram_sequence::type_id::create(.name("scramble_ram_seq"), .contxt(get_full_name()));
        `uvm_info("scramble_ram_test", { "\n", scramble_ram_seq.sprint() }, UVM_LOW)
        scramble_ram_seq.start(dpramenv.dpram_agt.dpram_seqr);

        assert_rst.trigger;
        `uvm_info(get_type_name(), "reset triggered\n", UVM_LOW)
        release_rst.wait_trigger;
    endtask

    task main_phase(uvm_phase phase);
        multiple_dpram_sequence dpram_seq;
        

        phase.raise_objection(.obj(this));
        scramble_reset_dpram();
        check_reset_state();

        dpram_seq = multiple_dpram_sequence::type_id::create(.name("dpram_seq"), .contxt(get_full_name()));
        // assert(dpram_seq.randomize()); redundant randomization
        `uvm_info("dpram_test", { "\n", dpram_seq.sprint() }, UVM_LOW)
        dpram_seq.start(dpramenv.dpram_agt.dpram_seqr);
        #10
        phase.drop_objection(.obj(this));
    endtask : main_phase
endclass
`endif