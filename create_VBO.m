function [buf_id_xyz,buf_id_faces] = create_VBO(xyz,faces)
global GL

buf_id_xyz =   glGenBuffers(1);
buf_id_faces = glGenBuffers(1);

buf_size_xyz = 8*length(xyz(:));

%buf_size_faces = size(buf_id_faces,1)%*size(buf_id_faces,2);

glBindBufferARB(GL.ARRAY_BUFFER_ARB, buf_id_xyz); % for vertex coordinates

glBufferDataARB(GL.ARRAY_BUFFER_ARB, buf_size_xyz, 0, GL.STATIC_DRAW_ARB);

%glBindBufferARB(GL.ELEMENT_ARRAY_BUFFER_ARB, buf_id_faces);   % for indices
%glBufferDataARB(GL.ARRAY_BUFFER_ARB, buf_size_faces,faces,GL.STATIC_DRAW_ARB);


% dare un'occhiata qui per calcolare le normali
% obj = AddNormalsToOBJ(obj [, flipDir=0]);