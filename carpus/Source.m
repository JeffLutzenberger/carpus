//
//  Source.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Source.h"
#import "GraphicsRectangle.h"
#import "GraphicsQuad.h"
#import "GraphicsCircle.h"

// Uniform index.
@implementation Source {
    float lastAddTime;
    float addPeriod; //ms per particle
    GraphicsRectangle* rect1;
    GraphicsRectangle* rect2;
}

- (id) initWithPositionSizeAndSpeed:(float)x y:(float)y w:(float)w h:(float)h theta:(float)theta speed:(float)speed {
    self = [super initWithPositionAndSize:x y:y w:w h:h theta:theta color:GREEN];
    if (self) {
        self.speed = speed;
        self.nparticles = 25;
        lastAddTime = 0;
        addPeriod = 100; //ms
        self.particles = [[NSMutableArray alloc] init];
        [self setColor:RED];
        const float* c = gGameColors[self.color];
        float color1[] = {c[0], c[1], c[2], 1.0};
        float color2[] = {1.0, 1.0, 1.0, 0.5};
        rect1 = [[GraphicsRectangle alloc] initWithPositionAndSize:0 y:0 w:w h:h theta:theta lineWidth:5 color:color1];
        rect2 = [[GraphicsRectangle alloc] initWithPositionAndSize:0 y:0 w:w h:h theta:theta lineWidth:2 color:color2];
    }
    return self;
}

- (void)setSourceColor:(ETColor)c {
    self.color = c;
    //update the graphics rectangle
    const float* gc = gGameColors[self.color];
    float color1[] = {gc[0], gc[1], gc[2], 1.0};
    float color2[] = {1.0, 1.0, 1.0, 0.5};
    [rect1 setColor:color1];
    [rect2 setColor:color2];
}

- (void) addParticles {
    Vector2D* v = [Vector2D subtract:self.p3 v2:self.p4];
    float x = 0;
    float y = 0;
    float vx = self.speed * self.n3.x;
    float vy = self.speed * self.n3.y;
    for (int i = 0; i < self.nparticles; i++) {
        x = self.p3.x + (float)drand48() * v.x;
        y = self.p3.y + (float)drand48() * v.y;
        Particle* p = [[Particle alloc] initWithPositionAndColor:x y:y r:4 color:RED];
        p.source = self;
        [p recycle:x y:y vx:vx vy:vy color:self.color];
        [self.particles insertObject:p atIndex:i];
    }
}

- (void) recycleParticle:(Particle*)p {
    Vector2D* v = [Vector2D subtract:self.p4 v2:self.p3];
    float x = self.p3.x + (float)drand48() * v.x;
    float y = self.p3.y + (float)drand48() * v.y;
    float vx = self.speed * self.n3.x;
    float vy = self.speed * self.n3.y;
    [p recycle:x y:y vx:vx vy:vy color:self.color];
}

- (void) update:(float)dt {
    lastAddTime += dt;
    if ([self.particles count] < self.nparticles && lastAddTime > addPeriod) {
        lastAddTime = 0;
        Vector2D* p1 = self.p3;
        Vector2D* p2 = self.p4;
        Vector2D* v = [[Vector2D alloc] initWithXY:p2.x - p1.x y:p2.y - p1.y];
        float x = p1.x + (float)drand48() * v.x;
        float y = p1.y + (float)drand48() * v.y;
        float vx = self.speed * self.n3.x;
        float vy = self.speed * self.n3.y;
        Particle* p = [[Particle alloc] initWithPositionAndColor:x y:y r:4 color:RED];
        p.source = self;
        [p recycle:x y:y vx:vx vy:vy color:self.color];
        [self.particles addObject:p];
    }
}

- (void) draw:(Camera*)camera {
    
    [camera translateObject:self.x y:self.y z:-0.5];
    [rect1 draw];
    [camera translateObject:self.x y:self.y z:-0.4];
    [rect2 draw];
    
}

@end
