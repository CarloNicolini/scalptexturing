function arcball = arcball_reset(arcball)

	arcball.fov = arcball.init_fov;

	arcball.cur_mv_mat = eye(4);

	arcball.tx = 0;
	arcball.ty = 0;
	arcball.start_tx=0;
	arcball.start_ty=0;
	arcball.cur_tx = 0;
	arcball.cur_ty = 0;