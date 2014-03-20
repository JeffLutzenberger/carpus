//
//  Rectangle.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Rectangle.h"

@implementation Rectangle {
}

- (id) initWithPositionAndSize:(float)x y:(float)y w:(float)w h:(float)h theta:(float)theta {
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
        self.w = w;
        self.h = h;
        self.theta = theta;
        self.enabled = true;
        self.show = true;
        self.selected = false;
        self.grabberSelected = false;
        self.interactable = true;
        [self updatePoints];
    }
    return self;
}

- (Vector2D*) position {
    return [[Vector2D alloc] initWithXY:self.x y:self.y];
};

- (void) updatePoints {
    float xl1 = -self.w * 0.5;
    float xl2 = self.w * 0.5;
    float yl1 = -self.h * 0.5;
    float yl2 = self.h * 0.5;
    Vector2D* pl1 = [Vector2D rotateXY:xl1 y:yl1 theta:self.theta];
    Vector2D* pl2 = [Vector2D rotateXY:xl2 y:yl1 theta:self.theta];
    Vector2D* pl3 = [Vector2D rotateXY:xl2 y:yl2 theta:self.theta];
    Vector2D* pl4 = [Vector2D rotateXY:xl1 y:yl2 theta:self.theta];
    Vector2D* pl5 = [Vector2D rotateXY:xl1 y:0 theta:self.theta];
    Vector2D* pl6 = [Vector2D rotateXY:xl2 y:0 theta:self.theta];
    
    self.p1 = [[Vector2D alloc] initWithXY:(self.x + pl1.x) y:(self.y + pl1.y)];
    self.p2 = [[Vector2D alloc] initWithXY:(self.x + pl2.x) y:(self.y + pl2.y)];
    self.p3 = [[Vector2D alloc] initWithXY:(self.x + pl3.x) y:(self.y + pl3.y)];
    self.p4 = [[Vector2D alloc] initWithXY:(self.x + pl4.x) y:(self.y + pl4.y)];
    self.p5 = [[Vector2D alloc] initWithXY:(self.x + pl5.x) y:(self.y + pl5.y)];
    self.p6 = [[Vector2D alloc] initWithXY:(self.x + pl6.x) y:(self.y + pl6.y)];
    self.n1 = [Vector2D normalize:[Vector2D subtract:self.p1 v2:self.p4]];
    self.n2 = [Vector2D normalize:[Vector2D subtract:self.p2 v2:self.p1]];
    self.n3 = [Vector2D normalize:[Vector2D subtract:self.p3 v2:self.p2]];
    self.n4 = [Vector2D normalize:[Vector2D subtract:self.p4 v2:self.p3]];
}


- (void) setPosition:(float)x y:(float)y {
    self.x = x;
    self.y = y;
    [self updatePoints];
}

- (BOOL) bbHit:(Vector2D*)p {
    return (p.x >= self.x - self.w * 0.5 &&
            p.x <= self.x + self.w * 0.5 &&
            p.y >= self.y - self.h * 0.5 &&
            p.y <= self.y + self.h * 0.5);
}

- (Vector2D*) hit:(Particle*)p {
    if ([p lineCollision:self.p1 p2:self.p2]) {
        return [[Vector2D alloc] initWithXY:self.n1.x y:self.n1.y];
    }
    if ([p lineCollision:self.p2 p2:self.p3]) {
        return [[Vector2D alloc] initWithXY:self.n2.x y:self.n2.y];
    }
    if ([p lineCollision:self.p3 p2:self.p4]) {
        return [[Vector2D alloc] initWithXY:self.n3.x y:self.n3.y];
    }
    if ([p lineCollision:self.p4 p2:self.p1]) {
        return [[Vector2D alloc] initWithXY:self.n4.x y:self.n4.y];
    }
    return Nil;
}

- (BOOL) circleHit:(Particle*)p {
    return ([p circleCollision:self.p1 p2:self.p2] ||
            [p circleCollision:self.p2 p2:self.p3] ||
            [p circleCollision:self.p3 p2:self.p4] ||
            [p circleCollision:self.p4 p2:self.p1]);
}

- (void) draw {
    //
    return;
}

@end
