/******************************************************************************
* Created by dstankiewicz on Oct 17, 2021
*******************************************************************************/

module alu_tb();

/**
 * Local variables and signals
 */

reg clk;
reg rst;

/**
 * Interfaces instantiation
 */ 
 

 

/**
 * Submodules placement
 */ 


/**
 * Test
 */


/**
 * Clock generation
 */
 
initial begin
	rst = 1'b0;
	clk = 1'b1;
	
	forever
		clk = #2.5 ~clk;
end
	
endmodule
