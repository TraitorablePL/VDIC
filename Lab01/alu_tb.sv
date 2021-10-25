/******************************************************************************
* Created by dstankiewicz on Oct 17, 2021
*******************************************************************************/
`timescale 1ns / 1ps

import alu_pkg::*;

module alu_tb();

/**
 * Local variables and signals
 */

logic clk;
logic rst_n;
logic sin;
logic sout;
logic [31:0] A, B;
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
 
task tb_init();
	
	alu_if.init();
	rst_n = 1'b0;
	
	@(negedge clk);    
    rst_n = 1'b1;
endtask

task tb_verify_result(
	input logic [31:0] A, 
	input logic [31:0] B, 
	input logic [2:0] OP, 
	input rsp_t RSP,
	input logic CRC_ERR,
	input logic DATA_ERR,
	input logic OP_ERR);
	
	logic [31:0] EXP_C = 32'h00000000;
	
	case(OP)
		AND_OP:		EXP_C = B & A;
		OR_OP:		EXP_C = B | A;
		ADD_OP:		EXP_C = B + A;
		SUB_OP: 	EXP_C = B - A;
		default:	$display("|  OP NOT SUPPORTED");
	endcase
	
	$display("|  C_EXP: 0x%08h", EXP_C);
	
	if(RSP.data == EXP_C)
		$display("|\n ------> TEST PASSED <------\n\n");
	else
		$display("|\n ------> TEST FAILED <------\n\n");
endtask


/**
 * Test
 */

initial begin
	
	tb_init();
//	
//	$display("\n --- AND OPERATION ---");
//	repeat (20) begin
//		A = $random();
//		B = $random();
//		alu_if.and_op(A, B, RSP);
//		tb_verify_result(A, B, AND_OP, RSP);
//	end
//	
//	$display("\n --- OR OPERATION ---");
//	repeat (20) begin
//		A = $random();
//		B = $random();
//		alu_if.or_op(A, B, RSP);
//		tb_verify_result(A, B, OR_OP, RSP);
//	end
//	
//	$display("\n --- ADD OPERATION ---");
//	repeat (20) begin
//		A = $random();
//		B = $random();
//		alu_if.add_op(A, B, RSP);
//		tb_verify_result(A, B, ADD_OP, RSP);
//	end

	$display("\n --- INVALID OPERATION ---");
	A = $random();
	B = $random();
	alu_if.op(A, B, 3'b111, RSP, 0, 0, 0);
	tb_verify_result(A, B, 3'b111, RSP, 0, 0, 1);
	
	$display("\n --- INVALID PKG FORMAT ---");
	A = $random();
	B = $random();
	alu_if.op(A, B, ADD_OP, RSP, 0, 1, 0);
	tb_verify_result(A, B, ADD_OP, RSP, 1, 0, 0);
	
	$display("\n --- INVALID BIT ---");
	A = $random();
	B = $random();
	alu_if.op(A, B, ADD_OP, RSP, 0, 0, 1);
	tb_verify_result(A, B, ADD_OP, RSP, 1, 0, 0);
	
	$display("\n --- INVALID CRC ---");
	A = $random();
	B = $random();
	alu_if.op(A, B, ADD_OP, RSP, 1, 0, 0);
	tb_verify_result(A, B, ADD_OP, RSP, 1, 0, 0);
	
	$display("\n --- SUB OPERATION ---");
	repeat (5) begin
		A = $random();
		B = $random();
		alu_if.sub_op(A, B, RSP);
		tb_verify_result(A, B, SUB_OP, RSP, 0, 0, 0);
	end
	
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
