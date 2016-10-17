uniform sampler2D color_texture;
uniform vec2 deltast;
varying vec2 texcoord;
void main()
{
    gl_FragColor = texture2D(color_texture, -texcoord.st + deltast.st);
}
