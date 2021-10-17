/******************************************************************************
* DVT CODE TEMPLATE: testbench top module
* Created by dstankiewicz on Oct 17, 2021
* uvc_company = uvc_company, uvc_name = uvc_name
*******************************************************************************/

module apple_tb;

	reg clk;
	reg a;
	reg b;
	reg q;

	apple u_apple (
		.a  (a),
		.b  (b),
		.clk(clk),
		.q  (q)
	);

	// Generate clock
	always
		#5 clk=~clk;

	// Generate reset
	initial begin
		clk <= 1'b1;
		a <= 1'b1;
		b <= 1'b1;
		
		for(int i = 0; i < 2; i++)
			@(posedge clk);
		
		a <= 1'b0;
		b <= 1'b1;
		
		for(int i = 0; i < 2; i++)
			@(posedge clk);
		
		a <= 1'b1;
		b <= 1'b0;
		
		for(int i = 0; i < 2; i++)
			@(posedge clk);
		
		a <= 1'b0;
		b <= 1'b0;
		
		for(int i = 0; i < 2; i++)
			@(posedge clk);
	end
endmodule
