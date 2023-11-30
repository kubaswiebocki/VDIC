`timescale 1ns/1ps

package mult_pkg;
	
	import uvm_pkg::*;
    `include "uvm_macros.svh"
	
	typedef enum bit[2:0] {
	    RST_OP      	= 3'b000,
	    VALID_A_B		= 3'b001,
	    INVALID_A_B  	= 3'b010,
	    VALID_A_INVALID_B 	= 3'b011,
	    VALID_B_INVALID_A 	= 3'b100
	} operation_t;

    // MULT data packet
    typedef struct packed {
	    bit			arg_a_parity;
	    bit 		arg_b_parity;
        shortint	arg_a;
        shortint	arg_b;
        operation_t op;
    } command_s;

    // Results data packet
    typedef struct packed {
        int			result;
		bit			result_parity;
		bit			arg_parity_error;
    } results_s;
	
	typedef enum {
        COLOR_BOLD_BLACK_ON_GREEN,
        COLOR_BOLD_BLACK_ON_RED,
        COLOR_BOLD_BLACK_ON_YELLOW,
        COLOR_BOLD_BLUE_ON_WHITE,
        COLOR_BLUE_ON_WHITE,
        COLOR_DEFAULT
	} print_color;
	
	function void set_print_color ( print_color c );
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
	    
	//------------------------------------------------------------------------------
	// testbench classes
	//------------------------------------------------------------------------------
	`include "coverage.svh"
	`include "base_tpgen.svh"
	`include "random_tpgen.svh"
	`include "corners_tpgen.svh"
	
	`include "scoreboard.svh"
	`include "driver.svh"
	
	`include "command_monitor.svh"
	`include "result_monitor.svh"
	`include "env.svh"
	
	//------------------------------------------------------------------------------
	// test classes
	//------------------------------------------------------------------------------
	`include "random_test.svh"
	`include "corners_test.svh"

endpackage : mult_pkg