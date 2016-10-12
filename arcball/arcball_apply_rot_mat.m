function arcball = arcball_apply_rot_mat(arcball)

if arcball.isrotating
	if norm(arcball.cur_rot_vec - arcball.start_rot_vec) > 1E-6
		rot_axis = cross(arcball.cur_rot_vec,arcball.start_rot_vec);
		rot_axis = rot_axis/norm(rot_axis);
		val = dot(arcball.cur_rot_vec,arcball.start_rot_vec);
		if val > 1-1E-10
			val = 1;
		end
		rot_angle = acos(val)*180.0/pi;
		arcball = arcball_apply_trans_mat(arcball,true);
		glRotated(rot_angle*2,-rot_axis(1),-rot_axis(2),-rot_axis(3));
		arcball = arcball_apply_trans_mat(arcball,false);
	end
	glMultMatrixd(arcball.start_matrix);
end