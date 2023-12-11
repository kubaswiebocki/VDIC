class command_transaction extends uvm_transaction;
    `uvm_object_utils(command_transaction)

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

    rand shortint arg_a;
    rand shortint arg_b;
    rand operation_t op;
	bit arg_a_parity;
	bit arg_b_parity;
	
	
	constraint data {
        arg_a dist {16'sh0000:=1, 16'sh0001:=5, 16'sh7FFF:=3,  16'shFFFF:=1, 16'sh8000:=3, [16'sh0002:16'sh7FFE], [16'sh8001:16'shFFFE]};
        arg_b dist {16'sh0000:=1, 16'sh0001:=7, 16'sh7FFF:=3,  16'shFFFF:=1, 16'sh8000:=4, [16'sh0002:16'sh7FFE], [16'sh8001:16'shFFFE]};
    }
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name = "");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// transaction functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------
    extern function void do_copy(uvm_object rhs);
    extern function command_transaction clone_me();
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();

endclass : command_transaction

function void command_transaction::do_copy(uvm_object rhs);
    command_transaction copied_transaction_h;

    if(rhs == null)
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

    super.do_copy(rhs); // copy all parent class data

    if(!$cast(copied_transaction_h,rhs))
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

    arg_a  = copied_transaction_h.arg_a;
    arg_b  = copied_transaction_h.arg_b;
    arg_a_parity  = copied_transaction_h.arg_a_parity;
    arg_b_parity  = copied_transaction_h.arg_b_parity;
    op = copied_transaction_h.op;

endfunction : do_copy


function command_transaction command_transaction::clone_me();
    
    command_transaction clone;
    uvm_object tmp;

    tmp = this.clone();
    $cast(clone, tmp);
    return clone;
    
endfunction : clone_me


function bit command_transaction::do_compare(uvm_object rhs, uvm_comparer comparer);
    
    command_transaction compared_transaction_h;
    bit same;

    if (rhs==null) `uvm_fatal("COMMAND TRANSACTION",
            "Tried to do comparison to a null pointer");

    if (!$cast(compared_transaction_h,rhs))
        same = 0;
    else
        same = super.do_compare(rhs, comparer) &&
        (compared_transaction_h.arg_a == arg_a) &&
        (compared_transaction_h.arg_b == arg_b) &&
        (compared_transaction_h.arg_a_parity == arg_a_parity) &&
        (compared_transaction_h.arg_b_parity == arg_b_parity) &&
        (compared_transaction_h.op == op);

    return same;
    
endfunction : do_compare


function string command_transaction::convert2string();
    string s;
    s = $sformatf("argA: %d  argB: %d argAparity: %d argBparity: %d op: %s", arg_a, arg_b, arg_a_parity, arg_b_parity, op.name());
    return s;
endfunction : convert2string

