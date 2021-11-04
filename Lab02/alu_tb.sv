/******************************************************************************
* Created by dstankiewicz on Oct 17, 2021
*******************************************************************************/
`timescale 1ns / 1ps

import alu_pkg::*;

module alu_tb();

/**
 * Local variables and signals
 */

logic clk;
logic rst_n;
logic sin;
logic sout;
logic [31:0] A, B;

logic [4:0] err_gen;
logic [2:0] err_in;
logic [1:0] op_gen;
logic [2:0] op_in;
logic [3:0] data_gen;
logic rep_op;
logic rst_op;
	
rsp_t RSP;
	
	
/**
 * Interfaces instantiation
 */ 
 
alu_if alu_if(
	.clk,
	.rst_n,
	.sin,
	.sout
);
	
	
/**
 * Submodules placement
 */ 

mtm_Alu mtm_Alu(
	.clk,
	.rst_n,
	.sin,
	.sout
);
	
	
/**
 * Test verifier
 */

function logic verify_result(
	input logic signed [31:0] A, 
	input logic signed [31:0] B, 
	input logic [2:0] OP, 
	input logic [2:0] ERROR,
	input rsp_t RSP);
	
	logic signed [31:0] RESULT;
	logic [32:0] RESULT_CARRY;
	logic [3:0] ALU_FLAGS;
	
	ALU_FLAGS = F_NONE;
	
	case(OP)
		AND_OP:	begin
			RESULT = B & A;
			RESULT_CARRY = 33'h000000000;
		end
		OR_OP:	begin
			RESULT = B | A;
			RESULT_CARRY = 33'h000000000;
		end
		ADD_OP: begin
			RESULT = B + A;
			RESULT_CARRY = {1'b0, B} + {1'b0, A};
			
			if((A[31] == 1'b0 && B[31] == 1'b0 && RESULT[31] == 1'b1) || 
				(A[31] == 1'b1 && B[31] == 1'b1 && RESULT[31] == 1'b0))
				ALU_FLAGS |= F_OVFL;
		end
		SUB_OP: begin
			RESULT = B - A;
			RESULT_CARRY = {1'b0, B} - {1'b0, A};
			
			if((A[31] == 1'b1 && B[31] == 1'b0 && RESULT[31] == 1'b1) || 
				(A[31] == 1'b0 && B[31] == 1'b1 && RESULT[31] == 1'b0))
				ALU_FLAGS |= F_OVFL;
		end
		default: begin
			RESULT = 32'h00000000;
			RESULT_CARRY = 33'h000000000;
		end
	endcase
	
	if(RESULT_CARRY[32] == 1'b1) 
		ALU_FLAGS |= F_CARRY;
	
	if(RESULT < 0)
		ALU_FLAGS |= F_NEG;
	
	if(RESULT == 0)
		ALU_FLAGS |= F_ZERO;
	
`ifdef DEBUG
	$display("|         OP: %03b", OP);
	$display("|          B: 0x%08h", B);
	$display("|          A: 0x%08h", A);
	$display("|          C: 0x%08h", RSP.data);
	$display("|      FLAGS: %06b", RSP.flags);
	$display("|      C_EXP: 0x%08h", RESULT);
	
	if(ERROR)
		$display("|      ERROR: %06b", {ERROR, ERROR});
	else
		$display("|  FLAGS_EXP: %06b", ALU_FLAGS);
