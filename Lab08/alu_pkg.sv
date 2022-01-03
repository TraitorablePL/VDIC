`timescale 1ns / 1ps

package alu_pkg;
	import uvm_pkg::*;
    `include "uvm_macros.svh"

////////////////////////////////////////
// ALU data types
////////////////////////////////////////

	typedef enum bit {DATA, CTL} cmd_t;
	
	typedef enum bit [2:0] {
		AND_OP = 3'b000, 
		OR_OP = 3'b001, 
		ADD_OP = 3'b100, 
		SUB_OP = 3'b101
	} op_t;
	
	typedef enum bit [3:0] {
		F_NONE = 4'b0000,
		F_NEG = 4'b0001, 
		F_ZERO = 4'b0010, 
		F_OVFL = 4'b0100, 
		F_CARRY = 4'b1000
	} alu_t;
	
	typedef enum bit [2:0] {
		F_ERRNONE = 3'b000, 
		F_ERROP = 3'b001, 
		F_ERRCRC = 3'b010, 
		F_ERRDATA = 3'b100
	} err_t;
	
	typedef struct packed {
		bit signed [31:0] data;
		bit [5:0] flags;
	} alu_result_t;
	
	typedef struct packed {
		bit signed [31:0] data;
		bit [3:0] flags;
	} exp_result_t;
	
	typedef struct packed {
		bit signed [31:0] A;
		bit signed [31:0] B;
		bit [2:0] OP;
		bit [2:0] ERROR;
		bit RST;
		exp_result_t EXP_RESULT;
    } cmd_pack_t;
    
    typedef enum {
        COLOR_BOLD_BLACK_ON_GREEN,
        COLOR_BOLD_BLACK_ON_RED,
        COLOR_BOLD_BLACK_ON_YELLOW,
        COLOR_BOLD_BLUE_ON_WHITE,
        COLOR_BLUE_ON_WHITE,
        COLOR_DEFAULT
    } print_color_t;
    
////////////////////////////////////////
// ALU tasks and functions
////////////////////////////////////////

function void set_print_color(print_color_t c);
    string ctl;
    case(c)
        COLOR_BOLD_BLACK_ON_GREEN : ctl = "\033\[1;30m\033\[102m";
        COLOR_BOLD_BLACK_ON_RED : ctl = "\033\[1;30m\033\[101m";
        COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
        COLOR_BOLD_BLUE_ON_WHITE : ctl = "\033\[1;34m\033\[107m";
        COLOR_BLUE_ON_WHITE : ctl = "\033\[0;34m\033\[107m";
        COLOR_DEFAULT : ctl = "\033\[0m\n";
        default : begin
            $error("set_print_color: bad_argument");
            ctl = "";
        end
    endcase
    $write(ctl);
endfunction

////////////////////////////////////////
// ALU includes
////////////////////////////////////////

`include "random_command.svh"
`include "extreme_val_command.svh"
`include "result_transaction.svh"

`include "coverage.svh"
`include "tester.svh"
`include "scoreboard.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"
`include "env.svh"

////////////////////////////////////////
// ALU test includes
////////////////////////////////////////

`include "random_test.svh"
`include "extreme_val_test.svh"

endpackage : alu_pkg
