/******************************************************************************
* Created by dstankiewicz on Nov 7, 2021
*******************************************************************************/

module top;
import alu_pkg::*;

/**
 * Interfaces instantiation
 */ 
 
alu_bfm bfm();
	
	
/**
 * Submodules placement
 */
 
mtm_Alu mtm_Alu(
	.clk(bfm.clk),
	.rst_n(bfm.rst_n),
	.sin(bfm.sin),
	.sout(bfm.sout)
);
 
Testbench testbench_h;

initial begin
	testbench_h = new(bfm);
	testbench_h.execute();
end

endmodule
