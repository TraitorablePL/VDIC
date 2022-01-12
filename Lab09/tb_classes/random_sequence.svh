class Random_sequence extends uvm_sequence #(Sequence_item);
	
    `uvm_object_utils(Random_sequence)
    
////////////////////////////////////////
// Random sequence body
////////////////////////////////////////

    task body();
        `uvm_info("SEQ_RANDOM", "", UVM_MEDIUM)
        
        `uvm_do_with(req, {RST == 1'b1;})
        
        `uvm_create(req)
        
        repeat (1000) begin : random_loop
            `uvm_rand_send(req)
        end : random_loop        
    endtask : body

////////////////////////////////////////
// Random sequence constructor
////////////////////////////////////////

    function new(string name = "Random_sequence");
        super.new(name);
    endfunction : new
    
endclass : Random_sequence
