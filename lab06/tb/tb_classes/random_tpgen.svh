class random_tpgen extends base_tpgen;
    `uvm_component_utils (random_tpgen)
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// function: get_data - generate random data for the tpgen
//------------------------------------------------------------------------------
	protected function shortint get_data();
	    return 16'($random);
	endfunction : get_data

//------------------------------------------------------------------------------
// function: get_op - generate random opcode for the tpgen
//------------------------------------------------------------------------------
	protected function operation_t get_op();
	    bit [2:0] op_choice;
	    op_choice = 3'($random);
	    case (op_choice)
	        3'b000 : return RST_OP;
	        3'b001 : return VALID_A_B;
			3'b010 : return INVALID_A_B;
	        3'b011 : return VALID_A_INVALID_B;
	        3'b100 : return VALID_B_INVALID_A;
		    default : return RST_OP;
	    endcase // case (op_choice)
	endfunction : get_op
    

endclass : random_tpgen