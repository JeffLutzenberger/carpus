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

- (id) initWithPositionAndColor:(float)x y:(float)y color:(ETColor)color {
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
        self.color = color;
        self.age = 0;
    }
    return self;
}

@end

@implementation Particle {
    NSMutableArray* trail;
    GraphicsCircle* circle1;
    GraphicsCircle* circle2;
    
    GraphicsTrace* trace1;
    GraphicsTrace* trace2;
}

- (id) initWithPositionAndColor:(float)x y:(float)y r:(float)r color:(ETColor)color {
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
        self.traceWidth = 2;
        self.accel = -0.0003;
        trail = [[NSMutableArray alloc] initWithCapacity:self.numTracers];
        self.source = nil;
        for (int i = 0; i < self.numTracers; i++) {
            [trail insertObject:[[Tracer alloc] initWithPositionAndColor:self.x
                                                                       y:self.y
                                                                   color:self.color] atIndex:i];
        }
        const float* c = gGameColors[self.color];
        float innerColor2[] = {c[0], c[1], c[2], 1.0};
        float outerColor2[] = {c[0], c[1], c[2], 1.0};
        circle1 = [[GraphicsCircle alloc] initWithPositionAndRadius:0
                                                                  y:0
                                                             radius:self.radius
                                                         innerColor:innerColor2
                                                         outerColor:outerColor2];
        const float* white = gGameColors[WHITE];
        float innerColor3[] = {white[0], white[1], white[2], 0.7};
        float outerColor3[] = {white[0], white[1], white[2], 0.7};
        circle2 = [[GraphicsCircle alloc] initWithPositionAndRadius:0
                                                                  y:0
                                                             radius:0.5 * self.radius
                                                         innerColor:innerColor3
                                                         outerColor:outerColor3];
        
        float traceColor1[] = {c[0], c[1], c[2], 0.25};
        trace1 = [[GraphicsTrace alloc] initWithTrailAndColor:trail lineWidth:2 * self.traceWidth color:traceColor1];
        
        float traceColor2[] = {c[0], c[1], c[2], 0.25};
        trace1 = [[GraphicsTrace alloc] initWithTrailAndColor:trail lineWidth:self.traceWidth color:traceColor2];


    }
    return self;
}

- (void) move:(float)dt {
    self.prevx = self.x;
    self.prevy = self.y;
    self.x += self.vel.x * dt * 0.08;
    self.y += self.vel.y * dt * 0.08;
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
    
    [trace1 updateCoordinates:trail];
    
    [trace2 updateCoordinates:trail];
}

- (void) update:(float)dt {
    [self move:dt];
    self.age += dt;
}

- (void)setParticleColor:(ETColor)color {
    self.color = color;
    const float* c = gGameColors[self.color];
    float c1[4] = {c[0], c[1], c[2], 1.0};
    [circle1 setColor:c1 outerColor:c1];
    [circle1 updateCircle];
    [trace1 setColor:c1];
    
    for (Tracer* t in trail) {
        [t setColor:color];
    }
}

- (void) recycle:(float)x y:(float)y vx:(float)vx vy:(float)vy color:(ETColor)color {
    Tracer* t;
    self.x = x;
    self.y = y;
    self.prevx = x;
    self.prevy = y;
    self.age = 0;
    self.vel.x = vx;
    self.vel.y = vy;
    [self setParticleColor:color];
    for (int i = 0; i < self.numTracers; i++) {
        t = [trail objectAtIndex:i];
        t.x = self.x;
        t.y = self.y;
        t.color = self.color;
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

    Vector2D* LineA1 = [[Vector2D alloc] initWithXY:self.prevx y:self.prevy];
    Vector2D* LineA2 = [[Vector2D alloc] initWithXY:self.x y:self.y];
    Vector2D* LineB1 = [[Vector2D alloc] initWithXY:p1.x y:p1.y];
    Vector2D* LineB2 = [[Vector2D alloc] initWithXY:p2.x y:p2.y];
    float denom = (LineB2.y - LineB1.y) * (LineA2.x - LineA1.x) - (LineB2.x - LineB1.x) * (LineA2.y - LineA1.y);
    
    if (denom != 0.0) {
        float ua = ((LineB2.x - LineB1.x) * (LineA1.y - LineB1.y) - (LineB2.y - LineB1.y) * (LineA1.x - LineB1.x)) / denom;
        float ub = ((LineA2.x - LineA1.x) * (LineA1.y - LineB1.y) - (LineA2.y - LineA1.y) * (LineA1.x - LineB1.x)) / denom;
        if (ua < 0 || ua > 1 || ub < 0 || ub > 1) {
            return false;
        }
        self.x = LineA1.x + ua * (LineA2.x - LineA1.x);
        self.y = LineA1.y + ua * (LineA2.y - LineA1.y);
        self.prevx = self.x;
        self.prevy = self.y;
        return true;
    }
    return false;
}

- (BOOL) circleCollision:(Vector2D*)p1 p2:(Vector2D*)p2 {
    return false;
}

- (BOOL) circleCircleCollision:(Vector2D*)p r:(float)r {
    return false;
}

- (void) draw:(Camera*)camera {
    
    [camera translateObject:0 y:0 z:-1];
    [trace1 draw];
    
    //[camera translateObject:0 y:0 z:-0.5];
    //[trace2 draw];
    
    [camera translateObject:self.x y:self.y z:-0.5];
    [circle1 draw];
    
    [camera translateObject:self.x y:self.y z:-0.25];
    [circle2 draw];
    
}

@end
