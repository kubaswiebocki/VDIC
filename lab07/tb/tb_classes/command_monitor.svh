class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;
    uvm_analysis_port #(command_transaction) ap;

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
        bfm.command_monitor_h = this;
        ap                    = new("ap",this);
    endfunction : build_phase


//------------------------------------------------------------------------------
// monitoring function called from BFM
//------------------------------------------------------------------------------
    function void write_to_monitor(shortint arg_a, shortint arg_b, bit arg_a_parity, bit arg_b_parity, operation_t op);
        command_transaction cmd;
	    `uvm_info("COMMAND MONITOR",$sformatf("MONITOR: arg_A: %2h  arg_B: %2h  op: %s",
                arg_a, arg_b, op.name()), UVM_HIGH);
	    cmd    = new("cmd");
        cmd.arg_a  = arg_a;
        cmd.arg_b  = arg_b;
        cmd.arg_a_parity  = arg_a_parity;
        cmd.arg_b_parity  = arg_b_parity;
        cmd.op = op;
        ap.write(cmd);
    endfunction : write_to_monitor
    
endclass : command_monitor