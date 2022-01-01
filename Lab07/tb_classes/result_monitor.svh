class Result_monitor extends uvm_component;
	
	`uvm_component_utils(Result_monitor)
	
	uvm_analysis_port #(Result_transaction) ap;
	
	
/**
 * Result_monitor tasks and functions
 */

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		virtual alu_bfm bfm;
		
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*", "bfm", bfm))
			$fatal(1, "Failed to get BFM");
		
		bfm.result_monitor_h = this;
		ap = new("ap", this);
	endfunction : build_phase
	
	function void write_to_monitor(alu_result_t result);
        Result_transaction res_action;
        res_action = new("res_action");
        res_action.ALU_RESULT = result;
		ap.write(res_action);
	endfunction : write_to_monitor
	
endclass : Result_monitor