function draw_mesh(vertices, indices, normals, uv)
global GL

% if normals exists, show them
if nargin>2 && ~isempty(normals)
    glEnableClientState(GL.NORMAL_ARRAY);
    glVertexPointer(3, GL.FLOAT, 0, normals(:));
end

%uv_id = glGenBuffers(1);
%glBindBuffer(GL.ARRAY_BUFFER,uv_id);
%glVertexAttribPointer(uv_id,2,GL.FLOAT,0,0,uv(:));
glEnableClientState(GL.TEXTURE_COORD_ARRAY);
glTexCoordPointer(2,GL.FLOAT,0,uv(:));

glEnableClientState(GL.VERTEX_ARRAY);
glVertexPointer(3, GL.FLOAT, 0, vertices(:));
glDrawElements(GL.TRIANGLES, length(indices(:)) - 1, GL.UNSIGNED_INT, indices);
glDisableClientState(GL.VERTEX_ARRAY);

if nargin>2 && ~isempty(normals)
    glDisableClientState(GL.NORMAL_ARRAY);
end

glDisableClientState(GL.TEXTURE_COORD_ARRAY);