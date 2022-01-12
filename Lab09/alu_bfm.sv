`timescale 1ns / 1ps

interface alu_bfm;
	
import alu_pkg::*;

////////////////////////////////////////
// ALU BFM global signals
////////////////////////////////////////

bit clk;
bit rst_n;

////////////////////////////////////////
// ALU BFM interface data
////////////////////////////////////////

bit DONE = 0;
alu_result_t ALU_RESULT;
cmd_pack_t CMD_PACK;

////////////////////////////////////////
// ALU BFM serial data
////////////////////////////////////////

bit sin;
bit sout;

////////////////////////////////////////
// ALU BFM monitors
////////////////////////////////////////

Command_monitor command_monitor_h;
Result_monitor result_monitor_h;

////////////////////////////////////////
// CRC tasks and functions
////////////////////////////////////////

function bit [3:0] _crc4(input bit [67:0] D);
	
	bit [3:0] crc;
	crc[0] = D[66] ^ D[64] ^ D[63] ^ D[60] ^ D[56] ^ D[55] ^ D[54] ^ D[53] ^ D[51] ^ D[49] ^ D[48] ^ D[45] ^ D[41] ^ D[40] ^ D[39] ^ D[38] ^ D[36] ^ D[34] ^ D[33] ^ D[30] ^ D[26] ^ D[25] ^ D[24] ^ D[23] ^ D[21] ^ D[19] ^ D[18] ^ D[15] ^ D[11] ^ D[10] ^ D[9] ^ D[8] ^ D[6] ^ D[4] ^ D[3] ^ D[0];
	crc[1] = D[67] ^ D[66] ^ D[65] ^ D[63] ^ D[61] ^ D[60] ^ D[57] ^ D[53] ^ D[52] ^ D[51] ^ D[50] ^ D[48] ^ D[46] ^ D[45] ^ D[42] ^ D[38] ^ D[37] ^ D[36] ^ D[35] ^ D[33] ^ D[31] ^ D[30] ^ D[27] ^ D[23] ^ D[22] ^ D[21] ^ D[20] ^ D[18] ^ D[16] ^ D[15] ^ D[12] ^ D[8] ^ D[7] ^ D[6] ^ D[5] ^ D[3] ^ D[1] ^ D[0];
	crc[2] = D[67] ^ D[66] ^ D[64] ^ D[62] ^ D[61] ^ D[58] ^ D[54] ^ D[53] ^ D[52] ^ D[51] ^ D[49] ^ D[47] ^ D[46] ^ D[43] ^ D[39] ^ D[38] ^ D[37] ^ D[36] ^ D[34] ^ D[32] ^ D[31] ^ D[28] ^ D[24] ^ D[23] ^ D[22] ^ D[21] ^ D[19] ^ D[17] ^ D[16] ^ D[13] ^ D[9] ^ D[8] ^ D[7] ^ D[6] ^ D[4] ^ D[2] ^ D[1];
	crc[3] = D[67] ^ D[65] ^ D[63] ^ D[62] ^ D[59] ^ D[55] ^ D[54] ^ D[53] ^ D[52] ^ D[50] ^ D[48] ^ D[47] ^ D[44] ^ D[40] ^ D[39] ^ D[38] ^ D[37] ^ D[35] ^ D[33] ^ D[32] ^ D[29] ^ D[25] ^ D[24] ^ D[23] ^ D[22] ^ D[20] ^ D[18] ^ D[17] ^ D[14] ^ D[10] ^ D[9] ^ D[8] ^ D[7] ^ D[5] ^ D[3] ^ D[2];
	return crc;
endfunction

function bit [3:0] _crc3(input bit [36:0] D);

	bit [2:0] crc;
	crc[0] = D[35] ^ D[32] ^ D[31] ^ D[30] ^ D[28] ^ D[25] ^ D[24] ^ D[23] ^ D[21] ^ D[18] ^ D[17] ^ D[16] ^ D[14] ^ D[11] ^ D[10] ^ D[9] ^ D[7] ^ D[4] ^ D[3] ^ D[2] ^ D[0];
	crc[1] = D[36] ^ D[35] ^ D[33] ^ D[30] ^ D[29] ^ D[28] ^ D[26] ^ D[23] ^ D[22] ^ D[21] ^ D[19] ^ D[16] ^ D[15] ^ D[14] ^ D[12] ^ D[9] ^ D[8] ^ D[7] ^ D[5] ^ D[2] ^ D[1] ^ D[0];
	crc[2] = D[36] ^ D[34] ^ D[31] ^ D[30] ^ D[29] ^ D[27] ^ D[24] ^ D[23] ^ D[22] ^ D[20] ^ D[17] ^ D[16] ^ D[15] ^ D[13] ^ D[10] ^ D[9] ^ D[8] ^ D[6] ^ D[3] ^ D[2] ^ D[1];
	return crc;
endfunction

////////////////////////////////////////
// Internal ALU BFM tasks and functions
////////////////////////////////////////

task _tx_byte(
	input bit [7:0] data, 
	input cmd_t tx_type);

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
endtask

task _rx_byte(
	output bit [7:0] data, 
	output cmd_t rx_type);
	
	// START and TYPE bits
	repeat (2) @(negedge clk);
	if(sout)
		rx_type = CTL;
	else
		rx_type = DATA;
	
	// DATA bits
	for(int i = 7;i >= 0; i--) begin
		@(negedge clk);
		data[i] = sout;
	end
	
	// STOP bit
	@(negedge clk);
endtask

task _rx_rsp(output alu_result_t rsp);
	
	bit rsp_type;
	bit [7:0] data;
	
	@(negedge sout);
	_rx_byte(data, rsp_type);

	if(rsp_type) begin
		rsp.data = 32'h00000000;
		rsp.flags = data[6:1];
		assert(data[0] == 1'b1) 
			else $error("ERROR: Invalid parity bit of CTL");
	end
	else begin
		rsp.data[31:24] = data;
		_rx_byte(rsp.data[23:16], rsp_type);
		_rx_byte(rsp.data[15:8], rsp_type);
		_rx_byte(rsp.data[7:0], rsp_type);
		_rx_byte(data, rsp_type);
		rsp.flags = {2'b00, data[6:3]};
		assert (data[2:0] == _crc3({rsp.data, 1'b0, data[6:3]})) 
			else $error("ERROR: Invalid CRC3 of DATA");
	end
endtask

task _alu_op(
	input bit signed [31:0] A, 
	input bit signed [31:0] B, 
	input bit [2:0] OP, 
	input bit [2:0] ERROR,
	output alu_result_t RSP);

	bit [3:0] crc;
	
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
		crc = _crc4({B, A, 1'b0, OP});
	else
		crc = _crc4({B, A, 1'b1, OP});
		
	_tx_byte({1'b0, OP, crc}, CTL);
	
	RSP.data = 32'h00000000;
	RSP.flags = 6'b000000;
	_rx_rsp(RSP);
endtask

function exp_result_t _exp_result(
    input bit signed [31:0] A, 
    input bit signed [31:0] B, 
    input bit [2:0] OP);
    
    bit [32:0] carry_chk;
    exp_result_t result;
    
    result.flags = F_NONE;
    
    case(OP)
        AND_OP: begin
            result.data = B & A;
            carry_chk = 33'h000000000;
        end
        OR_OP:  begin
            result.data = B | A;
            carry_chk = 33'h000000000;
        end
        ADD_OP: begin
            result.data = B + A;
            carry_chk = {1'b0, B} + {1'b0, A};
            
            if((A[31] == 1'b0 && B[31] == 1'b0 && result.data[31] == 1'b1) || 
                (A[31] == 1'b1 && B[31] == 1'b1 && result.data[31] == 1'b0))
                result.flags |= F_OVFL;
        end
        SUB_OP: begin
            result.data = B - A;
            carry_chk = {1'b0, B} - {1'b0, A};
            
            if((A[31] == 1'b1 && B[31] == 1'b0 && result.data[31] == 1'b1) || 
                (A[31] == 1'b0 && B[31] == 1'b1 && result.data[31] == 1'b0))
                result.flags |= F_OVFL;
        end
        default: begin
            result.data = 32'h00000000;
            carry_chk = 33'h000000000;
        end
    endcase
    
    if(carry_chk[32] == 1'b1) 
        result.flags |= F_CARRY;
    
    if(result.data < 0)
        result.flags |= F_NEG;
    
    if(result.data == 0)
        result.flags |= F_ZERO;
    
    return result;
endfunction

////////////////////////////////////////
// ALU BFM external tasks and functions
////////////////////////////////////////

task rst();
	sin = 1'b1;
	rst_n = 1'b0;
	
	@(negedge clk);    
    rst_n = 1'b1;
endtask

task op(
	input bit signed [31:0] A, 
	input bit signed [31:0] B, 
	input bit [2:0] OP, 
	input bit [2:0] ERROR,
	input bit RST,
    output alu_result_t RSP);
    
    bit [2:0] _OP;
    
    // Replace current OP with wrong OP
    if(ERROR == F_ERROP) begin
        case ($urandom() % 4)
            0: _OP = 3'b010;
            1: _OP = 3'b011;
            2: _OP = 3'b110;
            3: _OP = 3'b111;
        endcase
    end
    else begin
        _OP = OP;
    end
	
	if(RST)
		rst();
	
	CMD_PACK.A = A;
	CMD_PACK.B = B;
	CMD_PACK.OP = _OP;
	CMD_PACK.ERROR = ERROR;
	CMD_PACK.RST = RST;
	CMD_PACK.EXP_RESULT = _exp_result(A, B, _OP);
	
	_alu_op(A, B, _OP, ERROR, ALU_RESULT);
    RSP = ALU_RESULT;
	DONE = 1'b1;
	
	repeat(4) @(negedge clk);
endtask


////////////////////////////////////////
// Command monitor thread
////////////////////////////////////////

initial begin : cmd_monitor_thread
	forever begin	
		@(posedge DONE);
		command_monitor_h.write_to_monitor(CMD_PACK);
	end	
end : cmd_monitor_thread

////////////////////////////////////////
// Result monitor thread
////////////////////////////////////////

initial begin : result_monitor_thread
	forever begin
		@(posedge DONE)
		result_monitor_h.write_to_monitor(ALU_RESULT);
		DONE = 1'b0;
	end
end : result_monitor_thread

////////////////////////////////////////
// Clock generator
////////////////////////////////////////
 
initial begin
	clk = 1'b1;
	forever
		clk = #2.5 ~clk;
end

endinterface
