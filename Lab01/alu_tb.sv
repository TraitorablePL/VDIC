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
 * Tasks and function definitions
 */
 
task tb_init();
	
	C = 32'h00000000;
	FLAGS = 6'b000000;
	
	alu_if.init();
	rst_n = 1'b0;
	
	@(negedge clk);    
    rst_n = 1'b1;
endtask


/**
 * Test
 */

initial begin
	
	tb_init();
	
	$display("\n --- AND OPERATION ---");
	repeat (20) begin
		A = $random();
		B = $random();
		alu_if.and_op(A, B, C, FLAGS);
	end
	
	$display("\n --- OR OPERATION ---");
	repeat (20) begin
		A = $random();
		B = $random();
		alu_if.or_op(A, B, C, FLAGS);
	end
	
	$display("\n --- ADD OPERATION ---");
	repeat (20) begin
		A = $random();
		B = $random();
		alu_if.add_op(A, B, C, FLAGS);
	end
	
	$display("\n --- SUB OPERATION ---");
	repeat (20) begin
		A = $random();
		B = $random();
		alu_if.sub_op(A, B, C, FLAGS);
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
