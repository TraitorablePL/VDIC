
import alu_pkg::*;

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

function logic [3:0] _crc4(input logic [67:0] D);
	
	logic [3:0] crc;
	
	crc[0] = D[66] ^ D[64] ^ D[63] ^ D[60] ^ D[56] ^ D[55] ^ D[54] ^ D[53] ^ D[51] ^ D[49] ^ D[48] ^ D[45] ^ D[41] ^ D[40] ^ D[39] ^ D[38] ^ D[36] ^ D[34] ^ D[33] ^ D[30] ^ D[26] ^ D[25] ^ D[24] ^ D[23] ^ D[21] ^ D[19] ^ D[18] ^ D[15] ^ D[11] ^ D[10] ^ D[9] ^ D[8] ^ D[6] ^ D[4] ^ D[3] ^ D[0] ^ 0 ^ 0;
	crc[1] = D[67] ^ D[66] ^ D[65] ^ D[63] ^ D[61] ^ D[60] ^ D[57] ^ D[53] ^ D[52] ^ D[51] ^ D[50] ^ D[48] ^ D[46] ^ D[45] ^ D[42] ^ D[38] ^ D[37] ^ D[36] ^ D[35] ^ D[33] ^ D[31] ^ D[30] ^ D[27] ^ D[23] ^ D[22] ^ D[21] ^ D[20] ^ D[18] ^ D[16] ^ D[15] ^ D[12] ^ D[8] ^ D[7] ^ D[6] ^ D[5] ^ D[3] ^ D[1] ^ D[0] ^ 0 ^ 0 ^ 0;
	crc[2] = D[67] ^ D[66] ^ D[64] ^ D[62] ^ D[61] ^ D[58] ^ D[54] ^ D[53] ^ D[52] ^ D[51] ^ D[49] ^ D[47] ^ D[46] ^ D[43] ^ D[39] ^ D[38] ^ D[37] ^ D[36] ^ D[34] ^ D[32] ^ D[31] ^ D[28] ^ D[24] ^ D[23] ^ D[22] ^ D[21] ^ D[19] ^ D[17] ^ D[16] ^ D[13] ^ D[9] ^ D[8] ^ D[7] ^ D[6] ^ D[4] ^ D[2] ^ D[1] ^ 0 ^ 0 ^ 0;
	crc[3] = D[67] ^ D[65] ^ D[63] ^ D[62] ^ D[59] ^ D[55] ^ D[54] ^ D[53] ^ D[52] ^ D[50] ^ D[48] ^ D[47] ^ D[44] ^ D[40] ^ D[39] ^ D[38] ^ D[37] ^ D[35] ^ D[33] ^ D[32] ^ D[29] ^ D[25] ^ D[24] ^ D[23] ^ D[22] ^ D[20] ^ D[18] ^ D[17] ^ D[14] ^ D[10] ^ D[9] ^ D[8] ^ D[7] ^ D[5] ^ D[3] ^ D[2] ^ 0 ^ 0;
	
	return crc;
endfunction


