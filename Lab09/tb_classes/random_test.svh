class Random_test extends Alu_base_test;
    
    `uvm_component_utils(Random_test)

////////////////////////////////////////
// Random test variables
////////////////////////////////////////

local Random_sequence random_seq;

////////////////////////////////////////
// Random test run phase
////////////////////////////////////////

    task run_phase(uvm_phase phase);
        random_seq = new("random_seq");
        phase.raise_objection(this);
        random_seq.start(sequencer_h);
        phase.drop_objection(this);
    endtask : run_phase

////////////////////////////////////////
// Random test constructor
////////////////////////////////////////

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
endclass : Random_test