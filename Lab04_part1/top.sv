import shape_pkg::*;

module top;

	int fd;
	string shape;
	real w;
	real h;
	
	initial begin
		fd = $fopen("lab04part1_shapes.txt", "r");
		while ($fscanf(fd, "%s %g %g", shape, w, h) == 3) begin
			Shape_factory::make_shape(shape, w, h);
		end
		$fclose(fd);
		
		Shape_reporter#(Rectangle)::report_shapes();
		Shape_reporter#(Square)::report_shapes();
		Shape_reporter#(Triangle)::report_shapes();
	end	
	
endmodule : top