//
//  Particle.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Particle.h"
#import "GraphicsCircle.h"
#import "GraphicsTrace.h"

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface Tracer () {
    
}

@end

@implementation Tracer

- (id) initWithPositionAndColor:(float)x y:(float)y color:(float *)color {
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
        self.color =color;
        self.age = 0;
    }
    return self;
}

@end

@implementation Particle {
    NSMutableArray* trail;
    GraphicsCircle* graphicsCircle;
    GraphicsTrace* graphicsTrace;
}

- (id) initWithPositionAndColor:(float)x y:(float)y r:(float)r color:(float*)color {
    self = [super init];
    if(self) {
        self.x = x;
        self.y = y;
        self.prevx = x;
        self.prevy = y;
        self.radius = r;
        self.color = color;
        self.age = 0;
        self.dir = [[Vector2D alloc] initWithXY:1 y:0];
        self.vel = [[Vector2D alloc] initWithXY:0 y:0.1];
        self.numTracers = 30;
        self.traceWidth = 1;
        self.accel = -0.0003;
        trail = [[NSMutableArray alloc] initWithCapacity:self.numTracers];
        self.source = nil;
        for (int i = 0; i < self.numTracers; i++) {
            [trail insertObject:[[Tracer alloc] initWithPositionAndColor:self.x
                                                                       y:self.y
                                                                   color:self.color] atIndex:i];
        }
        float innerColor[] = {1.0, 0.0, 0.0, 1.0};
        float outerColor[] = {1.0, 0.0, 0.0, 0.25};
        graphicsCircle = [[GraphicsCircle alloc] initWithPositionAndRadius:0
                                                                         y:0
                                                                    radius:self.radius
                                                                innerColor:innerColor
                                                                outerColor:outerColor];
        graphicsTrace = [[GraphicsTrace alloc] initWithTrailAndColor:trail color:self.color];

    }
    return self;
}

- (void) move:(float)dt {
    self.prevx = self.x;
    self.prevy = self.y;
    //FIXME: the factor here is not consistent with the javascript version
    self.x += self.vel.x * dt * 0.001;
    self.y += self.vel.y * dt * 0.001;
    //NSLog(@"%0.2f", self.vel.y);
    self.age += dt;
}

- (void) trace {
    Tracer* t;
    for (int i = 0; i < self.numTracers; i++) {
        t =[trail objectAtIndex:i];
        t.age += 1;
    }
    if (self.numTracers > 0) {
        t = [trail lastObject];
        t.x = self.x;
        t.y = self.y;
        t.age = 0;
        [trail insertObject:t atIndex:0];
        [trail removeLastObject];
    }
    
    [graphicsTrace updateCoordinates:trail];
}

- (void) update:(float)dt {
    [self move:dt];
    self.age += dt;
}

- (void) recycle:(float)x y:(float)y vx:(float)vx vy:(float)vy color:(float*)color {
    Tracer* t;
    self.x = x;
    self.y = y;
    self.prevx = x;
    self.prevy = y;
    self.age = 0;
    self.vel.x = vx;
    self.vel.y = vy;
    self.color = color;
    for (int i = 0; i < self.numTracers; i++) {
        t = [trail objectAtIndex:i];
        t.x = self.x;
        t.y = self.y;
        t.color =self.color;
    }
}

- (void) bounce:(Vector2D*)n {
    float dot = 2 * [Vector2D dot:self.vel v2:n];
    self.vel.x -= dot * n.x;
    self.vel.y -= dot * n.y;
   
}

- (void) redirect:(Vector2D*)n {
    float speed = [Vector2D length:self.vel];
    self.vel.x = speed * n.x;
    self.vel.y = speed * n.y;

}

- (Vector2D*) position {
    return [[Vector2D alloc] initWithXY:self.x y:self.y];
};

- (BOOL) lineCollision:(Vector2D*)p1 p2:(Vector2D*)p2 {

    return false;
}

- (BOOL) circleCollision:(Vector2D*)p1 p2:(Vector2D*)p2 {
    return false;
}

- (BOOL) circleCircleCollision:(Vector2D*)p r:(float)r {
    return false;
}

- (void) draw:(Camera*)camera {
    
    [camera translateObject:0 y:0 z:0];
    
    [graphicsTrace draw];
    
    [camera translateObject:self.x y:self.y z:0];
    
    [graphicsCircle draw];
    
}

@end
