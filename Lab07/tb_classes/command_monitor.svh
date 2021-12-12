class Command_monitor extends uvm_component;
	
	`uvm_component_utils(Command_monitor)
	
	uvm_analysis_port #(cmd_pack_t) ap;
	
	
/**
 * Command_monitor tasks and functions
 */

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		virtual alu_bfm bfm;
		
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*", "bfm", bfm))
			$fatal(1, "Failed to get BFM");
		
		bfm.command_monitor_h = this;
		ap = new("ap", this);
	endfunction : build_phase
	
	function void write_to_monitor(cmd_pack_t cmd);
		ap.write(cmd);
	endfunction : write_to_monitor
	
endclass : Command_monitor