class Extreme_val_test extends Random_test;
	
	`uvm_component_utils(Extreme_val_test)
	
////////////////////////////////////////
// Extreme val test build phase
////////////////////////////////////////

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
        Random_command::type_id::set_type_override(Extreme_val_command::get_type());
	endfunction : build_phase

////////////////////////////////////////
// Extreme val test constructor
////////////////////////////////////////

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
endclass : Extreme_val_test