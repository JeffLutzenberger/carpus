//
//  ShaderParticle.h
//  carpus
//
//  Created by Jeff Lutzenberger on 3/29/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "ParticleShader.h"
#import "Camera.h"
#import "GameColor.h"

@interface ShaderParticleSystem : NSObject

- (id) initWithPositionAndColor:(float)x y:(float)y color:(ETColor)color;

- (void) draw:(Camera*)camera;

- (void)update:(float)timeElapsed;

- (void)loadParticleSystem:(ParticleShader*)shader;

@end
