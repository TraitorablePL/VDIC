interface alu_if(
	/* global signals */
	input logic 	clk,
	input logic 	rst_n,
	
	/* alu serial data */
	output logic 	sin,
	input logic 	sout
);


/**
 * Tasks and function definitions
 */
 
function void init();
	sin = 1'b1;
endfunction

function logic [3:0] crc_calc(input logic [67:0] d);

	logic [3:0] crc;

    crc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ 0 ^ 0;
    crc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ 0 ^ 0 ^ 0;
    crc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ 0 ^ 0 ^ 0;
    crc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ 0 ^ 0;
	
	return crc;
endfunction

task data(input logic [7:0] _data);
	
	// START bit
	@(negedge clk);
	sin = 1'b0;
	
	// DATA type bit
	@(negedge clk);
	sin = 1'b0;
	
	// DATA bits
	for(int i = 7;i >= 0; i--) begin
		@(negedge clk);
		sin = _data[i];
	end
	
	// STOP bit
	@(negedge clk);
	sin = 1'b1;
endtask

task ctrl(input logic [31:0] A, input logic [31:0] B, input logic [2:0] OP);
	
	static logic [3:0] data_crc;
	
	// START bit
	@(negedge clk);
	sin = 1'b0;
	
	// DATA type bit
	@(negedge clk);
	sin = 1'b1;
	
	@(negedge clk);
	sin = 1'b0;
	
	// OP bits
	for(int i = 2;i >= 0; i--) begin
		@(negedge clk);
		sin = OP[i];
	end
	
	$display("CRC Start %0t", $time);
	data_crc = crc_calc({B,A,OP});
	
	// CRC bits
	for(int i = 3;i >= 0; i--) begin
		@(negedge clk);
		sin = data_crc[i];
	end
	
	$display("CRC End: %0t", $time);
	
	// STOP bit
	@(negedge clk);
	sin = 1'b1;
endtask

task add(input logic [31:0] A, input logic [31:0] B);
	
	logic [3:0] crc;
	
	alu_if.data(B[31:24]);
	alu_if.data(B[23:16]);
	alu_if.data(B[15:8]);
	alu_if.data(B[7:0]);
	
	alu_if.data(A[31:24]);
	alu_if.data(A[23:16]);
	alu_if.data(A[15:8]);
	alu_if.data(A[7:0]);
	
	alu_if.ctrl(A, B, 3'b100);
	
endtask

endinterface
