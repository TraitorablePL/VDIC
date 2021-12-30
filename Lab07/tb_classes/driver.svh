class Driver extends uvm_component;
	
	`uvm_component_utils(Driver)

	virtual alu_bfm bfm;
	uvm_get_port #(Random_command) command_port;
	
	
/**
 * Driver tasks and functions
 */
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*", "bfm", bfm))
			$fatal(1, "Failed to get BFM");
		command_port = new("command_port", this);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		Random_command cmd;
		
		forever begin : command_loop
			command_port.get(cmd);
			bfm.op(cmd.A, cmd.B, cmd.OP, cmd.ERROR, cmd.RST);
		end : command_loop
	endtask : run_phase

endclass : Driver
