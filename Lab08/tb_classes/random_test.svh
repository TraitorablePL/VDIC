class Random_test extends uvm_test;
	
	`uvm_component_utils(Random_test)

////////////////////////////////////////
// Random test variables
////////////////////////////////////////

	Env env_h;

////////////////////////////////////////
// Random test simulation phase
////////////////////////////////////////

	virtual function void start_of_simulation_phase(uvm_phase phase);
		super.start_of_simulation_phase(phase);
		uvm_top.print_topology();
    endfunction : start_of_simulation_phase
    
////////////////////////////////////////
// Random command build phase
////////////////////////////////////////

    function void build_phase(uvm_phase phase);
        env_h = Env::type_id::create("env_h", this);
    endfunction : build_phase

////////////////////////////////////////
// Random command constructor
////////////////////////////////////////

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : Random_test