//
//  Particle.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2D.h"
#import "Camera.h"
#import "GameColor.h"
@interface Tracer : NSObject

@property float x;
@property float y;
@property float age;
//@property GameColor* color;
@property ETColor color;

- (id) initWithPositionAndColor:(float)x y:(float)y color:(ETColor)color;

@end

@interface Particle : NSObject

@property float x;
@property float y;
@property float prevx;
@property float prevy;
@property float age;
@property Vector2D* dir;
@property Vector2D* vel;
@property float radius;
//@property GameColor* color;
@property ETColor color;
@property int numTracers;
@property float traceWidth;
@property float accel;
@property id source;

- (id) initWithPositionAndColor:(float)x y:(float)y r:(float)r color:(ETColor)color;

- (void)setParticleColor:(ETColor)color;

- (void) move:(float)dt;

- (void) trace;

- (void) update:(float)dt;

- (void) recycle:(float)x y:(float)y vx:(float)vx vy:(float)vy color:(ETColor)color;

- (void) bounce:(Vector2D*)n;

- (void) redirect:(Vector2D*)n;

- (Vector2D*) position;

- (BOOL) lineCollision:(Vector2D*)p1 p2:(Vector2D*)p2;

- (BOOL) circleCollision:(Vector2D*)p1 p2:(Vector2D*)p2;

- (BOOL) circleCircleCollision:(Vector2D*)p r:(float)r;

- (void) draw:(Camera*)camera;

@end
