// Attributes
attribute float     a_pID;
attribute float     a_pRadius;
attribute float     a_pVelocity;
attribute float     a_pDamping;
attribute float     a_pPointSize;
attribute float     a_pTimeOffset;
attribute vec3      a_pColor;

// Uniforms
uniform float       u_Intensity; //0 to number of particles
uniform mat4        u_ProjectionMatrix;
uniform vec2        u_Gravity;
uniform float       u_Time;
uniform float       u_eRadius;
uniform float       u_eVelocity;
uniform float       u_eDecay;
uniform float       u_eSize;
uniform float       u_eLife;
uniform vec2        u_ePosition;

// Varying
varying vec4        v_pColorOffset;

void main(void)
{
    float r = u_eRadius + a_pRadius;
    float dx = cos(a_pID);
    float dy = sin(a_pID);
    float pointSize = a_pPointSize;
    float alpha = 1.0 - u_Time / u_eLife;
    alpha *= 0.025;
    float dt = u_Time * 0.01;
    if (u_Time < a_pTimeOffset) {
        dt = (u_eLife - a_pTimeOffset + u_Time) * 0.01;
        alpha = 1.0 - (u_eLife - a_pTimeOffset + u_Time) / u_eLife;
        //size = (u_eLife - a_pTimeOffset + u_Time) / u_eLife
        //gl_Position = u_ProjectionMatrix * vec4(0.0, 0.0, 0.0, 1.0);
        //gl_PointSize = 1.0;
        //v_pColorOffset = vec4(a_pColor, 0.0);
    } else {
        dt = (u_Time - a_pTimeOffset) * 0.01;
        alpha = 1.0 - (u_Time - a_pTimeOffset) / u_eLife;
    }
    
    alpha *= 0.025;
    
    float vx = a_pVelocity * dx + a_pDamping * dx * dt;
    float vy = a_pVelocity * dy + a_pDamping * dy * dt;
    float x = dx * r + vx * dt;
    float y = dy * r + vy * dt;
    
    vec2 position = vec2(x,y) + u_ePosition;
    gl_Position = u_ProjectionMatrix * vec4(position, 0.0, 1.0);
    //gl_Position = u_ProjectionMatrix * vec4(x + 400.0, y + 400. 0, 0.0, 1.0);
    gl_PointSize = max(0.0, (u_eSize + a_pPointSize));
    
    v_pColorOffset = vec4(a_pColor, alpha);
    
    //don't show this particle if the intensity is lower than particle index
    if (a_pID > u_Intensity) {
        gl_Position = vec4(0.0);
        gl_PointSize = 0.1;
        v_pColorOffset = vec4(0.0);
    }
}