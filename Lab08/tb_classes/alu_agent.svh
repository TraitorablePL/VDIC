class Alu_agent extends uvm_agent;
	
	`uvm_component_utils(Alu_agent)

////////////////////////////////////////
// ALU Agent variables
////////////////////////////////////////

    Alu_agent_config alu_agent_config_h;

	Tester tester_h;
    Driver driver_h;
    Scoreboard scoreboard_h;
	Coverage coverage_h;
	Command_monitor command_monitor_h;
	Result_monitor result_monitor_h;
    
    uvm_tlm_fifo #(Random_command) cmd_f;
    uvm_analysis_port #(Random_command) cmd_mon_ap;
    uvm_analysis_port #(Result_transaction) result_ap;
	
////////////////////////////////////////
// ALU Agent connect phase
////////////////////////////////////////

	function void connect_phase(uvm_phase phase);
        if(alu_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            driver_h.command_port.connect(cmd_f.get_export);
            tester_h.command_port.connect(cmd_f.put_export);
        end
        
        command_monitor_h.ap.connect(cmd_mon_ap);
        result_monitor_h.ap.connect(result_ap);
		
        command_monitor_h.ap.connect(coverage_h.analysis_export);
		command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export);
        result_monitor_h.ap.connect(scoreboard_h.analysis_export);
    endfunction : connect_phase

////////////////////////////////////////
// ALU Agent build phase
////////////////////////////////////////

    function void build_phase(uvm_phase phase);
        
        if(!uvm_config_db #(Alu_agent_config)::get(this, "", "config", alu_agent_config_h))
            `uvm_fatal("AGENT", "Failed to get config object");
        
        if(alu_agent_config_h.get_is_active() == UVM_ACTIVE) begin
            cmd_f = new("cmd_f", this);
            tester_h = Tester::type_id::create("tester_h", this);
            driver_h = Driver::type_id::create("driver_h", this);
        end
        
        command_monitor_h = Command_monitor::type_id::create("command_monitor_h", this);
        result_monitor_h = Result_monitor::type_id::create("result_monitor_h", this);
        
        coverage_h = Coverage::type_id::create("coverage_h", this);
        scoreboard_h = Scoreboard::type_id::create("scoreboard_h", this);
        
        cmd_mon_ap = new("cmd_mon_ap", this);
        result_ap = new("result_ap", this);
        
    endfunction : build_phase

////////////////////////////////////////
// ALU Agent constructor
////////////////////////////////////////
		
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
		
endclass : Alu_agent
