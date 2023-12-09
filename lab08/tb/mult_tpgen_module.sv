module mult_tpgen_module(mult_bfm bfm);
import mult_pkg::*;

function operation_t get_op();
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

function shortint get_data();

    bit [2:0] zero_ones;

    zero_ones = 3'($random);
	
    if (zero_ones == 3'b000)
        return 16'sh0000;
    else if (zero_ones == 3'b001) 
        return 16'sh0001;
    else if (zero_ones == 3'b010)
        return 16'sh7FFF;
    else if (zero_ones == 3'b100)
        return 16'shFFFF;
    else if (zero_ones == 3'b111)
        return 16'sh8000;
    else
        return 16'($random);
endfunction : get_data

initial begin
    shortint arg_a;
	shortint arg_b;
    operation_t op_set;
	bit arg_a_parity;	
	bit arg_b_parity;	

    bfm.reset_mult();
    repeat (10000) begin : random_loop
        op_set = get_op();
        arg_a     = get_data();
        arg_b     = get_data();
        bfm.send_op(arg_a, arg_b, op_set, arg_a_parity, arg_b_parity);
    end : random_loop
    
    bfm.send_op(arg_a, arg_b, op_set, arg_a_parity, arg_b_parity);
    bfm.reset_mult();
end // initial begin


endmodule : mult_tpgen_module





