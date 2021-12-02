class Add_tester extends Random_tester;
	
	`uvm_component_utils(Add_tester)
	
	
/**
 * Add_tester tasks and functions
 */
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function bit [2:0] gen_op(input bit [2:0] err_in);
		return alu_pkg::ADD_OP;
	endfunction
	
endclass : Add_tester
