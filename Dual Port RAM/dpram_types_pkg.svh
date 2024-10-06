
`ifndef DPRAM_TYPES_PKG_SVH
`define DPRAM_TYPES_PKG_SVH

package dpram_types_pkg;

    parameter CLK_PERIOD = 10;

    parameter ADDR_W = 8;
    parameter MAX_ADDR_BIT = ADDR_W - 1;
    parameter MAX_ADDR_VAL = 2**ADDR_W - 1;

    parameter BYTE = 8;
    parameter MAX_BYTE_BIT = BYTE - 1;
    parameter BYTES_IN_RAM = 2**ADDR_W;
    parameter MAX_ROW_BIT = BYTES_IN_RAM - 1;

    typedef logic[MAX_ADDR_BIT:0] addr_t;
    typedef logic[MAX_BYTE_BIT:0] data_t;
    typedef data_t[MAX_ROW_BIT:0] ram_t;
endpackage
`endif