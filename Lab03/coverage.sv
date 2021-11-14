module coverage(alu_bfm bfm);

import alu_pkg::*;

/**
 * Coverage
 */
 
covergroup op_cov;
	
	option.name = "cg_op_cov";
	
	all_ops : coverpoint bfm.OP {
		bins basic_op[] = {AND_OP, OR_OP, ADD_OP, SUB_OP};
		bins error_op[] = {3'b010, 3'b011, 3'b110, 3'b111};
		bins T12_repeated_op[] = ({AND_OP, OR_OP, ADD_OP, SUB_OP} [* 2]);
	}
	
	rst : coverpoint bfm.RST {
		bins active = {1'b1};
	}
	
	alu_flags : coverpoint bfm.EXP_RESULT.flags {
		wildcard bins neg = {4'b???1};
		wildcard bins zero = {4'b??1?};
		wildcard bins ovfl = {4'b?1??};
		wildcard bins carry = {4'b1???};
	}
	
	err_flags : coverpoint bfm.ERROR {
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
	
	all_ops : coverpoint bfm.OP {
        ignore_bins not_supported_ops = {3'b010, 3'b011, 3'b110, 3'b111};
	}
	
	a_arg: coverpoint bfm.A {
        bins zeros = {32'h00000000};
		bins min = {32'h80000000};
        bins others = {[32'h00000001:32'h7FFFFFFE], [32'h80000001:32'hFFFFFFFE]};
		bins max  = {32'h7FFFFFFF};
        bins ones  = {32'hFFFFFFFF};
    }

    b_arg: coverpoint bfm.B {
        bins zeros = {32'h00000000};
		bins min = {32'h80000000};
        bins others = {[32'h00000001:32'h7FFFFFFE], [32'h80000001:32'hFFFFFFFE]};
		bins max  = {32'h7FFFFFFF};
        bins ones  = {32'hFFFFFFFF};
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
        @(posedge bfm.clk);
        if(bfm.rst_n) begin
            operation_cov.sample();
            extreme_val_cov.sample();
        end
    end : sample_cov
end : coverage

endmodule
