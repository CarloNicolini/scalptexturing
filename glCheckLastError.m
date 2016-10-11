function glCheckLastError
global GL

errorval = glGetError;
while errorval ~= GL.NO_ERROR
    error(['== OPENGL ERROR == ' gluErrorString(errorval)]);
end
