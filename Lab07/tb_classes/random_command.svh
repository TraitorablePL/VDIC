class Random_command extends uvm_transaction;
	
    `uvm_object_utils(Random_command)
    
////////////////////////////////////////
// Random command variables
////////////////////////////////////////

    rand bit signed [31:0] A;
    rand bit signed [31:0] B;
    rand bit [2:0] OP;
    rand bit [2:0] ERROR;
    rand bit RST;
    exp_result_t EXP_RESULT;

////////////////////////////////////////
// Random command constraints
////////////////////////////////////////

    constraint random_data {
        OP dist {AND_OP := 1, OR_OP := 1, ADD_OP := 1, SUB_OP := 1};
        RST dist {1'b0 :/ 60, 1'b1 :/ 40};
        ERROR dist {F_ERRNONE :/ 70, F_ERRCRC :/ 10, F_ERRDATA :/ 10, F_ERROP :/ 10};
    }

////////////////////////////////////////
// Random command tasks and functions
////////////////////////////////////////

    function void do_copy(uvm_object rhs);
        Random_command copied_command_h;
       
        if(rhs == null)
            `uvm_fatal("RANDOM COMMAND", "Tried to copy form a null pointer")
           
        super.do_copy(rhs);
       
        if(!$cast(copied_command_h, rhs))
            `uvm_fatal("RANDOM COMMAND", "Tried to copy wrong type")
           
        A = copied_command_h.A;
        B = copied_command_h.B;
        OP = copied_command_h.OP;
        ERROR = copied_command_h.ERROR;
        RST = copied_command_h.RST;
        EXP_RESULT = copied_command_h.EXP_RESULT;
       
    endfunction : do_copy
   
    function Random_command clone_me();
        Random_command clone;
        uvm_object tmp;
       
        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
       
    endfunction : clone_me
   
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        Random_command compared_command_h;
        bit same;
       
        if(rhs == null)
            `uvm_fatal("RANDOM COMMAND", "Tried to do comparison to a null pointer")
           
        if(!$cast(compared_command_h, rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (compared_command_h.A == A) &&
            (compared_command_h.B == B) &&
            (compared_command_h.OP == OP) &&
            (compared_command_h.ERROR == ERROR) &&
            (compared_command_h.RST == RST) &&
            (compared_command_h.EXP_RESULT == EXP_RESULT);
        
        return same;
    endfunction : do_compare
    
    function string convert2string();
        string s;
        s = $sformatf("A: 0x%08h, B: 0x%08h, OP: %03b, ERROR: %03b, RST: %01b", A, B, OP, ERROR, RST);
        return s;
    endfunction : convert2string

////////////////////////////////////////
// Random command constructor
////////////////////////////////////////

    function new(string name = "");
        super.new(name);
    endfunction : new
    
endclass : Random_command
