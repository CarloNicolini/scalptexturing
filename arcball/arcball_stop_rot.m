function arcball = arcball_stop_rot(arcball)
    global GL
    glMatrixMode(GL.MODELVIEW);
	%glLoadIdentity();
    arcball = arcball_apply_rot_mat(arcball);
    arcball.cur_mv_mat = reshape(glGetDoublev(GL.MODELVIEW_MATRIX),[4 4]);
    arcball.isrotating=false;
	
	