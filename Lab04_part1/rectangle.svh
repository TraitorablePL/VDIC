class Rectangle extends Shape;
	
	function new(real w, real h);
		super.new(w, h);
	endfunction : new
	
	virtual function real get_area();
		return width*height;
	endfunction : get_area
	
	virtual function void print();
		$display("Rectangle w=%g h=%g area=%g", width, height, get_area());
	endfunction : print
	
endclass : Rectangle