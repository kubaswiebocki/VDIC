import mult_pkg::*;
 
interface mult_bfm;

bit 		clk;
bit 		rst_n;
shortint 	arg_a;
bit 		arg_a_parity;
shortint 	arg_b;
bit 		arg_b_parity;
bit 		req;

wire		ack;
int			result;
wire		result_parity;
wire		result_rdy;
wire		arg_parity_error;

operation_t op_set;
    
command_monitor command_monitor_h;
result_monitor result_monitor_h;

//------------------------------------------------------------------------------
// reset_alu
//------------------------------------------------------------------------------

task reset_mult();
    `ifdef DEBUG
    	$display("%0t DEBUG: reset_mult", $time);
    `endif

    req   = 1'b0;
    rst_n = 1'b0;

    @(negedge clk);
    rst_n = 1'b1;

endtask : reset_mult

//Input data parity check
function bit get_parity(
		input shortint   data,
		input bit        data_valid
	);
	
	bit       parity;
	parity = ^data;
	
	if (data_valid == 0)
		parity = !parity;
	return parity;
endfunction : get_parity

//------------------------------------------------------------------------------
// send_op
//------------------------------------------------------------------------------

task send_op(input shortint iArg_a, input shortint iArg_b, input operation_t iop, output bit oArg_a_parity, output bit oArg_b_parity);

    op_set 		= iop;
    arg_a 		= iArg_a;
    arg_b 		= iArg_b;
    oArg_a_parity = arg_a_parity;
    oArg_b_parity = arg_b_parity;
	
    case (op_set)
	RST_OP: begin: case_rst_op_blk
	    reset_mult(); 
	end : case_rst_op_blk
	VALID_A_B: begin: case_valid_a_b_blk
	    arg_a_parity = get_parity(arg_a, 1'b1);
	    arg_b_parity = get_parity(arg_b, 1'b1);
	end : case_valid_a_b_blk
	INVALID_A_B: begin: case_invalid_a_b_blk
	    arg_a_parity = get_parity(arg_a, 1'b0);
	    arg_b_parity = get_parity(arg_b, 1'b0);
	end : case_invalid_a_b_blk
	VALID_A_INVALID_B: begin: case_vd_a_ivd_b_blk
	    arg_a_parity = get_parity(arg_a, 1'b1);
	    arg_b_parity = get_parity(arg_b, 1'b0);
	end : case_vd_a_ivd_b_blk
	VALID_B_INVALID_A: begin: case_vd_b_ivd_a_blk
	    arg_a_parity = get_parity(arg_a, 1'b0);
	    arg_b_parity = get_parity(arg_b, 1'b1);
	end : case_vd_b_ivd_a_blk
    endcase // case (op_set)
    
    req = 1;
    wait(ack);
    req = 0;
    wait(result_rdy);

endtask : send_op

//------------------------------------------------------------------------------
// write command monitor
//------------------------------------------------------------------------------

always @(posedge clk) begin : op_monitor
    command_s command;
    if (req) begin : start_high
        command.arg_a  = arg_a;
        command.arg_b  = arg_b;
	    command.arg_a_parity = arg_a_parity;
	    command.arg_b_parity = arg_b_parity;
        command.op = op_set;
        command_monitor_h.write_to_monitor(command);
    end : start_high
end : op_monitor

always @(negedge rst_n) begin : rst_monitor
    command_s command;
    command.op = RST_OP;
    if (command_monitor_h != null) //guard against VCS time 0 negedge
        command_monitor_h.write_to_monitor(command);
end : rst_monitor


//------------------------------------------------------------------------------
// write result monitor
//------------------------------------------------------------------------------

initial begin : result_monitor_thread
	results_s res;
    forever begin
        @(posedge clk) ;
        if (result_rdy) begin
	        res.arg_parity_error = arg_parity_error;
	        res.result_parity = result_parity;
	        res.result = result;
            result_monitor_h.write_to_monitor(res);
	    end
    end
end : result_monitor_thread

//------------------------------------------------------------------------------
// clock generator  
//------------------------------------------------------------------------------
initial begin
    clk = 0;
    forever begin
        #10;
        clk = ~clk;
    end
end

endinterface : mult_bfm


