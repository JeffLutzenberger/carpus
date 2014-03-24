//
//  Spring.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/23/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Spring.h"

@implementation Spring

- (id) initWithPositionStiffnessAndDamping:(PointMass*)v1 v2:(PointMass*)v2 stiffness:(float)stiffness damping:(float)damping {
    self = [super init];
    if (self) {
        _end1 = [[PointMass alloc] initWithPosition:v1.x y:v1.y];
        _end2 = [[PointMass alloc] initWithPosition:v2.x y:v2.y];
        _stiffness = stiffness;
        _damping = damping;
        float dx = v1.x - v2.x;
        float dy = v1.y - v2.y;
        _targetLength = sqrt(dx * dx + dy * dy);
    }
    return self;
}

- (void) update:(float)dt {
    float dx = _end1.x - _end2.x;
    float dy = _end1.y - _end2.y;
    float length = sqrt(dx * dx + dy * dy);
    float dvx = _end2.vel.x - _end1.vel.x;
    float dvy = _end2.vel.y - _end1.vel.y;
    dt = 1.0;
    
    if (length <= _targetLength) {
        return;
    }
    
    dx = dx / length * (length - _targetLength);
    dy = dy / length * (length - _targetLength);
    
    float fx = _stiffness * dx - dvx * _damping * dt;
    float fy = _stiffness * dy - dvy * _damping * dt;
    
    [_end1 applyForce:fx fy:fy];
    [_end2 applyForce:fx fy:fy];
}

@end
