class random_test extends uvm_test;
    `uvm_component_utils(random_test)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    env env_h;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        env_h = env::type_id::create("env_h",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// start-of-simulation-phase
//------------------------------------------------------------------------------
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        // Print the test topology
        this.print();
    endfunction : end_of_elaboration_phase

endclass