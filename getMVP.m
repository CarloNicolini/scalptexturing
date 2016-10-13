function [MV, P,VIEW] = getMVP()
global GL

MV=glGetDoublev(GL.MODELVIEW_MATRIX);
P=glGetDoublev(GL.PROJECTION_MATRIX);
VIEW=glGetIntegerv(GL.VIEWPORT);
