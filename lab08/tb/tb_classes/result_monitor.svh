class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;
    uvm_analysis_port #(result_transaction) ap;

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
	    mult_agent_config agent_config_h;
        if(!uvm_config_db #(mult_agent_config)::get(this, "","config", agent_config_h))
            `uvm_fatal("RESULT MONITOR", "Failed to get CONFIG");
        agent_config_h.bfm.result_monitor_h = this;
        ap                   = new("ap",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// monitoring function called from BFM
//------------------------------------------------------------------------------
    function void write_to_monitor(int result, bit result_parity, bit arg_parity_error);
	    result_transaction result_t;
	    result_t  = new("result_t");
	    result_t.result = result;
	    result_t.result_parity = result_parity;
	    result_t.arg_parity_error = arg_parity_error;
        ap.write(result_t);
    endfunction : write_to_monitor

endclass : result_monitor






