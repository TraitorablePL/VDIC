class Env extends uvm_env;
	
	`uvm_component_utils(Env)

////////////////////////////////////////
// Env variables
////////////////////////////////////////

    Alu_agent class_alu_agent_h;
    Alu_agent module_alu_agent_h;
	
////////////////////////////////////////
// Env build phase
////////////////////////////////////////

    function void build_phase(uvm_phase phase);
        
        Env_config env_config_h;
        Alu_agent_config class_config_h;
        Alu_agent_config module_config_h;
        
        if(!uvm_config_db #(Env_config)::get(this, "", "config", env_config_h))
            `uvm_fatal("ENV", "Failed to get config object");
        
        class_config_h = new(.bfm(env_config_h.class_bfm), .is_active(UVM_ACTIVE));
        module_config_h = new(.bfm(env_config_h.module_bfm), .is_active(UVM_PASSIVE));
        
        uvm_config_db #(Alu_agent_config)::set(this, "class_alu_agent_h*", "config", class_config_h);
        uvm_config_db #(Alu_agent_config)::set(this, "module_alu_agent_h*", "config", module_config_h);
        
        class_alu_agent_h = Alu_agent::type_id::create("class_alu_agent_h", this);
        module_alu_agent_h = Alu_agent::type_id::create("module_alu_agent_h", this);
    endfunction : build_phase

////////////////////////////////////////
// Env constructor
////////////////////////////////////////
		
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
		
endclass : Env
