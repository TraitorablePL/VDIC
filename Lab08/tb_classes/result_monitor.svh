class Result_monitor extends uvm_component;
	
	`uvm_component_utils(Result_monitor)

////////////////////////////////////////
// Result monitor variables
////////////////////////////////////////

	uvm_analysis_port #(Result_transaction) ap;
	
////////////////////////////////////////
// Random monitor tasks and functions
////////////////////////////////////////

	function void write_to_monitor(alu_result_t result);
        Result_transaction res_action;
        res_action = new("res_action");
        res_action.ALU_RESULT = result;
		ap.write(res_action);
    endfunction : write_to_monitor
    
////////////////////////////////////////
// Random monitor build phase
////////////////////////////////////////
    
    function void build_phase(uvm_phase phase);
        Alu_agent_config alu_agent_config_h;
        
        if(!uvm_config_db #(Alu_agent_config)::get(this, "", "config", alu_agent_config_h))
            `uvm_fatal("RESULT MONITOR", "Failed to get CONFIG");
        
        alu_agent_config_h.bfm.result_monitor_h = this;
        ap = new("ap", this);
    endfunction : build_phase

////////////////////////////////////////
// Random monitor constructor
////////////////////////////////////////

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
endclass : Result_monitor
