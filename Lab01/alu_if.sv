

interface alu_if(
	/* global signals */
	input logic 	clk,
	input logic 	rst_n,
	
	/* alu serial data */
	output logic 	sin,
	input logic 	sout
);
	
enum bit [2:0] {AND_OP = 3'b000, OR_OP = 3'b001, ADD_OP = 3'b100, SUB_OP = 3'b101} OP;
	
enum bit {DATA, CTL} CMD_TYPE;

typedef struct {
	logic [31:0] data;
	logic [5:0] flags;
} rsp_t;
	
/**
 * Tasks and function definitions
 */

function logic [3:0] _crc_68(input logic [67:0] D);
	
	logic [3:0] crc;

    crc[0] = D[66] ^ D[64] ^ D[63] ^ D[60] ^ D[56] ^ D[55] ^ D[54] ^ D[53] ^ D[51] ^ D[49] ^ D[48] ^ D[45] ^ D[41] ^ D[40] ^ D[39] ^ D[38] ^ D[36] ^ D[34] ^ D[33] ^ D[30] ^ D[26] ^ D[25] ^ D[24] ^ D[23] ^ D[21] ^ D[19] ^ D[18] ^ D[15] ^ D[11] ^ D[10] ^ D[9] ^ D[8] ^ D[6] ^ D[4] ^ D[3] ^ D[0] ^ 0 ^ 0;
    crc[1] = D[67] ^ D[66] ^ D[65] ^ D[63] ^ D[61] ^ D[60] ^ D[57] ^ D[53] ^ D[52] ^ D[51] ^ D[50] ^ D[48] ^ D[46] ^ D[45] ^ D[42] ^ D[38] ^ D[37] ^ D[36] ^ D[35] ^ D[33] ^ D[31] ^ D[30] ^ D[27] ^ D[23] ^ D[22] ^ D[21] ^ D[20] ^ D[18] ^ D[16] ^ D[15] ^ D[12] ^ D[8] ^ D[7] ^ D[6] ^ D[5] ^ D[3] ^ D[1] ^ D[0] ^ 0 ^ 0 ^ 0;
    crc[2] = D[67] ^ D[66] ^ D[64] ^ D[62] ^ D[61] ^ D[58] ^ D[54] ^ D[53] ^ D[52] ^ D[51] ^ D[49] ^ D[47] ^ D[46] ^ D[43] ^ D[39] ^ D[38] ^ D[37] ^ D[36] ^ D[34] ^ D[32] ^ D[31] ^ D[28] ^ D[24] ^ D[23] ^ D[22] ^ D[21] ^ D[19] ^ D[17] ^ D[16] ^ D[13] ^ D[9] ^ D[8] ^ D[7] ^ D[6] ^ D[4] ^ D[2] ^ D[1] ^ 0 ^ 0 ^ 0;
    crc[3] = D[67] ^ D[65] ^ D[63] ^ D[62] ^ D[59] ^ D[55] ^ D[54] ^ D[53] ^ D[52] ^ D[50] ^ D[48] ^ D[47] ^ D[44] ^ D[40] ^ D[39] ^ D[38] ^ D[37] ^ D[35] ^ D[33] ^ D[32] ^ D[29] ^ D[25] ^ D[24] ^ D[23] ^ D[22] ^ D[20] ^ D[18] ^ D[17] ^ D[14] ^ D[10] ^ D[9] ^ D[8] ^ D[7] ^ D[5] ^ D[3] ^ D[2] ^ 0 ^ 0;
	
	return crc;
endfunction


function logic [3:0] _crc_37(input logic [36:0] D);
	
	logic [2:0] crc;

    crc[0] = D[35] ^ D[32] ^ D[31] ^ D[30] ^ D[28] ^ D[25] ^ D[24] ^ D[23] ^ D[21] ^ D[18] ^ D[17] ^ D[16] ^ D[14] ^ D[11] ^ D[10] ^ D[9] ^ D[7] ^ D[4] ^ D[3] ^ D[2] ^ D[0] ^ 0;
    crc[1] = D[36] ^ D[35] ^ D[33] ^ D[30] ^ D[29] ^ D[28] ^ D[26] ^ D[23] ^ D[22] ^ D[21] ^ D[19] ^ D[16] ^ D[15] ^ D[14] ^ D[12] ^ D[9] ^ D[8] ^ D[7] ^ D[5] ^ D[2] ^ D[1] ^ D[0] ^ 0 ^ 0;
    crc[2] = D[36] ^ D[34] ^ D[31] ^ D[30] ^ D[29] ^ D[27] ^ D[24] ^ D[23] ^ D[22] ^ D[20] ^ D[17] ^ D[16] ^ D[15] ^ D[13] ^ D[10] ^ D[9] ^ D[8] ^ D[6] ^ D[3] ^ D[2] ^ D[1] ^ 0 ^ 0;
	
	return crc;
