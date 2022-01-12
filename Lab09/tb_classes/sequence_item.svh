class Sequence_item extends uvm_sequence_item;
    
////////////////////////////////////////
// Sequence item variables
////////////////////////////////////////

    rand bit signed [31:0] A;
    rand bit signed [31:0] B;
    rand bit [2:0] OP;
    rand bit [2:0] ERROR;
    rand bit RST;
    exp_result_t EXP_RESULT;
    
    alu_result_t ALU_RESULT;
    
////////////////////////////////////////
// Sequence item macro
////////////////////////////////////////

`uvm_object_utils_begin(Sequence_item)
    `uvm_field_int(A, UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(B, UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(OP, UVM_DEFAULT)
    `uvm_field_int(ERROR, UVM_DEFAULT)
    `uvm_field_int(RST, UVM_DEFAULT)
    `uvm_field_int(EXP_RESULT, UVM_DEFAULT)
    `uvm_field_int(ALU_RESULT, UVM_DEFAULT)
`uvm_object_utils_end

////////////////////////////////////////
// Sequence item constraints
////////////////////////////////////////

    constraint random_data {
        A dist {
            [32'h00000001 : 32'hFFFFFFFE] :/ 1,
            32'h00000000 :/ 1,
            32'hFFFFFFFF :/ 1,
            32'h80000000 :/ 1,
            32'h7FFFFFFF :/ 1};
        B dist {
            [32'h00000001 : 32'hFFFFFFFE] :/ 1,
            32'h00000000 :/ 1,
            32'hFFFFFFFF :/ 1,
            32'h80000000 :/ 1,
            32'h7FFFFFFF :/ 1};
        OP dist {AND_OP :/ 1, OR_OP :/ 1, ADD_OP :/ 1, SUB_OP :/ 1};
        RST dist {1'b0 :/ 80, 1'b1 :/ 20};
        ERROR dist {F_ERRNONE :/ 70, F_ERRCRC :/ 10, F_ERRDATA :/ 10, F_ERROP :/ 10};
    }

////////////////////////////////////////
// Sequence item tasks and functions
////////////////////////////////////////

    function string convert2string();
        string s;
        s = $sformatf("A: 0x%08h, B: 0x%08h, OP: %03b, ERROR: %03b, RST: %01b", A, B, OP, ERROR, RST);
        return s;
    endfunction : convert2string

////////////////////////////////////////
// Sequence item constructor
////////////////////////////////////////

    function new(string name = "");
        super.new(name);
    endfunction : new
    
endclass : Sequence_item
