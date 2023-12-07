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
class tpgen extends uvm_component;
    `uvm_component_utils (tpgen)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

    uvm_put_port #(command_transaction) command_port;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------

    task run_phase(uvm_phase phase);
        command_transaction command;

        phase.raise_objection(this);

        command    = new("command");
        command.op = rst_op;
        command_port.put(command);

        command    = command_transaction::type_id::create("command");

        set_print_color(COLOR_BOLD_BLACK_ON_YELLOW);
        `uvm_info("TPGEN", $sformatf("*** Created transaction type: %s",command.get_type_name()), UVM_MEDIUM);
        set_print_color(COLOR_DEFAULT);

        repeat (10000) begin
            assert(command.randomize());
            command_port.put(command);
        end

        command    = new("command");
        command.op = mul_op;
        command.A  = 8'hFF;
        command.B  = 8'hFF;
        command_port.put(command);

        #500;
        phase.drop_objection(this);
    endtask : run_phase


endclass : tpgen