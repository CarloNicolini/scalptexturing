function [win,winRect,pars] = setup_opengl()

%
pars.oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
%
pars.oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);

% Find the screen to use for display:
screenid=max(Screen('Screens'));

% Disable Synctests for this simple demo:
pars.oldSkipSyncTests = Screen('Preference','SkipSyncTests',2);

% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper:
openglstyle=1;
debuglevel=2;
InitializeMatlabOpenGL(openglstyle,debuglevel);

% Open a double-buffered full-screen window on the main displays screen.
[win , winRect] = Screen('OpenWindow', screenid,[],[0 0 640 480]);
% Setup the OpenGL rendering context of the onscreen window for use by
% OpenGL wrapper. After this command, all following OpenGL commands will
% draw into the onscreen window 'win':

% Is the script running in OpenGL Psychtoolbox?
AssertOpenGL;
    
% Make sure GLSL and fragmentshaders are supported on first call:
AssertGLSL;

% Query supported extensions:
extensions = glGetString(GL_EXTENSIONS);
if isempty(findstr(extensions, 'GL_ARB_fragment_shader'))
	% No fragment shaders: This is a no go!
    error('Sorry, this function does not work on your graphics hardware due to lack of sufficient support for fragment shaders.');
end

Screen('BeginOpenGL', win);
% Get the aspect ratio of the screen:
ar=winRect(4)/winRect(3);

% Turn on OpenGL local lighting model: The lighting model supported by
% OpenGL is a local Phong model with Gouraud shading.
% glEnable(GL_LIGHTING);

% Enable the first local light source GL_LIGHT_0. Each OpenGL
% implementation is guaranteed to support at least 8 light sources. 
% glEnable(GL_LIGHT0);

% Enable two-sided lighting - Back sides of polygons are lit as well.
% glLightModelfv(GL_LIGHT_MODEL_TWO_SIDE,GL_TRUE);

% Enable proper occlusion handling via depth tests:
 glEnable(GL_DEPTH_TEST);

% Define the cubes light reflection properties by setting up reflection
% coefficients for ambient, diffuse and specular reflection:
% glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT, [ 1 1 1 1 ]);
% glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE, [ .78 .57 .11 1 ]);
% glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR, [ 1 1 1 1 ]);
% glMaterialfv(GL_FRONT_AND_BACK,GL_SHININESS,128);

% Set projection matrix: This defines a perspective projection,
% corresponding to the model of a pin-hole camera - which is a good
% approximation of the human eye and of standard real world cameras --
% well, the best aproximation one can do with 3 lines of code ;-)
glMatrixMode(GL_PROJECTION);
glLoadIdentity;

% Field of view is +/- 25 degrees from line of sight. Objects close than
% 0.1 distance units or farther away than 100 distance units get clipped
% away, aspect ratio is adapted to the monitors aspect ratio:
gluPerspective(25,1/ar,0.1,1000);

% Setup modelview matrix: This defines the position, orientation and
% looking direction of the virtual camera:
glMatrixMode(GL_MODELVIEW);
glLoadIdentity;

% Cam is located at 3D position (0,0,10), points upright (0,1,0) and fixates
% at the origin (0,0,0) of the worlds coordinate system:
%gluLookAt(0,0,10,0,0,0,0,1,0);
% Setup position and emission properties of the light source:

% Set background color to 'black':
%glClearColor(0.5,0.5,0.5,0);

% Point lightsource at (1,2,3)...
%glLightfv(GL_LIGHT0,GL_POSITION,[ 0 0 -100 0 ]);

% Emits white (1,1,1,1) diffuse light:
%glLightfv(GL_LIGHT0,GL_DIFFUSE, [ 1 1 1 1 ]);

% Emits reddish (1,1,1,1) specular light:
%glLightfv(GL_LIGHT0,GL_SPECULAR, [ 1 0 0 1 ]);

% There's also some blue, but weak (R,G,B) = (0.1, 0.1, 0.1)
% ambient light present:
%glLightfv(GL_LIGHT0,GL_AMBIENT, [ .1 .1 .6 1 ]);
%glHint(GL_POINT_BIT,GL_POINT_SMOOTH);

glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );

glEnable(GL_BLEND);
%glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
glEnable(GL_POINT_SMOOTH);
glEnable(GL_LINE_SMOOTH);
glEnable(GL_POLYGON_SMOOTH);

glPointSize(0.1);
glLineWidth(0.1);

glPixelStorei(GL_UNPACK_ALIGNMENT,1);
Screen('EndOpenGL', win);