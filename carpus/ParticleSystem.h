//
//  ParticleSystem.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/18/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2D.h"
#import "GameColor.h"
#import "Camera.h"

@interface PassiveParticle : NSObject

@property Vector2D* pos;
@property Vector2D* prevPos;
@property Vector2D* vel;
@property Vector2D* dir;
@property float theta;
//@property float speed;
@property float accel;
//@property float damping;
@property float age;
@property float lifetime;
@property Vector2D* scale;
@property GameColor* color;
@property GLuint texture;

- (id) initWithPosition:(float)x y:(float)y texture:(GLuint)texture;

- (void) update:(float)dt;

- (void) spiralUpdate:(float)dt s:(Vector2D*)s;

- (void) draw:(Camera*)camera;

@end

@interface ParticleSystem : NSObject
@property float x;
@property float y;
@property NSMutableArray* active;
@property NSMutableArray* pool;

- (id) initWithCoordsAndCapacity:(float)x y:(float)y capacity:(int)capacity;

- (void) burst:(float)x y:(float)y burstRadius:(float)burstRadius speed:(float)speed accel:(float)accel nparticles:(int)nparticles lifetime:(float)lifetime;

- (void) update:(float)dt;

- (void) spiralUpdate:(float)dt s:(Vector2D*)s;

- (void) draw:(Camera*)camera;

@end
