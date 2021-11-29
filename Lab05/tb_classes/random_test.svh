class Random_test extends uvm_test;
	`uvm_component_utils(Random_test);
	
	Random_tester tester_h;
	Coverage coverage_h;
	Scoreboard scoreboard_h;
	
	
/**
 * Random_test tasks and functions
 */

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		tester_h = new("tester_h", this);
		coverage_h = new("coverage_h", this);
		scoreboard_h = new("scoreboard_h", this);
	endfunction : build_phase
	
endclass : Random_test