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
    GraphicsRectangle* rect3;
    GraphicsRectangle* rect4;
}

- (id) initWithPositionSizeAndSpeed:(float)x y:(float)y w:(float)w h:(float)h theta:(float)theta speed:(float)speed {
    self = [super initWithPositionAndSize:x y:y w:w h:h theta:theta];
    if (self) {
        self.speed = speed;
        self.nparticles = 50;
        lastAddTime = 0;
        addPeriod = 100; //ms
        self.particles = [[NSMutableArray alloc] init];
        float color1[] = {1.0, 0.0, 0.0, 1.0};
        rect1 = [[GraphicsRectangle alloc] initWithPositionAndSize:0 y:0 w:w h:h theta:theta lineWidth:10 color:color1];
        
        //float color1[] = {1.0, 0.0, 0.0, 0.25};
        //rect1 = [[GraphicsRectangle alloc] initWithPositionAndSize:0 y:0 w:w h:h theta:theta lineWidth:10 color:color1];
        float color2[] = {1.0, 0.0, 0.0, 0.5};
        rect2 = [[GraphicsRectangle alloc] initWithPositionAndSize:0 y:0 w:w h:h theta:theta lineWidth:20 color:color2];
        float color3[] = {1.0, 1.0, 1.0, 0.7};
        rect3 = [[GraphicsRectangle alloc] initWithPositionAndSize:0 y:0 w:w h:h theta:theta lineWidth:5 color:color3];
        float color4[] = {1.0, 0.0, 0.0, 0.15};
        rect4 = [[GraphicsRectangle alloc] initWithPositionAndSize:0 y:0 w:w h:h theta:theta lineWidth:25 color:color4];
    }
    return self;
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
        Particle* p = [[Particle alloc] initWithPositionAndColor:x y:y r:4 color:self.color];
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
        Particle* p = [[Particle alloc] initWithPositionAndColor:x y:y r:4 color:self.color];
        p.source = self;
        [p recycle:x y:y vx:vx vy:vy color:self.color];
        [self.particles addObject:p];
    }
}

- (void) draw:(Camera*)camera {
    
    [camera translateObject:self.x y:self.y z:-0.5];
    [rect1 draw];
    //[camera translateObject:self.x y:self.y z:-0.6];
    //[rect2 draw];
    [camera translateObject:self.x y:self.y z:-0.4];
    [rect3 draw];
    [camera translateObject:self.x y:self.y z:-0.3];
    [rect4 draw];
    
}

@end
