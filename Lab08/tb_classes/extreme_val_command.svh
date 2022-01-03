class Extreme_val_command extends Random_command;
    
    `uvm_object_utils(Extreme_val_command)
    
////////////////////////////////////////
// Extreme val command constraints
////////////////////////////////////////

    constraint extreme_val_data {
        A dist {32'h00000000 := 1, 32'hFFFFFFFF := 1, 32'h80000000 := 1, 32'h7FFFFFFF := 1};
        B dist {32'h00000000 := 1, 32'hFFFFFFFF := 1, 32'h80000000 := 1, 32'h7FFFFFFF := 1};
    }
        
////////////////////////////////////////
// Extreme val command constructor
////////////////////////////////////////
 
    function new(string name = "");
        super.new(name);
    endfunction : new
    
endclass : Extreme_val_command
