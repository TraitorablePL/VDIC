module tester(alu_bfm bfm);
	
import alu_pkg::*;

/* Local data */
bit signed [31:0] A; 
bit signed [31:0] B;
bit [2:0] OP;
bit [2:0] ERROR;
	
/**
 * Data generator
 */
 
function bit signed [31:0] gen_data();
	case ($urandom() % 32)
		0: return 32'h00000000;
		1: return 32'hFFFFFFFF;
		2: return 32'h80000000;
		3: return 32'h7FFFFFFF;
		default: return $random;
	endcase
endfunction


/**
 * Error generator
 */
 
function bit [2:0] gen_error();
	case ($urandom() % 64)
		0: return F_ERRCRC;
		1: return F_ERRDATA;
		2: return F_ERROP;
		default: return F_ERRNONE;
	endcase
endfunction


/**
 * Operation generator
 */
 
function bit [2:0] gen_op(input bit [2:0] err_in);
	bit [1:0] op_gen;
	op_gen = $urandom() % 4;
	
	if (err_in == F_ERROP) begin
		case (op_gen)
			0: return 3'b010;
			1: return 3'b011;
			2: return 3'b110;
			3: return 3'b111;
		endcase
	end
	else begin
		case (op_gen)
			0: return AND_OP;
			1: return OR_OP;
			2: return ADD_OP;
			3: return SUB_OP;
		endcase
	end
endfunction


/**
 * Tester
 */

initial begin : tester
	
	bfm.rst();
	bfm.DONE = 1'b0;
	
	repeat (20000) begin
		bfm.REP = ($urandom() % 32 == 0) ? 1'b1 : 1'b0;
		bfm.RST = ($urandom() % 32 == 0) ? 1'b1 : 1'b0;
		
		ERROR = gen_error();
		OP = gen_op(ERROR);
		A = gen_data();
		B = gen_data();
		
		bfm.op(A, B, OP, ERROR, bfm.ALU_RESULT);
		repeat(2) @(negedge bfm.clk);
		
		if(bfm.REP == 1'b1) begin
			bfm.op(A, B, OP, ERROR, bfm.ALU_RESULT);
			repeat(2) @(negedge bfm.clk);
		end
	end
	
	repeat (10) @(negedge bfm.clk);  
	$finish();
end : tester

endmodule
