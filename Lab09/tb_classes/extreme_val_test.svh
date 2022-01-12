class Extreme_val_test extends Alu_base_test;
	
	`uvm_component_utils(Extreme_val_test)

////////////////////////////////////////
// Extreme val test variables
////////////////////////////////////////

local Extreme_val_sequence extreme_val_seq;

////////////////////////////////////////
// Extreme val test run phase
////////////////////////////////////////

	task run_phase(uvm_phase phase);
        extreme_val_seq = new("extreme_val_seq");
        phase.raise_objection(this);
        extreme_val_seq.start(sequencer_h);
        phase.drop_objection(this);
	endtask : run_phase

////////////////////////////////////////
// Extreme val test constructor
////////////////////////////////////////

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
endclass : Extreme_val_test