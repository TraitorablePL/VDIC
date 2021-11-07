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

logic [2:0] err_in;
logic [2:0] op_in;
logic rep_op;
logic rst_op;
bit test_flag;
	
alu_result_t alu_result;
exp_result_t exp_result;


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
 * Data generator
 */
 
function logic signed [31:0] gen_data();
	case ($urandom() % 32)
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
	case ($urandom() % 64)
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
	logic [1:0] op_gen;
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
		bins basic_op[] = {AND_OP, OR_OP, ADD_OP, SUB_OP};
		bins error_op[] = {3'b010, 3'b011, 3'b110, 3'b111};
		bins T12_repeated_op[] = ({AND_OP, OR_OP, ADD_OP, SUB_OP} [* 2]);
	}
	
	rst : coverpoint rst_op {
		bins active = {1'b1};
	}
	
	alu_flags : coverpoint exp_result.flags {
		bins neg = {F_NEG};
		bins zero = {F_ZERO};
		bins ovfl = {F_OVFL};
		bins carry = {F_CARRY};
	}
	
	err_flags : coverpoint err_in {
		bins T9_errcrc = {F_ERRCRC};
		bins T10_errdata = {F_ERRDATA};
		bins T11_errop = {F_ERROP};
	}
	
	T13_rst_op: cross all_ops, rst {
    	bins T13_reset_and = binsof (all_ops) intersect {AND_OP} && binsof (rst.active);
		bins T13_reset_or = binsof (all_ops) intersect {OR_OP} && binsof (rst.active);
		bins T13_reset_add = binsof (all_ops) intersect {ADD_OP} && binsof (rst.active);
		bins T13_reset_sub = binsof (all_ops) intersect {SUB_OP} && binsof (rst.active);
		
		ignore_bins others_reset = binsof(all_ops.error_op);
	}
	
	op_flags: cross all_ops, alu_flags {
		
        bins T5_carry_add = binsof (all_ops) intersect {ADD_OP} && binsof (alu_flags.carry);
		bins T5_carry_sub = binsof (all_ops) intersect {SUB_OP} && binsof (alu_flags.carry);
		
		bins T6_overflow_add = binsof (all_ops) intersect {ADD_OP} && binsof (alu_flags.ovfl);
		bins T6_overflow_sub = binsof (all_ops) intersect {SUB_OP} && binsof (alu_flags.ovfl);
		
		bins T7_negative_add = binsof (all_ops) intersect {ADD_OP} && binsof (alu_flags.neg);
		bins T7_negative_sub = binsof (all_ops) intersect {SUB_OP} && binsof (alu_flags.neg);
		bins T7_negative_and = binsof (all_ops) intersect {AND_OP} && binsof (alu_flags.neg);
		bins T7_negative_or = binsof (all_ops) intersect {OR_OP} && binsof (alu_flags.neg);
		
		bins T8_zero_add = binsof (all_ops) intersect {ADD_OP} && binsof (alu_flags.zero);
		bins T8_zero_sub = binsof (all_ops) intersect {SUB_OP} && binsof (alu_flags.zero);
		bins T8_zero_and = binsof (all_ops) intersect {AND_OP} && binsof (alu_flags.zero);
		bins T8_zero_or = binsof (all_ops) intersect {OR_OP} && binsof (alu_flags.zero);
		
		ignore_bins others_flags = binsof(all_ops.error_op);
		
		ignore_bins logic_carry_ovfl = 
			(binsof (all_ops) intersect {AND_OP,OR_OP} && binsof (alu_flags.carry)) ||
			(binsof (all_ops) intersect {AND_OP,OR_OP} && binsof (alu_flags.ovfl));
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
    
    Test_ops_extreme_values: cross a_arg, b_arg, all_ops {

        // T1: AND operation for random and extreme numbers
    	bins T1_and_zeros = binsof (all_ops) intersect {AND_OP} &&
        	(binsof (a_arg.zeros) || binsof (b_arg.zeros));
	    bins T1_and_ones = binsof (all_ops) intersect {AND_OP} &&
        	(binsof (a_arg.ones) || binsof (b_arg.ones));
     	bins T1_and_max = binsof (all_ops) intersect {AND_OP} &&
        	(binsof (a_arg.max) || binsof (b_arg.max));
	    bins T1_and_min = binsof (all_ops) intersect {AND_OP} &&
        	(binsof (a_arg.min) || binsof (b_arg.min));
	    
	    // T2: OR operation for random and extreme numbers
        bins T2_or_zeros = binsof (all_ops) intersect {OR_OP} &&
        	(binsof (a_arg.zeros) || binsof (b_arg.zeros));
        bins T2_or_ones = binsof (all_ops) intersect {OR_OP} &&
        	(binsof (a_arg.ones) || binsof (b_arg.ones));
        bins T2_or_max = binsof (all_ops) intersect {OR_OP} &&
        	(binsof (a_arg.max) || binsof (b_arg.max));
      	bins T2_or_min = binsof (all_ops) intersect {OR_OP} &&
        	(binsof (a_arg.min) || binsof (b_arg.min));
	    
	    // T3: ADD operation for random and extreme numbers
        bins T3_add_zeros = binsof (all_ops) intersect {ADD_OP} &&
        	(binsof (a_arg.zeros) || binsof (b_arg.zeros));
      	bins T3_add_ones = binsof (all_ops) intersect {ADD_OP} &&
        	(binsof (a_arg.ones) || binsof (b_arg.ones));
      	bins T3_add_max = binsof (all_ops) intersect {ADD_OP} &&
        	(binsof (a_arg.max) || binsof (b_arg.max));
        bins T3_add_min = binsof (all_ops) intersect {ADD_OP} &&
        	(binsof (a_arg.min) || binsof (b_arg.min));
	    
	    // T4: SUB operation for random and extreme numbers
        bins T4_sub_zeros = binsof (all_ops) intersect {SUB_OP} &&
        	(binsof (a_arg.zeros) || binsof (b_arg.zeros));
        bins T4_sub_ones = binsof (all_ops) intersect {SUB_OP} &&
        	(binsof (a_arg.ones) || binsof (b_arg.ones));
        bins T4_sub_max = binsof (all_ops) intersect {SUB_OP} &&
        	(binsof (a_arg.max) || binsof (b_arg.max));
        bins T4_sub_min = binsof (all_ops) intersect {SUB_OP} &&
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
	test_flag = 1'b0;
	repeat (10000) begin
		rep_op = ($urandom() % 32 == 0) ? 1'b1 : 1'b0;
		rst_op = ($urandom() % 32 == 0) ? 1'b1 : 1'b0;
		
		err_in = gen_error();
		op_in = gen_op(err_in);
		A = gen_data();
		B = gen_data();
		
		if(rst_op == 1'b1) begin
			alu_if.rst();
		end
		
		alu_if.op(A, B, op_in, err_in, alu_result);
		test_flag = 1'b1;
		repeat(2) @(negedge clk);
		
		if(rep_op == 1'b1) begin
			alu_if.op(A, B, op_in, err_in, alu_result);
			test_flag = 1'b1;
			repeat(2) @(negedge clk);
		end
	end
	
	repeat (10) @(negedge clk);  
	$finish();
end : tester


/**
 * Test verifier
 */

function logic verify_result(
	input logic signed [31:0] A, 
	input logic signed [31:0] B, 
	input logic [2:0] OP, 
	input logic [2:0] ERROR,
	input alu_result_t RSP);
	
	exp_result = alu_if.exp_result(A, B, OP);

	if((RSP.data == exp_result.data && RSP.flags[3:0] == exp_result.flags) || 
		(RSP.flags[5:3] == ERROR && ERROR != F_ERRNONE))
		return 1'b0;
	else
		return 1'b1;
endfunction


/**
 * Scoreboard
 */

initial begin : scoreboard
	forever begin
		@(posedge test_flag);
		assert(1'b0 == verify_result(A, B, op_in, err_in, alu_result)) begin
`ifdef DEBUG
		$display("\nTEST PASSED");
`endif
		end 
		else begin 
`ifdef DEBUG
		$warning("\nTEST FAILED");
`endif
		end
`ifdef DEBUG
		$display("|         OP: %03b", op_in);
		$display("|          B: 0x%08h", B);
		$display("|          A: 0x%08h", A);
		$display("|          C: 0x%08h", alu_result.data);
		$display("|      FLAGS: %06b", alu_result.flags);
`endif
		@(posedge clk);
		test_flag = 1'b0;
	end
end : scoreboard

endmodule
