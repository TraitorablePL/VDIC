class Shape_factory;
	
	static function Shape make_shape(string shape_type, real w, real h);
		Rectangle rectangle_h;
		Square square_h;
		Triangle triangle_h;
		
		case(shape_type)
			"rectangle" : begin
				rectangle_h = new(w, h);
				
				return rectangle_h;
			end
			
			"square" : begin
				square_h = new(w);
				return square_h;
			end
			
			"triangle" : begin
				triangle_h = new(w, h);
				return triangle_h;
			end
			
			default:
				$fatal(1, {"Shape does not exist: ", shape_type});
		endcase
	endfunction : make_shape
	
endclass : Shape_factory