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

class scoreboard extends uvm_component;
    `uvm_component_utils(scoreboard)


    protected typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result;

    typedef enum {
	    COLOR_BOLD_BLACK_ON_GREEN,
	    COLOR_BOLD_BLACK_ON_RED,
	    COLOR_BOLD_BLACK_ON_YELLOW,
	    COLOR_BOLD_BLUE_ON_WHITE,
	    COLOR_BLUE_ON_WHITE,
	    COLOR_DEFAULT
	} print_color;

	protected typedef struct packed {
	    shortint arg_a;
	    shortint arg_b;
		bit arg_a_parity;
		bit arg_b_parity;
	    operation_t op_set;
	    int result;
		bit result_parity;
		bit arg_parity_error;
	} data_packet_t;
	
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;
    protected test_result tr = TEST_PASSED; // the result of the current test

    // fifo for storing input and expected data
    protected data_packet_t sb_data_q [$];
	
	protected int                  result_scoreboard;
	protected bit                  result_parity_scoreboard;
	protected bit                  arg_parity_error_scoreboard;
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
	//------------------------------------------------------------------------------
	// calculate expected result
	//------------------------------------------------------------------------------
	protected task get_expected(
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
				tr = TEST_FAILED;
			end
		endcase
	endtask : get_expected


//------------------------------------------------------------------------------
// data registering and checking
//------------------------------------------------------------------------------
    protected task store_cmd();
        forever begin:scoreboard_fe_blk
            @(posedge bfm.clk);
            if(bfm.req) begin
                case(bfm.op_set)
            		VALID_A_B, INVALID_A_B, VALID_B_INVALID_A, VALID_A_INVALID_B: begin
	            		get_expected(bfm.arg_a, bfm.arg_b, bfm.op_set, result_scoreboard, result_parity_scoreboard, arg_parity_error_scoreboard);
                		sb_data_q.push_front(
                    	data_packet_t'({bfm.arg_a, bfm.arg_b, bfm.arg_a_parity, bfm.arg_b_parity, bfm.op_set, result_scoreboard, result_parity_scoreboard, arg_parity_error_scoreboard}));
                        while(!bfm.result_rdy)@(negedge bfm.clk);
                    end
                endcase
            end
        end
    endtask

    protected task process_data_from_dut();
        forever begin : scoreboard_be_blk
            @(negedge bfm.clk) ;
            if(bfm.result_rdy) begin:verify_result
                data_packet_t dp;

                dp = sb_data_q.pop_back();

                if(dp.op_set !== RST_OP) begin
	        		if((bfm.result === dp.result) & (bfm.result_parity === dp.result_parity) & (bfm.arg_parity_error === dp.arg_parity_error)) begin
	           		`ifdef DEBUG
	            		$display("%0t Test passed for arg_a=%0d, arg_a_parity=%0d, arg_b=%0d, arg_b_parity=%0d, op_set=%0d", $time, dp.arg_a, dp.arg_a_parity, dp.arg_b, dp.arg_b_parity, dp.op_set);
		        	`endif
	        		end
	        	else begin
	            	tr = TEST_FAILED;
	            	$error("%0t Test FAILED for arg_a=%0d arg_b=%0d op_set=%0d \n \
						Expected: %d  received: %d. Expected result_parity: %b  received result_parity: %b. E\
						xpected arg_parity_error: %b  received arg_parity_error: %b", 
						$time, dp.arg_a, dp.arg_b, dp.op_set, dp.result, bfm.result, dp.result_parity, bfm.result_parity, dp.arg_parity_error, bfm.arg_parity_error
	        		);         
	        	end
	        	end
            end
        end : scoreboard_be_blk
    endtask

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        fork
            store_cmd();
            process_data_from_dut();
        join_none
    endtask : run_phase
//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
    protected function void print_test_result (test_result r);
        if(tr == TEST_PASSED) begin
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

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

endclass : scoreboard






