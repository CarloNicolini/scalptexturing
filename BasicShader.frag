uniform sampler2D color_texture;
varying vec2 texcoord;
void main()
{
    gl_FragColor = texture2D(color_texture,texcoord);
}
