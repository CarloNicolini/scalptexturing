varying vec3 vnormal;
void main()
{
    float normIntensity = (vnormal.x+vnormal.y+vnormal.z)/3.0;
    gl_FragColor = vec4(normIntensity,normIntensity,normIntensity,1.0);
}
