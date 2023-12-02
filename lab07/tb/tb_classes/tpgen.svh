class tpgen extends uvm_component;
    `uvm_component_utils (tpgen)

// The macro is not there as we never instantiate/use the base_tpgen
//    `uvm_component_utils(base_tpgen)
//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------
    uvm_put_port #(command_transaction) command_port;
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
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
	    command.op = RST_OP;
        command_port.put(command);
	    
	    command = command_transaction::type_id::create("command"); 
	    repeat (5000) begin : random_loop
            if(command.randomize());
            command_port.put(command);
	    end : random_loop
	    
	    command    = new("command");
	    command.op = RST_OP;
	    command_port.put(command);
	    
	    #500;
        phase.drop_objection(this);

    endtask : run_phase

endclass : tpgen
