//
//  Sink.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/14/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Sink.h"
#import "Vector2D.h"
#import "Particle.h"
#import "GraphicsCircle.h"
#import "GraphicsCircleOutline.h"

@implementation Sink {
    GraphicsCircleOutline* influenceCircle1;
    GraphicsCircleOutline* influenceCircle2;
    GraphicsCircle* gradient1;
    GraphicsCircle* gradient2;
    GraphicsCircle* innerCircle1;
    GraphicsCircle* innerCircle2;
}


- (id) initWithPositionSizeForceAndSpeed:(float)x y:(float)y radius:(float)radius force:(float)force speed:(float)speed {
    self = [super initWithPositionAndSize:x y:y w:radius h:radius theta:0];
    if (self) {
        self.speed = speed;
        self.force = force;
        self.radius = radius;
        self.influenceRadius = radius * 5;
        float color1[] = {1.0, 0.0, 0.0, 1.0};
        float color2[] = {1.0, 0.0, 0.0, 0.5};
        float color3[] = {1.0, 0.0, 0.0, 0.0};
        float color4[] = {1.0, 0.0, 0.0, 0.25};
        float color5[] = {1.0, 1.0, 1.0, 1.0};
        float color6[] = {1.0, 1.0, 1.0, 0.0};
        gradient1 = [[GraphicsCircle alloc] initWithPositionAndRadius:0
                                                                           y:0
                                                                      radius:radius * 4
                                                                   //lineWidth:radius
                                                                  innerColor:color2
                                                                  outerColor:color3];
        
        influenceCircle1 = [[GraphicsCircleOutline alloc] initWithPositionAndRadius:0
                                                                                  y:0
                                                                             radius:_influenceRadius + 7
                                                                          lineWidth:2
                                                                         innerColor:color1
                                                                         outerColor:color1];
        
        influenceCircle2 = [[GraphicsCircleOutline alloc] initWithPositionAndRadius:0
                                                                                  y:0
                                                                             radius:_influenceRadius - 7
                                                                          lineWidth:2
                                                                         innerColor:color1
                                                                         outerColor:color1];
        
        innerCircle1 = [[GraphicsCircle alloc] initWithPositionAndRadius:0
                                                                       y:0
                                                                  radius:radius * 1.5
                                                              innerColor:color4
                                                              outerColor:color4];
        
        innerCircle2 = [[GraphicsCircle alloc] initWithPositionAndRadius:0
                                                                       y:0
                                                                  radius:radius * 0.5
                                                              innerColor:color5
                                                              outerColor:color4];
        
        gradient2 = [[GraphicsCircle alloc] initWithPositionAndRadius:0
                                                                           y:0
                                                                      radius:radius * 1.05
                                                                   //lineWidth:radius * 0.25
                                                                  innerColor:color5
                                                                  outerColor:color6];


    }
    return self;
}

- (void) setMyRadius:(float)radius {
    self.radius = radius;
    self.influenceRadius = radius * 5;
    self.w = radius;
    self.h = radius;
};

- (BOOL) checkIsFull {
    return (self.caught >= self.maxFill);
}

- (void) influence:(Particle*)p dt:(float)dt maxSpeed:(float)maxSpeed {
    Vector2D* v2 = [[Vector2D alloc] initWithXY:(self.x - p.x) y:(self.y - p.y)];
    float r2 = MAX([Vector2D squaredLength:v2], self.radius * self.radius);
    float res = 0;
    if (self.influenceEquation == 0) {
        // 1/r^2
        res = self.force * 100 / r2;
    } else if (self.influenceEquation == 1) {
        // 1/r smooths out influence
        res = self.force / sqrt(r2);
    } else if (self.influenceEquation == 2) {
        res = maxSpeed - sqrt(r2) * maxSpeed / 1000;
        res = MAX(0, res);
    } else if (self.influenceEquation == 3) {
        if (r2 < self.influenceRadius * self.influenceRadius) {
            res = maxSpeed;
        }
    }
    res *= dt * 0.08;
    res = MIN(res, maxSpeed);
    v2 =[Vector2D normalize:v2];
    v2.x *= res;
    v2.y *= res;
    p.vel.x += v2.x;
    p.vel.y += v2.y;
};

- (void) update:(float)dt {
    
}

- (void) draw:(Camera*)camera {
    [camera translateObject:self.x y:self.y z:-1];
    [gradient1 draw];
    [influenceCircle1 draw];
    [influenceCircle2 draw];
    [camera translateObject:self.x y:self.y z:-0.5];
    [innerCircle1 draw];
    //[camera translateObject:self.x y:self.y z:-0.4];
    [innerCircle2 draw];
    //[camera translateObject:self.x y:self.y z:-0.3];
    [gradient2 draw];
    
}

@end
