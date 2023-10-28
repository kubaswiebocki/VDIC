/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
interface mult_bfm;
import mult_pkg::*;

bit 		clk;
bit 		rst_n;
shortint 	arg_a;
bit 		arg_a_parity;
shortint 	arg_b;
bit 		arg_b_parity;
bit 		req;

wire		ack;
int			result;
wire		result_parity;
wire		result_rdy;
wire		arg_parity_error;

operation_t op_set;

modport tlm (import reset_mult, send_op);
    
//------------------------------------------------------------------------------
// clock generator  
//------------------------------------------------------------------------------
initial begin
    clk = 0;
    forever begin
        #10;
        clk = ~clk;
    end
end


//------------------------------------------------------------------------------
// reset_alu
//------------------------------------------------------------------------------

task reset_mult();
    `ifdef DEBUG
    	$display("%0t DEBUG: reset_mult", $time);
    `endif

    req   = 1'b0;
    rst_n = 1'b0;

    @(negedge clk);
    rst_n = 1'b1;

endtask : reset_mult

//Input data parity check
task get_parity(
		input shortint   data,
		input bit        data_valid,
		
		output bit       parity
	);
	
	parity = ^data;
	
	if (data_valid == 0)
		parity = !parity;

endtask : get_parity

//------------------------------------------------------------------------------
// send_op
//------------------------------------------------------------------------------

task send_op(input shortint iArg_a, input shortint iArg_b, input operation_t iop, output int mult_result, output bit mult_result_parity, output bit mult_arg_parity_error, output bit oArg_a_parity, output bit oArg_b_parity);

    op_set 		= iop;
    arg_a 		= iArg_a;
    arg_b 		= iArg_b;
    arg_a_parity 	= oArg_a_parity;
    arg_b_parity 	= oArg_b_parity;

    case (op_set)
	RST_OP: begin: case_rst_op_blk
	    reset_mult(); 
	end : case_rst_op_blk
	VALID_A_B: begin: case_valid_a_b_blk
	    get_parity(arg_a, 1'b1, arg_a_parity);
	    get_parity(arg_b, 1'b1, arg_b_parity);
	end : case_valid_a_b_blk
	INVALID_A_B: begin: case_invalid_a_b_blk
	    get_parity(arg_a, 1'b0, arg_a_parity);
	    get_parity(arg_b, 1'b0, arg_b_parity);
	end : case_invalid_a_b_blk
	VALID_A_INVALID_B: begin: case_vd_a_ivd_b_blk
	    get_parity(arg_a, 1'b1, arg_a_parity);
	    get_parity(arg_b, 1'b0, arg_b_parity);
	end : case_vd_a_ivd_b_blk
	VALID_B_INVALID_A: begin: case_vd_b_ivd_a_blk
	    get_parity(arg_a, 1'b0, arg_a_parity);
	    get_parity(arg_b, 1'b1, arg_b_parity);
	end : case_vd_b_ivd_a_blk
    endcase // case (op_set)
endtask : send_op


endinterface : mult_bfm


