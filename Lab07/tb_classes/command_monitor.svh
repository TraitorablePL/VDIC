class Command_monitor extends uvm_component;
	
	`uvm_component_utils(Command_monitor)

////////////////////////////////////////
// Command monitor variables
////////////////////////////////////////

	uvm_analysis_port #(Random_command) ap;

////////////////////////////////////////	
// Command monitor tasks and functions
////////////////////////////////////////
	
	function void build_phase(uvm_phase phase);
		virtual alu_bfm bfm;
		
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*", "bfm", bfm))
			$fatal(1, "Failed to get BFM");
		
		bfm.command_monitor_h = this;
		ap = new("ap", this);
	endfunction : build_phase
	
	function void write_to_monitor(cmd_pack_t cmd);
        Random_command rand_cmd;
        rand_cmd = new("rand_cmd");
        rand_cmd.A = cmd.A;
        rand_cmd.B = cmd.B;
        rand_cmd.OP = cmd.OP;
        rand_cmd.ERROR = cmd.ERROR;
        rand_cmd.RST = cmd.RST;
        rand_cmd.EXP_RESULT = cmd.EXP_RESULT;
		ap.write(rand_cmd);
	endfunction : write_to_monitor

////////////////////////////////////////
// Command monitor contructor
////////////////////////////////////////

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
endclass : Command_monitor
