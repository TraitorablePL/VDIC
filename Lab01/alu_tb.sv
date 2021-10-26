/******************************************************************************
* Created by dstankiewicz on Oct 17, 2021
*******************************************************************************/
`timescale 1ns / 1ps

import alu_pkg::*;

module alu_tb();

/**
 * Local variables and signals
 */
static int total, passed;
logic clk;
logic rst_n;
logic sin;
logic sout;
logic signed [31:0] A, B;
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
 * Tasks and function definitions
 */
 
task init();
	
	alu_if.init();
	rst_n = 1'b0;
	
	@(negedge clk);    
    rst_n = 1'b1;
endtask

task verify_result(
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
			$display("|  OP NOT SUPPORTED");
		end
	endcase
	
	if(RESULT_CARRY[32] == 1'b1) 
		ALU_FLAGS |= F_CARRY;
	
	if(RESULT < 0)
		ALU_FLAGS |= F_NEG;
	
	if(RESULT == 0)
		ALU_FLAGS |= F_ZERO;
	
	$display("|      C_EXP: 0x%08h", RESULT);
	
	if(ERROR)
		$display("|      ERROR: %06b", {ERROR, ERROR});
	else
		$display("|  FLAGS_EXP: %06b", ALU_FLAGS);
	
	total++;
	
	if((RSP.data == RESULT && RSP.flags[3:0] == ALU_FLAGS) || 
		RSP.flags[5:3] == ERROR && ERROR != F_ERRNONE) begin
		$display("|\n ------> TEST PASSED <------\n\n");
		passed++;
	end
	else begin
		$display("|\n ------> TEST FAILED <------\n\n");
	end
endtask


/**
 * Test
 */

initial begin
	
	init();
	
	$display("\n --- AND OPERATION ---");
	repeat (20) begin
		A = $random();
		B = $random();
		alu_if.op(A, B, AND_OP, F_ERRNONE, RSP);
		verify_result(A, B, AND_OP, F_ERRNONE, RSP);
	end
	
	$display("\n --- OR OPERATION ---");
	repeat (20) begin
		A = $random();
		B = $random();
		alu_if.op(A, B, OR_OP, F_ERRNONE, RSP);
		verify_result(A, B, OR_OP, F_ERRNONE, RSP);
	end
	
	$display("\n --- ADD OPERATION ---");
	repeat (20) begin
		A = $random();
		B = $random();
		alu_if.op(A, B, ADD_OP, F_ERRNONE, RSP);
		verify_result(A, B, ADD_OP, F_ERRNONE, RSP);
	end
	
	$display("\n --- SUB OPERATION ---");
	repeat (20) begin
		A = $random();
		B = $random();
		alu_if.op(A, B, SUB_OP, F_ERRNONE, RSP);
		verify_result(A, B, SUB_OP, F_ERRNONE, RSP);
	end

	$display("\n --- INVALID OPERATION ---");
	A = $random();
	B = $random();
	alu_if.op(A, B, 3'b111, F_ERROP, RSP);
	verify_result(A, B, 3'b111, F_ERROP, RSP);
	
	$display("\n --- INVALID PKG FORMAT ---");
	A = $random();
	B = $random();
	alu_if.op(A, B, ADD_OP, F_ERRDATA, RSP);
	verify_result(A, B, ADD_OP, F_ERRDATA, RSP);
	
	$display("\n --- INVALID CRC ---");
	A = $random();
	B = $random();
	alu_if.op(A, B, ADD_OP, F_ERRCRC, RSP);
	verify_result(A, B, ADD_OP, F_ERRCRC, RSP);
	
	$display("\n ------> SUMMARY <------\n\n");
	$display("      TOTAL: %0d ", total);
	$display("     PASSED: %0d ", passed);
	$display("     FAILED: %0d \n\n", total-passed);
		
	repeat (10) @(negedge clk);  
	
	$finish();
end


/**
 * Clock generation
 */
 
initial begin
	clk = 1'b1;
	
	forever
		clk = #2.5 ~clk;
end
	
endmodule
