//
//  ParticleShader.h
//  carpus
//
//  Created by Jeff Lutzenberger on 3/30/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParticleShader : NSObject

// Program Handle
@property (readwrite) GLuint    program;

// Attribute Handles
@property (readwrite) GLint     a_pID;
@property (readwrite) GLint     a_pRadiusOffset;
@property (readwrite) GLint     a_pVelocityOffset;
@property (readwrite) GLint     a_pDecayOffset;
@property (readwrite) GLint     a_pSizeOffset;
@property (readwrite) GLint     a_pTimeOffset;
@property (readwrite) GLint     a_pLife;
@property (readwrite) GLint     a_pActive;
@property (readwrite) GLint     a_pColorOffset;

// Uniform Handles
@property (readwrite) GLint     u_Intensity;
@property (readwrite) GLuint    u_ProjectionMatrix;
@property (readwrite) GLint     u_Gravity;
@property (readwrite) GLint     u_Time;
@property (readwrite) GLint     u_eRadius;
@property (readwrite) GLint     u_eVelocity;
@property (readwrite) GLint     u_eDecay;
@property (readwrite) GLint     u_eSize;
@property (readwrite) GLint     u_eColor;
@property (readwrite) GLint     u_eLife;
@property (readwrite) GLint     u_ePosition;

@end
