package alu_pkg;
	
	typedef enum bit [2:0] {
		AND_OP = 3'b000, 
		OR_OP = 3'b001, 
		ADD_OP = 3'b100, 
		SUB_OP = 3'b101} op_t;
	
	typedef enum bit {DATA, CTL} cmd_t;
	
	typedef enum bit [3:0] {
		F_NONE = 4'b0000,
		F_NEG = 4'b0001, 
		F_ZERO = 4'b0010, 
		F_OVFL = 4'b0100, 
		F_CARRY = 4'b1000} alu_t;
	
	typedef enum bit [2:0] {
		F_ERRNONE = 3'b000, 
		F_ERROP = 3'b001, 
		F_ERRCRC = 3'b010, 
		F_ERRDATA = 3'b100} err_t;
	
	typedef struct {
		logic signed [31:0] data;
		logic [5:0] flags;
	} alu_result_t;
	
	typedef struct {
		logic signed [31:0] data;
		logic [3:0] flags;
	} exp_result_t;
	
endpackage
