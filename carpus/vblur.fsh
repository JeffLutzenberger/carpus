uniform sampler2D Texture; // this should hold the texture rendered by the horizontal blur pass
varying lowp vec2 vTexCoord;

varying lowp vec4 colorVarying;

const highp float blurSize = 1.0/(0.25*1024.0);//(0.75 * 568.0);

void main(void)
{
    colorVarying;
    lowp vec4 sum = vec4(0.0);
    
    // blur in y (vertical)
    // take nine samples, with the distance blurSize between them
    sum += texture2D(Texture, vec2(vTexCoord.x, vTexCoord.y - 4.0*blurSize)) * 0.05;
    sum += texture2D(Texture, vec2(vTexCoord.x, vTexCoord.y - 3.0*blurSize)) * 0.09;
    sum += texture2D(Texture, vec2(vTexCoord.x, vTexCoord.y - 2.0*blurSize)) * 0.12;
    sum += texture2D(Texture, vec2(vTexCoord.x, vTexCoord.y - blurSize)) * 0.15;
    sum += texture2D(Texture, vec2(vTexCoord.x, vTexCoord.y)) * 0.16;
    sum += texture2D(Texture, vec2(vTexCoord.x, vTexCoord.y + blurSize)) * 0.15;
    sum += texture2D(Texture, vec2(vTexCoord.x, vTexCoord.y + 2.0*blurSize)) * 0.12;
    sum += texture2D(Texture, vec2(vTexCoord.x, vTexCoord.y + 3.0*blurSize)) * 0.09;
    sum += texture2D(Texture, vec2(vTexCoord.x, vTexCoord.y + 4.0*blurSize)) * 0.05;
    
    gl_FragColor = sum;
}