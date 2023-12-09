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
	    
	    set_print_color(COLOR_BOLD_BLACK_ON_YELLOW);
        `uvm_info("TPGEN", $sformatf("*** Created transaction type: %s",command.get_type_name()), UVM_MEDIUM);
        set_print_color(COLOR_DEFAULT);
	    
	    repeat (10000) begin : random_loop
            assert(command.randomize());
            command_port.put(command);
	    end : random_loop
	    
	    command    = new("command");
	    command.op = RST_OP;
	    command.arg_a = 16'hFFFF;
	    command.arg_b = 16'hFFFF;
	    command_port.put(command);
	    
	    #500;
        phase.drop_objection(this);

    endtask : run_phase

endclass : tpgen
