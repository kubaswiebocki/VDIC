class corners_transaction extends command_transaction;
    `uvm_component_utils(corners_transaction)

    shortint arg_a;
	shortint arg_b;
	operation_t op;
//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------
    constraint data {
        arg_a dist {16'h0000:=1, 16'sh0001:=1, 16'sh7FFF:=1,  16'shFFFF:=1, 16'sh8000:=1};
        arg_b dist {16'h0000:=1, 16'sh0001:=1, 16'sh7FFF:=1,  16'shFFFF:=1, 16'sh8000:=1};
	    op dist {[3'b000 : 3'b111]:=1};
    }
    
    
    function new(string name="");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// function: get_data - generate random data for the tpgen
//------------------------------------------------------------------------------
//	protected function shortint get_data();
//	
//	    bit [2:0] zero_ones;
//	
//	    zero_ones = 3'($random);
//		
//	    if (zero_ones == 3'b000)
//	        return 16'sh0000;
//	    else if (zero_ones == 3'b001) 
//	        return 16'sh0001;
//	    else if (zero_ones == 3'b010 || zero_ones == 3'b011)
//	        return 16'sh7FFF;
//	    else if (zero_ones == 3'b100 || zero_ones == 3'b101)
//	        return 16'shFFFF;
//	    else if (zero_ones == 3'b111)
//	        return 16'sh8000;
//	    else
//	        return 16'sh0000;
//	endfunction : get_data
//
////------------------------------------------------------------------------------
//// function: get_op - generate random opcode for the tpgen
////------------------------------------------------------------------------------
//	protected function operation_t get_op();
//	    bit [2:0] op_choice;
//	    op_choice = 3'($random);
//	    case (op_choice)
//	        3'b000 : return RST_OP;
//	        3'b001 : return VALID_A_B;
//			3'b010 : return INVALID_A_B;
//	        3'b011 : return VALID_A_INVALID_B;
//	        3'b100 : return VALID_B_INVALID_A;
//		    default : return RST_OP;
//	    endcase // case (op_choice)
//	endfunction : get_op

endclass : corners_transaction
