//
//  Shader.vsh
//  Test GL Game
//
//  Created by Jeff.Lutzenberger on 3/11/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

attribute vec4 color;
attribute vec4 position;
attribute vec3 normal;
attribute vec2 texcoord;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    
    colorVarying = color * nDotVP;
    
    texcoord;
        
    gl_Position = modelViewProjectionMatrix * position;
}
