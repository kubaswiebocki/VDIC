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
module tpgen(mult_bfm bfm);
    
import mult_pkg::*;


// Generate random operation to do
function operation_t get_op();
    bit [2:0] op_choice;
    op_choice = 3'($random);
    case (op_choice)
        3'b000 : return RST_OP;
        3'b001 : return VALID_A_B;
		3'b010 : return INVALID_A_B;
        3'b011 : return VALID_A_INVALID_B;
        3'b100 : return VALID_B_INVALID_A;
	    default : return RST_OP;
    endcase // case (op_choice)
endfunction : get_op


// Generate random data for input a,b
function shortint get_data();

    bit [2:0] zero_ones;

    zero_ones = 3'($random);
	
    if (zero_ones == 3'b000)
        return 16'h0000;
    else if (zero_ones == 3'b001) 
        return 16'h0001;
    else if (zero_ones == 3'b010)
        return 16'h7FFF;
    else if (zero_ones == 3'b100)
        return 16'hFFFF;
    else if (zero_ones == 3'b111)
        return 16'h8000;
    else
        return 16'($random);
endfunction : get_data


initial begin
    shortint arg_a;
	shortint arg_b;
    operation_t op_set;
    int result;
	bit result_parity;
	bit arg_parity_error;	
	bit arg_a_parity;	
	bit arg_b_parity;	
	
    bfm.reset_mult();
    
    repeat (1000) begin : tester_main_blk
        op_set = get_op();
	    arg_a 	= get_data();
	    arg_b 	= get_data();
		bfm.send_op(arg_a, arg_b, op_set, result, result_parity, arg_parity_error, arg_a_parity, arg_b_parity);
        bfm.req	= 1'b1;  
        while(!bfm.ack)@(negedge bfm.clk);
    	bfm.req = 1'b0;
        while(!bfm.result_rdy)@(negedge bfm.clk);        
    end : tester_main_blk
    $finish;
end // initial begin


endmodule : tpgen
