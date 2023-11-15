module top;

	coordinates_struct x_y_pos;
	coordinates_struct coordinates_q  [$];
	shape_c shape_o;

	string filename = "/home/student/jswiebocki/VDIC/lab04part1/tb/lab04part1_shapes.txt";
	string line;
	string input_str = "";
	int c = 0;
	int i= 0;
	
	initial begin
		static int file = $fopen(filename, "r");

		if (file == 0) begin
			$display("ERROR: File does not exist %s", filename);
			$stop;
		end

		while (!$feof(file)) begin
			if ($fgets(line,file) != 0) begin
				i = 0;
				foreach (line[c]) begin
					if (line[c] != " " && line[c] != 10) begin
						input_str = {input_str,line[c]};
					end

					else if (line[c] == " " || line[c] == 10) begin
						if (i % 2 == 0) begin
							x_y_pos.x = input_str.atoreal();
						end
						else begin
							x_y_pos.y = input_str.atoreal();
							coordinates_q.push_back(x_y_pos);
						end
						input_str = "";
						i++;
					end
				end
			end

			shape_o = shape_factory::make_shape(coordinates_q);
			shape_reporter#(shape_c)::shapes_storage(shape_o);
			coordinates_q.delete();
		end
		shape_reporter#(shape_c)::report_shapes();
		$fclose(file);

	end
endmodule : top