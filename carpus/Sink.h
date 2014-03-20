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


@interface Sink : Rectangle

@property float radius;
@property float force;
@property float influenceRadius;
@property float speed;
@property float* inColor;
@property float* outColor;
@property bool isSource;
@property bool isGoal;
@property int influenceEquation;
@property bool influenceBound;
@property bool localizeInfluence;
@property int maxFill;
@property int caught;
@property Rectangle* grabber;

- (id) initWithPositionSizeForceAndSpeed:(float)x y:(float)y radius:(float)radius force:(float)force speed:(float)speed;

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
