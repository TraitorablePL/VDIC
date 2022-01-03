class Alu_agent_config;
	
////////////////////////////////////////
// ALU Agent config variables
////////////////////////////////////////

	virtual alu_bfm bfm;
    protected uvm_active_passive_enum is_active;

////////////////////////////////////////
// ALU Agent config tasks and functions
////////////////////////////////////////

    function uvm_active_passive_enum get_is_active();
        return is_active;
    endfunction : get_is_active

////////////////////////////////////////
// ALU Agent config constructor
////////////////////////////////////////
		
	function new(virtual alu_bfm bfm, uvm_active_passive_enum is_active);
		this.bfm = bfm;
        this.is_active = is_active;
    endfunction : new
		
endclass : Alu_agent_config
