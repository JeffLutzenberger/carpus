//
//  Influencer.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/16/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Influencer.h"
#import "ParticleSystem.h"
#import "GraphicsCircle.h"
#import "GraphicsCircleOutline.h"
//#import "GraphicsArc.h"
#import "GraphicsTriangle.h"


@implementation Influencer {
    GraphicsCircleOutline* influenceCircle1;
    GraphicsCircleOutline* influenceCircle2;
    GraphicsTriangle* north;
    GraphicsTriangle* south;
    GraphicsTriangle* east;
    GraphicsTriangle* west;
}

- (id) initWithPositionSizeAndForce:(float)x y:(float)y radius:(float)radius force:(float)force {
    self = [super initWithPositionAndSize:x y:y w:radius h:radius theta:0 color:BLUE];
    if (self) {
        self.dragDirection = OMNI;
        self.force = force;
        self.radius = radius;
        self.influenceRadius = radius * 5;
        self.influenceEquation = 0;
        self.localizeInfluence = false;
        self.deflectParticles = false;
        self.color = BLUE;//[[GameColor alloc] initWithRGBA:0.0 g:0.0 b:1.0 a:1.0];
        
        const float* c = gGameColors[GRAY1];//gGameColors[self.color];
        float color1[] = {c[0], c[1], c[2], 1.0};
        
        influenceCircle1 = [[GraphicsCircleOutline alloc] initWithPositionAndRadius:0
                                                                                  y:0
                                                                             radius:self.influenceRadius
                                                                          lineWidth:3
                                                                         innerColor:color1
                                                                         outerColor:color1];
        
        float h = (self.influenceRadius - self.radius) * 0.5;
        float r = h;
        float w = h * 0.5;
        north = [[GraphicsTriangle alloc] initWithPoints:[[Vector2D alloc] initWithXY:0  y:r + h]
                                                      p2:[[Vector2D alloc] initWithXY:-w y:r]
                                                      p3:[[Vector2D alloc] initWithXY:w  y:r]];
        north.fanEffect = YES;
        [north setColor:color1];
        
        south = [[GraphicsTriangle alloc] initWithPoints:[[Vector2D alloc] initWithXY:0  y:-(r + h)]
                                                      p2:[[Vector2D alloc] initWithXY:w  y:-r]
                                                      p3:[[Vector2D alloc] initWithXY:-w y:-r]];
        south.fanEffect = YES;
        [south setColor:color1];
        
        east = [[GraphicsTriangle alloc] initWithPoints:[[Vector2D alloc] initWithXY:r + h y:0]
                                                      p2:[[Vector2D alloc] initWithXY:r    y:w]
                                                      p3:[[Vector2D alloc] initWithXY:r    y:-w]];
        east.fanEffect = YES;
        [east setColor:color1];
        west = [[GraphicsTriangle alloc] initWithPoints:[[Vector2D alloc] initWithXY:-(r + h) y:0]
                                                     p2:[[Vector2D alloc] initWithXY:-r       y:-w]
                                                     p3:[[Vector2D alloc] initWithXY:-r       y:w]];
        west.fanEffect = YES;
        [west setColor:color1];
        
        /*influenceCircle2 = [[GraphicsCircleOutline alloc] initWithPositionAndRadius:0
                                                                                  y:0
                                                                             radius:_influenceRadius - 7
                                                                          lineWidth:3
                                                                         innerColor:color1
                                                                         outerColor:color1];*/
    }
    return self;

}

- (void) setMyRadius:(float)radius {
    self.radius = radius;
    self.influenceRadius = radius * 5;
    self.w = radius;
    self.h = radius;
};

- (void) influence:(Particle*)p dt:(float)dt maxSpeed:(float)maxSpeed {
    Vector2D* v2 = [[Vector2D alloc] initWithXY:(self.x - p.x) y:(self.y - p.y)];
    float r2 = MAX([Vector2D squaredLength:v2], self.radius * self.radius);
    float res = 0;
    if (self.influenceEquation == 0) {
        // 1/r^2
        res = self.force * 100 / (r2 + 10 * 10);
    } else if (self.influenceEquation == 1) {
        // 1/r smooths out influence
        res = self.force * 2 / (sqrt(r2) + 10 * 10);
    } else if (self.influenceEquation == 2) {
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

- (BOOL) influencerHit:(Particle*)p {
    Vector2D* v2 = [[Vector2D alloc] initWithXY:self.x - p.x y:self.y - p.y];
    float d2 = [Vector2D squaredLength:v2];
    BOOL hit = NO;
    hit = (d2 <= 3 * self.radius * self.radius);
    return hit;
};

- (BOOL) influencerTouchHit:(Particle*)p {
    Vector2D* v2 = [[Vector2D alloc] initWithXY:self.x - p.x y:self.y - p.y];
    float d2 = [Vector2D squaredLength:v2];
    BOOL hit = NO;
    hit = (d2 <= 3 * self.influenceRadius * self.influenceRadius);
    return hit;
};

- (Vector2D*) bounce:(Particle*)p {
    Vector2D* v2 = [[Vector2D alloc] initWithXY:self.x - p.x y:self.y - p.y];
    float d1 = sqrtf([Vector2D squaredLength:v2]);
    float r1 = self.influenceRadius + 10;
    float r2 = r1 + 10;
    if (d1 < r1) {
        //get the normal vector at this point
        //n = new Vector(p.x - this.x, p.y - this.y);
        v2 = [Vector2D normalize:v2];
        p.x = self.x - r2 * v2.x;
        p.y = self.y - r2 * v2.y;
        //this.spark(p.x, p.y);
        return v2;
    }
    return nil;
}

- (void) draw:(Camera*)camera {
    [camera translateObject:self.x y:self.y z:-1];
    [influenceCircle1 draw];
    if(self.dragDirection == OMNI || self.dragDirection == NORTHSOUTH) {
        [north draw];
        [south draw];
    }
    if(self.dragDirection == OMNI || self.dragDirection == EASTWEST) {
        [east draw];
        [west draw];
    }
    //[influenceCircle2 draw];
}

@end
