//
//  Portal.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/23/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Portal.h"
#import "GraphicsRectangle.h"

@implementation Portal {
    GraphicsRectangle* rect1;
    GraphicsRectangle* rect2;
}

- (id) initWithPositionAndSize:(float)x y:(float)y w:(float)w h:(float)h theta:(float)theta color:(ETColor)color {
    self = [super initWithPositionAndSize:x y:y w:w h:h theta:theta color:color];
    if (self) {
        _inColor = color;
        _outColor = color;
        _outlet = [[Rectangle alloc] initWithPositionAndSize:x y:y + 2 * w w:w h:h theta:theta color:color];
        const float* c = gGameColors[self.color];
        float color1[] = {c[0], c[1], c[2], 1.0};
        //float color2[] = {1.0, 1.0, 1.0, 0.5};
        rect1 = [[GraphicsRectangle alloc] initWithPositionAndSize:0 y:0 w:w h:h theta:theta lineWidth:5 color:color1];
        rect2 = [[GraphicsRectangle alloc] initWithPositionAndSize:0 y:0 w:_outlet.w h:_outlet.h theta:_outlet.theta lineWidth:5 color:color1];
    }
    return self;
}
- (Vector2D*)hit:(Particle *)p {
    if ([p lineCollision:self.p1 p2:self.p2]) {
        if (p.color == self.color) {
            //move the particle to the channel outlet
            float x = self.outlet.x - self.outlet.w * 0.5 + drand48() * self.outlet.w;
            float y = self.outlet.y + self.outlet.h * 0.5;
            float s = [Vector2D length:p.vel];
            float vx = s * self.outlet.n3.x;
            float vy = s * self.outlet.n3.y;
            [p recycle:x y:y vx:vx vy:vy color:self.outlet.color];
            return nil;
        } else {
            return self.n1;
        }
    }
    return nil;

}

- (void)draw:(Camera *)camera {
    [camera translateObject:self.x y:self.y z:-0.5];
    [rect1 draw];
    [camera translateObject:_outlet.x y:_outlet.y z:-0.5];
    [rect2 draw];
}

@end
