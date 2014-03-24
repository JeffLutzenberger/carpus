//
//  Spring.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/23/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PointMass.h"
#import "Vector2D.h"

@interface Spring : NSObject

@property PointMass* end1;
@property PointMass* end2;
@property float stiffness;
@property float damping;
@property float targetLength;

- (id) initWithPositionStiffnessAndDamping:(PointMass*)v1 v2:(PointMass*)v2 stiffness:(float)stiffness damping:(float)damping;

- (void) update:(float)dt;

@end
