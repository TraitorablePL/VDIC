/******************************************************************************
* Created by dstankiewicz on Nov 7, 2021
*******************************************************************************/

`timescale 1ns / 1ps

import alu_pkg::*;

module top;

/**
 * Interfaces instantiation
 */ 
 
alu_bfm bfm();
	
	
/**
 * Submodules placement
 */ 
 
tester tester(bfm);
coverage coverage(bfm);
scoreboard scoreboard(bfm);

mtm_Alu mtm_Alu(
	.clk(bfm.clk),
	.rst_n(bfm.rst_n),
	.sin(bfm.sin),
	.sout(bfm.sout)
);
	
endmodule
