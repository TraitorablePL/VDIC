module scoreboard(alu_bfm bfm);

import alu_pkg::*;


/**
 * Test verifier
 */

function logic verify_result(
	input logic signed [31:0] A, 
	input logic signed [31:0] B, 
	input logic [2:0] OP, 
	input logic [2:0] ERROR,
	input alu_result_t RSP);

	if((RSP.data == bfm.EXP_RESULT.data && RSP.flags[3:0] == bfm.EXP_RESULT.flags) || 
		(RSP.flags[5:3] == bfm.ERROR && bfm.ERROR != F_ERRNONE))
		return 1'b0;
	else
		return 1'b1;
endfunction


/**
 * Scoreboard
 */

initial begin : scoreboard
	forever begin
		@(posedge bfm.DONE);
		assert(1'b0 == verify_result(bfm.A, bfm.B, bfm.OP, bfm.ERROR, bfm.ALU_RESULT)) begin
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
end : scoreboard

endmodule
