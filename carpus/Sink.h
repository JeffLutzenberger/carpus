//
//  Sink.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/14/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rectangle.h"
#import "Vector2D.h"
#import "Particle.h"
#import "Camera.h"
#import "GameColor.h"
#import "ShaderParticleSystem.h"

@interface Sink : Rectangle

@property float radius;
@property float force;
@property float influenceRadius;
@property float speed;
@property ETColor inColor;
@property ETColor outColor;
@property bool isSource;
@property bool isGoal;
@property int influenceEquation;
@property bool influenceBound;
@property bool localizeInfluence;
@property int maxFill;
@property int caught;
@property Rectangle* grabber;
@property ShaderParticleSystem* shaderParticleSystem;


- (id) initWithPositionSizeForceSpeedAndColor:(float)x y:(float)y radius:(float)radius force:(float)force speed:(float)speed inColor:(ETColor)inColor outColor:(ETColor)outColor;

- (void) setSinkColor:(ETColor)inColor outColor:(ETColor)outColor;

- (BOOL) checkIsFull;

- (void) recycleParticle:(Particle*)p;

- (void) influence:(Particle*)p dt:(float)dt maxSpeed:(float)maxSpeed;

- (BOOL) sinkHit:(Particle*)p;

- (BOOL) hitGrabber:(Particle*)p;

- (void) moveGrabber:(Vector2D*)v;

- (BOOL) insideInfluenceRing:(Particle*)p;

- (Vector2D*) trap:(Particle*)p;

- (Vector2D*) bounce:(Particle*)p;

- (void) update:(float)dt;

- (void) draw:(Camera*)camera;

@end
