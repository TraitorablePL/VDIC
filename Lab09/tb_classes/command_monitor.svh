class Command_monitor extends uvm_component;
	
	`uvm_component_utils(Command_monitor)

////////////////////////////////////////
// Command monitor variables
////////////////////////////////////////
    
    local virtual alu_bfm bfm;
	uvm_analysis_port #(Sequence_item) ap;

////////////////////////////////////////	
// Command monitor tasks and functions
////////////////////////////////////////
	
	function void write_to_monitor(cmd_pack_t cmd);
        Sequence_item seq;
        seq = new("rand_cmd");
        seq.A = cmd.A;
        seq.B = cmd.B;
        seq.OP = cmd.OP;
        seq.ERROR = cmd.ERROR;
        seq.RST = cmd.RST;
        seq.EXP_RESULT = cmd.EXP_RESULT;
		ap.write(seq);
    endfunction : write_to_monitor

////////////////////////////////////////
// Command monitor build phase
////////////////////////////////////////

    function void build_phase(uvm_phase phase);
        
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*", "bfm", bfm))
            $fatal(1, "Failed to get BFM");
        
        ap = new("ap", this);
    endfunction : build_phase
    
////////////////////////////////////////
// Command monitor connect phase
////////////////////////////////////////

    function void connect_phase(uvm_phase phase);
        bfm.command_monitor_h = this;
    endfunction : connect_phase

////////////////////////////////////////
// Command monitor constructor
////////////////////////////////////////

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
endclass : Command_monitor
