`include "dpram_if.svh"
`include "dpram_test.svh"
module tb_top;
    import uvm_pkg::*;
    bit clk, n_rst;
    
    dpram_if dpramif(clk);
    dpram dpram0(dpramif.dut, n_rst);

    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        uvm_event assert_rst, release_rst;
        uvm_event_pool event_pool = uvm_event_pool::get_global_pool();
        assert_rst = event_pool.get("reset_after_scramble");
        release_rst = event_pool.get("release_reset");
        n_rst = 0;
        #1 n_rst = 1;
        assert_rst.wait_trigger;
        n_rst = 0;
        #(CLK_PERIOD) n_rst = 1;
        release_rst.trigger;
    end

    initial begin
        $monitor("DUT: datain: %h, r_addr: %h, w_addr: %h, wen: %d, ren: %d, dataout: %h", 
        dpramif.datain, dpramif.r_addr, dpramif.w_addr, dpramif.write_en, dpramif.read_en, dpramif.dataout);
        uvm_config_db #(virtual dpram_if)::set(.cntxt(null), .inst_name("uvm_test_top.*"), .field_name("dpram_if"), .value(dpramif));
        run_test("dpram_test");
        $display("DUT: datain: %h, r_addr: %h, w_addr: %h, wen: %d, ren: %d, dataout: %h", 
        dpramif.datain, dpramif.r_addr, dpramif.w_addr, dpramif.write_en, dpramif.read_en, dpramif.dataout);
    end
      // Dump waves
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);
    end
endmodule