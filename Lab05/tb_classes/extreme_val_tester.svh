class Extreme_val_tester extends Random_tester;
	
	`uvm_component_utils(Extreme_val_tester)
	
	
/**
 * Extreme_val_tester tasks and functions
 */
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function bit signed [31:0] gen_data();
		case ($urandom() % 4)
			0: return 32'h00000000;
			1: return 32'hFFFFFFFF;
			2: return 32'h80000000;
			3: return 32'h7FFFFFFF;
		endcase
	endfunction
	
endclass : Extreme_val_tester
