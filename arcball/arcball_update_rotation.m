function arcball = arcball_update_rotation(arcball, x, y)
	
    px = x-arcball.width/2;
	py = arcball.height/2 - y;

	arcball.cur_rot_vec = convertXY(arcball,px,py);
	arcball.cur_rot_vec = arcball.cur_rot_vec/norm(arcball.cur_rot_vec);
