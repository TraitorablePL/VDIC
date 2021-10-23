/******************************************************************************
* Created by dstankiewicz on Oct 17, 2021
*******************************************************************************/
`timescale 1ns / 1ps

module alu_tb();

/**
 * Local variables and signals
 */

logic clk;
logic rst_n;
logic sin;
logic sout;
logic [31:0] A, B, C;
logic [5:0] FLAGS;
	
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
 * Test
 */

initial begin
	
	A = 32'h000000FF;
	B = 32'h000000FF;
	
	alu_if.init();
	rst_n = 1'b0;
	
	@(negedge clk);    
    rst_n = 1'b1;
	
	@(negedge clk);    
	alu_if.add_op(A, B, C, FLAGS);
	
	A = 32'h00003422;
	B = 32'h0022A45C;
	
	alu_if.add_op(A, B, C, FLAGS);
	
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
