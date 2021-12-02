class Env extends uvm_env;
	
	`uvm_component_utils(Env)
	
	Base_tester tester_h;
	Coverage coverage_h;
	Scoreboard scoreboard_h;
	
	
/**
 * Env tasks and functions
 */
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		tester_h = Base_tester::type_id::create("tester_h", this);
		coverage_h = Coverage::type_id::create("coverage_h", this);
		scoreboard_h = Scoreboard::type_id::create("scoreboard_h", this);
	endfunction : build_phase
	
endclass : Env