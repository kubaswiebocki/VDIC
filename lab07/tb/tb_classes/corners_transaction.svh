class corners_transaction extends command_transaction;
    `uvm_object_utils(corners_transaction)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------
    constraint data {
        arg_a dist {16'sh0000:=2, 16'sh0001:=2, 16'sh7FFF:=2,  16'shFFFF:=2, 16'sh8000:=2};
        arg_b dist {16'sh0000:=2, 16'sh0001:=2, 16'sh7FFF:=2,  16'shFFFF:=2, 16'sh8000:=2};
    }
    
    
    function new(string name="");
        super.new(name);
    endfunction : new

endclass : corners_transaction
