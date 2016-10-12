function arcball = arcball_apply_trans_mat(arcball, isreverse)
	if isreverse
		factor_rev = -1;
	else
		factor_rev = 1;
	end
	tx = arcball.tx + (arcball.cur_tx - arcball.start_tx)*arcball.translation_factor;
	ty = arcball.ty + (arcball.cur_ty - arcball.start_ty)*arcball.translation_factor;
	glTranslated(factor_rev*tx,-factor_rev*ty,0);