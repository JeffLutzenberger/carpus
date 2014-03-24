//
//  PointMass.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/23/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "PointMass.h"

@implementation PointMass

- (id) initWithPosition:(float)x y:(float)y {
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
        _vel = [[Vector2D alloc] initWithXY:0 y:0];
        _invMass = 1.0;
        _accel = [[Vector2D alloc] initWithXY:0 y:0];
        _damping = 0.98;
    }
    return self;
}


- (void) applyForce:(float)fx fy:(float)fy {
    _accel.x += fx * _invMass;
    _accel.y += fy * _invMass;
}

- (void) increaseDamping:(float)factor {
    self.damping *= factor;
}

- (void) update:(float)dt {
    //dt *= 0.1;
    dt = 1.0;
    _vel.x += _accel.x * dt;
    _vel.y += _accel.y * dt;
    _x += _vel.x * dt;
    _y += _vel.y * dt;
    _accel.x = 0;
    _accel.y = 0;
    if ([Vector2D squaredLength:_vel] < 0.001 * 0.001) {
        _vel.x = 0;
        _vel.y = 0;
    }
    _vel.x *= _damping;
    _vel.y *= _damping;
}

@end
