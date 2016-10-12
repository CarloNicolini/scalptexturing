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
    [win , winRect] = Screen('OpenWindow', screenid,[],[0 0 1024 768]);
    AssertOpenGL;
    AssertGLSL;
    A=imread([pwd '/probes_img/probe_planar.bmp']);
    mytex = Screen('MakeTexture', win, A, [], 1);
    [gltex, GL_TEXTURE_2D] = Screen('GetOpenGLTexture', win, mytex);
    Screen('BeginOpenGL', win);
    ar=winRect(4)/winRect(3);
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    gluPerspective(25,1/ar,0.1,1000);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;
    glEnable(GL_BLEND);
    glEnable(GL_POINT_SMOOTH);
    glPointSize(1);
    % Offset for polygon and filling
    glPolygonOffset(-1.0, -1.0); % Shift depth value
    glEnable(GL_POLYGON_OFFSET_LINE);
    
    %glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
    
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, gltex);
    glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT); % parameters can be GL_REPEAT, GL_CLAMP, GL_CLAMP_TO_EDGE
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    
    % Need mipmapping for trilinear filtering --> Create mipmaps:
    if ~isempty(findstr(glGetString(GL_EXTENSIONS), 'GL_EXT_framebuffer_object'))
        % Ask the hardware to generate all depth levels automatically:
        glGenerateMipmapEXT(GL_TEXTURE_2D);
    else
        % No hardware support for fast auto-mipmap-generation. Do it "manually":
        % Use GLU to compute the image resolution mipmap pyramid and create
        % OpenGL textures ouf of it: This is slow, compared to glGenerateMipmapEXT:
        if gluBuild2DMipmaps(GL_TEXTURE_2D, GL_LUMINANCE, size(myimg,1), size(myimg,2), GL_LUMINANCE, GL_UNSIGNED_BYTE, uint8(myimg)) > 0
            error('gluBuild2DMipmaps failed for some reason.');
        end
    end
    % Use bilinear filtering for magnification filter:
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    % Load the shader for texturing
    texture_shader = LoadGLSLProgramFromFiles([pwd '/TextureShader'], 2);
    % Load the shader for showing normals on vertices
    normal_shader = LoadGLSLProgramFromFiles([pwd '/NormalShader'], 2);
    addpath('arcball/');
    arcball = arcball_init(300,1024,768);
    angle = 0;
    prevbutton=[0 0 0];
    prevxy=[0 0];
    object_z = -300;
    [mouseIndex,prodname,allinfo] = GetMouseIndices;
    while (true)
        [mousex,mousey,mouse_buttons] = GetMouse(win);
        %[x y buttons]
        if (mouse_buttons(2)==1) && (prevbutton(2)==0)
            arcball = arcball_start_rotation(arcball,mousex,mousey);
        end
        if (mouse_buttons(2)==1)
            arcball = arcball_update_rotation(arcball,mousex,mousey);
        end
        if (mouse_buttons(2)==0) && (prevbutton(2)==1)
            arcball = arcball_stop_rot(arcball);
        end
        if (mouse_buttons(3)==1)
            object_z = object_z + mousey-prevxy(2);
        end
        prevbutton = mouse_buttons;
        prevxy = [mousex,mousey];
        glClear;
        % Draw the scene with the textured object
        glUseProgram(texture_shader);
        glPushMatrix;
        glTranslated(0,0,object_z);
        arcball = arcball_apply_rot_mat(arcball);
        % Here we draw the mesh
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(3, GL_FLOAT, 0, V(:));
        glActiveTexture(GL_TEXTURE0);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glTexCoordPointer(2,GL_FLOAT,0,UV(:));
        % Finally draw elements
        glDrawElements(GL_TRIANGLES, length(I(:)), GL_UNSIGNED_SHORT, I);
        % Disable texture coord array
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        % Disable vertex array...
        glDisableClientState(GL_VERTEX_ARRAY);
        
        % Draw the points
        glUseProgram(normal_shader);
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(3, GL_FLOAT, 0, V(:));
        glEnableClientState(GL_NORMAL_ARRAY);
        glNormalPointer(GL_FLOAT,0,N(:));
        glDrawArrays(GL_POINTS,0,size(V,2));
        glDisableClientState(GL_NORMAL_ARRAY);
        glDisableClientState(GL_VERTEX_ARRAY);
        %
        % END DRAWING
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