class Extreme_val_sequence extends uvm_sequence #(Sequence_item);
    
    `uvm_object_utils(Extreme_val_sequence)
    
////////////////////////////////////////
// Extreme val sequence body
////////////////////////////////////////

    task body();
        `uvm_info("SEQ_EXTREME_VAL", "", UVM_MEDIUM)
        
        `uvm_do_with(req, {RST == 1'b1;})
        
        `uvm_create(req)
        
        repeat (1000) begin : extreme_val_loop
            `uvm_do_with(req, {
                A dist {32'h00000000 := 1, 32'hFFFFFFFF := 1, 32'h80000000 := 1, 32'h7FFFFFFF := 1};
                B dist {32'h00000000 := 1, 32'hFFFFFFFF := 1, 32'h80000000 := 1, 32'h7FFFFFFF := 1};
            })
        end : extreme_val_loop        
    endtask : body
        
////////////////////////////////////////
// Extreme val sequence constructor
////////////////////////////////////////
 
    function new(string name = "");
        super.new(name);
    endfunction : new
    
endclass : Extreme_val_sequence
