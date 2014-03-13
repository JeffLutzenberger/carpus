//varying lowp vec4 vDstColor;
varying lowp vec4 colorVarying;

varying lowp vec2 vTexCoord; // New
uniform sampler2D Texture; // New

void main(void) {
    vTexCoord;
    gl_FragColor = colorVarying * texture2D(Texture, vTexCoord); // New
}
