//
//  GridWall.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/22/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GridWall.h"
#import "GraphicsLine.h"
#import "GraphicsQuad.h"

@implementation GridWall {
    NSMutableArray* doorPoints;
    GraphicsQuadLine* line1;
    GraphicsQuadLine* line2;
}

- (id) initWithPoints:(Vector2D*)p1 p2:(Vector2D*)p2 {
    self = [super init];
    if (self) {
        self.p1 = [[Vector2D alloc] initWithVector2D:p1];
        self.p2 = [[Vector2D alloc] initWithVector2D:p2];
        self.p3 = [[Vector2D alloc] initWithVector2D:p1];
        self.p4 = [[Vector2D alloc] initWithVector2D:p2];
        self.n = [Vector2D normalize:[[Vector2D alloc] initWithXY:-(self.p2.y - self.p1.y) y:self.p2.x - self.p1.x]];
        self.doorColor = GREEN;
        self.hasDoor = false;
        self.doorEnabled = true;
        doorPoints = [[NSMutableArray alloc] init];
        const float* c = gGameColors[ORANGE];
        float color[] = {c[0], c[1], c[2], 1.0};
        line1 = [[GraphicsQuadLine alloc] initWithCoordsAndColor:self.p1 end:self.p4 lineWidth:5 color:color];
        line2 = [[GraphicsQuadLine alloc] initWithCoordsAndColor:self.p1 end:self.p4 lineWidth:5 color:color];
        [self setDoor:0.5 s2:0.75];
    }
    return self;
}

- (Vector2D*) hit:(Particle*)p {
    if (self.hasDoor && self.doorEnabled && self.doorColor == p.color) {
        if ([p lineCollision:self.p1 p2:self.p2]) {
            return self.n;//[Vector2D normalize:[[Vector2D alloc] initWithXY:-(self.p2.y - self.p1.y) y:self.p2.x - self.p1.x]];
        }
        if ([p lineCollision:self.p3 p2:self.p4]) {
            return self.n;//[Vector2D normalize:[[Vector2D alloc] initWithXY:-(self.p4.y - self.p3.y) y:self.p4.x - self.p3.x]];
        }
    } else {
        if ([p lineCollision:self.p1 p2:self.p4]) {
            return self.n;//[Vector2D normalize:[[Vector2D alloc] initWithXY:-(self.p4.y - self.p1.y) y:self.p4.x - self.p1.x]];
        }
    }
    return nil;
}

- (Vector2D*) circleHit:(Particle*)p {
    if (self.hasDoor && self.doorEnabled && self.doorColor == p.color) {
        if ([p circleCollision:self.p1 p2:self.p2]) {
            return self.n;//[Vector2D normalize:[[Vector2D alloc] initWithXY:-(self.p2.y - self.p1.y) y:self.p2.x - self.p1.x]];
        }
        if ([p circleCollision:self.p3 p2:self.p4]) {
            return self.n;//[Vector2D normalize:[[Vector2D alloc] initWithXY:-(self.p4.y - self.p3.y) y:self.p4.x - self.p3.x]];
        }
    } else {
        if ([p circleCollision:self.p1 p2:self.p4]) {
            return self.n;//[Vector2D normalize:[[Vector2D alloc] initWithXY:-(self.p4.y - self.p1.y) y:self.p4.x - self.p1.x]];
        }
    }
    return nil;
}

- (void)setDoor:(float)s1 s2:(float)s2 {
    self.hasDoor = true;
    [self setS1:s1];
    [self setS2:s2];
    const float* c = gGameColors[ORANGE];
    float color[] = {c[0], c[1], c[2], 1.0};
    [line1 updateCoordinates:self.p1 end:self.p2 lineWidth:5 color:color];
    [line2 updateCoordinates:self.p3 end:self.p4 lineWidth:5 color:color];
}

- (void) setS1:(float)s1 {
    float doorjam = 20.0;
    Vector2D* v = [[Vector2D alloc] initWithXY:self.p4.x - self.p1.x y:self.p4.y - self.p1.y];
    Vector2D* n = [Vector2D normalize:[[Vector2D alloc] initWithXY:-(self.p2.y - self.p1.y) y:self.p2.x - self.p1.x]];
    self.hasDoor = true;
    self.p2 = [[Vector2D alloc] initWithXY:self.p1.x + v.x * s1 y:self.p1.y + v.y * s1];
    self.p5 = [[Vector2D alloc] initWithXY:self.p2.x + n.x * doorjam y:self.p2.y + n.y * doorjam];
    self.p6 = [[Vector2D alloc] initWithXY:self.p2.x - n.x * doorjam y:self.p2.y - n.y * doorjam];
}

- (void) setS2:(float)s2 {
    float doorjam = 20.0;
    Vector2D* v = [[Vector2D alloc] initWithXY:self.p4.x - self.p1.x y:self.p4.y - self.p1.y];
    Vector2D* n = [Vector2D normalize:[[Vector2D alloc] initWithXY:-(self.p2.y - self.p1.y) y:self.p2.x - self.p1.x]];
    self.hasDoor = true;
    self.p3 = [[Vector2D alloc] initWithXY:self.p1.x + v.x * s2 y:self.p1.y + v.y * s2];
    self.p7 = [[Vector2D alloc] initWithXY:self.p3.x + n.x * doorjam y:self.p3.y + n.y * doorjam];
    self.p8 = [[Vector2D alloc] initWithXY:self.p3.x - n.x * doorjam y:self.p3.y - n.y * doorjam];
}

- (float) getS1 {
    float l1 = [Vector2D length:[[Vector2D alloc] initWithXY:self.p4.x - self.p1.x y:self.p4.y - self.p1.y]];
    float l2 = [Vector2D length:[[Vector2D alloc] initWithXY:self.p2.x - self.p1.x y:self.p2.y - self.p1.y]];
    if (l1 <= 0) return 0;
    else return l2 / l1;
}

- (float) getS2 {
    float l1 = [Vector2D length:[[Vector2D alloc] initWithXY:self.p4.x - self.p1.x y:self.p4.y - self.p1.y]];
    float l2 = [Vector2D length:[[Vector2D alloc] initWithXY:self.p3.x - self.p1.x y:self.p3.y - self.p1.y]];
    if (l1 <= 0) return 0;
    else return l2 / l1;
}

- (void) draw:(Camera*)camera {
    [camera translateObject:0 y:0 z:-1];
    [line1 draw];
    if (self.hasDoor) {
        [line2 draw];
    }
}

@end
