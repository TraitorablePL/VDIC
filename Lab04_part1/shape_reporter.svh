class Shape_reporter #(type T=Shape);
	
	protected static T shape_storage [$];
	
	static function void add_shape(T s);
		shape_storage.push_back(s);
	endfunction : add_shape
	
	static function void report_shapes();
		real sum = 0;
		foreach (shape_storage[i]) begin
			sum += shape_storage[i].get_area();
			shape_storage[i].print();
		end
		$display("Total area: %g\n", sum);
	endfunction : report_shapes
	
endclass : Shape_reporter