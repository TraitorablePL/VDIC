class Tester;
	
	virtual alu_bfm bfm;

	/* Local data */
	bit signed [31:0] A; 
	bit signed [31:0] B;
	bit [2:0] OP;
	bit [2:0] ERROR;
	
	function new(virtual alu_bfm b);
		bfm = b;
	endfunction : new
	
	/**
	 * Data generator
	 */
	 
	protected function bit signed [31:0] gen_data();
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
	 
	protected function bit [2:0] gen_error();
		case ($urandom() % 64)
			0: return alu_pkg::F_ERRCRC;
			1: return alu_pkg::F_ERRDATA;
			2: return alu_pkg::F_ERROP;
			default: return alu_pkg::F_ERRNONE;
		endcase
	endfunction
	
	
	/**
	 * Operation generator
	 */
	 
	protected function bit [2:0] gen_op(input bit [2:0] err_in);
		bit [1:0] op_gen;
		op_gen = $urandom() % 4;
		
		if (err_in == alu_pkg::F_ERROP) begin
			case (op_gen)
				0: return 3'b010;
				1: return 3'b011;
				2: return 3'b110;
				3: return 3'b111;
			endcase
		end
		else begin
			case (op_gen)
				0: return alu_pkg::AND_OP;
				1: return alu_pkg::OR_OP;
				2: return alu_pkg::ADD_OP;
				3: return alu_pkg::SUB_OP;
			endcase
		end
	endfunction


	/**
	 * Tester
	 */
 
	task execute();
		bfm.rst();
		bfm.DONE = 1'b0;
		
		repeat (10000) begin
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
	endtask : execute

endclass : Tester
