`include "dpram_types_pkg.svh"

module dpram(dpram_if.dut dpramif, input logic n_rst);
    import dpram_types_pkg::*;

    data_t nxt_out;
    ram_t nxt_ram, ram;
    always_comb begin: nxt_dataout
        nxt_out = dpramif.dataout;
        nxt_ram = ram;
        case({dpramif.write_en, dpramif.read_en})
            2'b11: begin
                nxt_out = ram[dpramif.r_addr];
                nxt_ram[dpramif.w_addr] = dpramif.datain;
                if(dpramif.r_addr === dpramif.w_addr)
                    nxt_out = dpramif.datain;
            end
            2'b10: nxt_ram[dpramif.w_addr] = dpramif.datain;
            2'b01: nxt_out = ram[dpramif.r_addr];
        endcase
    end

    always_ff @ (posedge dpramif.clk, negedge n_rst) begin
        if(~n_rst) begin
            `uvm_info("DUT",
                $sformatf("Reset activated  datain: %h, r_addr: %h, w_addr: %h, wen: %d, ren: %d, dataout: %h",
                          dpramif.datain, dpramif.r_addr, dpramif.w_addr, dpramif.write_en, dpramif.read_en, dpramif.dataout), UVM_MEDIUM)
            dpramif.dataout <= '0;
            ram <= '0;
        end
        else begin
            `uvm_info("DUT",
                $sformatf("next clk edge datain: %h, r_addr: %h, w_addr: %h, wen: %d, ren: %d, dataout: %h",
                          dpramif.datain, dpramif.r_addr, dpramif.w_addr, dpramif.write_en, dpramif.read_en, dpramif.dataout), UVM_MEDIUM)
            dpramif.dataout <= nxt_out;
            ram <= nxt_ram;
        end
    end
endmodule