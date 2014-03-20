attribute vec4 position;
attribute vec4 color;

varying vec4 vDstColor;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;


attribute vec2 texcoord; // New
varying vec2 vTexCoord; // New

void main(void) {
    vDstColor = color;
    gl_Position = modelViewProjectionMatrix * position;
    vTexCoord = texcoord; // New
}