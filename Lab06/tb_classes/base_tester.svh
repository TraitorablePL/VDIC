virtual class Base_tester extends uvm_component;
	
	`uvm_component_utils(Base_tester)
	
	virtual alu_bfm bfm;
	
	
/**
 * Base_tester tasks and functions
 */
 
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*", "bfm", bfm))
			$fatal(1, "Failed to get BFM");
	endfunction : build_phase
	
	task run_phase(uvm_phase phase);
		bit signed [31:0] A; 
		bit signed [31:0] B;
		bit [2:0] OP;
		bit [2:0] ERROR;
		bit REP;
		bit RST;
		
		phase.raise_objection(this);
		
		bfm.rst();
		bfm.DONE = 1'b0;
		
		repeat (10000) begin
			REP = ($urandom() % 32 == 0) ? 1'b1 : 1'b0;
			RST = ($urandom() % 32 == 0) ? 1'b1 : 1'b0;
			
			ERROR = gen_error();
			OP = gen_op(ERROR);
			A = gen_data();
			B = gen_data();
			
			bfm.op(A, B, OP, ERROR, RST);
			repeat(2) @(negedge bfm.clk);
			
			if(REP == 1'b1) begin
				bfm.op(A, B, OP, ERROR, RST);
				repeat(2) @(negedge bfm.clk);
			end
		end
		
		repeat (10) @(negedge bfm.clk);  
		phase.drop_objection(this);
		
	endtask : run_phase
	
	pure virtual function bit signed [31:0] gen_data();

	pure virtual function bit [2:0] gen_error();
	
	pure virtual function bit [2:0] gen_op(input bit [2:0] err_in);
	
endclass : Base_tester