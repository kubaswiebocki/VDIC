class corners_test extends random_test;
    `uvm_component_utils(corners_test)

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
        
        super.build_phase(phase);
        command_transaction::type_id::set_type_override(corners_transaction::get_type());

    endfunction : build_phase
  
endclass
