//
//  BackgroundGrid.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/18/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2D.h"

@interface PointMass : NSObject

@property float x;
@property float y;
@property Vector2D* vel;
@property float invMass;
@property float accel;
@property float damping;

@end

@interface Spring : NSObject

@property Vector2D* end1;
@property Vector2D* end2;
@property float stiffness;
@property float damping;
@property float targetLength;

@end

@interface BackgroundGrid : NSObject

@end
