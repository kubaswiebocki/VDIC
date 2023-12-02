class scoreboard extends uvm_subscriber #(result_transaction);
    `uvm_component_utils(scoreboard)


    typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
//    virtual tinyalu_bfm bfm;
    uvm_tlm_analysis_fifo #(command_transaction) cmd_f;

    local test_result tr = TEST_PASSED; // the result of the current test
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
    local function void print_test_result (test_result r);
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
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

local function result_transaction get_expected(command_transaction cmd);
		shortint arg_a;
		shortint arg_b;
		operation_t op;
		result_transaction predicted;	
	
		arg_a = cmd.arg_a;
		arg_b = cmd.arg_b;
		op = cmd.op;
	
        predicted = new("predicted");
		case(op)
			VALID_A_B:
			begin
				predicted.result			= arg_a * arg_b;
				predicted.arg_parity_error	= 1'b0;
				predicted.result_parity    	= ^(arg_a * arg_b);
			end
			INVALID_A_B:
			begin
				predicted.result			= 32'b0;
				predicted.arg_parity_error	= 1'b1;
				predicted.result_parity    	= ^(32'b0);
			end
			VALID_A_INVALID_B:
			begin
				predicted.result			= 32'b0;
				predicted.arg_parity_error	= 1'b1;
				predicted.result_parity    	= ^(32'b0);
			end
			VALID_B_INVALID_A:
			begin
				predicted.result			= 32'b0;
				predicted.arg_parity_error	= 1'b1;
				predicted.result_parity    	= ^(32'b0);
			end	
			default:
			begin
				$display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op);
				tr = TEST_FAILED;
			end
		endcase
		return predicted;
endfunction : get_expected

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
    function void write(result_transaction t);
	    string data_str;
        command_transaction cmd;
	    result_transaction predicted;

        case(cmd.op)
    		VALID_A_B, INVALID_A_B, VALID_B_INVALID_A, VALID_A_INVALID_B: begin
        		predicted = get_expected(cmd);
            end
        endcase
        
        if (cmd.op!== RST_OP) begin
	        data_str = {cmd.convert2string(), "==> Actual ", t.convert2string(), "/Predicyed ", predicted.convert2string()};
	        if(!predicted.compare(t)) begin
		        `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
	            tr = TEST_FAILED;
	        end
	        else
		        `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)
        end
        
//		if(cmd.op !== RST_OP) begin
//	        if((t.result == predicted.result) && (t.result_parity == predicted.result_parity) && (t.arg_parity_error == predicted.arg_parity_error)) begin
//           		`ifdef DEBUG
//            		$display("%0t Test passed for arg_a=%0d, arg_a_parity=%0d, arg_b=%0d, arg_b_parity=%0d, op_set=%0d", $time, cmd.arg_a, cmd.arg_a_parity, cmd.arg_b, cmd.arg_b_parity, cmd.op);
//	        	`endif
//	        end
//	        else begin
//	            tr = TEST_FAILED;
//	            $error("%0t Test FAILED for arg_a=%0d arg_b=%0d op_set=%0d \n \
//						Expected: %d. Expected result_parity: %b Expected arg_parity_error: %b", 
//						$time, cmd.arg_a, cmd.arg_b, cmd.op, predicted.result, predicted.result_parity, predicted.arg_parity_error);         
//	        	end
//	    end
    endfunction : write


//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

endclass : scoreboard






