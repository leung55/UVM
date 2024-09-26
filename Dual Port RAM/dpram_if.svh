
`include "dpram_types_pkg.svh"

interface dpram_if(input bit clk);
    import dpram_types_pkg::*;
    addr_t w_addr, r_addr;
    data_t datain, dataout;
    logic write_en, read_en;

    modport tb (input clk, dataout, output datain, w_addr, r_addr, write_en, read_en);
    modport dut (output dataout, input clk, datain, w_addr, r_addr, write_en, read_en);
endinterface