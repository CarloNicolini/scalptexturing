varying vec3 vnormal;
void main()
{
    gl_FragColor = vec4(vnormal.x,vnormal.y,vnormal.z,1.0);
}
