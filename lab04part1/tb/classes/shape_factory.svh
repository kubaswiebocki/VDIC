parameter CIRCLE    = 2;
parameter TRIANGLE  = 3;
parameter RECTANGLE = 4;
parameter POLYGON   = 5;

class shape_factory;
	static function shape_c make_shape(coordinates_struct p[$]);
		circle_c circle_o;
		triangle_c triangle_o;
		rectangle_c rectangle_o;
		polygon_c polygon_o;

		coordinates_struct points_q[$];
		coordinates_struct points_q_copy[$];

		static int ctr_local = 0;
		coordinates_struct point1;
		coordinates_struct point2;
		coordinates_struct point3;
		coordinates_struct point4;
		real diameter1 = 0.0;
		real diameter2 = 0.0;

		points_q_copy = p;

		ctr_local = 0;

		foreach(p[i]) ctr_local++;

		point1 = points_q_copy.pop_front();
		point2 = points_q_copy.pop_front();
		point3 = points_q_copy.pop_front();
		point4 = points_q_copy.pop_front();

		diameter1 = ((point1.x - point3.x)**2 + (point1.y - point3.y)**2)**0.5;
		diameter2 = ((point2.x - point4.x)**2 + (point2.y - point4.y)**2)**0.5;

		//  check if rectangle
		if (ctr_local == 4 && diameter1 != diameter2) ctr_local = 5;

		case (ctr_local)
			CIRCLE:
			begin
				circle_o = new("circle",p);
				return circle_o;
			end
			TRIANGLE:
			begin
				triangle_o = new("triangle",p);
				return triangle_o;
			end
			RECTANGLE:
			begin
				rectangle_o = new("rectangle",p);
				return rectangle_o;
			end
			default :
			begin
				polygon_o = new("polygon",p);
				return polygon_o;
			end
		endcase

	endfunction : make_shape
endclass : shape_factory