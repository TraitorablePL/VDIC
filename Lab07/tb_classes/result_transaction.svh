class Result_transaction extends uvm_transaction;
    
    `uvm_object_utils(Result_transaction)
    
////////////////////////////////////////
// Result transaction variables
////////////////////////////////////////

    rand alu_result_t ALU_RESULT;
    
////////////////////////////////////////
// Result transaction tasks and functions
////////////////////////////////////////
    
    function void do_copy(uvm_object rhs);
        Result_transaction copied_transaction_h;
       
        if(rhs == null)
            `uvm_fatal("RANDOM COMMAND", "Tried to copy form a null pointer")
           
        super.do_copy(rhs);
       
        if(!$cast(copied_transaction_h, rhs))
            `uvm_fatal("RANDOM COMMAND", "Tried to copy wrong type")
           
        ALU_RESULT = copied_transaction_h.ALU_RESULT;
       
    endfunction : do_copy
   
    function Result_transaction clone_me();
        Result_transaction clone;
        uvm_object tmp;
       
        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
       
    endfunction : clone_me
   
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
       
        Result_transaction compared_transaction_h;
        bit same;
       
        if(rhs == null)
            `uvm_fatal("RANDOM COMMAND", "Tried to do comparison to a null pointer")
           
        if(!$cast(compared_transaction_h, rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (compared_transaction_h.ALU_RESULT == ALU_RESULT);
           
    endfunction : do_compare
    
    function string convert2string();
        string s;
        s = $sformatf("\nC: 0x%08h \nFLAGS: %04b", 
                ALU_RESULT.data, ALU_RESULT.flags);
        return s;
    endfunction : convert2string

////////////////////////////////////////
// Result transaction constructor
////////////////////////////////////////
 
    function new(string name = "");
        super.new(name);
    endfunction : new
    
endclass : Result_transaction
