class Square extends Shape;
	
	function new(real w);
		super.new(w, w);
	endfunction : new
	
	virtual function real get_area();
		return width*height;
	endfunction : get_area
	
	virtual function void print();
		$display("Square w=%g area=%g", width, get_area());
	endfunction : print
	
endclass : Square