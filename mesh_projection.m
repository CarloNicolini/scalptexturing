function mesh_projection(obj, obj_index, centering)

V = single( obj{obj_index}.vertices);
N = single(obj{obj_index}.normals);
UV = single(obj{obj_index}.texcoords);
I = uint16((obj{obj_index}.faces));

try
    pars.oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    pars.oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
    screenid=max(Screen('Screens'));
    pars.oldSkipSyncTests = Screen('Preference','SkipSyncTests',2);
    openglstyle=1; debuglevel=3;
    InitializeMatlabOpenGL(openglstyle,debuglevel);
    [win , winRect] = Screen('OpenWindow', screenid,[],[0 0 640 480]);
    AssertOpenGL;
    AssertGLSL;
    A=imread([pwd '/probes_img/probe_planar.bmp']);
    mytex = Screen('MakeTexture', win, A, [], 1);
    [gltex, gltextarget] = Screen('GetOpenGLTexture', win, mytex);
    Screen('BeginOpenGL', win);
    ar=winRect(4)/winRect(3);
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    gluPerspective(25,1/ar,0.1,1000);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;
    %glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
    
    glEnable(gltextarget);
    glBindTexture(gltextarget, gltex);
    glTexEnvfv(GL.TEXTURE_ENV, GL.TEXTURE_ENV_MODE, GL.MODULATE);
    glTexParameteri(gltextarget, GL.TEXTURE_WRAP_S, GL.REPEAT);
    glTexParameteri(gltextarget, GL.TEXTURE_WRAP_T, GL.REPEAT);
    
    glTexParameteri(gltextarget, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
    
    % Need mipmapping for trilinear filtering --> Create mipmaps:
    if ~isempty(findstr(glGetString(GL.EXTENSIONS), 'GL_EXT_framebuffer_object'))
        % Ask the hardware to generate all depth levels automatically:
        glGenerateMipmapEXT(GL.TEXTURE_2D);
    else
        % No hardware support for fast auto-mipmap-generation. Do it "manually":
        % Use GLU to compute the image resolution mipmap pyramid and create
        % OpenGL textures ouf of it: This is slow, compared to glGenerateMipmapEXT:
        if gluBuild2DMipmaps(gltextarget, GL.LUMINANCE, size(myimg,1), size(myimg,2), GL.LUMINANCE, GL.UNSIGNED_BYTE, uint8(myimg)) > 0
            error('gluBuild2DMipmaps failed for some reason.');
        end
    end
    % Use bilinear filtering for magnification filter:
    glTexParameteri(gltextarget, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
    
    shader = LoadGLSLProgramFromFiles([pwd '/BasicShader'], 2);
    glUseProgram(shader);glCheckLastError;
    
    angle = 0;
    while (true)
        angle=angle+5;
        % Setup cubes rotation around axis:
        glClear;
        % Draw the scene with the object
        glPushMatrix;
        glTranslated(0,0,-350);
        glRotated(angle,0,1,0);
        % Here we draw the mesh
        glEnableClientState(GL.VERTEX_ARRAY);
        glVertexPointer(3, GL.FLOAT, 0, V(:));
        glActiveTexture(GL.TEXTURE0);
        glEnableClientState(GL.TEXTURE_COORD_ARRAY);
        glTexCoordPointer(2,GL_FLOAT,0,UV(:));
        % Finally draw elements
        glDrawElements(GL.TRIANGLES, length(I(:)), GL.UNSIGNED_SHORT, I);
        % Disable texture coord array
        glDisableClientState(GL.TEXTURE_COORD_ARRAY);
        % Disable vertex array...
        glDisableClientState(GL.VERTEX_ARRAY);
        glPopMatrix;
        
        % Finish OpenGL rendering into PTB window and check for OpenGL errors.
        Screen('EndOpenGL', win);
        % Show rendered image at next vertical retrace:
        Screen('Flip', win);
        % Switch to OpenGL rendering again for drawing of next frame:
        Screen('BeginOpenGL', win);
        % Check for keyboard press and exit, if so:
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown && keyCode(KbName('Escape'))
            break;
        end;
    end
    % Shut down OpenGL rendering:
    Screen('EndOpenGL', win);
    % Close onscreen window and release all other ressources:
    Screen('CloseAll'); Screen('Preference','SkipSyncTests',pars.oldSkipSyncTests);
catch
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    moglfreeall;
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', pars.oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', pars.oldSupressAllWarnings);
    Screen('Preference','SkipSyncTests',pars.oldSkipSyncTests);
    psychrethrow(psychlasterror);
end