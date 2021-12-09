class Env extends uvm_env;
	
	`uvm_component_utils(Env)
	
	Random_tester tester_h;
	uvm_tlm_fifo #(cmd_pack_t) cmd_f;
	Driver driver_h;
	
	Coverage coverage_h;
	Scoreboard scoreboard_h;
	Command_monitor command_monitor_h;
	Result_monitor result_monitor_h;
	
	
/**
 * Env tasks and functions
 */
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		cmd_f = new("cmd_f", this);
		tester_h = Random_tester::type_id::create("random_tester_h", this);
		driver_h = Driver::type_id::create("driver_h", this);
		coverage_h = Coverage::type_id::create("coverage_h", this);
		scoreboard_h = Scoreboard::type_id::create("scoreboard_h", this);
		command_monitor_h = Command_monitor::type_id::create("command_monitor_h", this);
		result_monitor_h = Result_monitor::type_id::create("result_monitor_h", this);
	endfunction : build_phase
	
	function void connect_phase(uvm_phase phase);
		driver_h.command_port.connect(cmd_f.get_export);
		tester_h.command_port.connect(cmd_f.put_export);
		result_monitor_h.ap.connect(scoreboard_h.analysis_export);
		command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export);
		command_monitor_h.ap.connect(coverage_h.analysis_export);
	endfunction : connect_phase
	
	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		// display created tester type
        $write("\033\[1;30m\033\[103m"); // bold black on yellow
        $write("*** Created tester type: %s", tester_h.get_type_name());
        $write("\033\[0m\n");            // back to default color
	endfunction : end_of_elaboration_phase


	
endclass : Env
