//
//  Bucket.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/18/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Rectangle.h"
#import "Particle.h"
#import "Camera.h"

@interface Bucket : Rectangle

@property float caught;
@property float maxFill;
@property BOOL hasBottom;
@property int level;

- (BOOL)checkIsFull;

- (void)update:(float)dt;

- (void)reset;

- (void) draw:(Camera*)camera;

@end
