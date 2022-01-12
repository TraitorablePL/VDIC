class Scoreboard extends uvm_subscriber #(Result_transaction);
	
	`uvm_component_utils(Scoreboard)
    
////////////////////////////////////////
// Scoreboard typedefs
////////////////////////////////////////

    typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result_t;

////////////////////////////////////////
// Scoreboard variables
////////////////////////////////////////

	uvm_tlm_analysis_fifo #(Sequence_item) cmd_f;
    local test_result_t tr = TEST_PASSED;

////////////////////////////////////////
// Scoreboard tasks and functions
////////////////////////////////////////
	
    protected function void print_test_result(test_result_t r);
        if(tr == TEST_PASSED) begin
            set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
            $write(" __________________________\n");
            $write("|                          |\n");
            $write("| TEST SUCCESSFULLY PASSED |\n");
            $write("|__________________________|\n");
            set_print_color(COLOR_DEFAULT);
            $write("\n");
        end
        else begin
            set_print_color(COLOR_BOLD_BLACK_ON_RED);
            $write(" __________________________\n");
            $write("|                          |\n");
            $write("| TEST SUCCESSFULLY FAILED |\n");
            $write("|__________________________|\n");
            set_print_color(COLOR_DEFAULT);
        end
    endfunction
    
    protected function Result_transaction predict_result(Sequence_item seq);
        Result_transaction predicted;
        
        predicted = new("predicted");
        
        if(seq.ERROR == F_ERRNONE)
            predicted.ALU_RESULT.data = seq.EXP_RESULT.data;
        else
            predicted.ALU_RESULT.data = '0;
            
        case(seq.ERROR) 
            F_ERRNONE : predicted.ALU_RESULT.flags = {2'b00, seq.EXP_RESULT.flags};
            F_ERROP : predicted.ALU_RESULT.flags = {F_ERROP, F_ERROP};
            F_ERRCRC : predicted.ALU_RESULT.flags = {F_ERRCRC, F_ERRCRC};
            F_ERRDATA : predicted.ALU_RESULT.flags = {F_ERRDATA, F_ERRDATA};
        endcase
            
        return predicted;
    endfunction : predict_result
    
	function void write(Result_transaction t);
		Sequence_item seq;
        Result_transaction predicted;
        string info;
        
       	if(!cmd_f.try_get(seq))
           	$fatal(1, "Missing command in self checker");
        
        predicted = predict_result(seq);

        info = {"Transaction command: \n", seq.convert2string(),
            "\nTransaction result: \n", t.convert2string(),
            "\nExpected result: \n", predicted.convert2string(), "\n"};
        
        if(!predicted.compare(t)) begin
            `uvm_error("SELF_CHECKER", {"FAIL: \n", info})
            tr = TEST_FAILED;
        end
        else
            `uvm_info("SELF_CHECKER", {"PASS: \n", info}, UVM_HIGH)
       
    endfunction : write

////////////////////////////////////////
// Scoreboard report phase
////////////////////////////////////////

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

////////////////////////////////////////
// Scoreboard build phase
////////////////////////////////////////
    
    function void build_phase(uvm_phase phase);
        cmd_f = new("cmd_f", this);
    endfunction : build_phase
    
////////////////////////////////////////
// Scoreboard constructor
////////////////////////////////////////

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : Scoreboard
