class Triangle extends Shape;
	
	function new(real w, real h);
		super.new(w, h);
	endfunction : new
	
	virtual function real get_area();
		return (width*height)/2;
	endfunction : get_area
	
	virtual function void print();
		$display("Triangle w=%g h=%g area=%g", width, height, get_area());
	endfunction : print
	
endclass : Triangle