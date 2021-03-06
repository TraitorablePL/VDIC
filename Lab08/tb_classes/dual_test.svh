class Dual_test extends uvm_test;
	
	`uvm_component_utils(Dual_test)

////////////////////////////////////////
// Dual test variables
////////////////////////////////////////

	Env env_h;

////////////////////////////////////////
// Dual test simulation phase
////////////////////////////////////////

	function void start_of_simulation_phase(uvm_phase phase);
		super.start_of_simulation_phase(phase);
        set_print_color(COLOR_BLUE_ON_WHITE);
        this.print(uvm_default_table_printer);
        set_print_color(COLOR_DEFAULT);
    endfunction : start_of_simulation_phase
    
////////////////////////////////////////
// Dual test build phase
////////////////////////////////////////

    function void build_phase(uvm_phase phase);
        
        virtual alu_bfm class_bfm;
        virtual alu_bfm module_bfm;
        
        Env_config env_config_h;
        
        if(!uvm_config_db #(virtual alu_bfm)::get(this, "", "class_bfm", class_bfm))
            `uvm_fatal("DUAL TEST", "Failed to get CLASS BFM");
        if(!uvm_config_db #(virtual alu_bfm)::get(this, "", "module_bfm", module_bfm))
            `uvm_fatal("DUAL TEST", "Failed to get MODULE BFM");
        
        env_config_h = new(.class_bfm(class_bfm), .module_bfm(module_bfm));
        
        uvm_config_db #(Env_config)::set(this, "env_h*", "config", env_config_h);
        
        env_h = Env::type_id::create("env_h", this);
    endfunction : build_phase

////////////////////////////////////////
// Dual test constructor
////////////////////////////////////////

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : Dual_test