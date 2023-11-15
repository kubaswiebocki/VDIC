class triangle_c extends shape_c;

	function new(string n,coordinates_struct p[$]);
		super.new(n,p);
	endfunction : new

	function real get_area();
		coordinates_struct t_coords1;
		coordinates_struct t_coords2;
		coordinates_struct t_coords3;
		coordinates_struct points_copy[$];
		real area   = 0.0;

		points_copy = points;
		t_coords1 = points_copy.pop_front();
		t_coords2 = points_copy.pop_front();
		t_coords3 = points_copy.pop_front();

		area = 0.5 * (((t_coords2.x - t_coords1.x)*(t_coords3.y - t_coords1.y) - (t_coords2.y - t_coords1.y)*(t_coords3.x - t_coords1.x))**2)**0.5;

		return area;

	endfunction : get_area

endclass : triangle_c
