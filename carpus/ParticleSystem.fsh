// Varying
varying highp vec4      v_pColorOffset;

// Uniforms
uniform highp float     u_Time;
uniform highp vec3      u_eColor;

void main(void)
{
    // Color
    highp vec4 color = vec4(u_eColor, v_pColorOffset[3]);
    color.rgba = color + v_pColorOffset;
    color.rgba = clamp(color.rgba, vec4(0.0), vec4(1.0));
    
    // Required OpenGL ES 2.0 outputs
    //gl_FragColor = vec4(0.0, 0.6, 1.0, v_pColorOffset[3]);//color;
    gl_FragColor = color;
}