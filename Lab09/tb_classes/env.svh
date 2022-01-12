class Env extends uvm_env;
	
	`uvm_component_utils(Env)

////////////////////////////////////////
// Env variables
////////////////////////////////////////

	Sequencer sequencer_h;
	Coverage coverage_h;
	Scoreboard scoreboard_h;
    Driver driver_h;
	Command_monitor command_monitor_h;
	Result_monitor result_monitor_h;
	
////////////////////////////////////////
// Env connect phase
////////////////////////////////////////

	function void connect_phase(uvm_phase phase);
		driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
        command_monitor_h.ap.connect(coverage_h.analysis_export);
		command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export);
        result_monitor_h.ap.connect(scoreboard_h.analysis_export);
    endfunction : connect_phase

////////////////////////////////////////
// Env build phase
////////////////////////////////////////

    function void build_phase(uvm_phase phase);
        sequencer_h = Sequencer::type_id::create("sequencer_h", this);
        driver_h = Driver::type_id::create("driver_h", this);
        command_monitor_h = Command_monitor::type_id::create("command_monitor_h", this);
        result_monitor_h = Result_monitor::type_id::create("result_monitor_h", this);
        coverage_h = Coverage::type_id::create("coverage_h", this);
        scoreboard_h = Scoreboard::type_id::create("scoreboard_h", this);
    endfunction : build_phase

////////////////////////////////////////
// Env constructor
////////////////////////////////////////
		
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
		
endclass : Env
