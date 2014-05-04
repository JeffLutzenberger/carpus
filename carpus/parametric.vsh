// Attributes
//attribute float     a_pID;
//attribute float     a_pRadius;
//attribute float     a_pVelocity;
//attribute float     a_pDamping;
attribute float     a_pPointSize;
attribute float     a_pTimeOffset;
attribute vec3      a_pColor;

// Uniforms
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
    //t from 0 to 2 * Pi
    float period = 5000.0; //once cycle every x ms
    float t = u_Time;// % 5000;
    float dt = u_Time;
    if (u_Time < a_pTimeOffset) {
        dt = (u_eLife - a_pTimeOffset + u_Time);
        //alpha = 1.0 - (u_eLife - a_pTimeOffset + u_Time) / u_eLife;
    } else {
        dt = (u_Time - a_pTimeOffset);
        //alpha = 1.0 - (u_Time - a_pTimeOffset) / u_eLife;
    }

    float k = 0.25; //k = a/b;
    float b = 100.0;
    float a = k * b;
    float x = (a - b) * cos(dt) + b * (cos(dt * (a / b) - 1.0));
    float y = (a - b) * sin(dt) + b * (sin(dt * (a / b) - 1.0));
    float alpha = 1.0;
    vec2 position = vec2(x,y) + u_ePosition;
    gl_Position = u_ProjectionMatrix * vec4(position, 0.0, 1.0);
    //gl_Position = u_ProjectionMatrix * vec4(x + 400.0, y + 400. 0, 0.0, 1.0);
    gl_PointSize = 20.0;//max(0.0, (u_eSize + a_pPointSize));
    v_pColorOffset = vec4(a_pColor, alpha);
}