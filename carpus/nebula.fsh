precision mediump float;
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
varying vec2 surfacePosition;

void main( void ) {
    vec2 p = (gl_FragCoord.xy - 0.5 * resolution)/min(resolution.x,resolution.y);
    vec3 c=vec3(0);
    float pt = length(surfacePosition)*1e2+time+1e2;
    for(int i=0;i<2048;i++){
        float t = 2.*3.14*float(i)/20. * fract(pt*.00006);
        float x = cos(pow(1.1,mouse.y)*t);
        float y = sin(pow(1.1,mouse.x)*t);
        vec2 o = .3*vec2(x,y);
        c += .00063/(length(p-o))*vec3(.1,.13,.17);
    } 
    gl_FragColor = vec4(pow(c.x,1.385),pow(c.y,2.75),pow(c.x+c.z,3.15),1.);}
}