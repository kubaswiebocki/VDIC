class scoreboard extends uvm_subscriber #(results_s);
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

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
//    virtual tinyalu_bfm bfm;
    uvm_tlm_analysis_fifo #(command_s) cmd_f;

    protected test_result tr = TEST_PASSED; // the result of the current test
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
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
// calculate expected result
//------------------------------------------------------------------------------
	protected function bit get_expected_error(
			input operation_t	op_set
		);
	
	`ifdef DEBUG
		$display("%0t DEBUG: get_excepted(%0d,%0d)", $time, arg_a, arg_b);
	`endif
				
		bit	arg_parity_error;
		
		case(op_set)
			VALID_A_B:
			begin
				arg_parity_error	= 1'b0;
			end
			INVALID_A_B:
			begin
				arg_parity_error	= 1'b1;
			end
			VALID_A_INVALID_B:
			begin
				arg_parity_error	= 1'b1;
			end
			VALID_B_INVALID_A:
			begin
				arg_parity_error	= 1'b1;
			end	
			default:
			begin
				$display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set);
				tr = TEST_FAILED;
			end
		endcase
		return arg_parity_error;
	endfunction : get_expected_error
	
protected function int get_expected_result(
			input shortint	arg_a,
			input shortint	arg_b,
			input operation_t	op_set
		);
		
	`ifdef DEBUG
		$display("%0t DEBUG: get_excepted(%0d,%0d)", $time, arg_a, arg_b);
	`endif
			int    	    result;
		case(op_set)
			VALID_A_B:
			begin
				result	= arg_a * arg_b;
			end
			INVALID_A_B:
			begin
				result				= 32'b0;
			end
			VALID_A_INVALID_B:
			begin
				result				= 32'b0;
			end
			VALID_B_INVALID_A:
			begin
				result				= 32'b0;
			end	
			default:
			begin
				$display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set);
				tr = TEST_FAILED;
			end
		endcase
		return result;
endfunction : get_expected_result

protected function bit get_expected_parity(
			input int	res,
			input operation_t	op_set
		);
	
	`ifdef DEBUG
		$display("%0t DEBUG: get_excepted(%0d,%0d)", $time, arg_a, arg_b);
	`endif
		
		bit			result_parity;
	
		case(op_set)
			VALID_A_B:
			begin
				result_parity    	= ^res;
			end
			INVALID_A_B:
			begin
				result_parity    	= ^res;
			end
			VALID_A_INVALID_B:
			begin
				result_parity    	= ^res;
			end
			VALID_B_INVALID_A:
			begin
				result_parity    	= ^res;
			end	
			default:
			begin
				$display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set);
				tr = TEST_FAILED;
			end
		endcase
		return result_parity;
endfunction : get_expected_parity
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
    function void write(results_s t);
	    int result_scoreboard;
	    bit result_parity_scoreboard;
	    bit arg_parity_error_scoreboard;
	    
        command_s cmd;
	    
        cmd.arg_a        = 0;
	    cmd.arg_b        = 0;
        cmd.op           = RST_OP;

        case(cmd.op)
    		VALID_A_B, INVALID_A_B, VALID_B_INVALID_A, VALID_A_INVALID_B: begin
        		result_scoreboard = get_expected_result(cmd.arg_a, cmd.arg_b, cmd.op);
	    		result_parity_scoreboard = get_expected_parity(result_scoreboard, cmd.op);
	    		arg_parity_error_scoreboard = get_expected_error(cmd.op);
            end
        endcase
        
		if(cmd.op !== RST_OP) begin
	        if((t.result == result_scoreboard) && (t.result_parity == result_parity_scoreboard) && (t.arg_parity_error == arg_parity_error_scoreboard)) begin
           		`ifdef DEBUG
            		$display("%0t Test passed for arg_a=%0d, arg_a_parity=%0d, arg_b=%0d, arg_b_parity=%0d, op_set=%0d", $time, cmd.arg_a, cmd.arg_a_parity, cmd.arg_b, cmd.arg_b_parity, cmd.op);
	        	`endif
	        end
	        else begin
	            tr = TEST_FAILED;
	            $error("%0t Test FAILED for arg_a=%0d arg_b=%0d op_set=%0d \n \
						Expected: %d. Expected result_parity: %b Expected arg_parity_error: %b", 
						$time, cmd.arg_a, cmd.arg_b, cmd.op, result_scoreboard, result_parity_scoreboard, arg_parity_error_scoreboard);         
	        	end
	    end
    endfunction : write


//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

endclass : scoreboard






