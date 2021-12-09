class Scoreboard extends uvm_subscriber #(alu_result_t);
	
	`uvm_component_utils(Scoreboard)

	uvm_tlm_analysis_fifo #(cmd_pack_t) cmd_f;
	
/**
 * Scoreboard tasks and functions
 */
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		cmd_f = new("cmd_f", this);
	endfunction : build_phase

	protected function bit verify_result(cmd_pack_t CMD_PACK, alu_result_t ALU_RESULT);
		if((ALU_RESULT.data == CMD_PACK.EXP_RESULT.data && ALU_RESULT.flags[3:0] == CMD_PACK.EXP_RESULT.flags) || 
			(ALU_RESULT.flags[5:3] == CMD_PACK.ERROR && CMD_PACK.ERROR != alu_pkg::F_ERRNONE))
			return 1'b0;
		else
			return 1'b1;
	endfunction : verify_result

	function void write(alu_result_t t);
		cmd_pack_t cmd;
		
		cmd.A = 0;
		cmd.B = 0;
		cmd.OP = 0;
		cmd.RST = 0;
		cmd.ERROR = F_ERRNONE;
		cmd.EXP_RESULT.data = 0;
		cmd.EXP_RESULT.flags = F_NONE;
		
		if(!cmd_f.try_get(cmd))
			$fatal(1, "Missing command in self checker");
		
		assert(1'b0 == verify_result(cmd, t)) begin
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
		$display("|         OP: %03b", cmd.OP);
		$display("|          B: 0x%08h", cmd.B);
		$display("|          A: 0x%08h", cmd.A);
		$display("|          C: 0x%08h", t.data);
		$display("|      FLAGS: %06b", t.flags);
		$display("|      EXP_C: 0x%08h", cmd.EXP_RESULT.data);
		$display("|  EXP_FLAGS: %04b", cmd.EXP_RESULT.flags);
`endif
	endfunction : write
endclass : Scoreboard
