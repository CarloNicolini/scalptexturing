function v = convertXY(arcball,x,y)

	d = x^2+y^2;
	radius_squared = arcball.ballradius^2;
	if d > radius_squared
		v = [x,y,0];
	else
		v = [x,y,sqrt(radius_squared-d)];
	end