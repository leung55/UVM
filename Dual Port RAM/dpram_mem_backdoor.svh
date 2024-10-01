
class dpram_mem_backdoor extends uvm_reg_backdoor;
    `uvm_object_utils(dpram_mem_backdoor)

    function new(string name = "");
        super.new(name);
    endfunction
endclass