virtual class Alu_base_test extends uvm_test;
	
////////////////////////////////////////
// ALU base test variables
////////////////////////////////////////

	local Env env_h;
    protected Sequencer sequencer_h;

////////////////////////////////////////
// ALU base test simulation phase
////////////////////////////////////////

	function void start_of_simulation_phase(uvm_phase phase);
		super.start_of_simulation_phase(phase);
		uvm_top.print_topology();
    endfunction : start_of_simulation_phase
    
////////////////////////////////////////
// ALU base test end of elaboration phase
////////////////////////////////////////

    function void end_of_elaboration_phase(uvm_phase phase);
        sequencer_h = env_h.sequencer_h;
    endfunction : end_of_elaboration_phase
    
////////////////////////////////////////
// ALU base test build phase
////////////////////////////////////////

    function void build_phase(uvm_phase phase);
        env_h = Env::type_id::create("env_h", this);
    endfunction : build_phase

////////////////////////////////////////
// ALU base test constructor
////////////////////////////////////////

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : Alu_base_test