class Env_config;
	
////////////////////////////////////////
// Env config variables
////////////////////////////////////////

	virtual alu_bfm class_bfm;
    virtual alu_bfm module_bfm;
	
////////////////////////////////////////
// Env config constructor
////////////////////////////////////////
		
	function new(virtual alu_bfm class_bfm, virtual alu_bfm module_bfm);
		this.class_bfm = class_bfm;
        this.module_bfm = module_bfm;
	endfunction : new
		
endclass : Env_config
