`include "dpram_if.svh"
`include "dpram_test.svh"
module tb_top;
    import uvm_pkg::*;
    bit clk, n_rst;

    dpram_if dpramif(clk);
    dpram dpram0(dpramif.dut, n_rst);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        n_rst = 0;
        #1 n_rst = 1;
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
        $dumpvars(0, top);
    end
endmodule