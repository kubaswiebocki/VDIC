class circle_c extends shape_c;

	function new(string n, coordinates_struct p[$]);
		super.new(n, p);
	endfunction : new

	function real get_radius();

		coordinates_struct points_copy[$];
		coordinates_struct coords1;
		coordinates_struct coords2;
		real radius = 0.0;

		points_copy = points;
		coords1 = points_copy.pop_front();
		coords2 = points_copy.pop_front();
		radius = get_distance(coords1, coords2);

		return radius;
	endfunction : get_radius

	virtual function void print();

		$display("----------------------------------------------------------------------------------------");
		$display("This is: %s",name);

		foreach (points[i])
			$display("(%0.2f %0.2f)",points[i].x, points[i].y);

		$display("radius: %0.2f",get_radius());

		$display("Area is: %0.2f",get_area());

	endfunction : print

	function real get_area();

		coordinates_struct circle_coords1;
		coordinates_struct circle_coords2;
		coordinates_struct points_copy[$];
		real area   = 0.0;
		real radius   = 0.0;

		points_copy = points;
		circle_coords1 = points_copy.pop_front();
		circle_coords2 = points_copy.pop_front();

		radius = get_radius();
		area = 3.1415 * radius**2;

		return area;
	endfunction : get_area

endclass : circle_c