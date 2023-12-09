class corners_transaction extends command_transaction;
    `uvm_object_utils(corners_transaction)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------
    constraint data {
        arg_a dist {16'sh0000:=1, 16'sh0001:=1, 16'sh7FFF:=1,  16'shFFFF:=1, 16'sh8000:=1};
        arg_b dist {16'sh0000:=1, 16'sh0001:=1, 16'sh7FFF:=1,  16'shFFFF:=1, 16'sh8000:=1};
    }
    
    
    function new(string name="");
        super.new(name);
    endfunction : new

endclass : corners_transaction