function logic [3:0] _crc3(input logic [36:0] D);

	logic [2:0] crc;

	crc[0] = D[35] ^ D[32] ^ D[31] ^ D[30] ^ D[28] ^ D[25] ^ D[24] ^ D[23] ^ D[21] ^ D[18] ^ D[17] ^ D[16] ^ D[14] ^ D[11] ^ D[10] ^ D[9] ^ D[7] ^ D[4] ^ D[3] ^ D[2] ^ D[0] ^ 0;
	crc[1] = D[36] ^ D[35] ^ D[33] ^ D[30] ^ D[29] ^ D[28] ^ D[26] ^ D[23] ^ D[22] ^ D[21] ^ D[19] ^ D[16] ^ D[15] ^ D[14] ^ D[12] ^ D[9] ^ D[8] ^ D[7] ^ D[5] ^ D[2] ^ D[1] ^ D[0] ^ 0 ^ 0;
	crc[2] = D[36] ^ D[34] ^ D[31] ^ D[30] ^ D[29] ^ D[27] ^ D[24] ^ D[23] ^ D[22] ^ D[20] ^ D[17] ^ D[16] ^ D[15] ^ D[13] ^ D[10] ^ D[9] ^ D[8] ^ D[6] ^ D[3] ^ D[2] ^ D[1] ^ 0 ^ 0;
	
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
	end
	else begin
		rsp_packet.data[31:24] = data;
		_rx_byte(rsp_packet.data[23:16], rsp_type);
		_rx_byte(rsp_packet.data[15:8], rsp_type);
		_rx_byte(rsp_packet.data[7:0], rsp_type);
		_rx_byte(data, rsp_type);
		rsp_packet.flags = {1'b0, data[6:3]};
		// TODO ASSERT CRC CALC with CRC_37 from data[3:0];
	end
endtask

task _alu_op(
	input logic [31:0] A, 
	input logic [31:0] B, 
	input logic [2:0] OP, 
	output rsp_t rsp_packet,
	input logic CRC_ERR,
	input logic DATA_ERR,
	input logic BIT_ERR);

	logic [3:0] crc;
	
	$display("\n|     OP: 0x%03b", OP);
	
	_tx_byte(B[31:24], DATA);
	_tx_byte(B[23:16], DATA);
	_tx_byte(B[15:8], DATA);
	if(!DATA_ERR) 
		_tx_byte(B[7:0], DATA);
	else
		_tx_byte(B[7:0], CTL);
	
	$display("|      B: 0x%08h", B);
	
	_tx_byte(A[31:24], DATA);
	_tx_byte(A[23:16], DATA);
	_tx_byte(A[15:8], DATA);
	
	if(!BIT_ERR) 
		_tx_byte(A[7:0], DATA);
	else
		_tx_byte({A[7:1],~A[0]}, DATA);
	
	$display("|      A: 0x%08h", A);

	crc = _crc4({B,A,1'b1,OP});
	
	if(!CRC_ERR)
		_tx_byte({1'b0, OP, crc}, CTL);
	else
		_tx_byte({1'b0, OP, crc[3:1],~crc[0]}, CTL);
	
	$display("|    CRC: %04b", crc);
	
	rsp_packet.data = 32'h00000000;
	rsp_packet.flags = 6'b000000;
	_rx_rsp(rsp_packet);
	$display("|      C: 0x%08h", rsp_packet.data);
	$display("|  FLAGS: 0x%06b", rsp_packet.flags);
endtask


/**
 * ALU external tasks and functions
 */

function void init();

	sin = 1'b1;
endfunction

task and_op(
	input logic [31:0] A, 
	input logic [31:0] B, 
	output rsp_t rsp_packet);
	
	_alu_op(A, B, AND_OP, rsp_packet, 0, 0, 0);
endtask

task or_op(
	input logic [31:0] A, 
	input logic [31:0] B, 
	output rsp_t rsp_packet);

	_alu_op(A, B, OR_OP, rsp_packet, 0, 0, 0);
endtask

task add_op(
	input logic [31:0] A, 
	input logic [31:0] B, 
	output rsp_t rsp_packet);
	
	_alu_op(A, B, ADD_OP, rsp_packet, 0, 0, 0);
endtask

task sub_op(
	input logic [31:0] A, 
	input logic [31:0] B, 
	output rsp_t rsp_packet);
	
	_alu_op(A, B, SUB_OP, rsp_packet, 0, 0, 0);
endtask

task op(
	input logic [31:0] A, 
	input logic [31:0] B, 
	input logic [2:0] OP, 
	output rsp_t rsp_packet,
	input logic CRC_ERR,
	input logic PKG_ERR,
	input logic BIT_ERR);
	
	_alu_op(A, B, OP, rsp_packet, CRC_ERR, PKG_ERR, BIT_ERR);
endtask

endinterface
