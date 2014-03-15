//
//  Sink.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/14/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rectangle.h"
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
@property int maxFill;
@property int caught;
@property Rectangle* grabber;

- (id) initWithPositionSizeForceAndSpeed:(float)x y:(float)y radius:(float)radius force:(float)force speed:(float)speed;

- (void) update:(float)dt;

- (void) draw:(Camera*)camera;

@end
