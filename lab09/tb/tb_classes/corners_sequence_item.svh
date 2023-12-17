class corners_sequence_item extends sequence_item;
    `uvm_object_utils(corners_sequence_item)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------
    constraint corners {
        arg_a dist {16'sh0000:=1, 16'sh0001:=1, 16'sh7FFF:=1,  16'shFFFF:=1, 16'sh8000:=1};
        arg_b dist {16'sh0000:=1, 16'sh0001:=1, 16'sh7FFF:=1,  16'shFFFF:=1, 16'sh8000:=1};
    }
    
    
    function new(string name="corners_sequence_item");
        super.new(name);
    endfunction : new

endclass : corners_sequence_item
