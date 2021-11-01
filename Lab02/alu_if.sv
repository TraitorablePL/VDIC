
import alu_pkg::*;

interface alu_if(
	/* global signals */
	output logic 	clk,
	output logic 	rst_n,
	
	/* alu serial data */
	output logic 	sin,
	input logic 	sout
);
	
	
/**
 * Tasks and function definitions
 */

function logic [3:0] _crc4(input logic [67:0] D, input logic [3:0] crc_in);
	
	logic [3:0] crc;
	logic [3:0] C;
	
	C = crc_in;
	
//	crc[0] = D[66] ^ D[64] ^ D[63] ^ D[60] ^ D[56] ^ D[55] ^ D[54] ^ D[53] ^ D[51] ^ D[49] ^ D[48] ^ D[45] ^ D[41] ^ D[40] ^ D[39] ^ D[38] ^ D[36] ^ D[34] ^ D[33] ^ D[30] ^ D[26] ^ D[25] ^ D[24] ^ D[23] ^ D[21] ^ D[19] ^ D[18] ^ D[15] ^ D[11] ^ D[10] ^ D[9] ^ D[8] ^ D[6] ^ D[4] ^ D[3] ^ D[0] ^ C[0] ^ C[2];
//	crc[1] = D[67] ^ D[66] ^ D[65] ^ D[63] ^ D[61] ^ D[60] ^ D[57] ^ D[53] ^ D[52] ^ D[51] ^ D[50] ^ D[48] ^ D[46] ^ D[45] ^ D[42] ^ D[38] ^ D[37] ^ D[36] ^ D[35] ^ D[33] ^ D[31] ^ D[30] ^ D[27] ^ D[23] ^ D[22] ^ D[21] ^ D[20] ^ D[18] ^ D[16] ^ D[15] ^ D[12] ^ D[8] ^ D[7] ^ D[6] ^ D[5] ^ D[3] ^ D[1] ^ D[0] ^ C[1] ^ C[2] ^ C[3];
//	crc[2] = D[67] ^ D[66] ^ D[64] ^ D[62] ^ D[61] ^ D[58] ^ D[54] ^ D[53] ^ D[52] ^ D[51] ^ D[49] ^ D[47] ^ D[46] ^ D[43] ^ D[39] ^ D[38] ^ D[37] ^ D[36] ^ D[34] ^ D[32] ^ D[31] ^ D[28] ^ D[24] ^ D[23] ^ D[22] ^ D[21] ^ D[19] ^ D[17] ^ D[16] ^ D[13] ^ D[9] ^ D[8] ^ D[7] ^ D[6] ^ D[4] ^ D[2] ^ D[1] ^ C[0] ^ C[2] ^ C[3];
//	crc[3] = D[67] ^ D[65] ^ D[63] ^ D[62] ^ D[59] ^ D[55] ^ D[54] ^ D[53] ^ D[52] ^ D[50] ^ D[48] ^ D[47] ^ D[44] ^ D[40] ^ D[39] ^ D[38] ^ D[37] ^ D[35] ^ D[33] ^ D[32] ^ D[29] ^ D[25] ^ D[24] ^ D[23] ^ D[22] ^ D[20] ^ D[18] ^ D[17] ^ D[14] ^ D[10] ^ D[9] ^ D[8] ^ D[7] ^ D[5] ^ D[3] ^ D[2] ^ C[1] ^ C[3];

	crc[0] = D[66] ^ D[64] ^ D[63] ^ D[60] ^ D[56] ^ D[55] ^ D[54] ^ D[53] ^ D[51] ^ D[49] ^ D[48] ^ D[45] ^ D[41] ^ D[40] ^ D[39] ^ D[38] ^ D[36] ^ D[34] ^ D[33] ^ D[30] ^ D[26] ^ D[25] ^ D[24] ^ D[23] ^ D[21] ^ D[19] ^ D[18] ^ D[15] ^ D[11] ^ D[10] ^ D[9] ^ D[8] ^ D[6] ^ D[4] ^ D[3] ^ D[0];
	crc[1] = D[67] ^ D[66] ^ D[65] ^ D[63] ^ D[61] ^ D[60] ^ D[57] ^ D[53] ^ D[52] ^ D[51] ^ D[50] ^ D[48] ^ D[46] ^ D[45] ^ D[42] ^ D[38] ^ D[37] ^ D[36] ^ D[35] ^ D[33] ^ D[31] ^ D[30] ^ D[27] ^ D[23] ^ D[22] ^ D[21] ^ D[20] ^ D[18] ^ D[16] ^ D[15] ^ D[12] ^ D[8] ^ D[7] ^ D[6] ^ D[5] ^ D[3] ^ D[1] ^ D[0];
	crc[2] = D[67] ^ D[66] ^ D[64] ^ D[62] ^ D[61] ^ D[58] ^ D[54] ^ D[53] ^ D[52] ^ D[51] ^ D[49] ^ D[47] ^ D[46] ^ D[43] ^ D[39] ^ D[38] ^ D[37] ^ D[36] ^ D[34] ^ D[32] ^ D[31] ^ D[28] ^ D[24] ^ D[23] ^ D[22] ^ D[21] ^ D[19] ^ D[17] ^ D[16] ^ D[13] ^ D[9] ^ D[8] ^ D[7] ^ D[6] ^ D[4] ^ D[2] ^ D[1];
	crc[3] = D[67] ^ D[65] ^ D[63] ^ D[62] ^ D[59] ^ D[55] ^ D[54] ^ D[53] ^ D[52] ^ D[50] ^ D[48] ^ D[47] ^ D[44] ^ D[40] ^ D[39] ^ D[38] ^ D[37] ^ D[35] ^ D[33] ^ D[32] ^ D[29] ^ D[25] ^ D[24] ^ D[23] ^ D[22] ^ D[20] ^ D[18] ^ D[17] ^ D[14] ^ D[10] ^ D[9] ^ D[8] ^ D[7] ^ D[5] ^ D[3] ^ D[2];
	return crc;
