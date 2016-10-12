varying vec3 vnormal;
void main()
{
    vnormal = gl_Normal;
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}