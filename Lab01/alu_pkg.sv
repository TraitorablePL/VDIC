package alu_pkg;
	
	typedef enum bit [2:0] {AND_OP = 3'b000, OR_OP = 3'b001, ADD_OP = 3'b100, SUB_OP = 3'b101} OP;
	
	typedef enum bit {DATA, CTL} CMD_TYPE;

	typedef struct {
		logic [31:0] data;
		logic [5:0] flags;
	} rsp_t;
	
endpackage
