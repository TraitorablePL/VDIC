class Random_command extends uvm_transaction;
	
    `uvm_object_utils(Random_command)
    
    
// Transaction variables

    rand bit signed [31:0] A;
    rand bit signed [31:0] B;
    rand bit [2:0] OP;
    rand bit [2:0] ERROR;
    rand bit RST;
    rand exp_result_t EXP_RESULT;
    

// Constraints

//virtual protected function bit signed [31:0] gen_data();
//        case ($urandom() % 16)
//            0: return 32'h00000000;
//            1: return 32'hFFFFFFFF;
//            2: return 32'h80000000;
//            3: return 32'h7FFFFFFF;
//            default: return $random;
//        endcase
//    endfunction
//
//    virtual protected function bit [2:0] gen_error();
//        case ($urandom() % 64)
//            0: return alu_pkg::F_ERRCRC;
//            1: return alu_pkg::F_ERRDATA;
//            2: return alu_pkg::F_ERROP;
//            default: return alu_pkg::F_ERRNONE;
//        endcase
//    endfunction
//    
//    virtual protected function bit [2:0] gen_op(input bit [2:0] err_in);
//        bit [1:0] op_gen;
//        op_gen = $urandom() % 4;
//        
//        if (err_in == alu_pkg::F_ERROP) begin
//            case (op_gen)
//                0: return 3'b010;
//                1: return 3'b011;
//                2: return 3'b110;
//                3: return 3'b111;
//            endcase
//        end
//        else begin
//            case (op_gen)
//                0: return alu_pkg::AND_OP;
//                1: return alu_pkg::OR_OP;
//                2: return alu_pkg::ADD_OP;
//                3: return alu_pkg::SUB_OP;
//            endcase
//        end

// Command transaction constructor
 
    function new(string name = "");
        super.new(name);
    endfunction : new
    
    
// Command transaction functions
    
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
           
    endfunction : do_compare
    
    function string convert2string();
        string s;
        s = $sformatf("\nA: 0x%08h \nB: 0x%08h \nOP: %03b \
                \nERROR: %01b \nRST: %01b \
                \nEXP_DATA: 0x%08h \nEXP_FLAGS: %04b", 
                A, B, OP, ERROR, RST, EXP_RESULT.data, EXP_RESULT.flags);
        return s;
    endfunction : convert2string
    
endclass : Random_command