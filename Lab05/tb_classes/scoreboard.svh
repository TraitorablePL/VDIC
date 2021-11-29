class Scoreboard extends uvm_component;
	`uvm_component_utils(Scoreboard)

	virtual alu_bfm bfm;
	
	
/**
 * Scoreboard tasks and functions
 */
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*", "bfm", bfm))
			$fatal(1, "Failed to get BFM");
	endfunction : build_phase

	protected function bit verify_result();
		if((bfm.ALU_RESULT.data == bfm.EXP_RESULT.data && bfm.ALU_RESULT.flags[3:0] == bfm.EXP_RESULT.flags) || 
			(bfm.ALU_RESULT.flags[5:3] == bfm.ERROR && bfm.ERROR != alu_pkg::F_ERRNONE))
			return 1'b0;
		else
			return 1'b1;
	endfunction : verify_result

	task run_phase(uvm_phase phase);
		forever begin
			@(posedge bfm.DONE);
			assert(1'b0 == verify_result()) begin
`ifdef DEBUG
			$display("\nTEST PASSED");
`endif
			end 
			else begin 
`ifdef DEBUG
			$warning("\nTEST FAILED");
`endif
			end
`ifdef DEBUG
			$display("|         OP: %03b", bfm.OP);
			$display("|          B: 0x%08h", bfm.B);
			$display("|          A: 0x%08h", bfm.A);
			$display("|          C: 0x%08h", bfm.ALU_RESULT.data);
			$display("|      FLAGS: %06b", bfm.ALU_RESULT.flags);
			$display("|      EXP_C: 0x%08h", bfm.EXP_RESULT.data);
			$display("|  EXP_FLAGS: %04b", bfm.EXP_RESULT.flags);
`endif
			@(posedge bfm.clk);
			bfm.DONE = 1'b0;
		end
	endtask : run_phase

endclass : Scoreboard
