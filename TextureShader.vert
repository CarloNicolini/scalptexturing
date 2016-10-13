uniform sampler2D color_texture;
uniform vec2 deltast;
varying vec2 texcoord;
void main()
{
    texcoord = gl_MultiTexCoord0.st;
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}