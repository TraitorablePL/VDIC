class Driver extends uvm_driver #(Sequence_item);
	
	`uvm_component_utils(Driver)

////////////////////////////////////////
// Driver variables
////////////////////////////////////////

	protected virtual alu_bfm bfm;

////////////////////////////////////////
// Driver run phase
////////////////////////////////////////

	task run_phase(uvm_phase phase);
		Sequence_item seq;
		alu_result_t ALU_RESULT;
        void'(begin_tr(seq));
        
		forever begin : command_loop
			seq_item_port.get_next_item(seq);
			bfm.op(seq.A, seq.B, seq.OP, seq.ERROR, seq.RST, ALU_RESULT);
            seq.ALU_RESULT = ALU_RESULT;
            seq_item_port.item_done();
		end : command_loop
    endtask : run_phase
    
////////////////////////////////////////
// Driver build phase
////////////////////////////////////////
    
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*", "bfm", bfm))
            $fatal(1, "Failed to get BFM");
    endfunction : build_phase

////////////////////////////////////////
// Driver constructor
////////////////////////////////////////

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : Driver
