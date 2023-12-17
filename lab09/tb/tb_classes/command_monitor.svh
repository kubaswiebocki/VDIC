class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    local virtual mult_bfm bfm;
    uvm_analysis_port #(sequence_item) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction


//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);

        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")

        ap = new("ap",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// connect phase
//------------------------------------------------------------------------------

    function void connect_phase(uvm_phase phase);
        bfm.command_monitor_h = this;
    endfunction : connect_phase


//------------------------------------------------------------------------------
// monitoring function called from BFM
//------------------------------------------------------------------------------
    function void write_to_monitor(shortint arg_a, shortint arg_b, bit arg_a_parity, bit arg_b_parity, operation_t op);
        sequence_item cmd;
	    `uvm_info("COMMAND MONITOR",$sformatf("MONITOR: arg_a: %0d  arg_b: %0d op: %0d",
                arg_a, arg_b, op.name()), UVM_HIGH);
	    cmd    = new("cmd");
        cmd.arg_a  = arg_a;
        cmd.arg_b  = arg_b;
	    cmd.arg_a_parity = arg_a_parity;
	    cmd.arg_b_parity = arg_b_parity;
        cmd.op = op;
        ap.write(cmd);
    endfunction : write_to_monitor
    
endclass : command_monitor