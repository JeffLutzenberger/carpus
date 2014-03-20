attribute vec4 position;
attribute vec2 texcoord;
attribute vec3 normal;
attribute vec4 color;

uniform int verticalPass;

//uniform mediump float texelWidthOffset;
//uniform mediump float texelHeightOffset;
uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

varying vec2 v_texCoord;
varying vec2 v_blurTexCoords[14];
varying lowp vec4 colorVarying;

void main()
{
    //color;
    normal;
    
    //gl_Position = position;
    
    v_texCoord = texcoord;
    
    colorVarying = color;//gl_Color; //diffuseColor * nDotVP;
    
    gl_Position = modelViewProjectionMatrix * position;
    
    //vertical
    if (verticalPass == 1) {
        v_blurTexCoords[ 0] = v_texCoord + vec2(0.0, -0.028);
        v_blurTexCoords[ 1] = v_texCoord + vec2(0.0, -0.024);
        v_blurTexCoords[ 2] = v_texCoord + vec2(0.0, -0.020);
        v_blurTexCoords[ 3] = v_texCoord + vec2(0.0, -0.016);
        v_blurTexCoords[ 4] = v_texCoord + vec2(0.0, -0.012);
        v_blurTexCoords[ 5] = v_texCoord + vec2(0.0, -0.008);
        v_blurTexCoords[ 6] = v_texCoord + vec2(0.0, -0.004);
        v_blurTexCoords[ 7] = v_texCoord + vec2(0.0,  0.004);
        v_blurTexCoords[ 8] = v_texCoord + vec2(0.0,  0.008);
        v_blurTexCoords[ 9] = v_texCoord + vec2(0.0,  0.012);
        v_blurTexCoords[10] = v_texCoord + vec2(0.0,  0.016);
        v_blurTexCoords[11] = v_texCoord + vec2(0.0,  0.020);
        v_blurTexCoords[12] = v_texCoord + vec2(0.0,  0.024);
        v_blurTexCoords[13] = v_texCoord + vec2(0.0,  0.028);
    } else {
        //horizontal
        v_blurTexCoords[ 0] = v_texCoord + vec2(-0.028, 0.0);
        v_blurTexCoords[ 1] = v_texCoord + vec2(-0.024, 0.0);
        v_blurTexCoords[ 2] = v_texCoord + vec2(-0.020, 0.0);
        v_blurTexCoords[ 3] = v_texCoord + vec2(-0.016, 0.0);
        v_blurTexCoords[ 4] = v_texCoord + vec2(-0.012, 0.0);
        v_blurTexCoords[ 5] = v_texCoord + vec2(-0.008, 0.0);
        v_blurTexCoords[ 6] = v_texCoord + vec2(-0.004, 0.0);
        v_blurTexCoords[ 7] = v_texCoord + vec2( 0.004, 0.0);
        v_blurTexCoords[ 8] = v_texCoord + vec2( 0.008, 0.0);
        v_blurTexCoords[ 9] = v_texCoord + vec2( 0.012, 0.0);
        v_blurTexCoords[10] = v_texCoord + vec2( 0.016, 0.0);
        v_blurTexCoords[11] = v_texCoord + vec2( 0.020, 0.0);
        v_blurTexCoords[12] = v_texCoord + vec2( 0.024, 0.0);
        v_blurTexCoords[13] = v_texCoord + vec2( 0.028, 0.0);
    }
}
