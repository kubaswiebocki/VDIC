/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
module coverage(mult_bfm bfm);
import mult_pkg::*;

shortint                arg_a;
bit						arg_a_parity;
shortint                arg_b;
bit						arg_b_parity;
operation_t             op_set;

// Covergroup checking the op codes and theri sequences
covergroup op_cov;

    option.name = "cg_op_cov";

    coverpoint op_set {
        // #A1 test valid data at the input
        bins A1_valid_data_AB = VALID_A_B;

        // #A2 test invalid data at the input
        bins A2_invalid_data_AB = INVALID_A_B;

        // #A3 test invalid data at the A input, valid data at the B input
        bins A3_invalid_A_valid_B = VALID_B_INVALID_A;

        // #A4 test invalid data at the B input, valid data at the A input
        bins A4_valid_A_invalid_B = VALID_A_INVALID_B;
	    
    }

endgroup

// Covergroup checking for min and max arguments of the ALU
covergroup corner_values_on_ops;

    option.name = "cg_corner_values_on_ops";

    all_ops : coverpoint op_set {
        ignore_bins null_ops = {RST_OP};
    }

    a_leg: coverpoint arg_a {
	    bins min  		= {16'sh8000};
	    bins minus_one	= {16'shFFFF};
        bins zeros 		= {16'sh0000};
        bins others	    = {[16'shFFFE:16'sh8001], [16'sh0002:16'sh7FFE]};
	    bins one  		= {16'sh0001};
        bins max  		= {16'sh7FFF};
    }

    b_leg: coverpoint arg_b {
	    bins min  		= {16'sh8000};
	    bins minus_one	= {16'shFFFF};
        bins zeros 		= {16'sh0000};
        bins others	    = {[16'shFFFE:16'sh8001], [16'sh0002:16'sh7FFE]};
	    bins one  		= {16'sh0001};
        bins max  		= {16'sh7FFF};
    }

    B_op_corners: cross a_leg, b_leg, all_ops {
	    
	    // #B1 Simulate maximum value for signed data.   

        bins B1_vab_max          = binsof (all_ops) intersect {VALID_A_B} &&
        (binsof (a_leg.max) || binsof (b_leg.max));

        bins B1_iab_max          = binsof (all_ops) intersect {INVALID_A_B} &&
        (binsof (a_leg.max) || binsof (b_leg.max));

        bins B1_vbia_max         = binsof (all_ops) intersect {VALID_B_INVALID_A} &&
        (binsof (a_leg.max) || binsof (b_leg.max));

        bins B1_vaib_max         = binsof (all_ops) intersect {VALID_A_INVALID_B} &&
        (binsof (a_leg.max) || binsof (b_leg.max));
	    
	    // #B2 Simulate minimum value for signed data.   

        bins B2_vab_min          = binsof (all_ops) intersect {VALID_A_B} &&
        (binsof (a_leg.min) || binsof (b_leg.min));

        bins B2_iab_min          = binsof (all_ops) intersect {INVALID_A_B} &&
        (binsof (a_leg.min) || binsof (b_leg.min));

        bins B2_vbia_min         = binsof (all_ops) intersect {VALID_B_INVALID_A} &&
        (binsof (a_leg.min) || binsof (b_leg.min));

        bins B2_vaib_min         = binsof (all_ops) intersect {VALID_A_INVALID_B} &&
        (binsof (a_leg.min) || binsof (b_leg.min));
	    
	    // #B3 Simulate one value for signed data.   

        bins B3_vab_one          = binsof (all_ops) intersect {VALID_A_B} &&
        (binsof (a_leg.one) || binsof (b_leg.one));

        bins B3_iab_one          = binsof (all_ops) intersect {INVALID_A_B} &&
        (binsof (a_leg.one) || binsof (b_leg.one));

        bins B3_vbia_one         = binsof (all_ops) intersect {VALID_B_INVALID_A} &&
        (binsof (a_leg.one) || binsof (b_leg.one));

        bins B3_vaib_one         = binsof (all_ops) intersect {VALID_A_INVALID_B} &&
        (binsof (a_leg.one) || binsof (b_leg.one));

	    // #B4 Simulate minus one value for signed data.   

        bins B4_vab_mone          = binsof (all_ops) intersect {VALID_A_B} &&
        (binsof (a_leg.minus_one) || binsof (b_leg.minus_one));

        bins B4_iab_mone          = binsof (all_ops) intersect {INVALID_A_B} &&
        (binsof (a_leg.minus_one) || binsof (b_leg.minus_one));

        bins B4_vbia_mone         = binsof (all_ops) intersect {VALID_B_INVALID_A} &&
        (binsof (a_leg.minus_one) || binsof (b_leg.minus_one));

        bins B4_vaib_mone         = binsof (all_ops) intersect {VALID_A_INVALID_B} &&
        (binsof (a_leg.minus_one) || binsof (b_leg.minus_one));
	    
        // #B5 simulate zeros values

        bins B5_vab_0          = binsof (all_ops) intersect {VALID_A_B} &&
        (binsof (a_leg.zeros) || binsof (b_leg.zeros));

        bins B5_iab_0          = binsof (all_ops) intersect {INVALID_A_B} &&
        (binsof (a_leg.zeros) || binsof (b_leg.zeros));

        bins B5_vbia_0          = binsof (all_ops) intersect {VALID_B_INVALID_A} &&
        (binsof (a_leg.zeros) || binsof (b_leg.zeros));

        bins B5_vaib_0          = binsof (all_ops) intersect {VALID_A_INVALID_B} &&
        (binsof (a_leg.zeros) || binsof (b_leg.zeros));
	    
	    
        ignore_bins others_only =
        binsof(a_leg.others) && binsof(b_leg.others);
    }

endgroup


op_cov                      oc;
corner_values_on_ops        c_00_FF;

initial begin : coverage_block
    oc      = new();
    c_00_FF = new();
    forever begin : sampling_block
        @(posedge bfm.clk);
	    	arg_a = bfm.arg_a;
	    	arg_a_parity = bfm.arg_a_parity;
	    	arg_b = bfm.arg_b;
	    	arg_b_parity = bfm.arg_b_parity;
	    	op_set = bfm.op_set;

            oc.sample();
            c_00_FF.sample();
    end : sampling_block
end : coverage_block


endmodule : coverage




