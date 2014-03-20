//
//  Shader.vsh
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//


attribute vec4 position;
attribute vec3 normal;
attribute vec4 color;
attribute vec2 texcoord;
//attribute vec2 texcoord0;


varying lowp vec2 vTexCoord;
varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    //vec3 eyeNormal = normalize(normalMatrix * normal);
    //vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    //vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 0.25);
    
    //float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    position;
    normal;
    
    colorVarying = color;//gl_Color; //diffuseColor * nDotVP;
    
    gl_Position = modelViewProjectionMatrix * position;
    
    gl_PointSize = 6.0;
    
    // pass to fragment shader
    vTexCoord = texcoord;
    //vTexCoord = texcoord0; // New
}
