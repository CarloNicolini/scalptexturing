function [objX,objY,objZ] = unprojectMouse(x,y,z,P,M,V)
V=double(V);
wx = 2*(x-V(1))/V(3) -1;
wy = 2*(y-V(2))/V(4) -1;
wz = 2*z-1;
wt = 1;

PM = reshape(P,[4,4]);
MM = reshape(M,[4,4]);
IPM = inv(PM*MM);

objXYZW = IPM*[wx wy wz wt]';
objX = objXYZW(1);
objY = objXYZW(2);
objZ = objXYZW(3);