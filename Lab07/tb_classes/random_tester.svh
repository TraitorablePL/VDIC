class Random_tester extends Base_tester;
	`uvm_component_utils(Random_tester)
	
	
/**
 * Random_tester tasks and functions
 */
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	virtual protected function bit signed [31:0] gen_data();
		case ($urandom() % 16)
			0: return 32'h00000000;
			1: return 32'hFFFFFFFF;
			2: return 32'h80000000;
			3: return 32'h7FFFFFFF;
			default: return $random;
		endcase
	endfunction

	virtual protected function bit [2:0] gen_error();
		case ($urandom() % 64)
			0: return alu_pkg::F_ERRCRC;
			1: return alu_pkg::F_ERRDATA;
			2: return alu_pkg::F_ERROP;
			default: return alu_pkg::F_ERRNONE;
		endcase
	endfunction
	
	virtual protected function bit [2:0] gen_op(input bit [2:0] err_in);
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
	
endclass : Random_tester
