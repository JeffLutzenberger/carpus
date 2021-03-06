//
//  Rectangle.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2D.h"
#import "Particle.h"
#import "GameColor.h"
#import "Camera.h"

@interface Rectangle : NSObject

@property float x;
@property float y;
@property float w;
@property float h;
@property (nonatomic) ETColor color;
@property (nonatomic)float theta;
@property Vector2D* p1;
@property Vector2D* p2;
@property Vector2D* p3;
@property Vector2D* p4;
@property Vector2D* p5;
@property Vector2D* p6;
@property Vector2D* n1;
@property Vector2D* n2;
@property Vector2D* n3;
@property Vector2D* n4;
@property int stage;
@property BOOL enabled;
@property BOOL show;
@property BOOL selected;
@property BOOL grabberSelected;
@property BOOL interactable;

- (id) initWithPositionAndSize:(float)x y:(float)y w:(float)w h:(float)h theta:(float)theta color:(ETColor)color;

- (Vector2D*) position;

- (void) setPosition:(float)x y:(float)y;

- (BOOL) bbHit:(Particle*)p;

- (Vector2D*) hit:(Particle*)p;

- (BOOL) circleHit:(Vector2D*)p;

- (void) draw:(Camera*)camera;

@end
