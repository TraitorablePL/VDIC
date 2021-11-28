class Square extends Rectangle;
	
	function new(real w);
		super.new(w, w);
	endfunction : new
	
	virtual function void print();
		$display("Square w=%g area=%g", width, get_area());
	endfunction : print
	
endclass : Square