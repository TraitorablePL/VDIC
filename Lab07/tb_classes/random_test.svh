class Random_test extends uvm_test;
	
	`uvm_component_utils(Random_test)

	Env env_h;
	
/**
 * Random_test tasks and functions
 */

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		env_h = Env::type_id::create("env_h", this);
	endfunction : build_phase
	
	virtual function void start_of_simulation_phase(uvm_phase phase);
		super.start_of_simulation_phase(phase);
		uvm_top.print_topology();
	endfunction : start_of_simulation_phase
	
endclass : Random_test