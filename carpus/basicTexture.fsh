//varying lowp vec4 vDstColor;
varying lowp vec4 colorVarying;
varying lowp vec2 vTexCoord;

uniform sampler2D Texture; 

void main(void) {
    //vTexCoord;
    gl_FragColor = colorVarying * texture2D(Texture, vTexCoord); // New
}
