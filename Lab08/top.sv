module top;
	
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import alu_pkg::*;
    
////////////////////////////////////////
// Interfaces instantiation
////////////////////////////////////////

    alu_bfm bfm();
    	
////////////////////////////////////////
// Submodules placement
////////////////////////////////////////
     
    mtm_Alu mtm_Alu(
    	.clk(bfm.clk),
    	.rst_n(bfm.rst_n),
    	.sin(bfm.sin),
    	.sout(bfm.sout)
    );
    
    initial begin
    	uvm_config_db #(virtual alu_bfm)::set(null, "*", "bfm", bfm);
    	run_test();
    end

endmodule : top
