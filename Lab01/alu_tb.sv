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
	
	alu_if.init();
	rst_n = 1'b0;
	
	@(negedge clk);    
    rst_n = 1'b1;
	
	@(negedge clk);    
	alu_if.add(32'h00FFFFFF, 32'h00FFFFFF);
	
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
