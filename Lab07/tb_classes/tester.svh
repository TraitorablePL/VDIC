class Tester extends uvm_component;
	
    `uvm_component_utils(Tester)

////////////////////////////////////////
// Tester variables
////////////////////////////////////////

	uvm_put_port #(Random_command) command_port;

////////////////////////////////////////
// Tester tasks and functions
////////////////////////////////////////
	
	function void build_phase(uvm_phase phase);
		command_port = new("command_port", this);
	endfunction : build_phase
	
	task run_phase(uvm_phase phase);
		Random_command cmd;
		
		phase.raise_objection(this);
		
        cmd = new("command");
		cmd.RST = 1;
		cmd.A = '0;
		cmd.B = '0;
		cmd.ERROR = F_ERRNONE;
		cmd.OP = AND_OP;
		command_port.put(cmd);
        
        cmd = Random_command::type_id::create("command");
		
		repeat (10000) begin : tester_loop
			assert(cmd.randomize());
			command_port.put(cmd);
		end : tester_loop
		
		#500;  
		phase.drop_objection(this);
		
	endtask : run_phase

////////////////////////////////////////
// Tester constructor
////////////////////////////////////////
	 
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
endclass : Tester
