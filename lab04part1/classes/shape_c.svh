typedef struct packed {
    real x;
    real y;
} point;

virtual class shape_c;
	protected string name;
	protected real points[1:0];
	
	function new(string n, real x, real y);
		name = n;
		points[0] = x;
		points[1] = y;
	endfunction : new
	
	pure virtual function real get_area();
	
	function string print();
		
	endfunction : print
endclass : shape_c