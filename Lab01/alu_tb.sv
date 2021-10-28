/******************************************************************************
* Created by dstankiewicz on Oct 17, 2021
*******************************************************************************/
`timescale 1ns / 1ps

import alu_pkg::*;

module alu_tb();
	
`define DEBUG

/**
 * Local variables and signals
 */

logic clk;
logic rst_n;
logic sin;
logic sout;
logic signed [31:0] A, B;

logic [4:0] err_gen;
logic [2:0] err_in;
logic [1:0] op_gen;
logic [2:0] op_in;
logic [3:0] data_gen;
logic rep_op;
	
rsp_t RSP;
	
	
/**
 * Interfaces instantiation
 */ 
 
alu_if alu_if(
	.clk,
	.rst_n,
	.sin,
	.sout
);
	
	
/**
 * Submodules placement
 */ 

mtm_Alu mtm_Alu(
	.clk,
	.rst_n,
	.sin,
	.sout
);
	
	
/**
 * Test verifier
 */

function logic verify_result(
	input logic signed [31:0] A, 
	input logic signed [31:0] B, 
	input logic [2:0] OP, 
	input logic [2:0] ERROR,
	input rsp_t RSP);
	
	logic signed [31:0] RESULT;
	logic [32:0] RESULT_CARRY;
	logic [3:0] ALU_FLAGS;
	
	ALU_FLAGS = F_NONE;
	
	case(OP)
		AND_OP:	begin
			RESULT = B & A;
			RESULT_CARRY = 33'h000000000;
		end
		OR_OP:	begin
			RESULT = B | A;
			RESULT_CARRY = 33'h000000000;
		end
		ADD_OP: begin
			RESULT = B + A;
			RESULT_CARRY = {1'b0, B} + {1'b0, A};
			
			if((A[31] == 1'b0 && B[31] == 1'b0 && RESULT[31] == 1'b1) || 
				(A[31] == 1'b1 && B[31] == 1'b1 && RESULT[31] == 1'b0))
				ALU_FLAGS |= F_OVFL;
		end
		SUB_OP: begin
			RESULT = B - A;
			RESULT_CARRY = {1'b0, B} - {1'b0, A};
			
			if((A[31] == 1'b1 && B[31] == 1'b0 && RESULT[31] == 1'b1) || 
				(A[31] == 1'b0 && B[31] == 1'b1 && RESULT[31] == 1'b0))
				ALU_FLAGS |= F_OVFL;
		end
		default: begin
			RESULT = 32'h00000000;
			RESULT_CARRY = 33'h000000000;
		end
	endcase
	
	if(RESULT_CARRY[32] == 1'b1) 
		ALU_FLAGS |= F_CARRY;
	
	if(RESULT < 0)
		ALU_FLAGS |= F_NEG;
	
	if(RESULT == 0)
		ALU_FLAGS |= F_ZERO;
	
`ifdef DEBUG
	$display("|         OP: %03b", OP);
	$display("|          B: 0x%08h", B);
	$display("|          A: 0x%08h", A);
	$display("|          C: 0x%08h", RSP.data);
	$display("|      FLAGS: %06b", RSP.flags);
	$display("|      C_EXP: 0x%08h", RESULT);
	
	if(ERROR)
		$display("|      ERROR: %06b", {ERROR, ERROR});
	else
		$display("|  FLAGS_EXP: %06b", ALU_FLAGS);
`endif
	
	if((RSP.data == RESULT && RSP.flags[3:0] == ALU_FLAGS) || 
		RSP.flags[5:3] == ERROR && ERROR != F_ERRNONE) begin
		$display("TEST PASSED\n");
		return 1'b0;
	end
	else begin
		$display("TEST FAILED\n");
		return 1'b1;
	end
endfunction


/**
 * Data generator
 */
 
function logic signed [31:0] gen_data();
	data_gen = $urandom() % 16;
	case (data_gen)
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
 
function logic [2:0] gen_error();
	err_gen = $urandom() % 64;
	case (err_gen)
		0: return F_ERRCRC;
		1: return F_ERRDATA;
		2: return F_ERROP;
		default: return F_ERRNONE;
	endcase
endfunction


/**
 * Operation generator
 */
 
function logic [2:0] gen_op(input logic [2:0] err_in);
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
	alu_if.rst();
	repeat (10000) begin
		rep_op = ($urandom() % 32 == 0) ? 1'b1 : 1'b0;
		
		err_in = gen_error();
		op_in = gen_op(err_in);
		A = gen_data();
		B = gen_data();
		
		alu_if.op(A, B, op_in, err_in, RSP);
		assert(verify_result(A, B, op_in, err_in, RSP) == 1'b0);
		
		if(rep_op == 1'b1) begin
`ifdef DEBUG
			$display("|  Repeated operation");
`endif
			alu_if.op(A, B, op_in, err_in, RSP);
			assert(verify_result(A, B, op_in, err_in, RSP) == 1'b0);
		end
	end
	
	repeat (10) @(negedge clk);  
	$finish();
end : tester

endmodule
