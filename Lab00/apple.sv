/******************************************************************************
* (C) Copyright 2013 <Company Name> All Rights Reserved
*
* MODULE:    name
* DEVICE:
* PROJECT:
* AUTHOR:    dstankiewicz
* DATE:      2021 11:04:43 AM
*
* ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
*
*******************************************************************************/

module apple(
	input wire clk,
	input wire a,
	input wire b,
	output reg q
	);
	
always @(posedge clk) begin
	q <= a & b;
end
	
endmodule
