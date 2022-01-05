module alu_tester_module(alu_bfm bfm);
    
    import alu_pkg::*;

////////////////////////////////////////
// ALU tester module tasks and functions
////////////////////////////////////////
	
	function bit signed [31:0] gen_data();
		case ($urandom() % 16)
			0: return 32'h00000000;
			1: return 32'hFFFFFFFF;
			2: return 32'h80000000;
			3: return 32'h7FFFFFFF;
			default: return $random;
		endcase
	endfunction

	function bit [2:0] gen_error();
		case ($urandom() % 64)
			0: return alu_pkg::F_ERRCRC;
			1: return alu_pkg::F_ERRDATA;
			2: return alu_pkg::F_ERROP;
			default: return alu_pkg::F_ERRNONE;
		endcase
	endfunction
	
	function bit [2:0] gen_op();
		bit [1:0] op_gen;
		op_gen = $urandom() % 4;
		case (op_gen)
			0: return alu_pkg::AND_OP;
			1: return alu_pkg::OR_OP;
			2: return alu_pkg::ADD_OP;
			3: return alu_pkg::SUB_OP;
		endcase
	endfunction

////////////////////////////////////////
// ALU tester module loop
////////////////////////////////////////
 
	initial begin
        cmd_pack_t cmd;
		bfm.rst();
		
		repeat (100) begin
            cmd.A = gen_data();
            cmd.B = gen_data();
            cmd.OP = gen_op();
            cmd.ERROR = gen_error();
            cmd.RST = ($urandom() % 32 == 0) ? 1'b1 : 1'b0;
			bfm.op(cmd.A, cmd.B, cmd.OP, cmd.ERROR, cmd.RST);
			repeat(2) @(negedge bfm.clk);
		end
	end

endmodule : alu_tester_module
