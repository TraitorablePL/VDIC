class Testbench;
	
	virtual alu_bfm bfm;
	
	function new(virtual alu_bfm b);
		bfm = b;
	endfunction : new
	
	Tester tester_h;
	Coverage coverage_h;
	Scoreboard scoreboard_h;
	
	task execute();
		
		tester_h = new(bfm);
		coverage_h = new(bfm);
		scoreboard_h = new(bfm);
		
		fork
			tester_h.execute();
			coverage_h.execute();
			scoreboard_h.execute();
		join_none
		
	endtask : execute
endclass : Testbench