endfunction


function logic [3:0] _crc3(input logic [36:0] D, input logic [2:0] crc_in);

	logic [2:0] crc;
	logic [2:0] C;
	
	C = crc_in;

//	crc[0] = D[35] ^ D[32] ^ D[31] ^ D[30] ^ D[28] ^ D[25] ^ D[24] ^ D[23] ^ D[21] ^ D[18] ^ D[17] ^ D[16] ^ D[14] ^ D[11] ^ D[10] ^ D[9] ^ D[7] ^ D[4] ^ D[3] ^ D[2] ^ D[0] ^ C[1];
//	crc[1] = D[36] ^ D[35] ^ D[33] ^ D[30] ^ D[29] ^ D[28] ^ D[26] ^ D[23] ^ D[22] ^ D[21] ^ D[19] ^ D[16] ^ D[15] ^ D[14] ^ D[12] ^ D[9] ^ D[8] ^ D[7] ^ D[5] ^ D[2] ^ D[1] ^ D[0] ^ C[1] ^ C[2];
//	crc[2] = D[36] ^ D[34] ^ D[31] ^ D[30] ^ D[29] ^ D[27] ^ D[24] ^ D[23] ^ D[22] ^ D[20] ^ D[17] ^ D[16] ^ D[15] ^ D[13] ^ D[10] ^ D[9] ^ D[8] ^ D[6] ^ D[3] ^ D[2] ^ D[1] ^ C[0] ^ C[2];
	
	crc[0] = D[35] ^ D[32] ^ D[31] ^ D[30] ^ D[28] ^ D[25] ^ D[24] ^ D[23] ^ D[21] ^ D[18] ^ D[17] ^ D[16] ^ D[14] ^ D[11] ^ D[10] ^ D[9] ^ D[7] ^ D[4] ^ D[3] ^ D[2] ^ D[0];
	crc[1] = D[36] ^ D[35] ^ D[33] ^ D[30] ^ D[29] ^ D[28] ^ D[26] ^ D[23] ^ D[22] ^ D[21] ^ D[19] ^ D[16] ^ D[15] ^ D[14] ^ D[12] ^ D[9] ^ D[8] ^ D[7] ^ D[5] ^ D[2] ^ D[1] ^ D[0];
	crc[2] = D[36] ^ D[34] ^ D[31] ^ D[30] ^ D[29] ^ D[27] ^ D[24] ^ D[23] ^ D[22] ^ D[20] ^ D[17] ^ D[16] ^ D[15] ^ D[13] ^ D[10] ^ D[9] ^ D[8] ^ D[6] ^ D[3] ^ D[2] ^ D[1];
	return crc;
