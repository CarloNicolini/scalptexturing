function arcball = arcball_set_width_height(arcball,w, h)
	arcball.width = w;
	arcball.heigth = h;
	arcball.ballradius = min(w/2,h/2);