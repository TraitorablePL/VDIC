module top;
	
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import alu_pkg::*;
    
////////////////////////////////////////
// Interfaces instantiation
////////////////////////////////////////

    alu_bfm class_bfm();
    
    alu_bfm module_bfm();
    	
////////////////////////////////////////
// Submodules placement
////////////////////////////////////////
     
    mtm_Alu class_dut(
    	.clk(class_bfm.clk),
    	.rst_n(class_bfm.rst_n),
    	.sin(class_bfm.sin),
    	.sout(class_bfm.sout)
    );
    
    mtm_Alu module_dut(
        .clk(module_bfm.clk),
        .rst_n(module_bfm.rst_n),
        .sin(module_bfm.sin),
        .sout(module_bfm.sout)
    );
    
////////////////////////////////////////
// Stimulus generator for module dut
////////////////////////////////////////

alu_tester_module stim_module(module_bfm);
    
////////////////////////////////////////
// Initialization phase
////////////////////////////////////////
    
    initial begin
    	uvm_config_db #(virtual alu_bfm)::set(null, "*", "class_bfm", class_bfm);
        uvm_config_db #(virtual alu_bfm)::set(null, "*", "module_bfm", module_bfm);
    	run_test("Dual_test");
    end

endmodule : top
