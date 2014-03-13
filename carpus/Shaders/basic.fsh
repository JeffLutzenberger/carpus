//
//  Shader.fsh
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

uniform sampler2D uSampler;

varying lowp vec2 vTexCoord;
varying lowp vec4 colorVarying;

void main()
{
    //lowp vec4 texCol = texture2D(uSampler, vTexCoord);
    //gl_FragColor = vec4(texCol.rgb, 1.0);
    vTexCoord;
    gl_FragColor = colorVarying;
    
}