endfunction


/**
 * Internal ALU tasks
 */

task _tx_byte(input logic [7:0] data, input cmd_t tx_type);

	/* START bit */
	@(negedge clk);
	sin = 1'b0;
	
	/* TYPE bit */
	@(negedge clk);  
	if(tx_type)
		sin = 1'b1;
	else
		sin = 1'b0;
	
	/* DATA bits */
	for(int i = 7;i >= 0; i--) begin
		@(negedge clk);
		sin = data[i];
	end
	
	/* STOP bit */
	@(negedge clk);
	sin = 1'b1;
endtask


task _rx_byte(output logic [7:0] data, output cmd_t rx_type);
	
	/* START and TYPE bits */
	repeat (2) @(negedge clk);
	if(sout)
		rx_type = CTL;
	else
		rx_type = DATA;
	
	/* DATA bits */
	for(int i = 7;i >= 0; i--) begin
		@(negedge clk);
		data[i] = sout;
	end
	
	/* STOP bit */
	@(negedge clk);
endtask


task _rx_rsp(output rsp_t rsp_packet);
	
	logic rsp_type;
	logic [7:0] data;
	
	@(negedge sout);
	_rx_byte(data, rsp_type);

	if(rsp_type) begin
		rsp_packet.data = 32'h00000000;
		rsp_packet.flags = data[6:1];
		assert(data[0] == 1'b1) 
			else $error("Invalid parity of ctl");
	end
	else begin
		rsp_packet.data[31:24] = data;
		_rx_byte(rsp_packet.data[23:16], rsp_type);
		_rx_byte(rsp_packet.data[15:8], rsp_type);
		_rx_byte(rsp_packet.data[7:0], rsp_type);
		_rx_byte(data, rsp_type);
		rsp_packet.flags = {2'b00, data[6:3]};
		assert (data[2:0] == _crc3({rsp_packet.data, 1'b0, data[6:3]}, 3'b000)) 
			else $error("Invalid CRC3 of data");
	end
endtask

task _alu_op(
	input logic signed [31:0] A, 
	input logic signed [31:0] B, 
	input logic [2:0] OP, 
	input logic [2:0] ERROR,
	output rsp_t rsp_packet);

	logic [3:0] crc;
	
	_tx_byte(B[31:24], DATA);
	_tx_byte(B[23:16], DATA);
	_tx_byte(B[15:8], DATA);
	if(ERROR == F_ERRDATA) 
		_tx_byte(B[7:0], CTL);
	else
		_tx_byte(B[7:0], DATA);
	
	_tx_byte(A[31:24], DATA);
	_tx_byte(A[23:16], DATA);
	_tx_byte(A[15:8], DATA);
	_tx_byte(A[7:0], DATA);

	
	
	if(ERROR == F_ERRCRC)
		crc = _crc4({B,A,1'b0,OP}, 4'b0000);
	else
		crc = _crc4({B,A,1'b1,OP}, 4'b0000);
		
	_tx_byte({1'b0, OP, crc}, CTL);
	
	rsp_packet.data = 32'h00000000;
	rsp_packet.flags = 6'b000000;
	_rx_rsp(rsp_packet);
endtask


/**
 * ALU external tasks and functions
 */

task rst();
	sin = 1'b1;
	rst_n = 1'b0;
	
	@(negedge clk);    
    rst_n = 1'b1;
endtask

task op(
	input logic signed [31:0] A, 
	input logic signed [31:0] B, 
	input logic [2:0] OP, 
	input logic [2:0] ERROR,
	output rsp_t rsp_packet);
	
	_alu_op(A, B, OP, ERROR, rsp_packet);
endtask

/**
 * Clock generation
 */
 
initial begin
	clk = 1'b1;
	
	forever
		clk = #2.5 ~clk;
end

endinterface
