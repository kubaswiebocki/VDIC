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
class sequence_item extends uvm_sequence_item;

//  This macro is moved below the variables definition and expanded.
//    `uvm_object_utils(sequence_item)

//------------------------------------------------------------------------------
// sequence item variables
//------------------------------------------------------------------------------

    rand shortint arg_a;
    rand shortint arg_b;
    rand operation_t op;
	bit arg_a_parity;
	bit arg_b_parity;

//------------------------------------------------------------------------------
// Macros providing copy, compare, pack, record, print functions.
// Individual functions can be enabled/disabled with the last
// `uvm_field_*() macro argument.
// Note: this is an expanded version of the `uvm_object_utils with additional
//       fields added. DVT has a dedicated editor for this (ctrl-space).
//------------------------------------------------------------------------------

    `uvm_object_utils_begin(sequence_item)
        `uvm_field_int(arg_a, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(arg_b, UVM_ALL_ON | UVM_DEC)
        `uvm_field_enum(operation_t, op, UVM_ALL_ON)
        `uvm_field_int(arg_a_parity, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(arg_b_parity, UVM_ALL_ON | UVM_BIN)
    `uvm_object_utils_end

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

	constraint data {
        arg_a dist {16'sh0000:=5, 16'sh0001:=3, 16'sh7FFF:=5,  16'shFFFF:=1, 16'sh8000:=3, [16'sh0002:16'sh7FFE], [16'sh8001:16'shFFFE]};
        arg_b dist {16'sh0000:=5, 16'sh0001:=3, 16'sh7FFF:=5,  16'shFFFF:=3, 16'sh8000:=4, [16'sh0002:16'sh7FFE], [16'sh8001:16'shFFFE]};
    }

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "sequence_item");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// convert2string 
//------------------------------------------------------------------------------

	function string convert2string();
	    return {super.convert2string(),
	   		$sformatf("argA: %d  argB: %d argAparity: %d argBparity: %d op: %s", arg_a, arg_b, arg_a_parity, arg_b_parity, op.name())
	    };
	endfunction : convert2string

endclass : sequence_item


