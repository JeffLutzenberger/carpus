//
//  ParametricShader.m
//  carpus
//
//  Created by Jeff Lutzenberger on 4/6/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "ParametricShader.h"
#import "ShaderLoader.h"

@implementation ParametricShader

- (id) init {
    self = [super init];
    if (self) {
        [self loadShader];
    }
    return self;
}

- (void)loadShader
{
    [ShaderLoader load:@"parametric" fshFile:@"parametric" program:&_program];
    
    // Attributes
    self.a_pID = glGetAttribLocation(self.program, "a_pID");
    self.a_pRadiusOffset = glGetAttribLocation(self.program, "a_pRadius");
    self.a_pVelocityOffset = glGetAttribLocation(self.program, "a_pVelocity");
    self.a_pDecayOffset = glGetAttribLocation(self.program, "a_pDamping");
    self.a_pSizeOffset = glGetAttribLocation(self.program, "a_pPointSize");
    self.a_pTimeOffset = glGetAttribLocation(self.program, "a_pTimeOffset");
    self.a_pColorOffset = glGetAttribLocation(self.program, "a_pColor");
    
    // Uniforms
    self.u_ProjectionMatrix = glGetUniformLocation(self.program, "u_ProjectionMatrix");
    self.u_Gravity = glGetUniformLocation(self.program, "u_Gravity");
    self.u_Time = glGetUniformLocation(self.program, "u_Time");
    self.u_eRadius = glGetUniformLocation(self.program, "u_eRadius");
    self.u_eVelocity = glGetUniformLocation(self.program, "u_eVelocity");
    self.u_eDecay = glGetUniformLocation(self.program, "u_eDecay");
    self.u_eSize = glGetUniformLocation(self.program, "u_eSize");
    self.u_eColor = glGetUniformLocation(self.program, "u_eColor");
    self.u_eLife =glGetUniformLocation(self.program, "u_eLife");
    self.u_ePosition = glGetUniformLocation(self.program, "u_ePosition");
}

@end