endfunction


/**
 * Internal ALU tasks
 */

task _tx_byte(input logic [7:0] data, input logic tx_type);
	
	if(tx_type)
		$display("TX CTL Byte Start %0t", $time);
	else
		$display("TX Data Byte Start %0t", $time);
	
	// START bit
	@(negedge clk);
	sin = 1'b0;
	
	// TYPE bit
	@(negedge clk);  
	if(tx_type)
		sin = 1'b1;
	else
		sin = 1'b0;
	
	// DATA bits
	
	for(int i = 7;i >= 0; i--) begin
		@(negedge clk);
		sin = data[i];
	end
	
	// STOP bit
	@(negedge clk);
	sin = 1'b1;
	
	$display("TX Byte Stop %0t", $time);
endtask


task _rx_detect(output logic [7:0] data, output logic rx_type);
	
	// START bit
	repeat (2) @(negedge clk);
	
	// DATA bits
	for(int i = 7;i >= 0; i--) begin
		@(negedge clk);
		data[i] = sin;
	end
	
	// STOP bit
	@(negedge clk);
	sin = 1'b1;
endtask


task _rx_byte(output logic [7:0] data);

	// START bit
	repeat (2) @(negedge clk);
	
	// DATA bits
	for(int i = 7;i >= 0; i--) begin
		@(negedge clk);
		data[i] = sin;
	end
	
	// STOP bit
	@(negedge clk);
	sin = 1'b1;
	
endtask


task _rx_rsp(rsp_t rsp_packet);
	
	logic rsp_type;
	logic [7:0] data;
	
	@(negedge sout);
	_rx_detect(data, rsp_type);

	if(rsp_type) begin
		rsp_packet.data = 32'h00000000;
		rsp_packet.flags = data[6:1];
	end
	else begin
		rsp_packet.data[31:24] = data;
		_rx_byte(data);
		rsp_packet.data[23:16] = data;
		_rx_byte(data);
		rsp_packet.data[15:8] = data;
		_rx_byte(data);
		rsp_packet.data[7:0] = data;
		_rx_byte(data);
		rsp_packet.flags = {1'b0, data[6:3]};

		// TODO ASSERT CRC CALC with CRC_37 from data[3:0];
	end
endtask

task _alu_op(input logic [31:0] A, input logic [31:0] B, input logic [2:0] OP, output rsp_t rsp_packet);

	logic [3:0] crc;
	
	_tx_byte(B[31:24], DATA);
	_tx_byte(B[23:16], DATA);
	_tx_byte(B[15:8], DATA);
	_tx_byte(B[7:0], DATA);
	$display("B: 0x%08h", B);
	
	_tx_byte(A[31:24], DATA);
	_tx_byte(A[23:16], DATA);
	_tx_byte(A[15:8], DATA);
	_tx_byte(A[7:0], DATA);
	$display("A: 0x%08h", A);

	crc = _crc_68({B,A,1'b1,OP});
	_tx_byte({1'b0, OP, crc}, CTL);
	$display("CRC: %04b", crc);
	
	rsp_packet.data = 32'h00000000;
	rsp_packet.flags = 6'b000000;
	_rx_rsp(rsp_packet);
endtask

/**
 * ALU external tasks and functions
 */

function void init();

	sin = 1'b1;
endfunction

task and_op(input logic [31:0] A, input logic [31:0] B, output logic [32:0] C, output logic [5:0] FLAGS);
	
	rsp_t rsp_packet;
	_alu_op(A, B, AND_OP, rsp_packet);
	C = rsp_packet.data;
	FLAGS = rsp_packet.flags;
endtask

task or_op(input logic [31:0] A, input logic [31:0] B, output logic [32:0] C, output logic [5:0] FLAGS);
	
	rsp_t rsp_packet;
	_alu_op(A, B, OR_OP, rsp_packet);
	C = rsp_packet.data;
	FLAGS = rsp_packet.flags;
endtask

task add_op(input logic [31:0] A, input logic [31:0] B, output logic [32:0] C, output logic [5:0] FLAGS);
	
	rsp_t rsp_packet;
	_alu_op(A, B, ADD_OP, rsp_packet);
	C = rsp_packet.data;
	FLAGS = rsp_packet.flags;
endtask

task sub_op(input logic [31:0] A, input logic [31:0] B, output logic [32:0] C, output logic [5:0] FLAGS);
	rsp_t rsp_packet;
	_alu_op(A, B, SUB_OP, rsp_packet);
	C = rsp_packet.data;
	FLAGS = rsp_packet.flags;
endtask

endinterface
