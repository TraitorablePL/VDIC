class Env extends uvm_env;
	
	`uvm_component_utils(Env)

////////////////////////////////////////
// Env variables
////////////////////////////////////////

	Tester tester_h;
	Coverage coverage_h;
	Scoreboard scoreboard_h;
    Driver driver_h;
	Command_monitor command_monitor_h;
	Result_monitor result_monitor_h;
    uvm_tlm_fifo #(Random_command) cmd_f;
	
////////////////////////////////////////
// Env tasks and functions
////////////////////////////////////////
    
	function void build_phase(uvm_phase phase);
		cmd_f = new("cmd_f", this);
		tester_h = Tester::type_id::create("tester_h", this);
		driver_h = Driver::type_id::create("driver_h", this);
		coverage_h = Coverage::type_id::create("coverage_h", this);
		scoreboard_h = Scoreboard::type_id::create("scoreboard_h", this);
		command_monitor_h = Command_monitor::type_id::create("command_monitor_h", this);
		result_monitor_h = Result_monitor::type_id::create("result_monitor_h", this);
	endfunction : build_phase
	
    
	function void connect_phase(uvm_phase phase);
		driver_h.command_port.connect(cmd_f.get_export);
		tester_h.command_port.connect(cmd_f.put_export);
        cmd_f.put_ap.connect(coverage_h.analysis_export);
		command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export);
        result_monitor_h.ap.connect(scoreboard_h.analysis_export);
	endfunction : connect_phase

////////////////////////////////////////
// Env constructor
////////////////////////////////////////
		
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
		
endclass : Env
