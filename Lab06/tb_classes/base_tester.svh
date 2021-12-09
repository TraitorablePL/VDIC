virtual class Base_tester extends uvm_component;
	
	//`uvm_component_utils(Base_tester)
	
	uvm_put_port #(cmd_pack_t) command_port;
	
	
/**
 * Base_tester tasks and functions
 */
 
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		command_port = new("command_port", this);
	endfunction : build_phase
	
	task run_phase(uvm_phase phase);
		cmd_pack_t cmd;
		
		phase.raise_objection(this);
		
		cmd.RST = 1;
		cmd.A = gen_data();
		cmd.B = gen_data();
		cmd.ERROR = F_ERRNONE;
		cmd.OP = AND_OP;
		command_port.put(cmd);
		
		repeat (10000) begin : random_loop
			cmd.RST = ($urandom() % 32 == 0) ? 1'b1 : 1'b0;
			cmd.A = gen_data();
			cmd.B = gen_data();
			cmd.ERROR = gen_error();
			cmd.OP = gen_op(cmd.ERROR);
			command_port.put(cmd);
		end : random_loop
		
		#200;  
		phase.drop_objection(this);
		
	endtask : run_phase
	
	pure virtual protected function bit signed [31:0] gen_data();
	pure virtual protected function bit [2:0] gen_error();
	pure virtual protected function bit [2:0] gen_op(input bit [2:0] err_in);
	
endclass : Base_tester