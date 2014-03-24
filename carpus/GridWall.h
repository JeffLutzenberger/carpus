//
//  GridWall.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/22/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2D.h"
#import "Particle.h"
#import "GameColor.h"
#import "Camera.h"

@interface GridWall : NSObject

@property (nonatomic) Vector2D* p1;
@property (nonatomic) Vector2D* p2;
@property (nonatomic) Vector2D* p3;
@property (nonatomic) Vector2D* p4;
@property (nonatomic) Vector2D* p5;
@property (nonatomic) Vector2D* p6;
@property (nonatomic) Vector2D* p7;
@property (nonatomic) Vector2D* p8;
@property (nonatomic) Vector2D* n;
@property (nonatomic) ETColor doorColor;
@property (nonatomic) BOOL hasDoor;
@property (nonatomic) BOOL doorEnabled;

- (id) initWithPoints:(Vector2D*)p1 p2:(Vector2D*)p2;

- (Vector2D*) hit:(Particle*)p;

- (Vector2D*) circleHit:(Particle*)p;

- (void)setDoor:(float)s1 s2:(float)s2;

- (void) setS1:(float)s1;

- (void) setS2:(float)s2;

- (float)getS1;

- (float)getS2;

- (void)draw:(Camera*)camera;

@end
