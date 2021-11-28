virtual class Shape;
	
	real width = -1;
	real height = -1;
	
	function new(real w, real h);
		width = w;
		height = h;
	endfunction : new
	
	pure virtual function real get_area();
	pure virtual function void print();
	
endclass : Shape