`endif
	
	if((RSP.data == RESULT && RSP.flags[3:0] == ALU_FLAGS) || 
		(RSP.flags[5:3] == ERROR && ERROR != F_ERRNONE)) begin
		$display("TEST PASSED\n");
		return 1'b0;
	end
	else begin
		$display("TEST FAILED\n");
		return 1'b1;
	end
endfunction


/**
 * Data generator
 */
 
function logic signed [31:0] gen_data();
	data_gen = $urandom() % 32;
	case (data_gen)
		0: return 32'h00000000;
		1: return 32'hFFFFFFFF;
		2: return 32'h80000000;
		3: return 32'h7FFFFFFF;
		default: return $random;
	endcase
endfunction


/**
 * Error generator
 */
 
function logic [2:0] gen_error();
	err_gen = $urandom() % 64;
	case (err_gen)
		0: return F_ERRCRC;
		1: return F_ERRDATA;
		2: return F_ERROP;
		default: return F_ERRNONE;
	endcase
endfunction


/**
 * Operation generator
 */
 
function logic [2:0] gen_op(input logic [2:0] err_in);
	op_gen = $urandom() % 4;
	if (err_in == F_ERROP) begin
		case (op_gen)
			0: return 3'b010;
			1: return 3'b011;
			2: return 3'b110;
			3: return 3'b111;
		endcase
	end
	else begin
		case (op_gen)
			0: return AND_OP;
			1: return OR_OP;
			2: return ADD_OP;
			3: return SUB_OP;
		endcase
	end
endfunction

/**
 * Coverage
 */
 
covergroup op_cov;
	
	option.name = "cg_op_cov";
	
	all_ops : coverpoint op_in {
		bins A1_basic_op[] = {AND_OP, OR_OP, ADD_OP, SUB_OP};
		bins A1_error_op[] = {3'b010, 3'b011, 3'b110, 3'b111};
		bins A2_repeated_op[] = ({AND_OP, OR_OP, ADD_OP, SUB_OP} [* 2]);
	}
	
	rst : coverpoint rst_op {
		bins active = {1'b1};
	}
	
	flags : coverpoint RSP.flags {
		bins neg = {2'b00,F_NEG};
		bins zero = {2'b00,F_ZERO};
		bins ovfl = {2'b00,F_OVFL};
		bins carry = {2'b00,F_CARRY};
		bins errop = {F_ERROP,F_ERROP};
		bins errcrc = {F_ERRCRC,F_ERRCRC};
		bins errdata = {F_ERRDATA,F_ERRDATA};
	}
	
	A3_rst_op: cross all_ops, rst {
    	bins A3_reset_and = binsof (all_ops) intersect {AND_OP} && binsof (rst.active);
		bins A3_reset_or = binsof (all_ops) intersect {OR_OP} && binsof (rst.active);
		bins A3_reset_add = binsof (all_ops) intersect {ADD_OP} && binsof (rst.active);
		bins A3_reset_sub = binsof (all_ops) intersect {SUB_OP} && binsof (rst.active);
		
		ignore_bins others_reset = binsof(all_ops.A1_error_op);
	}
	
	A4_flag_op: cross all_ops, flags {
        bins A4_carry_add = binsof (all_ops) intersect {ADD_OP} && binsof (flags.carry);
		bins A4_overflow_add = binsof (all_ops) intersect {ADD_OP} && binsof (flags.ovfl);
		bins A4_negative_add = binsof (all_ops) intersect {ADD_OP} && binsof (flags.neg);
		bins A4_zero_add = binsof (all_ops) intersect {ADD_OP} && binsof (flags.zero);
		
		bins A4_carry_sub = binsof (all_ops) intersect {SUB_OP} && binsof (flags.carry);
		bins A4_overflow_sub = binsof (all_ops) intersect {SUB_OP} && binsof (flags.ovfl);
		bins A4_negative_sub = binsof (all_ops) intersect {SUB_OP} && binsof (flags.neg);
		bins A4_zero_sub = binsof (all_ops) intersect {SUB_OP} && binsof (flags.zero);
		
		bins A4_carry_and = binsof (all_ops) intersect {AND_OP} && binsof (flags.carry);
		bins A4_overflow_and = binsof (all_ops) intersect {AND_OP} && binsof (flags.ovfl);
		bins A4_negative_and = binsof (all_ops) intersect {AND_OP} && binsof (flags.neg);
		bins A4_zero_and = binsof (all_ops) intersect {AND_OP} && binsof (flags.zero);
		
		bins A4_carry_or = binsof (all_ops) intersect {OR_OP} && binsof (flags.carry);
		bins A4_overflow_or = binsof (all_ops) intersect {OR_OP} && binsof (flags.ovfl);
		bins A4_negative_or = binsof (all_ops) intersect {OR_OP} && binsof (flags.neg);
		bins A4_zero_or = binsof (all_ops) intersect {OR_OP} && binsof (flags.zero);
		
		ignore_bins err_flags = binsof (all_ops) && 
			(binsof (flags.errop) || binsof (flags.errcrc) || binsof (flags.errdata));
		
		ignore_bins others_flags = binsof(all_ops.A1_error_op);
	}
endgroup

covergroup extreme_val_on_ops;
	
	option.name = "cg_extreme_val_on_ops";
	
	all_ops : coverpoint op_in {
        ignore_bins not_supported_ops = {3'b010, 3'b011, 3'b110, 3'b111};
	}
	
	a_arg: coverpoint A {
        bins zeros = {32'h00000000};
		bins min = {32'h80000000};
        bins others = {[32'h00000001:32'h7FFFFFFE], [32'h80000001:32'hFFFFFFFE]};
		bins max  = {32'h7FFFFFFF};
        bins ones  = {32'hFFFFFFFF};
    }

    b_arg: coverpoint B {
        bins zeros = {'h00000000};
		bins min = {'h80000000};
        bins others = {['h00000001:'h7FFFFFFE], ['h80000001:'hFFFFFFFE]};
		bins max  = {'h7FFFFFFF};
        bins ones  = {'hFFFFFFFF};
    }
    
    B_op_extreme_values: cross a_arg, b_arg, all_ops {

        // #B1 simulate zero input for supported operations

    	bins B1_and_zeros = binsof (all_ops) intersect {AND_OP} &&
        	(binsof (a_arg.zeros) || binsof (b_arg.zeros));

        bins B1_or_zeros = binsof (all_ops) intersect {OR_OP} &&
        	(binsof (a_arg.zeros) || binsof (b_arg.zeros));

        bins B1_add_zeros = binsof (all_ops) intersect {ADD_OP} &&
        	(binsof (a_arg.zeros) || binsof (b_arg.zeros));

        bins B1_sub_zeros = binsof (all_ops) intersect {SUB_OP} &&
        	(binsof (a_arg.zeros) || binsof (b_arg.zeros));

        // #B2 simulate ones input for supported operations

        bins B2_and_ones = binsof (all_ops) intersect {AND_OP} &&
        	(binsof (a_arg.ones) || binsof (b_arg.ones));

        bins B2_or_ones = binsof (all_ops) intersect {OR_OP} &&
        	(binsof (a_arg.ones) || binsof (b_arg.ones));

        bins B2_add_ones = binsof (all_ops) intersect {ADD_OP} &&
        	(binsof (a_arg.ones) || binsof (b_arg.ones));

        bins B2_sub_ones = binsof (all_ops) intersect {SUB_OP} &&
        	(binsof (a_arg.ones) || binsof (b_arg.ones));

	    // #B3 simulate max input for supported operations

        bins B3_and_max = binsof (all_ops) intersect {AND_OP} &&
        	(binsof (a_arg.max) || binsof (b_arg.max));

        bins B3_or_max = binsof (all_ops) intersect {OR_OP} &&
        	(binsof (a_arg.max) || binsof (b_arg.max));

        bins B3_add_max = binsof (all_ops) intersect {ADD_OP} &&
        	(binsof (a_arg.max) || binsof (b_arg.max));

        bins B3_sub_max = binsof (all_ops) intersect {SUB_OP} &&
        	(binsof (a_arg.max) || binsof (b_arg.max));
	    
	    // #B4 simulate min input for supported operations

        bins B2_and_min = binsof (all_ops) intersect {AND_OP} &&
        	(binsof (a_arg.min) || binsof (b_arg.min));

        bins B2_or_min = binsof (all_ops) intersect {OR_OP} &&
        	(binsof (a_arg.min) || binsof (b_arg.min));

        bins B2_add_min = binsof (all_ops) intersect {ADD_OP} &&
        	(binsof (a_arg.min) || binsof (b_arg.min));

        bins B2_sub_min = binsof (all_ops) intersect {SUB_OP} &&
        	(binsof (a_arg.min) || binsof (b_arg.min));

        ignore_bins others_only =
        	binsof(a_arg.others) && binsof(b_arg.others);
    }
	
endgroup

op_cov 				operation_cov;
extreme_val_on_ops 	extreme_val_cov;

initial begin : coverage
    operation_cov = new();
    extreme_val_cov = new();
    forever begin : sample_cov
        @(posedge clk);
        if(rst_n) begin
            operation_cov.sample();
            extreme_val_cov.sample();
        end
    end
end : coverage

/**
 * Tester
 */

initial begin : tester
	alu_if.rst();
	repeat (10000) begin
		rep_op = ($urandom() % 32 == 0) ? 1'b1 : 1'b0;
		rst_op = ($urandom() % 32 == 0) ? 1'b1 : 1'b0;
		
		err_in = gen_error();
		op_in = gen_op(err_in);
		A = gen_data();
		B = gen_data();
		
		
		if(rst_op == 1'b1) begin
`ifdef DEBUG
			$display("|  Reset before");
`endif
			alu_if.rst();
		end
		
		alu_if.op(A, B, op_in, err_in, RSP);
		assert(verify_result(A, B, op_in, err_in, RSP) == 1'b0);
		
		if(rep_op == 1'b1) begin
`ifdef DEBUG
			$display("|  Repeated operation");
`endif
			alu_if.op(A, B, op_in, err_in, RSP);
			assert(verify_result(A, B, op_in, err_in, RSP) == 1'b0);
		end
	end
	
	repeat (10) @(negedge clk);  
	$finish();
end : tester

endmodule
