function mesh_projection(obj_scalp_full, obj_scalp_portion, ellipsoid)

ScalpV = single( obj_scalp_full{1}.vertices);
ScalpN = single(obj_scalp_full{1}.normals);
ScalpI = uint16((obj_scalp_full{1}.faces));

PortionV = single( obj_scalp_portion{1}.vertices);
PortionN = single(obj_scalp_portion{1}.normals);
PortionUV = single(obj_scalp_portion{1}.texcoords);
PortionI = uint16((obj_scalp_portion{1}.faces));


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
    A=imread([pwd '/probes_img/probe_planar2.bmp']);
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
    
    arcball = arcball_init(300,1024,768);
    angle = 0;
    
    
    object_z = -450;
    %[mouseIndex,prodname,allinfo] = GetMouseIndices;
    deltast=[0 0];
    mousex=0;mousey=0;mouse_buttons=[0 0 0];
    prevbutton=[0 0 0];
    nodeid=1;
    while (true)
        glClear;
        prevbutton = mouse_buttons;
        prevxy = [mousex,mousey];
        [mousex,mousey,mouse_buttons] = GetMouse(win);
        %[x y buttons]
        glPushMatrix;
        glTranslated(0,0,object_z);
        arcball = arcball_apply_rot_mat(arcball);
        
        if (mouse_buttons(2)==1) && (prevbutton(2)==0)
            arcball = arcball_start_rotation(arcball, mousex, mousey);
            %disp('justpressed');
        end
        if mouse_buttons(2)==1 && (prevbutton(2)==1)
            arcball = arcball_update_rotation(arcball,mousex,mousey);
            %disp('updating');
        end
        if (mouse_buttons(2)==0) && (prevbutton(2)==1)
            %arcball = arcball_stop_rot(arcball);
            %disp('stopping');
        end
        if (mouse_buttons(3)==1)
            object_z = object_z + mousey-prevxy(2);
        end
        
        % Draw the scene with the full scalp shown as mesh
        glUseProgram(texture_shader);
        % Change the texture displacement on the fragment shader
        glUniform2f(glGetUniformLocation(texture_shader, 'deltast'),deltast(1),deltast(2));
        
        [MV_MAT,P_MAT,VIEW]=getMVP();
        [objx, objy, objz] = unprojectMouse(mousex,mousey,object_z/300,P_MAT,MV_MAT,VIEW);
        o =  [objx, objy, object_z];
        
        %         % Here we draw the textured mesh portion
        %         glEnableClientState(GL_VERTEX_ARRAY);
        %         glVertexPointer(3, GL_FLOAT, 0, PortionV(:));
        %         glActiveTexture(GL_TEXTURE0);
        %         glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        %         glTexCoordPointer(2,GL_FLOAT,0,PortionUV(:));
        %         % Finally draw elements
        %         glDrawElements(GL_TRIANGLES, length(PortionI(:)), GL_UNSIGNED_SHORT, PortionI);
        %         % Disable texture coord array
        %         glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        %         % Disable vertex array...
        %         glDisableClientState(GL_VERTEX_ARRAY);
        
        % Here we draw the full mesh as triangles
        glUseProgram(normal_shader);
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(3, GL_FLOAT, 0, ScalpV(:));
        glEnableClientState(GL_NORMAL_ARRAY);
        glNormalPointer(GL_FLOAT,0,ScalpN(:));
        glDrawElements(GL_TRIANGLES, length(ScalpI(:)), GL_UNSIGNED_SHORT, ScalpI);
        glUseProgram(0);
        glVertexPointer(3, GL_FLOAT, 0, o(:));
        glDrawArrays(GL_POINTS,0,1);
        glDisableClientState(GL_NORMAL_ARRAY);
        glDisableClientState(GL_VERTEX_ARRAY);
        
        glColor3d(1,1,1);
        glPointSize(10);
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(3, GL_FLOAT, 0, ellipsoid.X(:));
        glDrawArrays(GL_POINTS,0,size(ellipsoid.X,2));
        glDisableClientState(GL_VERTEX_ARRAY);
        
        p = single(ellipsoid.X(:,nodeid));
        glColor3d(1,0,0);
        glPointSize(20);
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(3, GL_FLOAT, 0, p);
        glDrawArrays(GL_POINTS,0,size(p,2));
        glDisableClientState(GL_VERTEX_ARRAY);
        
        r = ellipsoid.radii(1);
        A = eye(4); A(1:3,1:3)=ellipsoid.evecs; A(1:3,4)=ellipsoid.center;
        glColor3d(0.5,0.5,0.5);
        glPushMatrix();
        glMultMatrixd(A);
        glScaled(1,ellipsoid.radii(2)/r,ellipsoid.radii(3)/r);
        glutWireSphere(r,200,200);
        glPopMatrix();
        
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
        if keyIsDown && keyCode(KbName('LeftArrow'))
            deltast(1) = deltast(1)+0.01;
        end
        if keyIsDown && keyCode(KbName('RightArrow'))
            deltast(1) = deltast(1)-0.01;
        end
        if keyIsDown && keyCode(KbName('UpArrow'))
            deltast(2) = deltast(2)+0.01;
        end
        if keyIsDown && keyCode(KbName('DownArrow'))
            deltast(2) = deltast(2)-0.01;
        end
        
        if keyIsDown && keyCode(KbName('n'))
            nodeid = nodeid+1;
            nodeid = 1+mod(nodeid,289);
            while KbCheck;
            end
        end
        if keyIsDown && keyCode(KbName('m'))
            nodeid = nodeid-1;
            nodeid = 1+mod(nodeid,289);
            while KbCheck;
            end
        end
        
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