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
package tinyalu_pkg;
    import uvm_pkg::*;
`include "uvm_macros.svh"

    typedef enum bit[2:0] {
        no_op  = 3'b000,
        add_op = 3'b001,
        and_op = 3'b010,
        xor_op = 3'b011,
        mul_op = 3'b100,
        rst_op = 3'b111} operation_t;

    // terminal print colors
    typedef enum {
        COLOR_BOLD_BLACK_ON_GREEN,
        COLOR_BOLD_BLACK_ON_RED,
        COLOR_BOLD_BLACK_ON_YELLOW,
        COLOR_BOLD_BLUE_ON_WHITE,
        COLOR_BLUE_ON_WHITE,
        COLOR_DEFAULT
    } print_color;

//------------------------------------------------------------------------------
// package functions
//------------------------------------------------------------------------------

    // used to modify the color of the text printed on the terminal

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
// sequence items
//------------------------------------------------------------------------------

`include "sequence_item.svh"
`include "add_sequence_item.svh"

// to be converted into sequence items
`include "result_transaction.svh"

//------------------------------------------------------------------------------
// sequencer
//------------------------------------------------------------------------------

//`include "sequencer.svh"

// we can use typedef instead of the sequencer class
    typedef uvm_sequencer #(sequence_item) sequencer;

//------------------------------------------------------------------------------
// sequences
//------------------------------------------------------------------------------

`include "random_sequence.svh"
`include "maxmult_sequence.svh"
`include "reset_sequence.svh"
`include "add_sequence.svh"
`include "fibonacci_sequence.svh"
`include "short_random_sequence.svh"

//------------------------------------------------------------------------------
// virtual sequences
//------------------------------------------------------------------------------

`include "runall_sequence.svh"
`include "parallel_sequence.svh"

//------------------------------------------------------------------------------
// testbench components (no agent here)
//------------------------------------------------------------------------------

`include "coverage.svh"
`include "scoreboard.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"
`include "env.svh"

//------------------------------------------------------------------------------
// tests
//------------------------------------------------------------------------------

`include "tinyalu_base_test.svh"
`include "runall_test.svh"
`include "fibonacci_test.svh"
`include "parallel_test.svh"


endpackage : tinyalu_pkg
