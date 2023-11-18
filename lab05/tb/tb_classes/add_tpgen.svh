class add_tpgen extends random_tpgen;
    `uvm_component_utils(add_tpgen)


	protected function operation_t get_op();
	    bit [2:0] op_choice;
	    return RST_OP;
	endfunction : get_op

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new


endclass : add_tpgen
