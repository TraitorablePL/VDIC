import shape_pkg::*;

module top;

	Shape shape_h;
	Rectangle rectangle_h;
	Square square_h;
	Triangle triangle_h;
	
	int fd;
	string shape;
	real w;
	real h;
	
	initial begin
		fd = $fopen("lab04part1_shapes.txt", "r");
		while ($fscanf(fd, "%s %g %g", shape, w, h) == 3) begin
			shape_h = Shape_factory::make_shape(shape, w, h);
			
			case(shape)
			"rectangle" : begin
				$cast(rectangle_h, shape_h);
				Shape_reporter#(Rectangle)::add_shape(rectangle_h);
			end
			
			"square" : begin
				$cast(square_h, shape_h);
				Shape_reporter#(Square)::add_shape(square_h);
			end
			
			"triangle" : begin
				$cast(triangle_h, shape_h);
				Shape_reporter#(Triangle)::add_shape(triangle_h);
			end
		
			default:
				$fatal(1, {"Shape %s does not exist", shape});
			
			endcase
		end
		$fclose(fd);
		
		Shape_reporter#(Rectangle)::report_shapes();
		Shape_reporter#(Square)::report_shapes();
		Shape_reporter#(Triangle)::report_shapes();
	end	
	
endmodule : top