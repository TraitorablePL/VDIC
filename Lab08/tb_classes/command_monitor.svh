class Command_monitor extends uvm_component;
	
	`uvm_component_utils(Command_monitor)

////////////////////////////////////////
// Command monitor variables
////////////////////////////////////////

	uvm_analysis_port #(Random_command) ap;

////////////////////////////////////////	
// Command monitor tasks and functions
////////////////////////////////////////
	
	function void write_to_monitor(cmd_pack_t cmd);
        Random_command rand_cmd;
        `uvm_info("COMMAND MONITOR", $sformatf("MONITOR: A: 0x%08h, B: 0x%08h\n OP: %03b, ERROR: %03b, RST: %01b", 
            cmd.A, cmd.B, cmd.OP, cmd.ERROR, cmd.RST), UVM_HIGH);
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
// Command monitor build phase
////////////////////////////////////////

    function void build_phase(uvm_phase phase);
        Alu_agent_config alu_agent_config_h;
        
        if(!uvm_config_db #(Alu_agent_config)::get(this, "", "config", alu_agent_config_h))
            `uvm_fatal("COMMAND MONITOR", "Failed to get CONFIG");
        
        alu_agent_config_h.bfm.command_monitor_h = this;
        ap = new("ap", this);
    endfunction : build_phase

////////////////////////////////////////
// Command monitor constructor
////////////////////////////////////////

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
endclass : Command_monitor
