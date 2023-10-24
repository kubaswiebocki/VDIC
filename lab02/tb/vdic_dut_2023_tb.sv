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

 History:
 2023-10-12 JS, AGH UST - Testbench create
 */
module top;
	
//------------------------------------------------------------------------------
// Type definitions
//------------------------------------------------------------------------------

typedef enum bit[2:0] {
    RST_OP      	  = 3'b000,
    VALID_A_B		  = 3'b001,
    INVALID_A_B  	  = 3'b010,
    VALID_A_INVALID_B = 3'b011,
    VALID_B_INVALID_A = 3'b100,
    ACK_OP  		  = 3'b101
} operation_t;


typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;


typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;

//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------

bit              	clk;
bit              	rst_n;
shortint			arg_a;
bit         	    arg_a_parity;
shortint			arg_b;
bit              	arg_b_parity;
bit              	req;

wire 			 	ack;
int      	 		result;
wire             	result_parity;
wire 			 	result_rdy;
wire			 	arg_parity_error;

int 				result_expected;
bit             	result_parity_expected;
bit			 		arg_parity_error_expected;
		         
bit			  [2:0] op;	

int					timeout;
operation_t         op_set;
assign op = op_set;

test_result_t       test_result = TEST_PASSED;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

vdic_dut_2023 DUT (.clk, .rst_n, .arg_a, .arg_a_parity, .arg_b, .arg_b_parity, .req, .ack, .result, .result_parity, .result_rdy, .arg_parity_error);

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

initial begin : clk_gen_blk
    clk = 0;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end

//------------------------------------------------------------------------------
// Timestamp monitor
//------------------------------------------------------------------------------
initial begin
    longint clk_counter;
    clk_counter = 0;
    forever begin
        @(posedge clk) clk_counter++;
        if(clk_counter % 1000 == 0) begin
            $display("%0t Clock cycles elapsed: %0d", $time, clk_counter);
        end
    end
end

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------
//---------------------------------
// Random data generation functions
//---------------------------------
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
	    3'b101 : return ACK_OP;
	    3'b110 : return RST_OP;
	    3'b111 : return RST_OP;
	    default : return RST_OP;
    endcase // case (op_choice)
endfunction : get_op

//---------------------------------
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

//---------------------------------
// Random data handling tasks
//---------------------------------

//---------------------------------
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

//---------------------------------
//Reset task
task reset_mult();

`ifdef DEBUG
	$display("%0t DEBUG: reset_mult", $time);
`endif
	
	req   	= 1'b0;
	rst_n	= 1'b0;
	
	@(negedge clk);
	rst_n	= 1'b1;
	
endtask : reset_mult

//---------------------------------
//Calculate expected result
task get_expected(
		input shortint	arg_a,
		input shortint	arg_b,
		input operation_t	op_set,
		
		output int    	    result,
		output bit			result_parity,
		output bit			arg_parity_error
	);

`ifdef DEBUG
	$display("%0t DEBUG: get_excepted(%0d,%0d)", $time, arg_a, arg_b);
`endif
	
	case(op_set)
		VALID_A_B:
		begin
			result				= arg_a * arg_b;
			arg_parity_error	= 1'b0;
			result_parity    	= ^result;
		end
		INVALID_A_B:
		begin
			result				= 32'b0;
			arg_parity_error	= 1'b1;
			result_parity    	= ^result;
		end
		VALID_A_INVALID_B:
		begin
			result				= 32'b0;
			arg_parity_error	= 1'b1;
			result_parity    	= ^result;
		end
		VALID_B_INVALID_A:
		begin
			result				= 32'b0;
			arg_parity_error	= 1'b1;
			result_parity    	= ^result;
		end	
		default:
		begin
			$display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set);
			test_result = TEST_FAILED;
		end
	endcase
endtask : get_expected

//------------------------
// Tester main
//------------------------

initial begin : tester
    reset_mult();
    repeat (1000) begin : tester_main_blk
        @(negedge clk);
        op_set = get_op();
	    arg_a 	= get_data();
	    arg_b 	= get_data();
        case (op_set) // handle the start signal
            RST_OP: begin: case_rst_op_blk
	            reset_mult();
	            assert(result === 0 & ack === 0 & result_rdy === 0) begin
	                `ifdef DEBUG
	                $display("Test passed for reset mult");
	                `endif
	            end
	            else begin
	                $display("Test FAILED for reset mult");
	                $display("Expected value for all outputs is 0. Received result: %d. Received ack: %b. Received result_rdy: %b.", result, ack, result_rdy);
	                test_result = TEST_FAILED;
	            end;
	            continue;
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
            ACK_OP: begin: case_ack_blk
	            timeout = 0;
	            req	= 1'b1;
	            while(!ack && !result_rdy && timeout<1000) begin
		            timeout += 1;
		            @(negedge clk);
	            end
	            assert (timeout < 1000) begin
		            `ifdef DEBUG
                	$display("Test passed for ack and result_rdy");
                	`endif
	            end
	            else begin
		            $display("Test FAILED for ack and result_rdy test");
	                $display("Expected value for both values is 1. Received ack: %b. Received result_rdy: %b.", ack, result_rdy);
	                test_result = TEST_FAILED;
	            end
	            req	= 1'b0;
	            continue;
            end: case_ack_blk
            default: begin : case_default_blk
            	reset_mult();
            end : case_default_blk
        endcase // case (op_set)
        req	= 1'b1;  
        begin
	        while(!ack)@(negedge clk);
        	req = 1'b0;
	        while(!result_rdy)@(negedge clk);
            get_expected(arg_a, arg_b, op_set, result_expected, result_parity_expected, arg_parity_error_expected);
            assert(result === result_expected & result_parity === result_parity_expected & arg_parity_error === arg_parity_error_expected) begin
                `ifdef DEBUG
                $display("Test passed for arg_a=%0d arg_b=%0d op_set=%0d arg_a_parity=%b arg_b_parity=%b", arg_a, arg_b, op, arg_a_parity, arg_b_parity);
                `endif
            end
            else begin
                $display("Test FAILED for arg_a=%0d arg_b=%0d op_set=%0d arg_a_parity=%b arg_b_parity=%b", arg_a, arg_b, op, arg_a_parity, arg_b_parity);
                $display("Expected: %d  received: %d. Expected result_parity: %b  received result_parity: %b. Expected arg_parity_error: %b  received arg_parity_error: %b ", result_expected, result, result_parity_expected, result_parity, arg_parity_error_expected, arg_parity_error);
                test_result = TEST_FAILED;
            end;
        end
    end : tester_main_blk
    $finish;
end : tester


//------------------------------------------------------------------------------
// Temporary. The scoreboard will be later used for checking the data
//------------------------------------------------------------------------------
final begin : finish_of_the_test
    print_test_result(test_result);
end

//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------
// used to modify the color of the text printed on the terminal
function void set_print_color ( print_color_t c );
    string ctl;
    case(c)
        COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
        COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
        COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
        COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
        COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
        COLOR_DEFAULT : ctl              = "\033\[0m\n";
        default : begin
            $error("set_print_color: bad argument");
            ctl                          = "";
        end
    endcase
    $write(ctl);
endfunction

function void print_test_result (test_result_t r);
    if(r == TEST_PASSED) begin
        set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
        $write ("-----------------------------------\n");
        $write ("----------- Test PASSED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
    else begin
        set_print_color(COLOR_BOLD_BLACK_ON_RED);
        $write ("-----------------------------------\n");
        $write ("----------- Test FAILED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
endfunction


endmodule : top
