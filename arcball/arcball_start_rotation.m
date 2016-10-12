function arcball = arcball_start_rotation(arcball, x, y)
	
	px = x-arcball.width/2;
	py = arcball.height/2 - y;
    

	arcball.start_rot_vec = convertXY(arcball,px,py);
	arcball.start_rot_vec = arcball.start_rot_vec/norm(arcball.start_rot_vec);

	arcball.cur_rot_vec = arcball.start_rot_vec;
	arcball.isrotating = true;