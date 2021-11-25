class Shape_factory;
	
	static function Shape make_shape(string shape_type, real w, real h);
		Rectangle rectangle_h;
		Square square_h;
		Triangle triangle_h;
		
		case(shape_type)
			"rectangle" : begin
				rectangle_h = new(w, h);
				shape_pkg::Shape_reporter#(Rectangle)::add_shape(rectangle_h);
				return rectangle_h;
			end
			
			"square" : begin
				square_h = new(w);
				shape_pkg::Shape_reporter#(Square)::add_shape(square_h);
				return square_h;
			end
			
			"triangle" : begin
				triangle_h = new(w, h);
				shape_pkg::Shape_reporter#(Triangle)::add_shape(triangle_h);
				return triangle_h;
			end
			
			default:
				$fatal(1, {"Shape does not exist: ", shape_type});
		endcase
	endfunction : make_shape
	
endclass : Shape_factory