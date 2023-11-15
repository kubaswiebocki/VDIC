class rectangle_c extends shape_c;

	function new(string n,coordinates_struct p[$]);
		super.new(n,p);
	endfunction : new

	function real get_area();
		coordinates_struct r_coords1;
		coordinates_struct r_coords2;
		coordinates_struct r_coords3;
		coordinates_struct r_coords4;
		coordinates_struct points_copy[$];
		real area   = 0.0;
		real side1 = 0.0;
		real side2 = 0.0;

		points_copy = points;
		r_coords1 = points_copy.pop_front();
		r_coords2 = points_copy.pop_front();
		r_coords3 = points_copy.pop_front();
		r_coords4 = points_copy.pop_front();

		side1 = get_distance(r_coords1,r_coords2);
		side2 = get_distance(r_coords2,r_coords3);

		return side1 * side2;
	endfunction : get_area

endclass : rectangle_c