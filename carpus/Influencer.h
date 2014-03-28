//
//  Influencer.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/16/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rectangle.h"
#import "Vector2D.h"
#import "Particle.h"
#import "Camera.h"

@interface Influencer : Rectangle

@property float radius;
@property float force;
@property float influenceRadius;
@property int influenceEquation;
@property bool influenceBound;
@property bool localizeInfluence;
@property bool deflectParticles;

- (id) initWithPositionSizeAndForce:(float)x y:(float)y radius:(float)radius force:(float)force;

- (void) influence:(Particle*)p dt:(float)dt maxSpeed:(float)maxSpeed;

- (BOOL) influencerHit:(Particle*)p;

- (BOOL) influencerTouchHit:(Particle*)p;

- (Vector2D*) bounce:(Particle*)p;

//- (void) update:(float)dt;

- (void) draw:(Camera*)camera;

@end
