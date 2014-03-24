//
//  PointMass.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/23/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2D.h"
@interface PointMass : NSObject

@property float x;
@property float y;
@property Vector2D* vel;
@property float invMass;
@property Vector2D* accel;
@property float damping;

- (id) initWithPosition:(float)x y:(float)y;

- (void) applyForce:(float)fx fy:(float)fy;

- (void) increaseDamping:(float)factor;

- (void) update:(float)dt;

@end
